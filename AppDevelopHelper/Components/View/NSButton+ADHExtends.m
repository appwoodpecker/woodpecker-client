//
//  NSButton+ADHExtends.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/5/12.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NSButton+ADHExtends.h"

@implementation NSButton (ADHExtends)

//button bad color
- (void)setTextColor: (NSColor *)textColor {
    NSMutableAttributedString*  attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedTitle];
    NSRange  range = NSMakeRange(0, attributedString.length);
    [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
    [self setAttributedTitle:attributedString];
}

@end


@implementation ADHButton

@end
