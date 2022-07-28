//
//  ADHDefines.m
//  ADHClient
//
//  Created by 张小刚 on 2019/2/24.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHDefines.h"

ADH_COLOR adhColorFromUIColor(UIColor *color) {
    ADH_COLOR adhColor;
    //others rgb
    CGFloat red,green,blue,alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    adhColor.mode = 0;
    adhColor.v1 = red;
    adhColor.v2 = green;
    adhColor.v3 = blue;
    adhColor.alpha = alpha;
    return adhColor;
}

UIColor *uicolorFromAdhColor(ADH_COLOR adhColor) {
    UIColor *color = [UIColor colorWithRed:adhColor.v1 green:adhColor.v2 blue:adhColor.v3 alpha:adhColor.alpha];
    return color;
}

ADH_FRAME adhFrameFromFrame(CGRect frame) {
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat centerX = frame.origin.x + width/2.0f;
    CGFloat centerY = frame.origin.y + height/2.0f;
    return adhFrameMake(centerX, centerY, width, height);
}

CGRect frameFromAdhFrame(ADH_FRAME frame) {
    CGFloat width = frame.width;
    CGFloat height = frame.height;
    CGFloat x = frame.centerX - width/2.0f;
    CGFloat y = frame.centerY - height/2.0f;
    CGRect rect = CGRectMake(x, y, width, height);
    return rect;
}

ADH_INSETS adhInsetsFromInsets(UIEdgeInsets insets) {
    return adhInsetsMake(insets.top, insets.left, insets.bottom, insets.right);
}

UIEdgeInsets uiinsetsFromAdhInsets(ADH_INSETS insets) {
    return UIEdgeInsetsMake(insets.top, insets.left, insets.bottom, insets.right);
}

ADHFont* adhFontFromUIFont(UIFont *font) {
    return [ADHFont fontWithName:font.fontName size:(NSInteger)(font.pointSize)];
}

UIFont *uifontFromAdhFont(ADHFont *font) {
    return [UIFont fontWithName:font.fontName size:font.fontSize];
}

@implementation ADHDefines

+ (NSString *)stringWithFont: (UIFont *)font {
    return [NSString stringWithFormat:@"%@ %.1f",font.fontName,font.pointSize];
}

@end
