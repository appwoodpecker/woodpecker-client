//
//  StateMasterViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/24.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "StateMasterViewController.h"
#import "StateSandboxViewController.h"
#import "StateUserDefaultsViewController.h"


@interface StateMasterViewController ()

@property (nonatomic, strong) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSSegmentedControl *segmentControl;
@property (weak) IBOutlet NSView *lineView;


@property (nonatomic, strong) StateSandboxViewController *sandboxVC;
@property (nonatomic, strong) StateUserDefaultsViewController *userdefaultsVC;

@end

@implementation StateMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self addNotification];
    [self loadContent];
    [self initUI];
}

- (void)setupUI {
    self.actionLayout.wantsLayer = YES;
    self.lineView.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)updateAppearanceUI {
    self.actionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    self.view.window.title = self.stateItem.title;
    self.segmentControl.left = (self.segmentControl.superview.width - self.segmentControl.width)/2.0f;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)loadContent {
    //document
    StateSandboxViewController *sandboxVC = [[StateSandboxViewController alloc] init];
    sandboxVC.context = self.context;
    sandboxVC.stateItem = self.stateItem;
    NSTabViewItem *sandboxItem = [NSTabViewItem tabViewItemWithViewController:sandboxVC];
    [self.tabView addTabViewItem:sandboxItem];
    self.sandboxVC = sandboxVC;
    //userdefaults
    StateUserDefaultsViewController *userdefaultsVC = [[StateUserDefaultsViewController alloc] init];
    userdefaultsVC.context = self.context;
    userdefaultsVC.stateItem = self.stateItem;
    NSTabViewItem *userdefaultsItem = [NSTabViewItem tabViewItemWithViewController:userdefaultsVC];
    [self.tabView addTabViewItem:userdefaultsItem];
    self.userdefaultsVC = userdefaultsVC;
}

- (void)initUI {
    self.segmentControl.selectedSegment = self.tabIndex;
    [self.tabView selectTabViewItemAtIndex:self.tabIndex];
}

- (IBAction)segmentControlValueChanged:(id)sender {
    [self.tabView selectTabViewItemAtIndex:self.segmentControl.selectedSegment];
}


@end
