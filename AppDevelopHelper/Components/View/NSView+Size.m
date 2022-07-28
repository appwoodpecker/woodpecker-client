//
//  NSView+Size.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/2.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NSView+Size.h"

@implementation NSView (Size)


- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left
{
    NSRect rect = self.frame;
    rect.origin.x = left;
    self.frame = rect;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
    NSRect rect = self.frame;
    rect.origin.x = right - rect.size.width;
    self.frame = rect;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

/*
 left - bottom
 */
- (void)setTop:(CGFloat)top
{
    NSRect rect = self.frame;
    rect.origin.y = top;
    self.frame = rect;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
    NSRect rect = self.frame;
    rect.origin.y = bottom - rect.size.height;
    self.frame = rect;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    NSRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    NSRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    NSRect rect = self.frame;
    rect.origin = origin;
    self.frame = rect;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    NSRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}

- (NSPoint)center
{
    CGFloat centerX = self.frame.origin.x + (self.frame.size.width / 2.0);
    CGFloat centerY = self.frame.origin.y + (self.frame.size.height / 2.0);
    
    return CGPointMake(centerX, centerY);
}

- (void)setCenter:(CGPoint)center
{
    CGFloat originX = center.x - (self.frame.size.width / 2.0);
    CGFloat originY = center.y - (self.frame.size.height / 2.0);
    
    self.frame = NSMakeRect(originX, originY, self.frame.size.width, self.frame.size.height);
}

@end
