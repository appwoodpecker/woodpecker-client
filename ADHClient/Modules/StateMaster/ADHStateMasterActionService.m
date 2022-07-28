//
//  ADHStateMasterActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2020/5/31.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHStateMasterActionService.h"

@implementation ADHStateMasterActionService

//service name
+ (NSString *)serviceName {
    return @"adh.statemaster";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"filesync" : NSStringFromSelector(@selector(onRequestFileSync:)),
             @"userdefaultsync" : NSStringFromSelector(@selector(onRequestUserDefaultSync:)),
             };
}

- (void)onRequestFileSync: (ADHRequest *)request {
    NSDictionary *data = request.body;
    NSData *payload = request.payload;
    BOOL dir = [data[@"dir"] boolValue];
    NSString *path = data[@"path"];
    NSString *filePath = [self getFilePath:path];
    if(dir) {
        [ADHFileUtil createDirAtPath:filePath];
    }else {
        NSString *folderPath = [filePath stringByDeletingLastPathComponent];
        [ADHFileUtil createDirAtPath:folderPath];
        [ADHFileUtil saveData:payload atPath:filePath];
    }
    [request finish];
}

//暂时只支持standard userdefaults
- (void)onRequestUserDefaultSync: (ADHRequest *)request {
    NSData *payload = request.payload;
    NSString *fileName = @"userdefaults.plist";
    NSString *tmpPath = [[ADHFileUtil tmpPath] stringByAppendingPathComponent:fileName];
    [payload writeToFile:tmpPath atomically:YES];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:tmpPath];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [defaults setObject:obj forKey:key];
    }];
    [defaults synchronize];
    [ADHFileUtil deleteFileAtPath:tmpPath];
    [request finish];
}

- (NSString *)getFilePath: (NSString *)path {
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    return filePath;
}

@end
