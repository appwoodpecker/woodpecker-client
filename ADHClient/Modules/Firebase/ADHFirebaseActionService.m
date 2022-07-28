//
//  ADHFirActionService.m
//  Woodepcker
//
//  Created by zhangxiaogang on 2020/7/16.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHFirebaseActionService.h"
#import "NSObject+ADHCategory.h"

@implementation ADHFirebaseActionService

+ (BOOL)isShared {
    return YES;
}

/**
 service name
 */
+ (NSString *)serviceName {
    return @"adh.firebase";
}

/**
 action list

 return @{
    @"actionName1" : selector1 string,
    @"actionName2" : selector2 string,
 };
 */
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
        @"queryall" : NSStringFromSelector(@selector(onRequestAllData:)),
        @"fetchRemote" : NSStringFromSelector(@selector(onRequestFetchRemote:)),
    };
}

/**
 called on service init
 */
- (void)onServiceInit {
    
}

+ (BOOL)available {
    Class clazz = NSClassFromString(@"FIRRemoteConfig");
    return (clazz != nil);
}

- (void)onRequestAllData: (ADHRequest *)request {
    NSDictionary *dic = [self getAllConfigs];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [request finishWithBody:nil payload:data];
}

- (NSDictionary *)getRemoteConfigInfo {
    id config = [self remoteConfig];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSDate * lastFetchTime = [config adhCallMethod:@"lastFetchTime"];
    if(lastFetchTime) {
        NSTimeInterval value = [lastFetchTime timeIntervalSince1970];
        data[@"lastFetchTime"] = [NSNumber numberWithDouble:value];
    }
    NSInteger lastFetchStatus = [[config adhCallMethod:@"lastFetchStatus"] integerValue];
    data[@"lastFetchStatus"] = [NSNumber numberWithInteger:lastFetchStatus];
    return data;
}

- (id)remoteConfig {
    Class clazz = NSClassFromString(@"FIRRemoteConfig");
    id config = [clazz performSelector:NSSelectorFromString(@"remoteConfig")];
    return config;
}

- (NSDictionary *)getAllConfigs {
    id config = [self remoteConfig];
    NSArray *remoteKeys = [config adhCallMethod:@"allKeysFromSource:" args:@[@(0)]];
    NSArray *defaultKeys = [config adhCallMethod:@"allKeysFromSource:" args:@[@(1)]];
    NSMutableSet *set = [NSMutableSet set];
    if(defaultKeys) {
        [set addObjectsFromArray:defaultKeys];
    }
    if(remoteKeys) {
        [set addObjectsFromArray:remoteKeys];
    }
    NSArray *allKeys = [set allObjects];
    [allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    for (NSString *key in allKeys) {
        id item = [config adhCallMethod:@"configValueForKey:" args:@[key]];
        NSString *text = [item adhCallMethod:@"stringValue" args:nil];
        if(!text) {
            text = @"";
        }
        data[key] = text;
    }
    return data;
}

- (void)onRequestFetchRemote: (ADHRequest *)request {
    id config = [self remoteConfig];
    /*
      FIRRemoteConfigFetchStatusNoFetchYet,
      FIRRemoteConfigFetchStatusSuccess,
      FIRRemoteConfigFetchStatusFailure,
      FIRRemoteConfigFetchStatusThrottled,
    }
     */
    void (^callback)(NSInteger, NSError*) = ^(NSInteger status, NSError * _Nullable error) {
        if(status == 1) {
            void (^activeCallback)(NSError * _Nullable) = ^(NSError * _Nullable error){
                NSMutableDictionary *data = [NSMutableDictionary dictionary];
                data[@"status"] = [NSNumber numberWithInteger:status];
                if(error && error.localizedFailureReason) {
                    data[@"error"] = error.localizedFailureReason;
                }else {
                    data[@"info"] = [self getRemoteConfigInfo];
                }
                NSDictionary *dic = [self getAllConfigs];
                NSData * payload = [NSKeyedArchiver archivedDataWithRootObject:dic];
                [request finishWithBody:data payload:payload];
            };
            [config adhCallMethod:@"activateWithCompletionHandler:" args:@[activeCallback]];
        }else {
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            data[@"status"] = [NSNumber numberWithInteger:status];
            if(error) {
                data[@"error"] = adhvf_safestringfy(error.localizedDescription);
                data[@"error_code"] = [NSNumber numberWithInteger:error.code];
            }
            [request finishWithBody:data];
        }
    };
    [config adhCallMethod:@"fetchWithExpirationDuration:completionHandler:" args:@[@(0),callback]];
}


@end
