//
//  DeviceInfoViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/3/16.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "DeviceInfoViewController.h"
#import "MacOrganizer.h"

@interface DeviceInfoViewController ()<NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSButton *refreshButton;

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *nameColumn;
@property (weak) IBOutlet NSTableColumn *valueColumn;
@property (nonatomic, strong) NSArray *contentList;


@end

@implementation DeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self loadContent];
}

- (void)setupAfterXib {
    self.tableView.rowHeight = 22.0f;
    self.view.wantsLayer = YES;
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

- (void)loadContent {
    if(!self.context.isConnected){
        return;
    }
    __weak typeof(self) wself = self;
    [self.refreshButton showHud];
    [self.apiClient requestWithService:@"adh.device" action:@"info" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself updateContent:body];
        [wself.refreshButton hideHud];
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (void)updateContent: (NSDictionary *)body
{
    NSArray * list = body[@"list"];
    self.contentList = list;
    [self.tableView reloadData];
}

#pragma mark -----------------   tableview datasource & delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.contentList.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView * cellView = nil;
    NSDictionary *data = self.contentList[row];
    if(tableColumn == self.nameColumn){
        cellView = (NSTableCellView *)[tableView makeViewWithIdentifier:@"nameCellId" owner:nil];
        NSString *name = adhvf_safestringfy(data[@"name"]);
        NSString *tip = adhvf_safestringfy(data[@"tip"]);
        cellView.textField.stringValue = name;
        if(tip.length > 0) {
            cellView.textField.toolTip = tip;
        }
    }else if(tableColumn == self.valueColumn){
        cellView = (NSTableCellView *)[tableView makeViewWithIdentifier:@"valueCellId" owner:nil];
        NSString *value = adhvf_safestringfy(data[@"value"]);
        cellView.textField.stringValue = value;
    }
    return cellView;
}

- (IBAction)refreshButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    [self loadContent];
}

- (void)onWorkAppUpdate
{
    if(!self.contentList){
        [self loadContent];
    }
}


@end





















