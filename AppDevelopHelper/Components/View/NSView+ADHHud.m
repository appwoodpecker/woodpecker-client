//
//  NSView+ADHHud.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/1/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NSView+ADHHud.h"
#import <objc/runtime.h>

static const char * kADHViewHud = "kADHViewHud";
static const char * kADHViewTipView = "kADHViewTipView";

@implementation NSView (ADHHud)

- (void)showHud {
    NSView * indicatorView = [self adh_getProgressIndicator];
    if(!indicatorView){
        NSProgressIndicator * indicator = [[NSProgressIndicator alloc] init];
        indicator.style = NSProgressIndicatorSpinningStyle;
        indicator.indeterminate = YES;
        NSSize containerSize = self.size;
        if(containerSize.width > 100 && containerSize.height > 100) {
            indicator.controlSize = NSControlSizeRegular;
        }else {
            indicator.controlSize = NSControlSizeSmall;
        }
        [indicator sizeToFit];
        indicator.displayedWhenStopped = NO;
        indicatorView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, indicator.frame.size.width, indicator.frame.size.height)];
        indicatorView.wantsLayer = YES;
        indicatorView.layer.backgroundColor = [NSColor clearColor].CGColor;
        [indicatorView addSubview:indicator];
        [self adh_setProgressIndicator:indicatorView];
    }
    CGRect frame = indicatorView.frame;
    CGFloat x = CGRectGetMidX(self.frame) - indicatorView.bounds.size.width/2;
    CGFloat y = CGRectGetMidY(self.frame) - indicatorView.bounds.size.height/2;
    frame.origin = CGPointMake(x, y);
    indicatorView.frame = frame;
    [self.superview addSubview:indicatorView positioned:NSWindowAbove relativeTo:self];
    NSProgressIndicator * indicator = indicatorView.subviews[0];
    [indicator startAnimation:self];
    indicatorView.hidden = NO;
}

- (void)hideHud
{
    NSView * indicatorView = [self adh_getProgressIndicator];
    if(indicatorView) {
        NSProgressIndicator * indicator = indicatorView.subviews[0];
        indicatorView.hidden = YES;
        [indicator stopAnimation:self];
    }
}

- (NSView *)adh_getProgressIndicator
{
    NSView * indicator = objc_getAssociatedObject(self, kADHViewHud);
    return indicator;
}

- (void)adh_setProgressIndicator: (NSView *)indicator
{
    objc_setAssociatedObject(self, kADHViewHud, indicator, OBJC_ASSOCIATION_RETAIN);
}

- (void)showToastWithIcon: (NSString *)icon statusText: (NSString *)text
{
    NSView * toastView = nil;
    NSArray * topObjects = nil;
    [[NSBundle mainBundle] loadNibNamed:@"ADHToast" owner:nil topLevelObjects:&topObjects];
    for(id object in topObjects){
        if([object isKindOfClass:[NSView class]]){
            toastView = object;
            break;
        }
    }
    NSImageView * imageView = [toastView viewWithTag:100];
    NSTextField * statusLabel = [toastView viewWithTag:101];
    toastView.wantsLayer = YES;
    toastView.layer.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.8].CGColor;
    toastView.layer.cornerRadius = 5.0f;
    
    imageView.image = [NSImage imageNamed:icon];
    if(!text) {
        text = @"";
    }
    statusLabel.stringValue = text;
    if(text.length > 0) {
        imageView.top = 71.0f;
    }else {
        imageView.top = (toastView.height - imageView.height)/2.0f;
    }
    NSRect contentRect = self.bounds;
    NSRect toastRect = toastView.bounds;
    toastRect.origin = CGPointMake((contentRect.size.width-toastRect.size.width)/2.0f, (contentRect.size.height-toastRect.size.height)/2.0f);
    toastView.frame = toastRect;
    toastView.alphaValue = 0;
    [self addSubview:toastView];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        toastView.animator.alphaValue = 1.0f;
        context.duration = 0.1;
    } completionHandler:^{
        toastView.alphaValue = 1.0f;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                context.duration = 0.8;
                toastView.animator.alphaValue = 0.0f;
            } completionHandler:^{
                toastView.alphaValue = 0.0f;
                [toastView removeFromSuperview];
            }];
        });
    }];
}

#pragma mark -----------------   tip view  ----------------

- (ADHTipView *)adh_getTipView
{
    ADHTipView * tipview = objc_getAssociatedObject(self, kADHViewTipView);
    return tipview;
}

- (void)adh_setTipView: (ADHTipView *)tipView
{
    objc_setAssociatedObject(self, kADHViewTipView, tipView, OBJC_ASSOCIATION_RETAIN);
}

- (void)showTip: (NSString *)text actionText: (NSString *)actionText actionBlock: (ADHTipViewActionBlock)actionBlock {
    ADHTipView * tipView = [self adh_getTipView];
    if(!tipView) {
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:@"ADHTipView" owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[ADHTipView class]]){
                tipView = object;
                break;
            }
        }
        [self adh_setTipView:tipView];
    }
    //will caculate content size itself
    [tipView setText:text actionText:actionText action:actionBlock];
    [tipView showInView:self];
}




@end






















