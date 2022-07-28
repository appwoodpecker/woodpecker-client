//
//  ADHCloudItem.m
//  ADHClient
//
//  Created by 张小刚 on 2019/9/15.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHCloudItem.h"

@implementation ADHCloudItem

+ (ADHCloudItem *)item {
    return [[ADHCloudItem alloc] init];
}

- (NSDictionary *)dicPresentation {
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [self deepScanItem:self intoData:data];
    return data;
}

- (void)deepScanItem: (ADHCloudItem *)cloudItem intoData: (NSMutableDictionary *)data {
    data[@"name"] = adhvf_safestringfy(cloudItem.name);
    data[@"path"] = adhvf_safestringfy(cloudItem.path);
    data[@"isDir"] = [NSNumber numberWithBool:cloudItem.isDir];
    data[@"creationTime"] = [NSNumber numberWithDouble:cloudItem.creationTime];
    if(!cloudItem.isDir){
        data[@"updateTime"] = [NSNumber numberWithDouble:cloudItem.updateTime];
        data[@"fileSize"] = [NSNumber numberWithUnsignedInt:cloudItem.fileSize];
    }
    data[@"conflicted"] = [NSNumber numberWithBool:cloudItem.conflicted];
    data[@"downloadStatus"] = [NSNumber numberWithInt:cloudItem.downloadStatus];
    data[@"downloading"] = [NSNumber numberWithBool:cloudItem.downloading];
    data[@"downloadPercent"] = [NSNumber numberWithFloat:cloudItem.downloadPercent];
    if(cloudItem.downloadError) {
        data[@"downloadError"] = adhvf_safestringfy(cloudItem.downloadError);
    }
    data[@"uploaded"] = [NSNumber numberWithBool:cloudItem.uploaded];
    data[@"uploading"] = [NSNumber numberWithBool:cloudItem.uploading];
    data[@"uploadPercent"] = [NSNumber numberWithFloat:cloudItem.uploadPercent];
    if(cloudItem.uploadError) {
        data[@"uploadError"] = adhvf_safestringfy(cloudItem.uploadError);
    }
    if(cloudItem.subItems){
        NSMutableArray * subItemList = [NSMutableArray array];
        for (ADHCloudItem * subItem in cloudItem.subItems) {
            NSMutableDictionary * subData = [NSMutableDictionary dictionary];
            [self deepScanItem:subItem intoData:subData];
            [subItemList addObject:subData];
        }
        data[@"subItems"] = subItemList;
    }
}

+ (ADHCloudItem *)itemWithDic: (NSDictionary *)data {
    ADHCloudItem * cloudItem = [ADHCloudItem item];
    [ADHCloudItem deepScanItemWithData:data intoItem:cloudItem];
    return cloudItem;
}

+ (void)deepScanItemWithData: (NSDictionary *)data intoItem: (ADHCloudItem *)cloudItem {
    cloudItem.name = data[@"name"];
    cloudItem.path = data[@"path"];
    cloudItem.isDir = [data[@"isDir"] boolValue];
    cloudItem.creationTime = [data[@"creationTime"] doubleValue];
    if(!cloudItem.isDir) {
        cloudItem.updateTime = [data[@"updateTime"] doubleValue];
        cloudItem.fileSize = [data[@"fileSize"] unsignedIntValue];
    }
    cloudItem.conflicted = [data[@"conflicted"] boolValue];
    cloudItem.downloadStatus = [data[@"downloadStatus"] intValue];
    cloudItem.downloading = [data[@"downloading"] boolValue];
    cloudItem.downloadPercent = [data[@"downloadPercent"] floatValue];
    cloudItem.downloadError = data[@"downloadError"];
    cloudItem.uploaded = [data[@"uploaded"] boolValue];
    cloudItem.uploading = [data[@"uploading"] boolValue];
    cloudItem.uploadPercent = [data[@"uploadPercent"] floatValue];
    cloudItem.uploadError = data[@"uploadError"];
    NSArray * subDatas = data[@"subItems"];
    NSMutableArray * subItems = [NSMutableArray array];
    for (NSDictionary * subData in subDatas) {
        ADHCloudItem * subItem = [ADHCloudItem item];
        [ADHCloudItem deepScanItemWithData:subData intoItem:subItem];
        subItem.parent = cloudItem;
        [subItems addObject:subItem];
    }
    cloudItem.subItems = subItems;
}

- (NSString *)getDownloadStatusText {
    NSString *text = nil;
    switch (self.downloadStatus) {
        case ADHCloudItemStatusNotDownload:
            text = @"not downloaded";
            break;
        case ADHCloudItemStatusDownloaded:
            text = @"downloaded";
            break;
        case ADHCloudItemStatusCurrent:
            text = @"current";
            break;
        default:
            break;
    }
    return text;
}

//tool tip
- (NSString *)getStateText {
    NSMutableArray *tips = [NSMutableArray array];
    [tips addObject:[NSString stringWithFormat:@"Name: %@",adhvf_safestringfy(self.name)]];
    //create time
    NSString *createTime = [NSString stringWithFormat:@"Create time: %@",[ADHDateUtil readbleTextWithTimeInterval:self.creationTime]];
    [tips addObject:adhvf_safestringfy(createTime)];
    //update time
    NSString *updateTime = [NSString stringWithFormat:@"Update time: %@",[ADHDateUtil readbleTextWithTimeInterval:self.updateTime]];
    [tips addObject:adhvf_safestringfy(updateTime)];
    if(!self.isDir) {
        //file size
        NSString *fileSize = [NSString stringWithFormat:@"Size: %@",[FunctionUtil readbleBytesSize:self.fileSize]];
        [tips addObject:adhvf_safestringfy(fileSize)];
    }
    //download status
    {
        NSMutableArray *downloadTexts = [NSMutableArray array];
        NSString *status = [NSString stringWithFormat:@"Download: %@",[self getDownloadStatusText]];
        [downloadTexts addObject:status];
        if(self.downloadPercent > 0) {
            [downloadTexts addObject:[NSString stringWithFormat:@" progress: %.2f",self.downloadPercent]];
        }
        if(self.downloadError) {
            [downloadTexts addObject:[NSString stringWithFormat:@"error: %@", self.downloadError]];
        }
        NSString *text = [downloadTexts componentsJoinedByString:@" "];
        [tips addObject:text];
    }
    //upload status
    {
        NSMutableArray *uploadTexts = [NSMutableArray array];
        NSString *status = [NSString stringWithFormat:@"Uploaded: %@",self.uploaded ? @"yes":@"no"];
        [uploadTexts addObject:status];
        if(self.uploadPercent > 0) {
            [uploadTexts addObject:[NSString stringWithFormat:@"progress: %.2f",self.uploadPercent]];
        }
        if(self.uploadError) {
            [uploadTexts addObject:[NSString stringWithFormat:@"error: %@", self.uploadError]];
        }
        NSString *text = [uploadTexts componentsJoinedByString:@" "];
        [tips addObject:text];
    }
    //conflicted status
    if(self.conflicted) {
        [tips addObject:[NSString stringWithFormat:@"Conflicted : YES"]];
    }
    NSString *text = [tips componentsJoinedByString:@"\n"];
    return text;
}

- (NSInteger)level {
    NSInteger level = 0;
    ADHCloudItem * parent = self.parent;
    while (parent) {
        level++;
        parent = parent.parent;
    }
    return level;
}

@end
