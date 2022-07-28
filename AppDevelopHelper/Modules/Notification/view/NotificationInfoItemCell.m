//
//  NotificationInfoItemCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/6/3.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationInfoItemCell.h"

@interface NotificationInfoItemCell ()

@property (weak) IBOutlet NSImageView *statusIcon;
@property (weak) IBOutlet NSTextField *titleTextfield;

@end

@implementation NotificationInfoItemCell

- (void)setData: (NSDictionary *)data
{
    NSString * title = data[@"title"];
    self.titleTextfield.stringValue = title;
    NSString * type = data[@"type"];
    NSString *valueText = nil;
    CGFloat textLeft = 0.0f;
    if([type isEqualToString:@"text"]){
        self.statusIcon.hidden = YES;
        valueText = adhvf_safestringfy(data[@"value"]);
        textLeft = 27.0f;
    }else{
        self.statusIcon.hidden = NO;
        NSInteger status = [data[@"value"] integerValue];
        NSString * iconName = [self statusIconWithType:type value:status];
        self.statusIcon.image = [NSImage imageNamed:iconName];
        valueText = data[@"value_des"];
        textLeft = 16.0f + (30.0f + 8.0f);
    }
    self.titleTextfield.stringValue = valueText;
    CGRect frame = self.titleTextfield.frame;
    frame.origin.x = textLeft;
    CGFloat width = CGRectGetWidth(self.bounds) - textLeft - 20.0f;
    frame.size.width = width;
    self.titleTextfield.frame = frame;
}

- (NSString *)statusIconWithType: (NSString *)type value: (NSInteger)value
{
    NSString * statusIcon = nil;
    if([type isEqualToString:@"alertStyle"]){
        if(value == 0){
            //UNAlertStyleNone
            statusIcon = @"NSStatusNone";
        }else if(value == 1){
            //UNAlertStyleBanner
            statusIcon = @"NSStatusAvailable";
        }else if(value == 2){
            //UNAlertStyleAlert
            statusIcon = @"NSStatusAvailable";
        }
    }else if([type isEqualToString:@"showPreviews"]){
        if(value == 0){
            //UNShowPreviewsSettingAlways ,Notification previews are always shown.
            statusIcon = @"NSStatusAvailable";
        }else if(value == 1){
            //UNShowPreviewsSettingWhenAuthenticated, Notifications previews are only shown when authenticated.
            statusIcon = @"NSStatusPartiallyAvailable";
        }else if(value == 2){
            //UNShowPreviewsSettingNever, Notifications previews are never shown.
            statusIcon = @"NSStatusNone";
        }
    }else{
        if(value == 0){
            statusIcon = @"NSStatusNone";
        }else if(value == 1){
            statusIcon = @"NSStatusUnavailable";
        }else if(value == 2){
            statusIcon = @"NSStatusAvailable";
        }
    }
    return statusIcon;
}

@end
