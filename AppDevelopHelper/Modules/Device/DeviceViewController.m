//
//  DeviceInfoViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "DeviceViewController.h"
#import "ScreenshotViewController.h"
#import "DeviceInfoViewController.h"

@interface DeviceViewController ()<NSSplitViewDelegate>

@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *screenshotLayout;
@property (nonatomic, strong) ScreenshotViewController * screenshotVC;
@property (weak) IBOutlet NSView *infoLayout;
@property (nonatomic, strong) DeviceInfoViewController * infoVC;

@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
}

- (void)setupAfterXib
{
    CGRect ssViewRect = self.screenshotLayout.frame;
    ssViewRect.size.width = [self screenshotPreferWidth];
    self.screenshotLayout.frame = ssViewRect;
    
    ScreenshotViewController * scVC = [[ScreenshotViewController alloc] init];
    scVC.context = self.context;
    NSView * scView = scVC.view;
    scView.frame = self.screenshotLayout.bounds;
    scView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.screenshotLayout addSubview:scView];
    self.screenshotVC = scVC;
    
    DeviceInfoViewController * infoVC = [[DeviceInfoViewController alloc] init];
    infoVC.context = self.context;
    NSView * infoView = infoVC.view;
    infoView.frame = self.infoLayout.bounds;
    infoView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.infoLayout addSubview:infoView];
    self.infoVC = infoVC;
}

- (CGFloat)screenshotPreferWidth
{
    NSScreen * screen = [NSScreen mainScreen];
    CGSize size = screen.frame.size;
    //1/5 - 1/4
    CGFloat width = ceilf(size.width * 0.22);
    if(width < 300){
        width = 300;
    }
    if(width > 500){
        width = 500;
    }
    return width;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    //如果splitview大小发生变化，计算子视图位置
    CGFloat splitWidth = splitView.bounds.size.width;
    CGFloat splitHeight = splitView.bounds.size.height;
    
    CGFloat dividerThickness = splitView.dividerThickness;
    CGFloat ssWidth = self.screenshotLayout.bounds.size.width;
    self.screenshotLayout.frame = CGRectMake(0, 0, ssWidth, splitHeight);
    
    CGFloat infoWidth = splitWidth - dividerThickness - ssWidth;
    self.infoLayout.frame = CGRectMake(ssWidth+dividerThickness, 0, infoWidth, splitHeight);
}



@end






















