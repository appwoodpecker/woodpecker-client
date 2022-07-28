//
//  NetworkCookieViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/5/14.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NetworkCookieViewController.h"
#import "NetworkCookieTableAdapter.h"
#import "ADHNetworkCookie.h"
#import "MacOrganizer.h"

@interface NetworkCookieViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSView *actionLayout;

@property (nonatomic, strong) NetworkCookieTableAdapter * adapter;
@property (nonatomic, strong) NSArray<ADHNetworkCookie *> * cookieList;

@end

@implementation NetworkCookieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self setupAdapter];
    [self loadCookie];
    [self addNotification];
}

- (void)setupAfterXib {
    self.tableView.rowHeight = 20.0f;
    self.tableView.gridStyleMask = NSTableViewDashedHorizontalGridLineMask | NSTableViewSolidVerticalGridLineMask;
    self.tableView.intercellSpacing = NSZeroSize;
    self.tableView.columnAutoresizingStyle = NSTableViewNoColumnAutoresizing;
    self.actionLayout.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    self.actionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    NSWindow * window = self.view.window;
    window.title = @"App Cookie";
    NSWindowStyleMask style = window.styleMask;
    style = (style & ~(NSWindowStyleMaskResizable));
    window.styleMask = style;
    
}

- (void)setupAdapter {
    NetworkCookieTableAdapter *adapter = [[NetworkCookieTableAdapter alloc] init];
    [adapter prepareHeader:self.tableView.width];
    [adapter setTableView:self.tableView];
    self.adapter = adapter;
    [self.adapter update];
}

- (void)loadCookie {
    if(!self.context.isConnected){
        return;
    }
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.network" action:@"cookieList" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.refreshButton hideHud];
        NSString *content = body[@"list"];
        [wself updateContent:content];
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
    [self.refreshButton showHud];
}

- (void)updateContent: (NSString *)content {
    NSArray *dataList = [content adh_jsonObject];
    NSMutableArray *cookieList = [NSMutableArray array];
    for (NSDictionary * data in dataList) {
        ADHNetworkCookie *cookie = [ADHNetworkCookie cookieWithData:data];
        [cookieList addObject:cookie];
    }
    //sort by name
    [cookieList sortUsingComparator:^NSComparisonResult(ADHNetworkCookie * obj1, ADHNetworkCookie * obj2) {
        return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
    }];
    self.cookieList = cookieList;
    [self updateContentUI];
}
- (void)updateContentUI {
    [self.adapter setData:self.cookieList];
}

- (IBAction)refreshButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    [self loadCookie];
}

- (void)onWorkAppUpdate {
    [self loadCookie];
}

@end











