//
//  FileUtil.m
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHFileUtil.h"
#import "ADHFileHash.h"

@implementation ADHFileUtil

+ (NSString *)appPath {
    NSString * appPath = NSHomeDirectory();
    return appPath;
}

+ (NSString *)documentPath {
    return [[self appPath] stringByAppendingPathComponent:@"Documents"];
}

+ (NSString *)tmpPath {
    return [[self appPath] stringByAppendingPathComponent:@"tmp"];
}

+ (NSString *)containerRootName {
    return @".extension-containers";
}

+ (NSString *)getGroupContainerPath: (NSString *)containerName {
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:containerName];
    NSString *path = [containerURL absoluteString];
    path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    return path;
}



+ (BOOL)saveData: (NSData *)data atPath: (NSString *)path {
    return [ADHFileUtil saveData:data atPath:path modificationDate:0];
}

+ (BOOL)saveData: (NSData *)data atPath: (NSString *)path modificationDate: (NSTimeInterval)interval {
    BOOL ret = NO;
    //创建目录
    NSString * dirPath = [path stringByDeletingLastPathComponent];
    if(dirPath.length > 0){
        if(![ADHFileUtil dirExistsAtPath:dirPath]){
            [ADHFileUtil createDirAtPath:dirPath];
        }
    }
    //创建文件
    if(![ADHFileUtil fileExistsAtPath:path]){
        if(![ADHFileUtil createFileAtPath:path creationDate:interval]){
            return ret;
        }
    }
    ret = [data writeToFile:path atomically:NO];
    if(interval > 0 && ret) {
        ret = [ADHFileUtil updateFileModificationTime:interval atPath:path];
    }
    return ret;
}

+ (BOOL)dirExistsAtPath: (NSString *)path
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    return (isExists && isDir);
}

+ (BOOL)createDirAtPath: (NSString *)path
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    BOOL result = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    return result;
}

+ (BOOL)fileExistsAtPath: (NSString *)path
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    return (isExists && !isDir);
}

+ (BOOL)createFileAtPath: (NSString *)path
{
    return [ADHFileUtil createFileAtPath:path creationDate:0];
}

+ (BOOL)createFileAtPath: (NSString *)path creationDate: (NSTimeInterval)interval {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    if(interval > 0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        if(date) {
            attributes[NSFileCreationDate] = date;
            attributes[NSFileModificationDate] = date;
        }
    }
    BOOL result = [fileManager createFileAtPath:path contents:[NSData data] attributes:attributes];
    return result;
}


+ (BOOL)deleteFileAtPath: (NSString *)path
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    BOOL result = [fileManager removeItemAtPath:path error:&error];
    return result;
}


+ (NSString *)fileMd5: (NSString *)path
{
    return [ADHFileHash md5HashOfFileAtPath:path];
}

+ (void)emptyDir: (NSString *)path {
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray *items = [fm contentsOfDirectoryAtPath:path error:nil];
    for (NSString *item in items) {
        NSString *itemPath = [path stringByAppendingPathComponent:item];
        [fm removeItemAtPath:itemPath error:nil];
    }
}

+ (BOOL)updateFileModificationTime: (NSTimeInterval)updateTime atPath: (NSString *)path {
    if(![ADHFileUtil fileExistsAtPath:path]) {
        return NO;
    }
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:updateTime];
    if(!date) {
        return NO;
    }
    NSDictionary *attirubtes = @{
                                 NSFileModificationDate : date,
                                 };
    NSError *error = nil;
    BOOL ret = [fileManager setAttributes:attirubtes ofItemAtPath:path error:&error];
    return ret;
}

+ (NSTimeInterval)getFileModificationTime: (NSString *)path {
    if(![ADHFileUtil fileExistsAtPath:path]) {
        return 0;
    }
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary * attributes = [fileManager attributesOfItemAtPath:path error:&error];
    NSDate *date = attributes[NSFileModificationDate];
    return [date timeIntervalSince1970];
}

@end














