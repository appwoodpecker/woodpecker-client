//
//  NSView+TintColor.h
//  Woodpecker
//
//  Created by 张小刚 on 2019/11/3.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

@interface NSButton (TintColor)

- (void)setTintColor: (NSColor *)color;

@end


@interface NSImageView (TintColor)

- (void)setTintColor: (NSColor *)color;

@end
