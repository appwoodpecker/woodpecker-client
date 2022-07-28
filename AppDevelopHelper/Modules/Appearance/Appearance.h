//
//  Appearance.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/1/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Appearance : NSObject

+ (NSColor *)themeColor;
+ (NSColor *)controlSeperatorColor;
+ (NSColor *)controlBackgroundColor;

+ (NSColor *)tipThemeColor;

//内容背景色
+ (NSColor *)backgroundColor;
//导航类型背景色
+ (NSColor *)barBackgroundColor;
//按钮图片颜色
+ (NSColor *)actionImageColor;

+ (NSColor *)colorWithRed: (NSInteger)red green: (NSInteger)green blue: (NSInteger)blue alpha: (CGFloat)alpha;
+ (NSColor *)colorWithHex: (NSInteger)hexValue;
+ (NSColor *)colorWithHex: (NSInteger)hexValue alpha:(CGFloat)alpha;
+ (CGSize)getModalWindowSize: (CGSize)parentSize;

+ (NSString *)effectiveAppearance;
+ (BOOL)isDark;

+ (void)setMGSFragariaColor;



@end
