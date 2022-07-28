//
//  Appearance.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/1/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "Appearance.h"
#import <MGSFragaria/MGSFragaria.h>

@implementation Appearance

+ (NSColor *)themeColor {
    //25A261
    return [Appearance colorWithRed:0x25 green:0xA2 blue:0x61 alpha:1.0f];
}

+ (NSColor *)tipThemeColor {
    return [[Appearance themeColor] colorWithAlphaComponent:0.6];
}

+ (NSColor *)controlSeperatorColor {
    NSColor *color = [[NSColor blackColor] colorWithAlphaComponent:0.1];
    NSColor *darkColor = [Appearance colorWithHex:0xEEEEEE alpha:0.1];
    return [Appearance colorWithNormal:color dark:darkColor];
}

+ (NSColor *)controlBackgroundColor {
    return [Appearance colorWithRed:236 green:236 blue:236 alpha:1.0];
}

+ (NSColor *)backgroundColor {
    NSColor *color = [Appearance colorWithHex:0xF5F6F7];
    NSColor *darkColor = [Appearance colorWithHex:0x323232];
    return [Appearance colorWithNormal:color dark:darkColor];
}

+ (NSColor *)barBackgroundColor {
    NSColor *color = [NSColor whiteColor];
    NSColor *darkColor = [Appearance colorWithHex:0x323232];
    return [Appearance colorWithNormal:color dark:darkColor];
}

+ (NSColor *)actionImageColor {
    NSColor *color = [Appearance colorWithHex:0x8A8A8A];
    NSColor *darkColor = [Appearance colorWithHex:0xBBBBBB];
    return [Appearance colorWithNormal:color dark:darkColor];
}

+ (NSColor *)colorWithNormal: (NSColor *)color dark: (NSColor *)darkColor {
    if([Appearance isDark]) {
        return darkColor;
    }else {
        return color;
    }
}

+ (NSString *)effectiveAppearance {
    return @"effectiveAppearance";
}

+ (BOOL)isDark {
    BOOL dark = NO;
    if (@available(macOS 10.14, *)) {
        NSAppearance *appearance = [NSApplication sharedApplication].effectiveAppearance;
        dark = [appearance.name isEqualToString:NSAppearanceNameDarkAqua];
    }
    return dark;
}

+ (NSColor *)colorWithRed: (NSInteger)red green: (NSInteger)green blue: (NSInteger)blue alpha: (CGFloat)alpha
{
    return [NSColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

+ (NSColor *)colorWithHex: (NSInteger)hexValue {
    return [Appearance colorWithHex:hexValue alpha:1.0f];
}

//0xAAAAAA
+ (NSColor *)colorWithHex: (NSInteger)hexValue alpha:(CGFloat)alpha {
    NSInteger red = (0xFF0000 & hexValue) >> 16;
    NSInteger green = (0x00FF00 & hexValue) >> 8;
    NSInteger blue = 0x0000FF & hexValue;
    return [Appearance colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGSize)getModalWindowSize:(CGSize)parentSize {
    CGFloat widthFactor = 1/2.0f;
    CGFloat heightFactor = 0.6;
    CGFloat width = ceilf(parentSize.width*widthFactor);
    CGFloat height = ceilf(parentSize.height * heightFactor);
    CGSize viewSize = CGSizeMake(width,height);
    return viewSize;
}

/*
 //背景色
extern NSString * const MGSFragariaPrefsBackgroundColourWell;
 //command
extern NSString * const MGSFragariaPrefsCommandsColourWell;
 //注释
extern NSString * const MGSFragariaPrefsCommentsColourWell;
 //指令
extern NSString * const MGSFragariaPrefsInstructionsColourWell;
 //关键字
extern NSString * const MGSFragariaPrefsKeywordsColourWell;
 //自动完成
extern NSString * const MGSFragariaPrefsAutocompleteColourWell;
 //变量
extern NSString * const MGSFragariaPrefsVariablesColourWell;
 //字符串
extern NSString * const MGSFragariaPrefsStringsColourWell;
 //属性
extern NSString * const MGSFragariaPrefsAttributesColourWell;
 //普通文本
extern NSString * const MGSFragariaPrefsTextColourWell;
 //gutter
extern NSString * const MGSFragariaPrefsGutterTextColourWell;
 //不可见字符
extern NSString * const MGSFragariaPrefsInvisibleCharactersColourWell;
 //高亮文本
extern NSString * const MGSFragariaPrefsHighlightLineColourWell;
 //数字
extern NSString * const MGSFragariaPrefsNumbersColourWell;
*/
+ (void)setMGSFragariaColor {
    if([Appearance isDark]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance backgroundColor]] forKey:MGSFragariaPrefsBackgroundColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance backgroundColor]] forKey:MGSFragariaPrefsGutterBackgroundColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[NSColor secondaryLabelColor]] forKey:MGSFragariaPrefsGutterTextColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[NSFont systemFontOfSize:14]] forKey:MGSFragariaPrefsTextFont];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance colorWithHex:0xC22B8D]] forKey:MGSFragariaPrefsCommandsColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance colorWithHex:0x45BB3E]] forKey:MGSFragariaPrefsCommentsColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance colorWithHex:0x149C92]] forKey:MGSFragariaPrefsNumbersColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance colorWithHex:0xDE3A3B]] forKey:MGSFragariaPrefsStringsColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:MGSFragariaPrefsTextColourWell];
    }else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:MGSFragariaPrefsBackgroundColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.94f alpha:1.0f]] forKey:MGSFragariaPrefsGutterBackgroundColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.42f alpha:1.0f]] forKey:MGSFragariaPrefsGutterTextColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[NSFont systemFontOfSize:14]] forKey:MGSFragariaPrefsTextFont];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance colorWithHex:0x4F00DA]] forKey:MGSFragariaPrefsCommandsColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance colorWithHex:0x007300]] forKey:MGSFragariaPrefsCommentsColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance colorWithHex:0x0800DA]] forKey:MGSFragariaPrefsNumbersColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[Appearance colorWithHex:0xCD1227]] forKey:MGSFragariaPrefsStringsColourWell];
        [defaults setValue:[NSArchiver archivedDataWithRootObject:[NSColor blackColor]] forKey:MGSFragariaPrefsTextColourWell];
    }
}

@end
