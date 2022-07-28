//
//  ADHNotificationService.m
//  ADHClient
//
//  Created by 张小刚 on 2017/12/25.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHNotificationActionService.h"
#import "ADHNotificationItem.h"
#import "ADHNotificationService.h"

@import CoreLocation;
@import UserNotifications;

#if TARGET_OS_IPHONE
@import UserNotificationsUI;

#elif TARGET_OS_MAC

#endif

@implementation ADHNotificationActionService

- (void)onServiceInit
{
    
}

+ (NSString *)serviceName
{
    return @"adh.notification";
}

+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"info" : NSStringFromSelector(@selector(onRequestInfo:)),
             @"localNotificatioins" : NSStringFromSelector(@selector(onRequestLocalNotificatioins:)),
             @"remove" : NSStringFromSelector(@selector(onRequestRemoveNotification:)),
             };
}

- (void)onRequestInfo: (ADHRequest *)request {
    __weak typeof(self) wself = self;
    if (@available(iOS 10.0,macOS 10.14, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            [wself onSettingFetched:settings forRequest:request];
        }];
    }else {
        // Fallback on earlier versions
        [request finishWithBody:@{
                                  kADHApiErrorCodeKey : [NSNumber numberWithInteger:kADHApiErrorCodeVersionDismatch],
                                  }];
    }
}

/*
 权限，device token
 */
- (void)onSettingFetched: (UNNotificationSettings *)settings forRequest: (ADHRequest *)request
API_AVAILABLE(ios(10.0),macos(10.14)){
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    //settings
    NSMutableArray * settingList = [NSMutableArray array];
    //auth status
    [settingList addObject:[self settingDataWithType:@"authStatus" value:settings.authorizationStatus]];
    //sound
    [settingList addObject:[self settingDataWithType:@"sound" value:settings.soundSetting]];
    //badge
    [settingList addObject:[self settingDataWithType:@"badge" value:settings.badgeSetting]];
    //alert
    [settingList addObject:[self settingDataWithType:@"alert" value:settings.alertSetting]];
    //notificationCenter
    [settingList addObject:[self settingDataWithType:@"notificationCenter" value:settings.notificationCenterSetting]];
    //lockScreen
    [settingList addObject:[self settingDataWithType:@"lockScreen" value:settings.lockScreenSetting]];
#if TARGET_OS_IPHONE
    //carPlay
    [settingList addObject:[self settingDataWithType:@"carPlay" value:settings.carPlaySetting]];
#elif TARGET_OS_MAC
    
#endif
    //alertStyle
    [settingList addObject:[self settingDataWithType:@"alertStyle" value:settings.alertStyle]];
    //showPreviews
    if (@available(iOS 11.0,macOS 10.14, *)) {
        [settingList addObject:[self settingDataWithType:@"showPreviews" value:settings.showPreviewsSetting]];
    } else {
        // Fallback on earlier versions
    }
    data[@"settingList"] = settingList;
    //deviceToken
    data[@"apsToken"] = [self apsTokenData];
    [request finishWithBody:data];
}

- (NSDictionary *)settingDataWithType: (NSString *)type value: (NSInteger)value
{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    data[@"type"] = type;
    data[@"title"] = [self readbleTitleWithType:type];
    data[@"value"] = adhvf_string_integer(value);
    if (@available(iOS 10.0,macOS 10.14, *)) {
        data[@"value_des"] = [self readbleStatusWithType:type value:value];
    }
    return data;
}

- (NSDictionary *)apsTokenData
{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    data[@"type"] = @"text";
    data[@"title"] = @"Push Device Token";
    NSString *apsToken = [[ADHNotificationService sharedService] apsToken];
    if(apsToken.length == 0) {
        apsToken = @"Not Available";
    }
    data[@"value"] = apsToken;
    return data;
}

- (NSString *)readbleTitleWithType: (NSString *)type
{
    NSString * name = nil;
    if([type isEqualToString:@"authStatus"]){
        name = @"Authorization Status";
    }else if([type isEqualToString:@"sound"]){
        name = @"Sound Enabled";
    }else if([type isEqualToString:@"badge"]){
        name = @"Badge Enabled";
    }else if([type isEqualToString:@"alert"]){
        name = @"Alert Enabled";
    }else if([type isEqualToString:@"notificationCenter"]){
        name = @"Notification Center Enalbed";
    }else if([type isEqualToString:@"lockScreen"]){
        name = @"Lock Screen Enabled";
    }else if([type isEqualToString:@"carPlay"]){
        name = @"Car Play Enabled";
    }else if([type isEqualToString:@"alertStyle"]){
        name = @"Alert Style";
    }else if([type isEqualToString:@"showPreviews"]){
        name = @"Previews Show Type";
    }
    return name;
}

- (NSString *)readbleStatusWithType: (NSString *)type value: (NSInteger)value API_AVAILABLE(ios(10.0),macos(10.14)){
    NSString * des = nil;
    if([type isEqualToString:@"authStatus"]){
            if(value == UNAuthorizationStatusNotDetermined){
                des = @"Not Determined";
            }else if(value == UNAuthorizationStatusDenied){
                des = @"Denied";
            }else if(value == UNAuthorizationStatusAuthorized){
                des = @"Authorized";
            }
    }else if([type isEqualToString:@"sound"] ||
             [type isEqualToString:@"badge"] ||
             [type isEqualToString:@"alert"] ||
             [type isEqualToString:@"notificationCenter"] ||
             [type isEqualToString:@"lockScreen"] ||
             [type isEqualToString:@"carPlay"]){
        if(value == UNNotificationSettingNotSupported){
            des = @"Not Supported";
        }else if(value == UNNotificationSettingDisabled){
            des = @"Disabled";
        }else if(value == UNNotificationSettingEnabled){
            des = @"Enabled";
        }
    }else if([type isEqualToString:@"alertStyle"]){
        if(value == UNAlertStyleNone){
            des = @"Display None";
        }else if(value == UNAlertStyleBanner){
            des = @"Banner";
        }else if(value == UNAlertStyleAlert){
            des = @"Alert";
        }
    }else if([type isEqualToString:@"showPreviews"]){
        if (@available(iOS 11.0,macOS 10.14, *)) {
            if(value == UNShowPreviewsSettingAlways){
                des = @"Alway Show";
            }else if(value == UNShowPreviewsSettingWhenAuthenticated){
                des = @"Show When Authenticated";
            }else if(value == UNShowPreviewsSettingNever){
                des = @"Never Show";
            }
        }
    }
    return des;
}

/*
 本地通知列表
 */
- (void)onRequestLocalNotificatioins: (ADHRequest *)request API_AVAILABLE(ios(10.0),macos(10.14)){
    if (@available(iOS 10.0,macOS 10.14, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            NSMutableArray * itemList = [NSMutableArray array];
            for (UNNotificationRequest * request in requests) {
                ADHNotificationItem * item = [[ADHNotificationService sharedService] itemWithRequest:request];
                NSDictionary * data = [item dicPresentation];
                [itemList addObject:data];
            }
            NSDictionary * body = @{
                                    @"list" : itemList,
                                    };
            [request finishWithBody:body];
        }];
    }else {
        [request finishWithBody:@{
                                  kADHApiErrorCodeKey : [NSNumber numberWithInteger:kADHApiErrorCodeVersionDismatch],
                                  }];
    }
}

- (void)onRequestRemoveNotification: (ADHRequest *)request API_AVAILABLE(ios(10.0),macos(10.14)){
    NSString *requestId = request.body[@"identifier"];
    if(requestId) {
        //remove one
        NSArray *requestIds = @[requestId];
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:requestIds];
    }else {
        //remove all
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    }
    [request finish];
}

@end
