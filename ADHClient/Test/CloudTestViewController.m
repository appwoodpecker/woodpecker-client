//
//  CloudTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2019/9/13.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "CloudTestViewController.h"
#import "ADHCloudService.h"

@interface CloudTestViewController ()

@property (nonatomic, strong) NSMetadataQuery *query;

@end

@implementation CloudTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"iCloud";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudStatusUpdate) name:NSUbiquityIdentityDidChangeNotification object:nil];
}

- (IBAction)checkButtonPressed:(id)sender {
    [self checkiCloudService];
}

- (IBAction)icloudStartButtonPressed:(id)sender {
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *baseURL = [wself baseURL];
        NSLog(@"base: %@",baseURL);
    });
}

- (void)checkiCloudService {
    NSLog(@"check icloud status...");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        id token = [fm ubiquityIdentityToken];
        if(token) {
            NSLog(@"icloud available: %@",token);
        }else {
            NSLog(@"⚠️ icloud not available, icloud maybe disabled or not login");
        }
        
    });
}

- (void)iCloudStatusUpdate {
    NSLog(@"icloud status update");
    [self checkiCloudService];
}

- (NSURL *)baseURL {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *baseURL = [fm URLForUbiquityContainerIdentifier:@"iCloud.lifebetter.Demos"];
    return baseURL;
}

- (IBAction)addButtonPressed:(id)sender {
//    [self addFile];
//    [self addFile2];
    [self addFile3];
}

- (void)addFile {
    NSURL *baseURL = [self baseURL];
    NSString *text = @"123";
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [baseURL URLByAppendingPathComponent:@"test2.txt"];
    NSString *filePath = fileURL.path;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL ret = [fm createFileAtPath:filePath contents:data attributes:nil];
    if(ret) {
        NSLog(@"create file success");
    }else {
        NSLog(@"create file failed");
    }
}

- (void)addFile2 {
    NSURL *baseURL = [self baseURL];
    NSString *text = @"ddd";
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [baseURL URLByAppendingPathComponent:@"Documents/ddd.txt"];
    NSString *filePath = fileURL.path;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL ret = [fm createFileAtPath:filePath contents:data attributes:nil];
    if(ret) {
        NSLog(@"create file success");
    }else {
        NSLog(@"create file failed");
    }
}

- (void)addFile3 {
    NSLog(@"add file...");
    NSURL *fileURL = [[self baseURL] URLByAppendingPathComponent:@"bbb.txt"];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *error = nil;
    [coordinator coordinateWritingItemAtURL:fileURL options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
        NSString *text = [NSString stringWithFormat:@"%@",[NSDate date]];
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        NSString *path = [fileURL path];
        NSError *error2 = nil;
        BOOL ret = [data writeToFile:path options:NSDataWritingAtomic error:&error2];
        if(ret) {
            NSLog(@"create file success");
        }else {
            NSLog(@"create file failed: %@",error2);
        }
    }];
    NSLog(@"write done: %@",error);
}

- (IBAction)queryButtonPressed:(id)sender {
    [self read6];
}
- (IBAction)optionQueryButtonPressed:(id)sender {
    [self read4];
}

- (void)metaQuery {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    query.searchScopes = @[NSMetadataQueryUbiquitousDataScope,NSMetadataQueryUbiquitousDocumentsScope];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryStart:) name:NSMetadataQueryDidStartGatheringNotification object:query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(querying:) name:NSMetadataQueryDidUpdateNotification object:query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryEnd:) name:NSMetadataQueryDidFinishGatheringNotification object:query];
    self.query = query;
    BOOL ret = [query startQuery];
    if(!ret) {
        NSLog(@"query not start");
    }
}

- (void)queryStart: (NSNotification *)noti {
    NSLog(@"query start");
}

- (void)querying: (NSNotification *)noti {
    NSLog(@"query going");
    [self updateFiles];
}

- (void)queryEnd: (NSNotification *)noti {
    NSLog(@"query end");
    [self updateFiles];
}

- (void)updateFiles {
    // Enumerate through the results
    [self.query enumerateResultsUsingBlock:^(id result, NSUInteger idx, BOOL *stop) {
        // Grab the file URL
        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        NSString *fileStatus;
        NSError *error;
        [fileURL getResourceValue:&fileStatus forKey:NSURLUbiquitousItemDownloadingStatusKey error:&error];
        NSString *fileName = [result valueForAttribute:NSMetadataItemFSNameKey];
        if(error){
            NSLog(@"[iCloud] Failed to get resource value with error: %@.", error);
            return;
        }
        if ([fileStatus isEqualToString:NSURLUbiquitousItemDownloadingStatusDownloaded]) {
            // File will be updated soon
            NSLog(@"find downloaded: %@",fileName);
        }
        if ([fileStatus isEqualToString:NSURLUbiquitousItemDownloadingStatusCurrent]) {
            NSLog(@"find current: %@",fileName);
            
        } else if ([fileStatus isEqualToString:NSURLUbiquitousItemDownloadingStatusNotDownloaded]) {
            NSError *error;
            NSLog(@"find not download: %@",fileName);
            [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:fileURL error:&error];
        }
    }];
}

- (IBAction)removeButtonPressed:(id)sender {
    [self remove2];
}

- (void)removeLocalCopy {
    NSURL *baseURL = [self baseURL];
    NSURL *fileURL = [baseURL URLByAppendingPathComponent:@"bbb.txt"];
    NSError *error = nil;
    BOOL ret = [[NSFileManager defaultManager] evictUbiquitousItemAtURL:fileURL error:&error];
    if(ret) {
        NSLog(@"evict success");
    }else {
        NSLog(@"evict failed: %@",error);
    }
}

- (void)remove2 {
    NSURL *baseURL = [self baseURL];
    NSURL *fileURL = [baseURL URLByAppendingPathComponent:@"bbb.txt"];
    NSError *error = nil;
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    [coordinator coordinateWritingItemAtURL:fileURL options:NSFileCoordinatorWritingForDeleting error:&error byAccessor:^(NSURL * _Nonnull newURL) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error2 = nil;
        if([fm removeItemAtURL:fileURL error:&error2]) {
            NSLog(@"delete from icloud");
        }else {
            NSLog(@"delete file: %@ failed: %@",fileURL,error2);
        }
    }];
}


- (void)read2 {
    /*
    NSURL *baseURL = [self baseURL];
    NSURL *fileURL = [baseURL URLByAppendingPathComponent:@"test.txt"];
    ADHDocument *document = [[ADHDocument alloc] initWithFileURL:fileURL];
    [document openWithCompletionHandler:^(BOOL success) {
        if(success) {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSData *data = [[NSData alloc] initWithContentsOfURL:fileURL];
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",text);
        }
    }];
     */
}

- (void)read3 {
    /*
    NSLog(@"read from url directly");
    NSURL *baseURL = [self baseURL];
    NSURL *fileURL = [baseURL URLByAppendingPathComponent:@"test.txt"];
    ADHDocument *document = [[ADHDocument alloc] initWithFileURL:fileURL];
    NSError *error = nil;
    BOOL ret = [document readFromURL:fileURL error:&error];
    if(ret) {
        NSLog(@"read from url succeed");
        NSFileManager *fm = [NSFileManager defaultManager];
        NSData *data = [[NSData alloc] initWithContentsOfURL:fileURL];
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",text);
    }else {
        NSLog(@"read from url failed: %@",error);
    }
     */
}


- (void)read4 {
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSURL *baseURL = [self baseURL];
    NSURL *fileURL = [baseURL URLByAppendingPathComponent:@"bbb.txt"];
    NSError *error = nil;
    [coordinator coordinateReadingItemAtURL:fileURL options:NSFileCoordinatorReadingWithoutChanges error:&error byAccessor:^(NSURL * _Nonnull newURL) {
        NSString *path = [newURL path];
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:path];
        if(!fileData) {
            NSLog(@"read failed");
        }else {
            NSLog(@"read succeed");
            NSString *text = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",text);
        }
    }];
    NSLog(@"read 4 finish: %@",error);

}

//bad
- (void)read5 {
    NSURL *baseURL = [self baseURL];
    NSURL *fileURL = [baseURL URLByAppendingPathComponent:@"bbb.txt"];
    NSString *path = [fileURL path];
    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:path];
    if(!fileData) {
        NSLog(@"read failed");
    }else {
        NSLog(@"read succeed");
        NSString *text = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",text);
    }
}


- (void)read6 {
    NSURL *fileURL = [self baseURL];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [coordinator coordinateReadingItemAtURL:fileURL options:0 error:&error byAccessor:^(NSURL *newURL) {
        NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtURL:fileURL includingPropertiesForKeys:@[NSURLUbiquitousItemDownloadingStatusKey] options:0 errorHandler:nil];
        NSString *filename;
        while ((filename = [dirEnum nextObject])) {
            NSLog(@"%@",filename);
        }
    }];
}

- (void)read7 {
    ADHCloudService *service = [ADHCloudService serviceWithId:nil];
    [service fetchCloudItemsOnCompletion:^(NSDictionary * _Nonnull data, NSString * _Nonnull errorMsg) {
        if(data) {
            NSLog(@"%@",data);
        }else {
            NSLog(@"%@",errorMsg);
        }
        
    }];
}

- (IBAction)userDefaultsAddButtonPressed:(id)sender {
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    [store setObject:[NSDate date] forKey:@"date"];
    [store synchronize];
    
}

- (IBAction)userDefaultDelButtonPressed:(id)sender {
}

@end
