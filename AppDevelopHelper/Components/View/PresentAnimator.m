//
//  PresentAnimator.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/2.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "PresentAnimator.h"
@import QuartzCore;

@implementation PresentAnimator

/* Called when the view controller is going to be presented. Implement presentation in this method when it is called.
 */
- (void)animatePresentationOfViewController:(NSViewController *)viewController fromViewController:(NSViewController *)fromViewController
{
    NSView * parentView = fromViewController.view;
    NSView * contentView = viewController.view;
    contentView.wantsLayer = YES;
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [[NSColor blackColor] colorWithAlphaComponent:0.5];
    shadow.shadowOffset = CGSizeMake(0, -2.0f);
    shadow.shadowBlurRadius = 4.0f;
    contentView.shadow = shadow;
    
    contentView.center = CGPointMake(parentView.width/2.0f,parentView.height/2.0f);
    [parentView addSubview:contentView];
    /*
    contentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    contentView.layer.position = CGPointMake(parentView.width/2.0f,parentView.height/2.0f + 60.0f);
    [parentView addSubview:contentView];
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D from = CATransform3DMakeScale(0, 0, 1);
    CATransform3D to = CATransform3DMakeScale(1, 1, 1);
    animation.fromValue = [NSValue valueWithCATransform3D:from];
    animation.toValue = [NSValue valueWithCATransform3D:to];
    animation.duration = 0.2;
    [contentView.layer addAnimation:animation forKey:@"show"];
     */
    contentView.alphaValue = 0;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.1;
        contentView.animator.alphaValue = 1;
    }completionHandler:^{
        contentView.animator.alphaValue = 1;
    }];
}

/* Called to dismiss a previously shown view controller.
 */
- (void)animateDismissalOfViewController:(NSViewController *)viewController fromViewController:(NSViewController *)fromViewController
{
    NSView * contentView = viewController.view;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.1;
        contentView.animator.alphaValue = 0;
    }completionHandler:^{
        contentView.animator.alphaValue = 0;
        [contentView removeFromSuperview];
    }];
    
}

@end
