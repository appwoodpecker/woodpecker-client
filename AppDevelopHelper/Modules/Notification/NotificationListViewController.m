//
//  NotificationViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/2/13.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationListViewController.h"
#import "NotificationInfoViewController.h"
#import "ADHNotificationItem.h"
#import "NotificationCellItem.h"
#import "NotificationCell.h"
#import "NotificationDetailViewController.h"
#import "NotificationActionService.h"
#import "MacOrganizer.h"


static CGFloat const kColumnFlexibleMinUnitWidth = 200.0f;

@interface NotificationListViewController ()<NSTableViewDelegate, NSTableViewDataSource,ADHBaseCellDelegate>

@property (weak) IBOutlet NSScrollView *tableScrollView;

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSArray *columnList;
@property (nonatomic, strong) NSMutableArray<NotificationCellItem *> *itemList;

@end

@implementation NotificationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initialValues];
    [self initialUI];
    if(self.bLocal) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedNotification:) name:kNotificationServiceNotificationReceived object:nil];
    }
}

- (void)setupAfterXib
{
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([NotificationCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([NotificationCell class])];
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask;
    self.tableView.intercellSpacing = NSZeroSize;
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.columnAutoresizingStyle = NSTableViewNoColumnAutoresizing;
    self.tableView.rowHeight = 28.0f;
    if(self.refreshButton) {
        self.refreshButton.target = self;
        self.refreshButton.action = @selector(refreshButtonPressed:);
    }
}

- (void)initialValues
{
    self.itemList = [NSMutableArray array];
    if(!self.bLocal) {
        self.columnList = @[
                            @{
                                @"name" : @"Index",
                                @"key" : @"Index",
                                @"width" : @80,
                                @"align-center" : @"1",
                                },
                            @{
                                @"name" : @"Date",
                                @"key" : @"Date",
                                @"width" : @156,
                                },
                            @{
                                @"name" : @"Title",
                                @"key" : @"Title",
                                @"flexible-width" : @1.2,
                                },
                            @{
                                @"name" : @"User Info",
                                @"key" : @"UserInfo",
                                @"flexible-width" : @1,
                                },
                            @{
                                @"name" : @"Identifier",
                                @"key" : @"Identifier",
                                @"width" : @200,
                                },
                            @{
                                @"name" : @"Action Identifier",
                                @"key" : @"Action Identifier",
                                @"width" : @320,
                                },
                            @{
                                @"name" : @"Trigger",
                                @"key" : @"Trigger",
                                @"width" : @190,
                                },
                            @{
                                @"name" : @"Source",
                                @"key" : @"Source",
                                @"width" : @240,
                                },
                            ];
    }else {
        self.columnList = @[
                            @{
                                @"name" : @"Index",
                                @"key" : @"Index",
                                @"width" : @80,
                                @"align-center" : @"1",
                                },
                            @{
                                @"name" : @"Title",
                                @"key" : @"Title",
                                @"flexible-width" : @1,
                                },
                            //类型
                            @{
                                @"name" : @"Trigger",
                                @"key" : @"Trigger",
                                @"width" : @190,
                                },
                            //Fire Date
                            @{
                                @"name" : @"Fire Date",
                                @"key" : @"FireDate",
                                @"width" : @156,
                                },
                            //是否重复
                            @{
                                @"name" : @"Repeat",
                                @"key" : @"Repeat",
                                @"width" : @100,
                                },
                            @{
                                @"name" : @"User Info",
                                @"key" : @"UserInfo",
                                @"flexible-width" : @1,
                                },
                            @{
                                @"name" : @"Identifier",
                                @"key" : @"Identifier",
                                @"width" : @200,
                                },
                            ];
    }
}

- (void)initialUI {
    [self setupColumn];
}

- (void)setupColumn
{
    NSArray *columns = [self.tableView.tableColumns mutableCopy];
    for (NSTableColumn * column in columns) {
        [self.tableView removeTableColumn:column];
    }
    for (NSDictionary * data in self.columnList) {
        NSString * name = data[@"name"];
        NSTableColumn * column = [[NSTableColumn alloc] init];
        column.identifier = name;
        NSString * title = name;
        column.title = title;
        column.minWidth = 60.0f;
        if(data[@"align-center"]) {
            column.headerCell.alignment = NSTextAlignmentCenter;
        }
        [self.tableView addTableColumn:column];
    }
    [self updateColumnSize];
}

- (void)updateColumnSize
{
    CGFloat contentWidth = self.tableView.frame.size.width;
    CGFloat totalFixWidth = 0;
    float flexibleUnits = 0;
    for (NSDictionary * columnData in self.columnList) {
        if(columnData[@"width"]){
            CGFloat fixWidth = [columnData[@"width"] floatValue];
            totalFixWidth += fixWidth;
        }else if(columnData[@"flexible-width"]){
            float flexibleUnit = [columnData[@"flexible-width"] floatValue];
            flexibleUnits += flexibleUnit;
        }
    }
    CGFloat flexibleWidth = contentWidth - totalFixWidth;
    CGFloat unitWidth = (flexibleWidth /flexibleUnits);
    unitWidth = MAX(unitWidth, kColumnFlexibleMinUnitWidth);
    
    NSArray *columns = [self.tableView.tableColumns mutableCopy];
    for (NSInteger index=0;index<columns.count;index++) {
        NSTableColumn * column = columns[index];
        NSDictionary * columnData = self.columnList[index];
        if(columnData[@"width"]){
            column.width = [columnData[@"width"] floatValue];
        }else if(columnData[@"flexible-width"]){
            float units = [columnData[@"flexible-width"] floatValue];
            column.width = units * unitWidth;
        }
    }
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    [self updateColumnSize];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    if(self.bLocal) {
        [self loadLocalContent];
    }
}

- (void)loadLocalContent
{
    if(!self.context.isConnected) return;
    __weak typeof(self) wself = self;
    [self.refreshButton showHud];
    [self.apiClient requestWithService:@"adh.notification" action:@"localNotificatioins" onSuccess:^(NSDictionary *body, NSData *payload) {
        NSArray * dataList = body[@"list"];
        NSMutableArray * itemList = [NSMutableArray array];
        for (NSInteger i=0;i<dataList.count;i++) {
            NSDictionary * data = dataList[i];
            ADHNotificationItem * item = [ADHNotificationItem itemWithData:data];
            NotificationCellItem *cellItem = [[NotificationCellItem alloc] init];
            cellItem.item = item;
            cellItem.unread = NO;
            [itemList addObject:cellItem];
        }
        wself.itemList = itemList;
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

- (void)updateContentUI
{
    [self.tableView reloadData];
}

#pragma mark -----------------   tableview datasource & delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.itemList.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NotificationCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([NotificationCell class]) owner:nil];
    NotificationCellItem *cellItem = self.itemList[row];
    NSInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];
    NSDictionary * columnData = self.columnList[columnIndex];
    NSString * key = columnData[@"key"];
    cellItem.index = row+1;
    [cell setItem:cellItem key:key];
    cell.delegate = self;
    return cell;
}

- (void)cellClicked:(ADHBaseCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    NotificationCellItem *cellItem = self.itemList[row];
    if(cellItem.unread) {
        cellItem.unread = NO;
        [self reloadRow:row];
    }
}

- (void)cellDoubleClicked: (ADHBaseCell *)cell
{
    NSInteger row = [self.tableView rowForView:cell];
    NotificationCellItem *cellItem = self.itemList[row];
    ADHNotificationItem * item = cellItem.item;
    NotificationDetailViewController * detailVC = [[NotificationDetailViewController alloc] init];
    detailVC.bLocal = self.bLocal;
    detailVC.title = @"Detail";
    [self presentViewControllerAsModalWindow:detailVC];
    [detailVC setData:item];
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point {
    NSInteger row = [self.tableView rowForView:cell];
    if(row < 0) return;
    NotificationCellItem * cellItem = self.itemList[row];
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //detail
    NSMenuItem * detailMenu = [[NSMenuItem alloc] initWithTitle:@"Detail" action:@selector(detailMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    detailMenu.target = self;
    detailMenu.representedObject = cellItem;
    [menu addItem:detailMenu];
    if(!self.bLocal) {
        //clear
        NSMenuItem * clearMenu = [[NSMenuItem alloc] initWithTitle:@"Clear" action:@selector(clearMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        clearMenu.target = self;
        clearMenu.representedObject = cellItem;
        [menu addItem:clearMenu];
        //clear all
        NSMenuItem * clearAllMenu = [[NSMenuItem alloc] initWithTitle:@"Clear All" action:@selector(clearMenuAllSelected:) keyEquivalent:adhvf_const_emptystr()];
        clearAllMenu.target = self;
        clearAllMenu.representedObject = cellItem;
        [menu addItem:clearAllMenu];
        //clear others
        NSMenuItem * clearOtherMenu = [[NSMenuItem alloc] initWithTitle:@"Clear Others" action:@selector(clearOthersMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        clearOtherMenu.target = self;
        clearOtherMenu.representedObject = cellItem;
        [menu addItem:clearOtherMenu];
    }else {
        NSString *identifier = cellItem.item.identifier;
        if(identifier) {
            //remove
            NSMenuItem * removeItem = [[NSMenuItem alloc] initWithTitle:@"Remove" action:@selector(removeMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
            removeItem.target = self;
            removeItem.representedObject = cellItem;
            [menu addItem:removeItem];
        }
        //remove all
        NSMenuItem * removeAllItem = [[NSMenuItem alloc] initWithTitle:@"Remove All" action:@selector(removeAllMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        removeAllItem.target = self;
        removeAllItem.representedObject = cellItem;
        [menu addItem:removeAllItem];
    }
    [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
}

- (void)detailMenuSelected: (NSMenuItem *)menu {
    NotificationCellItem * cellItem = menu.representedObject;
    ADHNotificationItem * item = cellItem.item;
    NotificationDetailViewController * detailVC = [[NotificationDetailViewController alloc] init];
    detailVC.bLocal = self.bLocal;
    detailVC.title = @"Detail";
    [self presentViewControllerAsModalWindow:detailVC];
    [detailVC setData:item];
}

- (void)clearMenuAllSelected: (NSMenuItem *)menu {
    [self.itemList removeAllObjects];
    [self.tableView reloadData];
}

- (void)clearMenuSelected: (NSMenuItem *)menu {
    NotificationCellItem * cellItem = menu.representedObject;
    [self.itemList removeObject:cellItem];
    [self.tableView reloadData];
}

- (void)clearOthersMenuSelected: (NSMenuItem *)menu {
    NotificationCellItem * cellItem = menu.representedObject;
    [self.itemList removeAllObjects];
    [self.itemList addObject:cellItem];
    [self.tableView reloadData];
}

- (void)reloadRow: (NSInteger)row {
    NSIndexSet *rowSet = [NSIndexSet indexSetWithIndex:row];
    NSRange columnRange = NSMakeRange(0, self.tableView.tableColumns.count);
    NSIndexSet *columnSets = [NSIndexSet indexSetWithIndexesInRange:columnRange];
    [self.tableView reloadDataForRowIndexes:rowSet columnIndexes:columnSets];
}

//remove this local notifications
- (void)removeMenuSelected: (NSMenuItem *)menu {
    NotificationCellItem * cellItem = menu.representedObject;
    ADHNotificationItem *item = cellItem.item;
    NSString *requestId = item.identifier;
    if(!requestId) {
        return;
    }
    NSDictionary *userInfo = @{
                               @"identifier" : requestId,
                               };
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.notification" action:@"remove" body:userInfo onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself loadLocalContent];
    }onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

//remove all local notifications
- (void)removeAllMenuSelected: (NSMenuItem *)menu {
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.notification" action:@"remove" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself loadLocalContent];
    }onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (void)onReceivedNotification: (NSNotification *)noti {
    AppContext *context = noti.userInfo[@"context"];
    if(context && context != self.context) {
        //不为当前context
        return;
    }
    NSArray<ADHNotificationItem *> * itemList = noti.userInfo[@"list"];
    NSInteger count = self.itemList.count;
    for (NSInteger i=0;i<itemList.count;i++) {
        ADHNotificationItem * item = itemList[i];
        NotificationCellItem *cellItem = [[NotificationCellItem alloc] init];
        cellItem.item = item;
        cellItem.index = count +i+1;
        cellItem.unread = YES;
        [self.itemList addObject:cellItem];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateContentUI];
    });
}

- (void)refreshButtonPressed: (NSButton *)button {
    if(![self doCheckConnectionRoutine]) return;
    if(self.bLocal) {
        [self loadLocalContent];
    }
}

- (void)onWorkAppUpdate {
    if(self.itemList.count == 0){
        [self loadLocalContent];
    }
}

@end
