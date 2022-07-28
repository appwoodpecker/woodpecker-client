//
//  NSView+ADHHud.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/1/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NSView+ADHExtends.h"

@implementation NSView (ADHExtends)

- (void)setShadowWithColor:(NSColor *)color offset:(CGSize)offset radius:(CGFloat)radius {
    NSView *view = self;
    view.wantsLayer = YES;
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowOffset = offset;
    if (radius > 0 ) {
        view.layer.shadowRadius = radius;
    }
    view.layer.masksToBounds = NO;
}


@end
