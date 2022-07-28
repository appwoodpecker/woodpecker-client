//
//  AppBundleActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2019/1/20.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHAppBundleActionService.h"
#import "ADHFileBrowserUtil.h"

@implementation ADHAppBundleActionService

//filebrowser
+ (NSString *)serviceName {
    return @"adh.bundle";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"tree" : NSStringFromSelector(@selector(onRequestBundleTree:)),
             @"readfile" : NSStringFromSelector(@selector(onRequestReadFile:)),
             };
}

//bundle tree
- (void)onRequestBundleTree: (ADHRequest *)request {
    NSString *path = [self mainBundlePath];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ADHFileItem * fileItem = [ADHFileBrowserUtil scanRootFolder:path];
        NSDictionary * dic = [fileItem dicPresentation];
        NSString * content = [dic adh_jsonPresentation];
        NSDictionary * body = @{
                                @"success" : @(1),
                                @"content" : adhvf_safestringfy(content),
                                };
        [request finishWithBody:body];
    });
}

//read file
- (void)onRequestReadFile: (ADHRequest *)request {
    NSDictionary * data = request.body;
    NSString * path = data[@"path"];
    NSString * filePath = [self absolutePath:path];
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

#pragma mark -----------------   util   ----------------

- (NSString *)mainBundlePath {
    NSBundle * bundle = [NSBundle mainBundle];
    return [bundle bundlePath];
}

- (NSString *)absolutePath: (NSString *)path {
    return [[self mainBundlePath] stringByAppendingPathComponent:path];
}



@end
