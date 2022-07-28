//
//  FSFileItem.m
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHFileItem.h"

@implementation ADHFileItem

- (NSDictionary *)dicPresentation
{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [self deepScanItem:self intoData:data];
    return data;
}

- (void)deepScanItem: (ADHFileItem *)fileItem intoData: (NSMutableDictionary *)data
{
    data[@"name"] = adhvf_safestringfy(fileItem.name);
    data[@"path"] = adhvf_safestringfy(fileItem.path);
    data[@"isDir"] = fileItem.isDir ? adhvf_const_strtrue() : adhvf_const_strfalse();
    data[@"md5"] = adhvf_safestringfy(fileItem.md5Value);
    data[@"level"] = adhvf_string_integer(fileItem.level);
    if(!fileItem.isDir){
        data[@"updateTime"] = [NSString stringWithFormat:@"%.5f",fileItem.updateTime];
        data[@"fileSize"] = [NSString stringWithFormat:@"%d",fileItem.fileSize];
    }
    if(fileItem.subItems){
        NSMutableArray * subItemList = [NSMutableArray array];
        for (ADHFileItem * subItem in fileItem.subItems) {
            NSMutableDictionary * subData = [NSMutableDictionary dictionary];
            [self deepScanItem:subItem intoData:subData];
            [subItemList addObject:subData];
        }
        data[@"subItems"] = subItemList;
    }
}

+ (ADHFileItem *)itemWithDic: (NSDictionary *)dic
{
    ADHFileItem * fileItem = [[ADHFileItem alloc] init];
    [ADHFileItem deepScanItemWithData:dic intoFileItem:fileItem];
    return fileItem;
}

+ (void)deepScanItemWithData: (NSDictionary *)dic intoFileItem: (ADHFileItem *)fileItem
{
    fileItem.name = dic[@"name"];
    fileItem.path = dic[@"path"];
    fileItem.isDir = [dic[@"isDir"] boolValue];
    fileItem.md5Value = dic[@"md5"];
    fileItem.level = [dic[@"level"] intValue];
    if(!fileItem.isDir){
        fileItem.updateTime = [dic[@"updateTime"] doubleValue];
        fileItem.fileSize = [dic[@"fileSize"] intValue];
    }
    NSArray * subDatas = dic[@"subItems"];
    NSMutableArray * subFileItems = [NSMutableArray array];
    for (NSDictionary * subData in subDatas) {
        ADHFileItem * subItem = [[ADHFileItem alloc] init];
        [ADHFileItem deepScanItemWithData:subData intoFileItem:subItem];
        subItem.parent = fileItem;
        [subFileItems addObject:subItem];
    }
    fileItem.subItems = subFileItems;
}

- (ADHFileItem *)dumpCopy
{
    ADHFileItem * tFileItem = [[ADHFileItem alloc] init];
    tFileItem.name = self.name;
    tFileItem.path = self.path;
    tFileItem.isDir = self.isDir;
    tFileItem.level = self.level;
    tFileItem.md5Value = nil;
    tFileItem.updateTime = 0;
    tFileItem.fileSize = 0;
    tFileItem.subItems = nil;
    return tFileItem;
}


@end











