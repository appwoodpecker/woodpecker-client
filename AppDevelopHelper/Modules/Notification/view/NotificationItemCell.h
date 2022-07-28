//
//  NotificationItemCell.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/2/27.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NotificationItemCell : ADHBaseCell

- (void)setData: (id)data contentWidth: (CGFloat)contentWidth;
+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth;

@end
