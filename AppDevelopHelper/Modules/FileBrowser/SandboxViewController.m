//
//  SandboxViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/7/12.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "SandboxViewController.h"
#import "FileBrowserViewController.h"
#import "FileActivityViewController.h"

@interface SandboxViewController ()

@property (weak) IBOutlet NSTabView *tabView;


@end

@implementation SandboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContent];
}

- (void)loadContent {
    NSTabViewItem * fsItem = [[NSTabViewItem alloc] init];
    FileBrowserViewController *fsVC = [[FileBrowserViewController alloc] init];
    fsVC.container = self;
    fsItem.viewController = fsVC;
    fsItem.label = @"File System";
    fsVC.context = self.context;
    NSTabViewItem * activityItem = [[NSTabViewItem alloc] init];
    FileActivityViewController *activityVC = [[FileActivityViewController alloc] init];
    activityVC.container = self;
    activityItem.viewController = activityVC;
    activityItem.label = @"Activity";
    activityVC.context = self.context;
    [self.tabView addTabViewItem:fsItem];
    [self.tabView addTabViewItem:activityItem];
}

- (void)switchToActivityMode {
    [self.tabView selectTabViewItemAtIndex:1];
}

- (void)switchToTreeMode {
    [self.tabView selectTabViewItemAtIndex:0];
}

@end
