//
//  ADHTipView.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/5/12.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHTipView.h"
@import QuartzCore;

static const CGFloat kADHTipViewMaxWidth = 180.0f;
static const CGFloat kADHTipViewPaddingLeft = 20.0f;
static const CGFloat kADHTipViewPaddingRight = 20.0f;
static const NSTimeInterval kADHTipViewDimissInterval = 4.0f;


@interface ADHTipView ()

@property (nonatomic, strong) ADHTipViewActionBlock actionBlock;
@property (weak) IBOutlet NSTextField *contentLabel;
@property (weak) IBOutlet NSButton *actionButton;

@property (nonatomic, strong) NSTimer * dismissTimer;
@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation ADHTipView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.8].CGColor;
    self.layer.cornerRadius = 4.0f;
    self.contentLabel.textColor = [NSColor whiteColor];
}

- (void)setText: (NSString *)text actionText: (NSString *)actionText action: (ADHTipViewActionBlock)actionBlock {
    self.actionBlock = actionBlock;
    //先计算内容宽度
    self.contentLabel.stringValue = text;
    CGFloat contentWidth = kADHTipViewMaxWidth - (kADHTipViewPaddingLeft + kADHTipViewPaddingRight);
    NSSize textSize = [self.contentLabel sizeThatFits:NSMakeSize(contentWidth, CGFLOAT_MAX)];
    contentWidth = textSize.width;
    CGFloat bottom = 12.0f;
    CGFloat left = kADHTipViewPaddingLeft;
    if(actionText.length > 0) {
        self.actionButton.hidden = NO;
        self.actionButton.title = actionText;
        [self.actionButton setTextColor:[Appearance themeColor]];
        NSSize size = [self.actionButton sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
        self.actionButton.origin = CGPointMake(left, bottom);
        self.actionButton.width = size.width;
        self.actionButton.height = 24.0f;
        bottom += (self.actionButton.height + 2.0f);
    }else {
        self.actionButton.hidden = YES;
    }
    self.contentLabel.origin = CGPointMake(left, bottom);
    self.contentLabel.size = textSize;
    bottom += textSize.height;
    bottom += 26.0f;
    CGSize size = CGSizeMake(contentWidth + (kADHTipViewPaddingLeft + kADHTipViewPaddingRight), bottom);
    self.size = size;
}

- (void)showInView: (NSView *)containerView {
    CGSize contentSize = self.size;
    CGFloat x = 20.0f;
    CGFloat y = 30.0f;
    CGPoint fromPos = CGPointMake(containerView.width, y);
    CGPoint toPos = CGPointMake(containerView.width-x-contentSize.width, y);
    self.alphaValue  = 1.0f;
    self.origin = fromPos;
    //most front
    [self removeFromSuperview];
    [containerView addSubview:self];
    __weak typeof(self) wself = self;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.3f;
        NSRect rect = wself.frame;
        rect.origin = toPos;
        wself.animator.frame = rect;
    } completionHandler:nil];
    [self setupDimissTimer];
}

- (void)dismissAnimated: (BOOL)animated manaul: (BOOL)manaul {
    NSView * containerView = self.superview;
    CGPoint toPos = CGPointMake(containerView.width, self.origin.y);
    __weak typeof(self) wself = self;
    if(animated) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            if(manaul) {
                context.duration = 0.3f;
            }else {
                context.duration = 0.8f;
            }
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            NSRect rect = wself.frame;
            rect.origin = toPos;
            wself.animator.frame = rect;
            wself.animator.alphaValue = 0.0f;
        } completionHandler:^{
            
        }];
    }else {
        self.origin = toPos;
        self.alphaValue = 0.0f;
    }
}

- (void)setupDimissTimer {
    if(self.dismissTimer) {
        [self clearDismissTimer];
    }
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:kADHTipViewDimissInterval target:self selector:@selector(dismissTimerFired) userInfo:nil repeats:NO];
}

- (void)clearDismissTimer {
    [self.dismissTimer invalidate];
    self.dismissTimer = nil;
}

- (void)dismissTimerFired {
    [self clearDismissTimer];
    [self dismissAnimated:YES manaul:NO];
}

- (IBAction)actionButtonPressed:(id)sender {
    if(self.actionBlock) {
        self.actionBlock();
        [self dismissAnimated:NO manaul:YES];
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissAnimated:YES manaul:YES];
}

- (void)mouseEntered:(NSEvent *)event {
    [self clearDismissTimer];
}

- (void)mouseExited:(NSEvent *)event {
    [self setupDimissTimer];
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if(self.trackingArea) {
        [self removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
    NSTrackingArea * trackingArea = nil;
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

@end







