//
//  RoundProgressView.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/6/19.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "CircularProgressView.h"
#import "NSBezierPath+Bezier.h"
@import QuartzCore;

@interface CircularProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation CircularProgressView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.wantsLayer = YES;
    CGFloat lineWidth = 2.0f;
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.strokeColor = [Appearance themeColor].CGColor;
    layer.fillColor = [NSColor clearColor].CGColor;
    layer.lineWidth = lineWidth;
    layer.lineCap = @"round";
    layer.strokeStart = 0;
    layer.strokeEnd = 0;
    layer.frame = self.bounds;
    CGFloat radius = (self.width - lineWidth)/2.0f;
    NSBezierPath *path = [[NSBezierPath alloc] init];
    NSPoint center = layer.position;
    CGFloat startAngle = 90;
    CGFloat endAngle = startAngle - 360;
    [path appendBezierPathWithArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    layer.path = [path cgPath];
    [self.layer addSublayer:layer];
    self.progressLayer = layer;
    [self resetProgress];
}

- (void)resetProgress {
    [CATransaction begin];
    [CATransaction disableActions];
    self.progressLayer.strokeStart = 0;
    self.progressLayer.strokeEnd = 0;
    [CATransaction commit];
}

- (void)setProgress: (float)progress {
    self.progressLayer.strokeEnd = progress;
}



@end
