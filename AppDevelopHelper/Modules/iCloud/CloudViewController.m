//
//  CloudViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/10/11.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "CloudViewController.h"
#import "CloudDocumentsViewController.h"
#import "CloudUserDefaultsViewController.h"

@interface CloudViewController ()

@property (weak) IBOutlet NSView *lineView;

@property (weak) IBOutlet NSSegmentedControl *segmentControl;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSView *documentView;
@property (weak) IBOutlet NSView *userdefaultsView;
@property (weak) IBOutlet NSView *actionLayout;
@property (nonatomic, strong) CloudDocumentsViewController *documentVC;
@property (nonatomic, strong) CloudUserDefaultsViewController *userdefaultsVC;

@end

@implementation CloudViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self loadContent];
    [self initUI];
}

- (void)setupAfterXib {
    self.lineView.wantsLayer = YES;
    self.actionLayout.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    self.actionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
}

- (void)loadContent {
    //document
    CloudDocumentsViewController *documentVC = [[CloudDocumentsViewController alloc] init];
    documentVC.context = self.context;
    NSView *docView = documentVC.view;
    docView.frame = self.documentView.bounds;
    docView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.documentView addSubview:docView];
    self.documentVC = documentVC;
    //userdefaults
    CloudUserDefaultsViewController *userdefaultsVC = [[CloudUserDefaultsViewController alloc] init];
    userdefaultsVC.context = self.context;
    NSView *udView = userdefaultsVC.view;
    udView.frame = self.userdefaultsView.bounds;
    udView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.userdefaultsView addSubview:udView];
    self.userdefaultsVC = userdefaultsVC;
}

- (void)initUI {
    self.segmentControl.selectedSegment = 0;
    [self.tabView selectTabViewItemAtIndex:0];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    self.segmentControl.left = (self.segmentControl.superview.width - self.segmentControl.width)/2.0f;
}

- (IBAction)segmentControlValueChanged:(id)sender {
    [self.tabView selectTabViewItemAtIndex:self.segmentControl.selectedSegment];
}



@end
