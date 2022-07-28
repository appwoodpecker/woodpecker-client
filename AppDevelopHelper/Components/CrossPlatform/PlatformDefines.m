//
//  PlatformDefines.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/24.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "PlatformDefines.h"


ADH_COLOR adhColorMake(int mode,CGFloat v1, CGFloat v2, CGFloat v3, CGFloat v4, CGFloat alpha) {
    ADH_COLOR color;
    color.mode = mode;
    color.v1 = v1;
    color.v2 = v2;
    color.v3 = v3;
    color.v4 = v4;
    color.alpha = alpha;
    return color;
}

ADH_COLOR adhColorZero(void) {
    return adhColorMake(0, 0, 0, 0, 0, 0);
}

ADH_FRAME adhFrameMake(CGFloat centerX, CGFloat centerY, CGFloat width, CGFloat height) {
    ADH_FRAME frame;
    frame.centerX = centerX;
    frame.centerY = centerY;
    frame.width = width;
    frame.height = height;
    return frame;
}

ADH_INSETS adhInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    ADH_INSETS insets;
    insets.top = top;
    insets.left = left;
    insets.bottom = bottom;
    insets.right = right;
    return insets;
}

@implementation ADHFont

+ (ADHFont *)fontWithName: (NSString *)fontName size: (NSInteger)fontSize {
    ADHFont *font = [[ADHFont alloc] init];
    font.fontName = fontName;
    font.fontSize = fontSize;
    return font;
}

- (NSString *)stringValue {
    NSString *value = [NSString stringWithFormat:@"%@,%zd",self.fontName,self.fontSize];
    return value;
}

+ (ADHFont *)fontWithString: (NSString *)value {
    NSString *fontName = nil;
    NSInteger fontSize = 0;
    NSArray *values = [value componentsSeparatedByString:@","];
    if(values.count >= 2) {
        fontName = values[0];
        fontSize = [values[1] integerValue];
    }
    return [ADHFont fontWithName:fontName size:fontSize];
}

@end

@implementation PlatformDefines

@end
