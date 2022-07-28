//
//  FileBrowserActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2017/11/4.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHFileBrowserActionService.h"
#import "ADHFileItem.h"
#import "ADHFileBrowserUtil.h"
#import "ADHFileObserver.h"
#import "ADHUtil.h"

NSString *const kSandboxContainerName = @"container";
NSString *const kSandboxWorkDirectoryName = @"workdir";

@interface ADHFileBrowserActionService ()

@property (nonatomic, strong) ADHFileObserver *activityObserver;

@end

@implementation ADHFileBrowserActionService

//filebrowser
+ (NSString *)serviceName
{
    return @"adh.sandbox";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"sandbox" : NSStringFromSelector(@selector(onRequestFileSystem:)),
             @"readfile" : NSStringFromSelector(@selector(onRequestReadFile:)),
             @"writefile" : NSStringFromSelector(@selector(onRequestWriteFile:)),
             @"readfilestate" : NSStringFromSelector(@selector(onRequestFileState:)),
             @"removefile" : NSStringFromSelector(@selector(onRequestRemoveFile:)),
             //activity
             @"activityStart" : NSStringFromSelector(@selector(onRequestActivityStateUpdate:)),
             //cotnainer
             @"groupContainerCheck" : NSStringFromSelector(@selector(onGroupContainerCheck:)),
             };
}

/**
 保存文件
 */
- (void)onRequestWriteFile: (ADHRequest *)request {
    NSDictionary * data = request.body;
    NSString * path = data[@"path"];
    BOOL isDir = [data[@"isdir"] boolValue];
    NSString * containerName = data[kSandboxContainerName];
    NSString * workDir = data[kSandboxWorkDirectoryName];
    NSString * filePath = nil;
    if(workDir.length > 0) {
        filePath = [self getAbsolutePath:path workPath:workDir];
    }else if(containerName.length > 0) {
        filePath = [self getContainerAbsolutePath:path container:containerName];
    }else {
        filePath = [self absolutePath:path];
    }
    if(!isDir){
        NSTimeInterval updateTime = [data[@"updateTime"] doubleValue];
        NSData * fileData = request.payload;
        if(!fileData) {
            //create an empty file if nil
            fileData = [NSData data];
        }
        BOOL ret = [ADHFileUtil saveData:fileData atPath:filePath modificationDate:updateTime];
        if(ret){
            [request finishWithBody:@{
                                      @"success" : @1,
                                      }];
        }else{
            [request finishWithBody:@{
                                      @"success" : @0,
                                      }];
        }
    }else{
        BOOL ret = [ADHFileUtil createDirAtPath:filePath];
        if(ret){
            [request finishWithBody:@{
                                      @"success" : @1,
                                      }];
        }else{
            [request finishWithBody:@{
                                      @"success" : @0,
                                      }];
        }
    }
}

/**
 * @param path String
 * @param isDir number
 */
- (void)onRequestRemoveFile: (ADHRequest *)request {
    NSDictionary * data = request.body;
    NSString * path = data[@"path"];
    BOOL isDir = NO;
    if(data[@"isDir"]) {
        isDir = [data[@"isDir"] boolValue];
    }
    NSString * containerName = data[kSandboxContainerName];
    NSString * workDir = data[kSandboxWorkDirectoryName];
    NSString * filePath = nil;
    if(workDir.length > 0) {
        filePath = [self getAbsolutePath:path workPath:workDir];
    }else if(containerName.length > 0) {
        filePath = [self getContainerAbsolutePath:path container:containerName];
    }else {
        filePath = [self absolutePath:path];
    }
    BOOL success = NO;
#if TARGET_OS_IPHONE
    
#elif TARGET_OS_MAC
    if(![ADHUtil isSandboxed]) {
        //移动到垃圾桶
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        NSURL *resultURL = nil;
        NSError *error = nil;
        success = [[NSFileManager defaultManager] trashItemAtURL:fileURL resultingItemURL:&resultURL error:&error];
        if(success) {
            [request finishWithBody:@{@"success" : @(1)}];
        }else {
            [request finishWithBody:@{@"success" : @(0)}];
        }
        return;
    }
#endif
    if(!isDir) {
        if(![ADHFileUtil fileExistsAtPath:filePath]) {
            success = YES;
        }else {
            success = [ADHFileUtil deleteFileAtPath:filePath];
        }
    }else {
        if(![ADHFileUtil dirExistsAtPath:filePath]) {
            success = YES;
        }else {
            success = [ADHFileUtil deleteFileAtPath:filePath];
        }
    }
    if(success) {
        [request finishWithBody:@{@"success" : @(1)}];
    }else {
        [request finishWithBody:@{@"success" : @(0)}];
    }
    
}

/**
 读取文件
 */
- (void)onRequestReadFile: (ADHRequest *)request {
    NSDictionary * data = request.body;
    NSString * containerName = data[kSandboxContainerName];
    NSString * workDir = data[kSandboxWorkDirectoryName];
    NSString * path = data[@"path"];
    NSString * filePath = nil;
    if(workDir.length > 0) {
        filePath = [self getAbsolutePath:path workPath:workDir];
    }else if(containerName.length > 0) {
        filePath = [self getContainerAbsolutePath:path container:containerName];
    }else {
        filePath = [self absolutePath:path];
    }
    BOOL success = NO;
    BOOL exists = [ADHFileUtil fileExistsAtPath:filePath];
    NSData * fileData = nil;
    if(exists) {
        NSError * error = nil;
        NSData * data = [[NSData alloc] initWithContentsOfFile:filePath options:0 error:&error];
        if(!error) {
            fileData = data;
            success = YES;
        }else {
            success = NO;
        }
    }
    NSTimeInterval updateTime = [ADHFileUtil getFileModificationTime:filePath];
    NSDictionary *resultBody = @{
                              @"success" : [NSNumber numberWithBool:success],
                              @"updateTime" : [NSNumber numberWithDouble:updateTime],
                              };
    [request finishWithBody: resultBody payload:fileData];
}

/**
 更新单个文件/目录状态
 */
- (void)onRequestFileState: (ADHRequest *)request {
    NSDictionary * data = request.body;
    NSString * path = data[@"path"];
    NSString * containerName = data[kSandboxContainerName];
    NSString * workDir = data[kSandboxWorkDirectoryName];
    BOOL isDir = [data[@"isdir"] boolValue];
    NSString * relativePath = nil;
    if(workDir.length > 0) {
        relativePath = workDir;
    }else if(containerName.length > 0) {
        relativePath = [ADHFileUtil getGroupContainerPath:containerName];
    }else {
        relativePath = [ADHFileUtil appPath];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ADHFileItem * fileItem = nil;
        if(isDir){
            fileItem = [ADHFileBrowserUtil scanFolder:path relativePath:relativePath];
        }else{
            fileItem = [ADHFileBrowserUtil scanFileAtPath:path relativePath:relativePath];
        }
        NSDictionary * dic = [fileItem dicPresentation];
        NSString * content = [dic adh_jsonPresentation];
        NSDictionary * body = @{
                                @"content" : adhvf_safestringfy(content),
                                };
        [request finishWithBody:body];
    });
}

/**
 App目录结构
 */
- (void)onRequestFileSystem: (ADHRequest *)request {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *data = request.body;
        NSString *containerName = data[kSandboxContainerName];
        NSString *workDir = data[kSandboxWorkDirectoryName];
        ADHFileItem * fileItem = nil;
        if(workDir.length > 0) {
            fileItem = [ADHFileBrowserUtil scanRootFolder:workDir];
        }else if(containerName.length > 0) {
            NSString *containerPath = [ADHFileUtil getGroupContainerPath:containerName];
            fileItem = [ADHFileBrowserUtil scanRootFolder:containerPath];
            fileItem.name = containerName;
        }else {
            fileItem = [ADHFileBrowserUtil scanRootFolder:[ADHFileUtil appPath]];
        }
        NSDictionary * dic = [fileItem dicPresentation];
        NSString * content = [dic adh_jsonPresentation];
        NSDictionary * body = @{
                                @"content" : adhvf_safestringfy(content),
                                };
        [request finishWithBody:body];
    });
}

/**
 * group container check
 */
- (void)onGroupContainerCheck: (ADHRequest *)request {
    NSDictionary *data = request.body;
    NSString *containerName = data[kSandboxContainerName];
    BOOL exists = NO;
    if(containerName.length > 0) {
        NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:containerName];
        if([containerURL isKindOfClass:[NSURL class]]) {
            exists = YES;
        }
    }
    [request finishWithBody:@{
                              @"success" : [NSNumber numberWithBool:exists],
                              }];
}

#pragma mark -----------------   Activity   ----------------

- (void)onRequestActivityStateUpdate: (ADHRequest *)request {
    NSDictionary *data = request.body;
    BOOL on = [data[@"start"] boolValue];
    NSString *containerName = data[kSandboxContainerName];
    if(on) {
        //work dir
        NSString *workDir = data[@"workdir"];
        //sub folder
        NSString *workPath = data[@"workpath"];
        if(!workPath) {
            workPath = @"";
        }
        [self clearActivityContext];
        self.activityObserver = [[ADHFileObserver alloc] init];
        self.activityObserver.containerName = containerName;
        self.activityObserver.workDir = workDir;
        [self.activityObserver startWithPath:workPath];
    }else {
        [self clearActivityContext];
    }
    [request finish];
}

- (void)clearActivityContext {
    if(self.activityObserver) {
        [self.activityObserver stop];
        self.activityObserver = nil;
    }
}

#pragma mark -----------------   util   ----------------

- (NSString *)absolutePath: (NSString *)path {
    return [[ADHFileUtil appPath] stringByAppendingPathComponent:path];
}

- (NSString *)getContainerAbsolutePath: (NSString *)path container: (NSString *)containerName {
    NSString *containerPath = [ADHFileUtil getGroupContainerPath:containerName];
    return [containerPath stringByAppendingPathComponent:path];
}

- (NSString *)getAbsolutePath: (NSString *)path workPath: (NSString *)workPath {
    return [workPath stringByAppendingPathComponent:path];
}

#pragma mark -----------------   debug   ----------------

- (void)logFileItem: (ADHFileItem *)fileItem intoContent: (NSMutableString *)content {
    NSMutableString * levelPrefix = [NSMutableString string];
    for (NSInteger i=0; i<fileItem.level; i++) {
        [levelPrefix appendFormat: @"+\t"];
    }
    [content appendFormat:@"%@%@\n",levelPrefix,fileItem.name];
    if(fileItem.subItems){
        for (ADHFileItem * subItem in fileItem.subItems) {
            [self logFileItem:subItem intoContent:content];
        }
    }
}



@end

