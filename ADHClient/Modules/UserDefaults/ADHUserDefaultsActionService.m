//
//  UserDefaultsActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHUserDefaultsActionService.h"
@import CoreFoundation;

NSString *const kUserDefaultSuiteName = @"suitename";

@implementation ADHUserDefaultsActionService

+ (NSString *)serviceName
{
    return @"adh.userdefaults";
}

+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"requestData" : NSStringFromSelector(@selector(onRequestData:)),
             @"updateValue" : NSStringFromSelector(@selector(onUpdateValue:)),
             @"add" : NSStringFromSelector(@selector(onAddRequest:)),
             @"remove" : NSStringFromSelector(@selector(onRemoveRequest:)),
             };
}

- (NSUserDefaults *)userDefaultsWithSuiteName: (NSString *)suiteName {
    NSUserDefaults *userDefaults = nil;
    if([suiteName isKindOfClass:[NSString class]] && suiteName.length > 0) {
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
    }else {
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return userDefaults;
}

- (void)onRequestData: (ADHRequest *)request {
    NSDictionary *body = request.body;
    NSString *suiteName = body[kUserDefaultSuiteName];
    NSUserDefaults *userDefaults = [self userDefaultsWithSuiteName:suiteName];
    NSDictionary * dic = [userDefaults dictionaryRepresentation];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [request finishWithBody:nil payload:data];
}

- (void)onUpdateValue: (ADHRequest *)request {
    NSDictionary * body = request.body;
    NSData * payload = request.payload;
    NSString * key = body[@"key"];
    id value = [NSKeyedUnarchiver unarchiveObjectWithData:payload];
    NSString *suiteName = body[kUserDefaultSuiteName];
    NSUserDefaults *userDefaults = [self userDefaultsWithSuiteName:suiteName];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
    [request finish];
}

- (void)onAddRequest: (ADHRequest *)request {
    NSDictionary *body = request.body;
    NSString *key = adhvf_safestringfy(body[@"key"]);
    NSString *value = adhvf_safestringfy(body[@"value"]);
    if(key.length > 0) {
        NSString *suiteName = body[kUserDefaultSuiteName];
        NSUserDefaults *userDefaults = [self userDefaultsWithSuiteName:suiteName];
        [userDefaults setObject:value forKey:key];
        [userDefaults synchronize];
        [request finishWithBody:@{
                                  @"success" : @(1),
                                  }];
    }else {
        [request finishWithBody:@{
                                  @"success" : @(0),
                                  }];
    }
}

- (void)onRemoveRequest: (ADHRequest *)request {
    NSDictionary *body = request.body;
    NSString *key = adhvf_safestringfy(body[@"key"]);
    NSString *suiteName = body[kUserDefaultSuiteName];
    NSUserDefaults *userDefaults = [self userDefaultsWithSuiteName:suiteName];
    id value = [userDefaults objectForKey:key];
    if(value) {
        [userDefaults removeObjectForKey:key];
        [userDefaults synchronize];
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




















