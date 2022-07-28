//
//  NotificationCellItem.h
//  ADHClient
//
//  Created by 张小刚 on 2018/6/3.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHNotificationItem.h"

@interface NotificationCellItem : NSObject

@property (nonatomic, strong) ADHNotificationItem *item;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL unread;

@end
