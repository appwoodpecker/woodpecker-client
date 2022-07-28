//
//  NSView+ADHHud.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/1/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHTipView.h"

@interface NSView (ADHHud)

/**
 * 加载指示器
 */
- (void)showHud;
- (void)hideHud;

/**
 * 中间提示弹框
 */
- (void)showToastWithIcon: (NSString *)icon statusText: (NSString *)text;

/**
 * 右下角提示文字
 */
- (void)showTip: (NSString *)text actionText: (NSString *)actionText actionBlock: (ADHTipViewActionBlock)actionBlock;

@end
