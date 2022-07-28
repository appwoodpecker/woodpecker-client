//
//  FileBrowserUtil.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/13.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHFileItem.h"

@interface ADHFileBrowserUtil : NSObject

/**
 @folderPath  目标文件夹路径
 */
+ (ADHFileItem *)scanRootFolder: (NSString *)folderPath;

+ (ADHFileItem *)scanFolder: (NSString *)folderPath relativePath: (NSString *)relativePath;

+ (ADHFileItem *)scanFileAtPath: (NSString *)filePath relativePath: (NSString *)relativePath;

/**
 * * scan the item, find the fileitem whose path equals to itemPath
 */
+ (ADHFileItem *)searchFileItemWithPath: (NSString *)itemPath inFileItem: (ADHFileItem *)item isDir: (BOOL)isDir;

@end
