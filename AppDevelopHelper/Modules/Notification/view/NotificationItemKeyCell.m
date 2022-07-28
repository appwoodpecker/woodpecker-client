//
//  NotificationItemKeyCell.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/2/27.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationItemKeyCell.h"

@interface NotificationItemKeyCell ()

@property (weak) IBOutlet NSTextField *titleTextfield;

@end

@implementation NotificationItemKeyCell

- (void)setData: (id)data
{
    NSString * value = data;
    self.titleTextfield.stringValue = value;
}

@end
