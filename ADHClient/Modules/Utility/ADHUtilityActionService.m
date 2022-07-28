//
//  ADHUtilityActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2020/7/12.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHUtilityActionService.h"
@import CoreServices;

@implementation ADHUtilityActionService

//service name
+ (NSString *)serviceName {
    return @"adh.utility";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"dateformat" : NSStringFromSelector(@selector(onRequestDateFormat:)),
             @"pasteboard" : NSStringFromSelector(@selector(onRequestPasteboard:)),
             @"writePasteboard" : NSStringFromSelector(@selector(onRequestWritePasteboard:)),
             @"clearPasteboard" : NSStringFromSelector(@selector(onRequestClearPasteboard:)),
             @"removeCache" : NSStringFromSelector(@selector(onRequestRemoveCache:)),
             };
}

- (void)onRequestDateFormat: (ADHRequest *)request {
    NSData * payload = request.payload;
    NSDate *date = [NSKeyedUnarchiver unarchiveObjectWithData:payload];
    NSDictionary *data = request.body;
    NSString *format = data[@"format"];
    NSInteger dateStyle = [data[@"datestyle"] integerValue];
    NSInteger timeStyle = [data[@"timestyle"] integerValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(format) {
        [formatter setDateFormat:format];
    }else {
        [formatter setDateStyle:dateStyle];
        [formatter setTimeStyle:timeStyle];
    }
    NSString *text = [formatter stringFromDate:date];
    NSDictionary *body = @{
        @"text" : adhvf_safestringfy(text),
    };
    [request finishWithBody:body];
}

//pasteboard
- (void)onRequestPasteboard: (ADHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
       UIPasteboard *pb = [UIPasteboard generalPasteboard];
        NSData *pbData = nil;
        NSString *type = nil;
        UIImage *image = [pb image];
        NSURL *url = [pb URL];
        NSString *text = [pb string];
        if(image) {
            pbData = UIImagePNGRepresentation(image);
            type = @"image";
        }else if(url) {
            NSString *text = [url absoluteString];
            pbData = [text dataUsingEncoding:NSUTF8StringEncoding];
            type = @"url";
        }else if(text) {
            pbData = [text dataUsingEncoding:NSUTF8StringEncoding];
            type = @"text";
        }
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        if(pbData) {
            data[@"success"] = @(1);
            data[@"type"] = type;
        }
        [request finishWithBody:data payload:pbData];
    });
}

- (void)onRequestWritePasteboard: (ADHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *body = request.body;
        NSData *payload = request.payload;
        NSString *type = body[@"type"];
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        if([type isEqualToString:@"text"]) {
            NSString *text = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
            [pb setString:text];
        }else if([type isEqualToString:@"url"]) {
            NSString *text = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
            [pb setString:text];
        }else if([type isEqualToString:@"image"]) {
            [pb setData:payload forPasteboardType:@"public.png"];
        }
        NSDictionary *data = @{
            @"success" : @(1),
        };
        [request finishWithBody:data];
    });
}

- (void)onRequestClearPasteboard: (ADHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setItems:@[]];
        NSDictionary *data = @{
            @"success" : @(1),
        };
        [request finishWithBody:data];
    });
}

- (void)onRequestRemoveCache: (ADHRequest *)request {
    NSDictionary *body = request.body;
    NSInteger type = [body[@"type"] integerValue];
    if(type == 1) {
        [self doRemoveSandbox];
    }else if(type == 2) {
        [self doRemoveUserDefaults];
    }else {
        [self doRemoveCaches];
    }
    NSDictionary *data = @{
        @"success" : @(1),
    };
    [request finishWithBody:data];
}

- (void)doRemoveCaches {
    NSString *appPath = NSHomeDirectory();
    NSString *libPath = [appPath stringByAppendingPathComponent:@"Library"];
    //Caches
    NSString *libCachePath = [libPath stringByAppendingPathComponent:@"Caches"];
    NSString *webPath = [libPath stringByAppendingPathComponent:@"WebKit"];
    NSString *cookiePath = [libPath stringByAppendingPathComponent:@"Cookies"];
    NSString *splashPath = [libPath stringByAppendingPathComponent:@"SplashBoard"];
    NSString *statePath = [libPath stringByAppendingPathComponent:@"Saved Application State"];
    NSString *tmpPath = [appPath stringByAppendingPathComponent:@"tmp"];
    NSArray *cachePathes = @[
        webPath,
        cookiePath,
        splashPath,
        statePath,
    ];
    NSArray *emptyPathes = @[
        libCachePath,
        tmpPath,
    ];
    for (NSString *path in cachePathes) {
        [ADHFileUtil deleteFileAtPath:path];
    }
    for (NSString *path in emptyPathes) {
        [ADHFileUtil emptyDir:path];
    }
}

- (void)doRemoveSandbox {
    NSString *appPath = NSHomeDirectory();
    NSString *docPath = [appPath stringByAppendingPathComponent:@"Documents"];
    NSString *libPath = [appPath stringByAppendingPathComponent:@"Library"];
    NSString *sysPath = [appPath stringByAppendingPathComponent:@"SystemData"];
    NSString *tmpPath = [appPath stringByAppendingPathComponent:@"tmp"];
    NSArray *pathes = @[
        docPath,
        libPath,
        sysPath,
        tmpPath
    ];
    for (NSString *path in pathes) {
        [ADHFileUtil emptyDir:path];
    }
}

- (void)doRemoveUserDefaults {
    NSDictionary * info = [[NSBundle mainBundle] infoDictionary];
    NSString * bundleId = info[@"CFBundleIdentifier"];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:bundleId];
}

@end
