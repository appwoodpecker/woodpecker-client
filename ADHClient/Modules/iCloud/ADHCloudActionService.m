//
//  ADHCloudActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2019/9/16.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHCloudActionService.h"
#import "ADHCloudService.h"

@implementation ADHCloudActionService

//filebrowser
+ (NSString *)serviceName {
    return @"adh.icloud";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             //document
             @"tree" : NSStringFromSelector(@selector(onRequestCloudItems:)),
             @"readfile" : NSStringFromSelector(@selector(onRequestReadFile:)),
             @"ubiquityIdCheck" : NSStringFromSelector(@selector(onUbiquityIdCheckRequest:)),
             //userdefaults
             @"requestUserDefaults" : NSStringFromSelector(@selector(onRequestUserDefaults:)),
             @"updateUserDefaults" : NSStringFromSelector(@selector(onUpdateUserDefaultsValue:)),
             @"addUserDefaults" : NSStringFromSelector(@selector(onAddUserDefaultsRequest:)),
             @"removeUserDefaults" : NSStringFromSelector(@selector(onRemoveUserDefaultsRequest:)),
             };
}

- (void)onUbiquityIdCheckRequest: (ADHRequest *)request {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *body = request.body;
        NSString *containerId = nil;
        if(body[@"containerId"]) {
            containerId = body[@"containerId"];
        }
        //check container id okay? (container id correct)
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *containerURL = [fm URLForUbiquityContainerIdentifier:containerId];
        if(containerURL) {
            NSDictionary *data = @{
                                   @"success": @(1),
                                   };
            [request finishWithBody:data];
        }else {
            NSDictionary *data = @{
                                   @"success": @(0),
                                   @"msg" : @"invalid icloud container id",
                                   };
            [request finishWithBody:data];
        }
    });
}

//bundle tree
- (void)onRequestCloudItems: (ADHRequest *)request {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *body = request.body;
        NSString *containerId = nil;
        if(body[@"containerId"]) {
            containerId = body[@"containerId"];
        }
        ADHCloudService *service = [ADHCloudService serviceWithId:containerId];
        NSString *errorMsg = nil;
        NSInteger errCode = 0;
        if(![service iCloudEnabled]) {
            errorMsg = @"Ubiquity identity token is nil, please check the iCloud setup";
            errCode = 100;
        }
        if(![service isContainerAvailable]) {
            errorMsg = @"Ubiquity container URL is nil, please check the iCloud setup in Setting, or the Capability setup in Xcode";
            errCode = 101;
        }
        if(errorMsg) {
            NSDictionary *body = @{
                                   @"success" : @(0),
                                   @"msg" : errorMsg,
                                   @"code" : [NSNumber numberWithInteger:errCode],
                                   };
            [request finishWithBody:body];
        }else {
            [service fetchCloudItemsOnCompletion:^(NSDictionary *data, NSString *errorMsg) {
                if(data) {
                    NSDictionary *body = @{
                                           @"success" : @(1),
                                           };
                    NSData *payload = [NSKeyedArchiver archivedDataWithRootObject:data];
                    [request finishWithBody:body payload:payload];
                }else {
                    NSDictionary *body = @{
                                           @"success" : @(0),
                                           @"msg" : adhvf_safestringfy(errorMsg),
                                           };
                    [request finishWithBody:body];
                }
            }];
        }
    });
}

- (void)onRequestReadFile: (ADHRequest *)request {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *body = request.body;
        NSString *containerId = nil;
        if(body[@"containerId"]) {
            containerId = body[@"containerId"];
        }
        NSString *path = body[@"path"];
        ADHCloudService *service = [ADHCloudService serviceWithId:containerId];
        [service readFile:path onCompletion:^(NSData *fileData, NSString *errorMsg) {
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            BOOL success = [fileData isKindOfClass:[NSData class]];
            data[@"success"] = [NSNumber numberWithBool:success];
            if(!success && errorMsg) {
                data[@"msg"] = adhvf_safestringfy(errorMsg);
            }
            [request finishWithBody:data payload:fileData];
        }];
    });
}

- (void)onRequestUserDefaults: (ADHRequest *)request {
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    NSDictionary *dic = [store dictionaryRepresentation];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [request finishWithBody:nil payload:data];
}

- (void)onUpdateUserDefaultsValue: (ADHRequest *)request {
    NSDictionary * body = request.body;
    NSData * payload = request.payload;
    NSString * key = body[@"key"];
    id value = [NSKeyedUnarchiver unarchiveObjectWithData:payload];
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    [store setObject:value forKey:key];
    [store synchronize];
    [request finish];
}

- (void)onAddUserDefaultsRequest: (ADHRequest *)request {
    NSDictionary *body = request.body;
    NSString *key = adhvf_safestringfy(body[@"key"]);
    NSString *value = adhvf_safestringfy(body[@"value"]);
    if(key.length > 0) {
        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
        [store setObject:value forKey:key];
        [store synchronize];
        [request finishWithBody:@{
                                  @"success" : @(1),
                                  }];
    }else {
        [request finishWithBody:@{
                                  @"success" : @(0),
                                  }];
    }
}

- (void)onRemoveUserDefaultsRequest: (ADHRequest *)request {
    NSDictionary *body = request.body;
    NSString *key = adhvf_safestringfy(body[@"key"]);
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    id value = [store objectForKey:key];
    if(value) {
        [store removeObjectForKey:key];
        [store synchronize];
        [request finishWithBody:@{
                                  @"success" : @(1),
                                  }];
    }else {
        [request finishWithBody:@{
                                  @"success" : @(0),
                                  }];
    }
}


@end
