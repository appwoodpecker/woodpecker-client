//
//  NotificationInfoViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/2/13.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationInfoViewController.h"
#import "NotificationInfoItemCell.h"
#import "MacOrganizer.h"

@interface NotificationInfoViewController ()<NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *keyColumn;
@property (weak) IBOutlet NSTableColumn *contentColumn;

@property (nonatomic) NSDictionary * infoData;
@property (nonatomic, strong) NSArray *itemList;

@end

@implementation NotificationInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self loadContent];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
}

- (void)setupAfterXib {
    NSNib *cellNib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([NotificationInfoItemCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forIdentifier:NSStringFromClass([NotificationInfoItemCell class])];
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask;
    self.tableView.intercellSpacing = NSZeroSize;
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask;
    self.tableView.rowHeight = 40.0f;
    if(self.refreshButton) {
        self.refreshButton.target = self;
        self.refreshButton.action = @selector(refreshButtonPressed:);
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self loadContent];
}

- (void)loadContent
{
    if(!self.context.isConnected) return;
    [self.refreshButton showHud];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.notification" action:@"info" onSuccess:^(NSDictionary *body, NSData *payload) {
        wself.infoData = body;
        [wself cookList];
        [wself updateContentUI];
        [wself.refreshButton hideHud];
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
        if(error.code == kADHApiErrorCodeVersionDismatch) {
            NSString *tip = @"Sorry, Notification only support iOS 10+, MacOS 10.14+";
            [wself.view showTip:tip actionText:@"Help" actionBlock:^{
                [UrlUtil openExternalLocalizedUrl:@"web_tool_notification"];
            }];
        }
    }];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.itemList.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView *resultView = nil;
    NSDictionary *data = self.itemList[row];
    if(tableColumn == self.keyColumn) {
        NSTableCellView * keyCell = nil;
        static NSString * const kNotificationInfoKeyCellId = @"NotificationInfoKeyCellId";
        keyCell = [tableView makeViewWithIdentifier:kNotificationInfoKeyCellId owner:nil];
        NSString * title = data[@"title"];
        keyCell.textField.stringValue = title;
        resultView = keyCell;
    }else {
        NotificationInfoItemCell *itemCell = [tableView makeViewWithIdentifier:NSStringFromClass([NotificationInfoItemCell class]) owner:nil];
        [itemCell setData:data];
        resultView = itemCell;
    }
    return resultView;
}

- (void)cookList {
    NSArray * settingList = self.infoData[@"settingList"];
    NSDictionary * apsData = self.infoData[@"apsToken"];
    NSMutableArray *itemList = [NSMutableArray array];
    [itemList addObject:apsData];
    [itemList addObjectsFromArray:settingList];
    self.itemList = itemList;
}

- (void)updateContentUI {
    [self.tableView reloadData];
}

- (void)refreshButtonPressed: (NSButton *)button {
    if(![self doCheckConnectionRoutine]) return;
    [self loadContent];
}

- (void)onWorkAppUpdate {
    if(!self.infoData) {
        [self loadContent];
    }
}

@end
