//
//  UIUtil.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/18.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "UIUtil.h"

@implementation UIUtil

+ (CGFloat)measureTextSize: (CGFloat)boundingWidth text: (NSString *)text font: (NSFont *)font {
    NSDictionary *attributes = @{
                                 NSFontAttributeName : font,
                                 };
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(boundingWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    return textSize.height;
}

+ (NSAttributedString *)attributeStringWithText:(NSString *)text font:(NSFont *)font lineSpacing:(CGFloat)lineSpacing {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:lineSpacing];
    NSDictionary *attributes = @{
        NSFontAttributeName : font,
        NSParagraphStyleAttributeName: paragraphStyle,
    };
    NSAttributedString *authorText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return authorText;
}

+ (NSTextField *)label {
    NSTextField *label = [[NSTextField alloc] init];
    label.editable = NO;
    label.bezeled = NO;
    label.selectable = NO;
    label.backgroundColor = [NSColor clearColor];
    return label;
}

+ (NSImageView *)iconNamed:(NSString *)iconName {
    NSImageView *icon = [[NSImageView alloc] init];
    icon.image = [NSImage imageNamed:iconName];
    [icon sizeToFit];
    icon.imageAlignment = NSImageAlignCenter;
    icon.imageScaling = NSImageScaleProportionallyDown;
    return icon;
}

@end
