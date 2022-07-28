//
//  NotificationDetailViewController.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/2/27.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHNotificationItem.h"

@interface NotificationDetailViewController : NSViewController

- (void)setData: (ADHNotificationItem *)item;
@property (nonatomic, assign) BOOL bLocal;

@end
