//
//  ADHCloudService.m
//  ADHClient
//
//  Created by 张小刚 on 2019/9/13.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHCloudService.h"
#import "ADHCloudItem.h"

static NSMutableArray *gServiceList;

@interface ADHCloudService ()

@property (nonatomic, strong) NSString *containerId;
@property (nonatomic, strong) NSURL *containerURL;
@property (nonatomic, strong) NSMetadataQuery *query;
@property (nonatomic, strong) ADHCloudServiceFetchBlock fetchBlock;

@end

@implementation ADHCloudService

+ (ADHCloudService *)serviceWithId: (NSString *)containerId {
    if(!gServiceList) {
        gServiceList = [NSMutableArray array];
    }
    ADHCloudService *targetService = nil;
    for (ADHCloudService *service in gServiceList) {
        if(!containerId) {
            if(!service.containerId) {
                targetService = service;
                break;
            }
        }else {
            if([service.containerId isEqualToString:containerId]) {
                targetService = service;
                break;
            }
        }
    }
    if(!targetService) {
        ADHCloudService *service = [[ADHCloudService alloc] init];
        service.containerId = containerId;
        [gServiceList addObject:service];
        targetService = service;
    }
    return targetService;
}

//icloud okay? (icloud enabled & sign in)
- (BOOL)iCloudEnabled {
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    return (token != nil);
}

//check container id okay? (container id correct)
- (BOOL)isContainerAvailable {
    if(!self.containerURL) {
        self.containerURL = [self baseURL];
    }
    return (self.containerURL != nil);
}

- (NSURL *)baseURL {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *baseURL = [fm URLForUbiquityContainerIdentifier:self.containerId];
    return baseURL;
}

- (void)clearQueryContext {
    if(self.query) {
        if(self.query.isStarted) {
            [self.query stopQuery];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:self.query];
    }
    self.query = nil;
    self.fetchBlock = nil;
}

- (void)fetchCloudItemsOnCompletion: (ADHCloudServiceFetchBlock)completionBlock {
    [self clearQueryContext];
    self.fetchBlock = completionBlock;
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    query.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope, NSMetadataQueryUbiquitousDataScope];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryEnd:) name:NSMetadataQueryDidFinishGatheringNotification object:query];
    self.query = query;
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //must be called from the receiver’s operationQueue or on the main thread.
        BOOL ret = [query startQuery];
        if(!ret) {
            wself.fetchBlock(nil, @"query start failed");
            [wself clearQueryContext];
        }
    });
}

- (void)queryEnd: (NSNotification *)noti {
    NSLog(@"query end");
    [self.query stopQuery];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self onQueryFinish];
    });
}

- (void)onQueryFinish {
    NSMutableArray<ADHCloudItem *> *itemList = [NSMutableArray array];
    [self.query enumerateResultsUsingBlock:^(NSMetadataItem * result, NSUInteger idx, BOOL *stop) {
        NSString *name = [result valueForAttribute:NSMetadataItemFSNameKey];
        NSString *path = [result valueForAttribute:NSMetadataItemPathKey];
        NSNumber *fileSize = [result valueForAttribute:NSMetadataItemFSSizeKey];
        NSDate *creationDate = [result valueForAttribute:NSMetadataItemFSCreationDateKey];
        NSDate *updateDate = [result valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        NSString *type = [result valueForAttribute:NSMetadataItemContentTypeKey];
        BOOL conflicted = [[result valueForAttribute:NSMetadataUbiquitousItemHasUnresolvedConflictsKey] boolValue];
        NSString *downloadStatus = [result valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusKey];
        BOOL downloading = [[result valueForAttribute:NSMetadataUbiquitousItemIsDownloadingKey] boolValue];
        float downloadPercent = [[result valueForAttribute:NSMetadataUbiquitousItemPercentDownloadedKey] floatValue];
        NSError *downloadError = [result valueForAttribute:NSMetadataUbiquitousItemDownloadingErrorKey];
        BOOL uploaded = [[result valueForAttribute:NSMetadataUbiquitousItemIsUploadedKey] boolValue];
        BOOL uploading = [[result valueForAttribute:NSMetadataUbiquitousItemIsUploadingKey] boolValue];
        float uploadPercent = [[result valueForAttribute:NSMetadataUbiquitousItemPercentUploadedKey] floatValue];
        NSError *uploadError = [result valueForAttribute:NSMetadataUbiquitousItemUploadingErrorKey];
        
        ADHCloudItem *item = [ADHCloudItem item];
        item.name = name;
        item.path = path;
        item.fileSize = [fileSize unsignedIntValue];
        item.creationTime = [creationDate timeIntervalSince1970];
        item.updateTime = [updateDate timeIntervalSince1970];
        if([type isEqualToString:@"public.folder"]) {
            item.isDir = YES;
        }
        item.conflicted = conflicted;
        ADHCloudItemStatus itemStatus = 0;
        if([downloadStatus isEqualToString:NSMetadataUbiquitousItemDownloadingStatusNotDownloaded]) {
            itemStatus = ADHCloudItemStatusNotDownload;
        }else if([downloadStatus isEqualToString:NSMetadataUbiquitousItemDownloadingStatusDownloaded]) {
            itemStatus = ADHCloudItemStatusDownloaded;
        }else if([downloadStatus isEqualToString:NSMetadataUbiquitousItemDownloadingStatusCurrent]) {
            itemStatus = ADHCloudItemStatusCurrent;
        }
        item.downloadStatus = itemStatus;
        item.downloading = downloading;
        item.downloadPercent = downloadPercent;
        if(downloadError) {
            item.downloadError = [downloadError localizedFailureReason];
        }
        item.uploaded = uploaded;
        item.uploading = uploading;
        item.uploadPercent = uploadPercent;
        if(item.uploadError) {
            item.uploadError = [uploadError localizedFailureReason];
        }
        [itemList addObject:item];
    }];
    [itemList sortUsingComparator:^NSComparisonResult(ADHCloudItem *obj1, ADHCloudItem *obj2) {
        return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
    }];
    ADHCloudItem *rootItem = [self makeCloudItemTree:itemList];
    NSDictionary *data = [rootItem dicPresentation];
    if(self.fetchBlock) {
        self.fetchBlock(data, nil);
    }
}

- (ADHCloudItem *)makeCloudItemTree: (NSArray<ADHCloudItem *> *)itemList {
    ADHCloudItem *rootItem = [ADHCloudItem item];
    rootItem.path = self.containerURL.path;
    rootItem.name = @"";
    rootItem.isDir = YES;
    [self traverseItem:rootItem fromList:itemList];
    return rootItem;
}

- (void)traverseItem: (ADHCloudItem *)parentItem fromList: (NSArray<ADHCloudItem *> *)itemList {
    NSString *itemPath = parentItem.path;
    NSMutableArray *subItems = [NSMutableArray array];
    for (ADHCloudItem *item in itemList) {
        NSString *path = item.path;
        NSString *leftPath = [path stringByDeletingLastPathComponent];
        if([leftPath isEqualToString:itemPath] && ![path isEqualToString:itemPath]) {
            [subItems addObject:item];
        }
        if(item.isDir) {
            NSMutableArray *leftItems = [itemList mutableCopy];
            [leftItems removeObject:item];
            [self traverseItem:item fromList:leftItems];
        }
        item.parent = parentItem;
        parentItem.subItems = subItems;
    }
}

//read file
- (void)readFile: (NSString *)path onCompletion: (void (^)(NSData *fileData, NSString *errorMsg))completionBlock {
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    //1. delete local copy first
    NSError *error = nil;
    
    if([[NSFileManager defaultManager] evictUbiquitousItemAtURL:fileURL error:nil]) {
//        NSLog(@"filed removed success");
    }else {
//        NSLog(@"remove %@ failed: %@",fileURL,error);
    }
    //2. read from icloud
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
//    NSLog(@"step 1 %@",[NSDate date]);
    [coordinator coordinateReadingItemAtURL:fileURL options:NSFileCoordinatorReadingWithoutChanges error:&error byAccessor:^(NSURL * _Nonnull newURL) {
//        NSLog(@"step 2 %@",[NSDate date]);
        NSString *msg = nil;
        NSData *fileData = nil;
        if(!error) {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSData *data = [fm contentsAtPath:newURL.path];
            if(data) {
                fileData = data;
            }else {
                msg = @"File download failed, please retry later";
            }
        }else {
            msg = error.localizedDescription;
        }
        if(fileData) {
            if(completionBlock) {
                completionBlock(fileData,nil);
            }
        }else {
            if(completionBlock) {
                completionBlock(nil,msg);
            }
        }
    }];
//    NSLog(@"step 3 %@",[NSDate date]);
}

@end
