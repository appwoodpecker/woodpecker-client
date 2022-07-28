//
//  NotificationActionService.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/2/27.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationActionService.h"
#import "ADHNotificationItem.h"

NSString * const kNotificationServiceNotificationReceived = @"kNotificationServiceNotificationReceived";

@implementation NotificationActionService

+ (NSString *)serviceName {
    return @"adh.notification";
}

+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"notificationReceived" : NSStringFromSelector(@selector(onReceivedNotification:context:)),
             };
}

- (void)onReceivedNotification: (ADHRequest *)request context: (ADHApiClient *)apiClient {
    NSDictionary * data = request.body;
    [request finish];
    NSArray * dataList = data[@"list"];
    if(dataList.count == 0) return;
    NSMutableArray * itemList = [NSMutableArray array];
    for (NSDictionary * data in dataList) {
        ADHNotificationItem * item = [ADHNotificationItem itemWithData:data];
        [itemList addObject:item];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"list"] = itemList;
    AppContext *context = [AppContextManager.manager contextWithApiClient:apiClient];
    if(context) {
        userInfo[@"context"] = context;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationServiceNotificationReceived object:self userInfo:userInfo];
    
}

@end
