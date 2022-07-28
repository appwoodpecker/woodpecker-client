//
//  UIUtil.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/18.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UIUtil : NSObject

+ (CGFloat)measureTextSize: (CGFloat)boundingWidth text: (NSString *)text font: (NSFont *)font;

+ (NSAttributedString *)attributeStringWithText:(NSString *)text font:(NSFont *)font lineSpacing:(CGFloat)lineSpacing;

+ (NSTextField *)label;

+ (NSImageView *)iconNamed:(NSString *)iconName;

@end
