//
//  FileBrowserUtil.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/13.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHFileBrowserUtil.h"

@implementation ADHFileBrowserUtil

+ (ADHFileItem *)scanRootFolder: (NSString *)folderPath {
    return [ADHFileBrowserUtil scanFolder:@"" relativePath:folderPath];
}

+ (ADHFileItem *)scanFolder: (NSString *)folderPath relativePath: (NSString *)relativePath {
    ADHFileItem * fileItem = nil;
    if([ADHFileUtil dirExistsAtPath:[relativePath stringByAppendingPathComponent:folderPath]]){
        fileItem = [[ADHFileItem alloc] init];
        fileItem.name = [folderPath lastPathComponent];
        if(fileItem.name.length == 0){
            fileItem.name = @"/";
        }
        fileItem.path = folderPath;
        fileItem.isDir = YES;
        fileItem.level = 0;
        [self scanPath:fileItem.path parent:fileItem relativePath:relativePath];
    }
    return fileItem;
}

+ (void)scanPath: (NSString *)path parent: (ADHFileItem *)parentItem relativePath: (NSString *)relativePath {
    NSMutableArray * subFileItems = [NSMutableArray array];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    NSString * absolutePath = [relativePath stringByAppendingPathComponent:path];
    NSArray * contents = [fileManager contentsOfDirectoryAtPath:absolutePath error:&error];
    if(!error){
        contents = [contents sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull str1, NSString * _Nonnull str2) {
            return [str1 compare:str2 options:NSCaseInsensitiveSearch];
        }];
        for (NSString * fileName in contents) {
            ADHFileItem * fileItem = [[ADHFileItem alloc] init];
            fileItem.name = fileName;
            fileItem.path = [path stringByAppendingPathComponent:fileName];
            NSString * itemFilePath = [relativePath stringByAppendingPathComponent:fileItem.path];
            NSDictionary * attributes = [fileManager attributesOfItemAtPath:itemFilePath error:&error];
            NSString * fileType = attributes[NSFileType];
            if([fileType isEqualToString:NSFileTypeSymbolicLink]) {
                continue;
            }
            if([fileType isEqualToString:NSFileTypeDirectory]){
                //目录
                fileItem.isDir = YES;
            }else{
                //文件
                NSNumber * fileSize = attributes[NSFileSize];
                NSDate * updateDate = attributes[NSFileModificationDate];
                if(!updateDate) {
                    updateDate = attributes[NSFileCreationDate];
                }
                fileItem.fileSize = [fileSize intValue];
                fileItem.updateTime = [updateDate timeIntervalSince1970];
            }
            fileItem.level += parentItem.level + 1;
            fileItem.parent = parentItem;
            if(fileItem.isDir){
                [self scanPath:fileItem.path parent:fileItem relativePath:relativePath];
            }
            [subFileItems addObject:fileItem];
        }
    }
    parentItem.subItems = subFileItems;
}

+ (ADHFileItem *)scanFileAtPath: (NSString *)path relativePath: (NSString *)relativePath
{
    ADHFileItem * fileItem = nil;
    if([ADHFileUtil fileExistsAtPath:[relativePath stringByAppendingPathComponent:path]]){
        fileItem = [[ADHFileItem alloc] init];
        NSString * fileName = [path lastPathComponent];
        fileItem.name = fileName;
        fileItem.path = path;
        NSString * itemFilePath = [relativePath stringByAppendingPathComponent:fileItem.path];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSError * error = nil;
        NSDictionary * attributes = [fileManager attributesOfItemAtPath:itemFilePath error:&error];
        //文件
        NSNumber * fileSize = attributes[NSFileSize];
        NSDate * updateDate = attributes[NSFileModificationDate];
        if(!updateDate) {
            updateDate = attributes[NSFileCreationDate];
        }
        fileItem.fileSize = [fileSize intValue];
        fileItem.updateTime = [updateDate timeIntervalSince1970];
    }
    return fileItem;
}

/**
 * scan the item, find the fileitem whose path equals to itemPath
 */
+ (ADHFileItem *)searchFileItemWithPath: (NSString *)itemPath inFileItem: (ADHFileItem *)item isDir: (BOOL)isDir {
    ADHFileItem *targetItem = nil;
    if([itemPath isEqualToString:item.path] && item.isDir == isDir) {
        targetItem = item;
    }else if([itemPath containsString:item.path] || item.path.length == 0) {
        for (ADHFileItem *subItem in item.subItems) {
            targetItem = [self searchFileItemWithPath:itemPath inFileItem:subItem isDir:isDir];
            if(targetItem){
                break;
            }
        }
    }
    return targetItem;
}

@end










