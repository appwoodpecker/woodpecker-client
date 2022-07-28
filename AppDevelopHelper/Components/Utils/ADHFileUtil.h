//
//  FileUtil.h
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHFileUtil : NSObject

//App
+ (NSString *)appPath;
+ (NSString *)documentPath;
+ (NSString *)tmpPath;
+ (NSString *)getGroupContainerPath: (NSString *)containerName;
+ (NSString *)containerRootName;

+ (BOOL)saveData: (NSData *)data atPath: (NSString *)path;
+ (BOOL)saveData: (NSData *)data atPath: (NSString *)path modificationDate: (NSTimeInterval)interval;
+ (BOOL)fileExistsAtPath: (NSString *)path;
+ (BOOL)createFileAtPath: (NSString *)path;
+ (BOOL)createFileAtPath: (NSString *)path creationDate: (NSTimeInterval)interval;
+ (BOOL)deleteFileAtPath: (NSString *)path;

+ (BOOL)dirExistsAtPath: (NSString *)path;
+ (BOOL)createDirAtPath: (NSString *)path;

+ (NSString *)fileMd5: (NSString *)path;

+ (void)emptyDir: (NSString *)path;

+ (NSTimeInterval)getFileModificationTime: (NSString *)path;
+ (BOOL)updateFileModificationTime: (NSTimeInterval)updateTime atPath: (NSString *)path;

@end
