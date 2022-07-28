//
//  NotificationViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/6/3.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationListViewController.h"
#import "NotificationInfoViewController.h"

@interface NotificationViewController ()

@property (weak) IBOutlet NSSegmentedControl *segmentControl;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSButton *infoRefreshButton;


@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self initUI];
}

- (void)setupAfterXib {
    [self setupTabItem];
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    [self.infoRefreshButton setTintColor:[Appearance actionImageColor]];
}

- (void)initUI {
    self.segmentControl.selectedSegment = 0;
    [self.tabView selectTabViewItemAtIndex:0];
    [self updateStateUI];
}

- (void)setupTabItem {
    //Local
    {
        NSTabViewItem * localItem = [[NSTabViewItem alloc] init];
        localItem.label = @"Local Notification";
        NotificationListViewController * localVC = [[NotificationListViewController alloc] init];
        localVC.bLocal = YES;
        localVC.refreshButton = self.refreshButton;
        localVC.context = self.context;
        localItem.viewController = localVC;
        [self.tabView addTabViewItem:localItem];
    }
    //Activity
    {
        NSTabViewItem * activityItem = [[NSTabViewItem alloc] init];
        activityItem.label = @"Activity";
        NotificationListViewController * activityVC = [[NotificationListViewController alloc] init];
        activityVC.context = self.context;
        activityItem.viewController = activityVC;
        [self.tabView addTabViewItem:activityItem];
    }
    //Info
    {
        NSTabViewItem * infoItem = [[NSTabViewItem alloc] init];
        infoItem.label = @"Info";
        NotificationInfoViewController * infoVC = [[NotificationInfoViewController alloc] init];
        infoVC.context = self.context;
        infoVC.refreshButton = self.infoRefreshButton;
        infoItem.viewController = infoVC;
        [self.tabView addTabViewItem:infoItem];
    }
}

- (void)viewDidLayout {
    [super viewDidLayout];
    self.segmentControl.left = (self.segmentControl.superview.width - self.segmentControl.width)/2.0f;
}

- (IBAction)segmentControlValueChanged:(id)sender {
    [self.tabView selectTabViewItemAtIndex:self.segmentControl.selectedSegment];
    [self updateStateUI];
}

- (void)updateStateUI {
    self.refreshButton.hidden = (self.segmentControl.selectedSegment != 0);
    self.infoRefreshButton.hidden = (self.segmentControl.selectedSegment != 2);
}

@end
