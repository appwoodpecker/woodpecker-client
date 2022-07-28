//
//  SplitTestViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/12.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "SplitTestViewController.h"

@interface SplitTestViewController ()<NSSplitViewDelegate>
@property (weak) IBOutlet NSSplitView *splitView;

@property (weak) IBOutlet NSView *leftView;
@property (weak) IBOutlet NSView *midView;

@end

@implementation SplitTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftView.wantsLayer = YES;
    self.leftView.layer.backgroundColor = [[NSColor greenColor] colorWithAlphaComponent:0.1].CGColor;
    self.midView.wantsLayer = YES;
    self.midView.layer.backgroundColor = [[NSColor blueColor] colorWithAlphaComponent:0.1].CGColor;
    self.splitView.delegate = self;
    
    self.splitView.dividerStyle = NSSplitViewDividerStyleThick;
    
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    BOOL ret = YES;
    if(subview == self.midView){
        ret = NO;
    }
    return ret;
    
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
    return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    CGFloat minWidth = proposedMinimumPosition;
    if(dividerIndex == 0){
        minWidth = 100.0f;
    }else if(dividerIndex == 1){
        minWidth = 400.0f;
    }
    return minWidth;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    CGFloat maxWidth = proposedMaximumPosition;
    if(dividerIndex == 0){
        maxWidth = 250.0f;
    }
    return maxWidth;
}







@end







