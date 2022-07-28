//
//  ADHNotificationItem.h
//  ADHClient
//
//  Created by 张小刚 on 2018/2/26.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ADHNotificationTriggerType) {
    ADHNotificationTriggerTypeNone,
    ADHNotificationTriggerTypeTimeInterval,
    ADHNotificationTriggerTypeCalendar,
    ADHNotificationTriggerTypeLocation,
    ADHNotificationTriggerTypePush,
    //UILocalNotification（非region）
    ADHNotificationTriggerTypeLegacyCalendar,
};

@interface ADHNotificationItem : NSObject

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *title;
// request identifier
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *badge;
@property (nonatomic, strong) NSString *sound;
@property (nonatomic, strong) NSString *categoryIdentifier;
@property (nonatomic, strong) NSString *launchImageName;
@property (nonatomic, strong) NSArray <NSDictionary *> *attachments;

@property (nonatomic, assign) ADHNotificationTriggerType triggerType;
@property (nonatomic, strong) NSString *triggerDetail;
@property (nonatomic, assign) BOOL triggerRepeat;
@property (nonatomic, assign) NSTimeInterval nextTriggerTimeinterval;

//接收到Notification日期
@property (nonatomic, assign) NSTimeInterval fireTimeinterval;
//接收后处理identifier
@property (nonatomic, strong) NSString * actionIdentifier;

@property (nonatomic, strong) NSString *source;


- (NSDictionary *)dicPresentation;
+ (ADHNotificationItem *)itemWithData: (NSDictionary *)dic;

- (NSString *)readbleTextWithKey: (NSString *)key;
+ (NSString *)readbleTriggerType: (ADHNotificationTriggerType)type;

@end
