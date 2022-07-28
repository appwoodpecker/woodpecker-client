//
//  NotificationCell.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/2/17.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NotificationCellItem.h"

@interface NotificationCell : ADHBaseCell

- (void)setItem: (NotificationCellItem *)item key: (NSString *)key;

@end
