//
//  ADHNotificationService.h
//  ADHClient
//
//  Created by 张小刚 on 2018/2/27.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ADHNotificationItem;
#import <UserNotifications/UserNotifications.h>

@interface ADHNotificationService : NSObject

+ (ADHNotificationService *)sharedService;

@property (nonatomic, strong) NSString * apsToken;

- (void)didReceiveRemoteNotification: (NSDictionary *)userInfo;
- (void)willPresentNotification: (UNNotification*)notification API_AVAILABLE(ios(10.0),macos(10.14));
- (void)didReceiveNotificationResponse: (UNNotificationResponse*)response API_AVAILABLE(ios(10.0),macos(10.14));
//aps
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

//util
- (ADHNotificationItem *)itemWithRequest: (UNNotificationRequest *)request API_AVAILABLE(ios(10.0),macos(10.14));


@end
