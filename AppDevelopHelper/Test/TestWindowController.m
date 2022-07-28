//
//  TestWindowController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "TestWindowController.h"
#import "DBTestViewController.h"
#import "SplitTestViewController.h"
#import "RichTextPreviewTestViewController.h"

@interface TestWindowController ()

@property (nonatomic, strong) NSTabViewController * tabVC;

@end

@implementation TestWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSTabViewController * tabVC = [[NSTabViewController alloc] init];
    tabVC.tabStyle = NSTabViewControllerTabStyleSegmentedControlOnTop;
    
    //rich text
    RichTextPreviewTestViewController * richTextVC = [[RichTextPreviewTestViewController alloc] init];
    richTextVC.title = @"RichText";
    [tabVC addChildViewController:richTextVC];
    
    //DBTest
    DBTestViewController * dbVC = [[DBTestViewController alloc] init];
    dbVC.title = @"DBTest";
    [tabVC addChildViewController:dbVC];
    
    //Split
    SplitTestViewController * splitVC = [[SplitTestViewController alloc] init];
    splitVC.title = @"SplitTest";
    [tabVC addChildViewController:splitVC];
    
    
    self.tabVC = tabVC;
    self.contentViewController = self.tabVC;
    
}

@end
