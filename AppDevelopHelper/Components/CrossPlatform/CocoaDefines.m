//
//  CocoaDefines.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/30.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "CocoaDefines.h"

ADH_COLOR adhColorFromNSColor(NSColor *color) {
    NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    ADH_COLOR adhColor;
    CGFloat red,green,blue,alpha = 0;
    [rgbColor getRed:&red green:&green blue:&blue alpha:&alpha];
    adhColor.mode = 0;
    adhColor.v1 = red;
    adhColor.v2 = green;
    adhColor.v3 = blue;
    adhColor.alpha = alpha;
    return adhColor;
}

NSColor * nscolorFromAdhColor(ADH_COLOR adhColor) {
    NSColor * color = nil;
    CGFloat red = adhColor.v1;
    CGFloat green = adhColor.v2;
    CGFloat blue = adhColor.v3;
    CGFloat alpha = adhColor.alpha;
    color = [NSColor colorWithRed:red green:green blue:blue alpha:alpha];
    return color;
}

@implementation CocoaDefines

@end
