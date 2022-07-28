//
//  ADHFileNodeUtil.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/29.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHFileNodeUtil.h"

@implementation ADHFileNodeUtil

+ (ADHFileNode *)scanFolder: (NSString *)folderPath {
    ADHFileNode * fileItem = nil;
    if([ADHFileUtil dirExistsAtPath:folderPath]){
        fileItem = [[ADHFileNode alloc] init];
        fileItem.name = [folderPath lastPathComponent];
        fileItem.isDir = YES;
        [self scanFolderContent:folderPath parent:fileItem];
    }
    return fileItem;
}

+ (void)scanFolderContent: (NSString *)parentPath parent: (ADHFileNode *)parentItem {
    NSMutableArray * children = [NSMutableArray array];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    NSString * absolutePath = parentPath;
    NSArray * contents = [fileManager contentsOfDirectoryAtPath:absolutePath error:&error];
    if(!error){
        contents = [contents sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull str1, NSString * _Nonnull str2) {
            return [str1 compare:str2 options:NSCaseInsensitiveSearch];
        }];
        for (NSString * fileName in contents) {
            ADHFileNode * fileItem = [[ADHFileNode alloc] init];
            fileItem.name = fileName;
            NSString * itemFilePath = [parentPath stringByAppendingPathComponent:fileName];
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
                fileItem.fileSize = [fileSize intValue];
            }
            fileItem.parent = parentItem;
            if(fileItem.isDir){
                NSString *path = [parentPath stringByAppendingPathComponent:fileItem.name];
                [self scanFolderContent:path parent:fileItem];
            }
            [children addObject:fileItem];
        }
    }
    parentItem.children = children;
}

+ (NSArray<ADHFileNode *> *)getLeafNodes: (ADHFileNode *)rootNode {
    NSMutableArray *leafNodes = [NSMutableArray array];
    [self traverseLeafNode:rootNode toContainer:leafNodes];
    return leafNodes;
}

+ (void)traverseLeafNode: (ADHFileNode *)parentNode toContainer: (NSMutableArray<ADHFileNode *> *)leafNodes {
    NSArray *children = parentNode.children;
    for (ADHFileNode *child in children) {
        if(child.children.count == 0) {
            [leafNodes addObject:child];
        }else {
            [self traverseLeafNode:child toContainer:leafNodes];
        }
    }
}





@end
