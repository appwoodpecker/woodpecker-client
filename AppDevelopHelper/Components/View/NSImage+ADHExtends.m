//
//  NSImage+ADHExtends.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/11/3.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "NSImage+ADHExtends.h"
#import <AppKit/AppKit.h>


@implementation NSImage (ADHExtends)

- (NSImage *)imageWithTintColor: (NSColor *)color {
    NSImage *image = self;
    NSImage *tintImage = [image copy];
    [tintImage lockFocus];
    [color set];
    NSRectFillUsingOperation(NSMakeRect(0, 0, tintImage.size.width, tintImage.size.height),NSCompositingOperationSourceAtop);
    [tintImage unlockFocus];
    return tintImage;
}



@end
