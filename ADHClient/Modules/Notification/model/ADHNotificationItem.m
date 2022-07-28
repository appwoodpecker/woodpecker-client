//
//  ADHNotificationItem.m
//  ADHClient
//
//  Created by 张小刚 on 2018/2/26.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHNotificationItem.h"

@implementation ADHNotificationItem

- (NSDictionary *)dicPresentation
{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    ADHNotificationItem * item = self;
    data[@"identifier"] = adhvf_safestringfy(item.identifier);
    data[@"body"] = adhvf_safestringfy(item.body);
    data[@"title"] = adhvf_safestringfy(item.title);
    data[@"subtitle"] = adhvf_safestringfy(item.subtitle);
    data[@"badge"] = adhvf_safestringfy(item.badge);
    data[@"sound"] = adhvf_safestringfy(item.sound);
    data[@"launchImageName"] = adhvf_safestringfy(item.launchImageName);
    if(item.userInfo){
        data[@"userInfo"] = item.userInfo;
    }
    data[@"categoryIdentifier"] = adhvf_safestringfy(item.categoryIdentifier);
    data[@"triggerType"] = adhvf_string_integer(item.triggerType);
    data[@"triggerRepeat"] = item.triggerRepeat ?@1:@0;
    data[@"triggerDetail"] = adhvf_safestringfy(item.triggerDetail);
    data[@"nextTriggerTimeinterval"] = [NSString stringWithFormat:@"%f",item.nextTriggerTimeinterval];
    data[@"fireTimeinterval"] = [NSString stringWithFormat:@"%f",item.fireTimeinterval];
    data[@"actionIdentifier"] = adhvf_safestringfy(item.actionIdentifier);
    if(item.attachments){
        data[@"attachments"] = item.attachments;
    }
    data[@"source"] = adhvf_safestringfy(item.source);
    return data;
}

+ (ADHNotificationItem *)itemWithData: (NSDictionary *)data
{
    ADHNotificationItem * item = [[ADHNotificationItem alloc] init];
    item.identifier = data[@"identifier"];
    item.body = data[@"body"];
    item.title = data[@"title"];
    item.subtitle = data[@"subtitle"];
    
    item.badge = data[@"badge"];
    item.sound = data[@"sound"];
    item.launchImageName = data[@"launchImageName"];
    item.userInfo = data[@"userInfo"];
    item.categoryIdentifier = data[@"categoryIdentifier"];
    item.triggerType = [data[@"triggerType"] integerValue];
    item.triggerRepeat = [data[@"triggerRepeat"] boolValue];
    item.triggerDetail = data[@"triggerDetail"];
    item.nextTriggerTimeinterval = [data[@"nextTriggerTimeinterval"] doubleValue];
    item.fireTimeinterval = [data[@"fireTimeinterval"] doubleValue];
    item.actionIdentifier = adhvf_safestringfy(data[@"actionIdentifier"]);
    item.attachments = data[@"attachments"];
    item.source = adhvf_safestringfy(data[@"source"]);
    return item;
}

- (NSString *)readbleTextWithKey:(NSString *)key {
    NSString *value = nil;
    if([key isEqualToString:@"Title"]) {
        value = self.body;
        if(value.length == 0) {
            value = self.title;
        }
        if(value.length == 0) {
            value = self.subtitle;
        }
    }else if([key isEqualToString:@"Date"]) {
        if(self.fireTimeinterval > 0){
            value = [ADHDateUtil readbleTextWithTimeInterval:self.fireTimeinterval];
        }
    }else if([key isEqualToString:@"UserInfo"]) {
        if(self.userInfo){
            value = [self.userInfo adh_jsonPresentation];
        }
    }else if([key isEqualToString:@"Identifier"]) {
        value = self.identifier;
    }else if([key isEqualToString:@"Action Identifier"]) {
        value = self.actionIdentifier;
    }else if([key isEqualToString:@"Trigger"]) {
        value = [ADHNotificationItem readbleTriggerType:self.triggerType];
    }else if([key isEqualToString:@"Source"]) {
        value  = self.source;
    }else if([key isEqualToString:@"Repeat"]) {
        value = self.triggerRepeat ? @"YES" : @"NO";
    }else if([key isEqualToString:@"FireDate"]) {
        if(self.nextTriggerTimeinterval > 0) {
            value = [ADHDateUtil formatStringWithTimeInterval:self.nextTriggerTimeinterval dateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
    }
    return value;
}

+ (NSString *)readbleTriggerType: (ADHNotificationTriggerType)type {
    NSString *value = nil;
    if(type == ADHNotificationTriggerTypeTimeInterval) {
        value = @"Interval";
    }else if(type == ADHNotificationTriggerTypeCalendar) {
        value = @"Calendar";
    }else if(type == ADHNotificationTriggerTypeLocation) {
        value = @"Location";
    }else if(type == ADHNotificationTriggerTypePush) {
        value = @"Remote Push";
    }else if(type == ADHNotificationTriggerTypeLegacyCalendar) {
        value = @"Legacy Calendar";
    }
    return adhvf_safestringfy(value);
}

@end























