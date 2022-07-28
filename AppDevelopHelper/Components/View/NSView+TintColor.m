//
//  NSView+TintColor.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/11/3.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "NSView+TintColor.h"
#import <AppKit/AppKit.h>

@implementation NSButton (TintColor)

- (void)setTintColor: (NSColor *)color {
    NSImage *image = self.image;
    if(!image) {
        return;
    }
    image.template = YES;
    self.contentTintColor = color;
}

@end

@implementation NSImageView (TintColor)

- (void)setTintColor: (NSColor *)color {
    NSImage *image = self.image;
    if(!image) {
        return;
    }
    image.template = YES;
    self.contentTintColor = color;
}

@end
