//
//  DeviceManageViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/17.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "DeviceManageViewController.h"
#import "DeviceManageCell.h"
#import "MacOrganizer.h"

static NSString *kHeader = @"header";
static NSString *kId = @"id";
static NSString *kIndex = @"index";
static NSString *kIdAllowHeader = @"allow-header";
static NSString *kIdDisallowHeader = @"disallow-header";
static NSString *kIdAllowAdd = @"allow-add";
static NSString *kIdDisallowAdd = @"disallow-add";
static NSString *kIdAllow = @"allow";
static NSString *kIdDisallow = @"disallow";


@interface DeviceManageViewController ()<NSTableViewDelegate, NSTableViewDataSource, DeviceManageCellDelegate>

@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSView *allowHeadView;
@property (nonatomic, strong) IBOutlet NSButton *allowCheckButton;

@property (nonatomic, strong) IBOutlet NSView *allowAddView;
@property (nonatomic, strong) IBOutlet NSTextField *allowTextField;
@property (nonatomic, strong) IBOutlet NSSegmentedControl *allowSegmentControl;

@property (nonatomic, strong) IBOutlet NSView *disallowHeadView;
@property (nonatomic, strong) IBOutlet NSView *disallowAddView;
@property (nonatomic, strong) IBOutlet NSTextField *disallowTextField;
@property (nonatomic, strong) IBOutlet NSSegmentedControl *disallowSegmentControl;

@property (nonatomic, strong) NSArray *allowList;
@property (nonatomic, strong) NSArray *disallowList;
@property (nonatomic, strong) NSArray *rowList;

@end

@implementation DeviceManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValue];
    [self setupUI];
    [self initUI];
}

- (void)initValue {
    [self updateTableContent];
}

- (void)setupUI {
    self.title = @"Device Management";
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([DeviceManageCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([DeviceManageCell class])];
    self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
}

- (void)initUI {
    [self.tableView reloadData];
    self.allowSegmentControl.selectedSegment = 0;
    self.disallowSegmentControl.selectedSegment = 0;
    if(self.allowList.count ==0 && self.disallowList.count == 0) {
        [self.allowTextField becomeFirstResponder];
    }else {
        [self resetInputUI];
    }
    [self updateAllowCheckUI];
}

- (void)updateContent {
    [self updateTableContent];
    [self.tableView reloadData];
}

- (void)updateTableContent {
    NSArray *allowList = [Preference getAllowedDeviceList];
    NSArray *disallowList = [Preference getDisallowedDeviceList];
    self.allowList = allowList;
    self.disallowList = disallowList;
    NSMutableArray *rowList = [NSMutableArray array];
    //allow header
    [rowList addObject:@{
        kId : kIdAllowHeader,
        kHeader : @(YES),
    }];
    //allow list
    for (NSInteger i=0; i<allowList.count; i++) {
        NSDictionary *data = allowList[i];
        NSDictionary *rowData = @{
            @"data" : data,
            kIndex : [NSNumber numberWithInteger:i],
            kId : kIdAllow,
        };
        [rowList addObject:rowData];
    }
    //allow add
    [rowList addObject:@{
        kId : kIdAllowAdd,
    }];
    
    //disallow header
    [rowList addObject:@{
        kId : kIdDisallowHeader,
        kHeader : @(YES),
    }];
    //disallow list
    for (NSInteger i=0; i<disallowList.count; i++) {
        NSDictionary *data = disallowList[i];
        NSDictionary *rowData = @{
            @"data" : data,
            kIndex : [NSNumber numberWithInteger:i],
            kId : kIdDisallow,
        };
        [rowList addObject:rowData];
    }
    //disallow add
    [rowList addObject:@{
        kId : kIdDisallowAdd,
    }];
    self.rowList = rowList;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = self.rowList.count;
    return count;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    NSDictionary *rowData = self.rowList[row];
    BOOL header = [rowData[kHeader] boolValue];
    return header;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat height = 0;
    NSDictionary *rowData = self.rowList[row];
    NSString *rowId = rowData[kId];
    //header
    if([rowId isEqualToString:kIdAllowHeader]) {
        //allow header
        height = self.allowHeadView.height;
    }else if([rowId isEqualToString:kIdDisallowHeader]) {
        //disallow header
        height = self.disallowHeadView.height;
    }else if([rowId isEqualToString:kIdAllowAdd]) {
        //allow add
        height = self.allowAddView.height;
    }else if([rowId isEqualToString:kIdDisallowAdd]) {
        //disallow add
        height = self.disallowAddView.height;
    }else {
        //row
        height = 40.0f;
    }
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView *cell = nil;
    NSInteger columnIndex = [self.tableView.tableColumns indexOfObject:tableColumn];
    NSDictionary *rowData = self.rowList[row];
    NSString *rowId = rowData[kId];
    if(columnIndex == NSNotFound) {
        //header
        if([rowId isEqualToString:kIdAllowHeader]) {
            //allow header
            cell = self.allowHeadView;
        }else if([rowId isEqualToString:kIdDisallowHeader]) {
            //disallow header
            cell = self.disallowHeadView;
        }
    }else {
        if([rowId isEqualToString:kIdAllowAdd]) {
            //allow add
            cell = self.allowAddView;
        }else if([rowId isEqualToString:kIdDisallowAdd]) {
            //disallow add
            cell = self.disallowAddView;
        }else {
            //row
            DeviceManageCell *deviceCell = [tableView makeViewWithIdentifier:NSStringFromClass([DeviceManageCell class]) owner:nil];
            [deviceCell setData:rowData];
            deviceCell.delegate = self;
            cell = deviceCell;
        }
    }
    return cell;
}

- (IBAction)allowAddButtonPressed:(id)sender {
    NSString *name = self.allowTextField.stringValue;
    if(name.length == 0) {
        [self.allowTextField becomeFirstResponder];
        return;
    }
    NSString *type = nil;
    NSInteger value = self.allowSegmentControl.selectedSegment;
    if(value == 1) {
        type = @"c";
    }else {
        type = @"e";
    }
    NSArray *allowList = self.allowList;
    NSMutableArray *resultList = [allowList mutableCopy];
    [resultList addObject:@{
        @"n" : name,
        @"t" : type,
    }];
    [Preference saveAllowedDeviceList:resultList];
    [self updateContent];
    [self resetInputUI];
    [self notifyUpdate];
}

- (IBAction)disallowAddButtonPressed:(id)sender {
    NSString *name = self.disallowTextField.stringValue;
    if(name.length == 0) {
        [self.disallowTextField becomeFirstResponder];
        return;
    }
    NSString *type = nil;
    NSInteger value = self.disallowSegmentControl.selectedSegment;
    if(value == 1) {
        type = @"c";
    }else {
        type = @"e";
    }
    NSArray *allowList = self.disallowList;
    NSMutableArray *resultList = [allowList mutableCopy];
    [resultList addObject:@{
        @"n" : name,
        @"t" : type,
    }];
    [Preference saveDisallowedDeviceList:resultList];
    [self updateContent];
    [self resetInputUI];
    [self notifyUpdate];
}

- (void)resetInputUI {
    self.allowTextField.stringValue = @"";
    self.disallowTextField.stringValue = @"";
    [self.allowTextField resignFirstResponder];
    [self.disallowTextField resignFirstResponder];
    self.allowSegmentControl.selectedSegment = 0;
    self.disallowSegmentControl.selectedSegment = 0;
}

- (void)deviceManageCellDeleteRequest: (DeviceManageCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    NSDictionary *rowData = self.rowList[row];
    NSString *rowId = rowData[kId];
    NSInteger index = [rowData[kIndex] integerValue];
    if([rowId isEqualToString:kIdAllow]) {
        NSMutableArray *resultList = [self.allowList mutableCopy];
        [resultList removeObjectAtIndex:index];
        [Preference saveAllowedDeviceList:resultList];
    }else if([rowId isEqualToString:kIdDisallow]) {
        NSMutableArray *resultList = [self.disallowList mutableCopy];
        [resultList removeObjectAtIndex:index];
        [Preference saveDisallowedDeviceList:resultList];
    }
    [self updateContent];
    [self notifyUpdate];
}

- (IBAction)allowCheckButtonPressed:(id)sender {
    if(self.allowCheckButton.state == NSControlStateValueOn) {
        [Preference setDisallowOtherDevice:YES];
    }else {
        [Preference setDisallowOtherDevice:NO];
    }
    [self updateAllowCheckUI];
    [self notifyUpdate];
}

- (void)updateAllowCheckUI {
    BOOL value = [Preference disallowOtherDevice];
    self.allowCheckButton.state = value;
}

- (void)notifyUpdate {
    MacConnector *connector = MacOrganizer.organizer.connector;
    [connector updateAllowDevice];
}

@end
