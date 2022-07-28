//
//  ViewGestureRecognizerViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewGestureRecognizerViewController.h"
#import "ViewAttributeHeader.h"
#import "ViewAttributeCell.h"
#import "ViewAttributeNameCell.h"
#import "ViewTextAttributeCell.h"
#import "ViewFrameAttributeCell.h"
#import "ViewColorAttributeCell.h"
#import "ViewAutoresizeAttributeCell.h"
#import "ViewEditableTextAttrCell.h"
#import "ViewImageViewAttrCell.h"
#import "ViewPopupAttributeCell.h"
#import "ViewSliderAttributeCell.h"
#import "ViewStepperAttributeCell.h"
#import "ViewBooleanAttributeCell.h"
#import "ViewSelectAttributeCell.h"
#import "ViewValueAttributeCell.h"
#import "ViewFontAttributeCell.h"
#import "ViewAttriWebNaviCell.h"
#import "ViewInsetsAttributeCell.h"


@interface ViewGestureRecognizerViewController ()<NSTableViewDataSource, NSTableViewDelegate, ViewAttributeCellDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *nameColumn;
@property (weak) IBOutlet NSTableColumn *contentColumn;
@property (weak) IBOutlet NSView *titleLayout;

@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSView *topLineView;


@property (nonatomic, strong) NSArray *rowList;

@end

@implementation ViewGestureRecognizerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self cookData];
    [self updateUI];
}

- (void)setupAfterXib {
//    self.view.wantsLayer = YES;
//    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
//    self.titleLabel.backgroundColor = [NSColor whiteColor];
    self.topLineView.wantsLayer = YES;
    self.topLineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    NSArray *cells = @[
                       [ViewAttributeHeader class],
                       [ViewAttributeNameCell class],
                       [ViewTextAttributeCell class],
                       [ViewEditableTextAttrCell class],
                       [ViewFrameAttributeCell class],
                       [ViewColorAttributeCell class],
                       [ViewAutoresizeAttributeCell class],
                       [ViewImageViewAttrCell class],
                       [ViewPopupAttributeCell class],
                       [ViewSelectAttributeCell class],
                       [ViewSliderAttributeCell class],
                       [ViewStepperAttributeCell class],
                       [ViewBooleanAttributeCell class],
                       [ViewValueAttributeCell class],
                       [ViewFontAttributeCell class],
                       [ViewAttriWebNaviCell class],
                       [ViewInsetsAttributeCell class],
                       ];
    for (Class clazz in cells) {
        NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass(clazz) bundle:nil];
        [self.tableView registerNib:nib forIdentifier:NSStringFromClass(clazz)];
    }
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.rowHeight = 32.0f;
    self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
}

- (void)cookData {
    NSArray *list = [self.viewAttribute getGestureRecognizerItemList:self.index];
    self.rowList = list;
}

- (void)updateUI {
    [self.tableView reloadData];
    self.titleLabel.stringValue = self.name;
}

#pragma mark -----------------   cell delegate   ----------------

//数据更新
- (void)valueUpdateRequest: (ViewAttributeCell *)cell value: (id)value info: (NSDictionary *)info {
    NSInteger row = [self.tableView rowForView:cell];
    if(row == NSNotFound || row <0 || row >self.rowList.count-1) {
        return;
    }
    ADHAttrItem *item = self.rowList[row];
    if(self.updationBlock) {
        self.updationBlock(item.key, value, info);
    }
}

#pragma mark -----------------   table view   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.rowList.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat height = 0;
    id rowData = self.rowList[row];
    ADHAttrItem *item = rowData;
    CGFloat keyHeight = [ViewAttributeNameCell heightForData:item.name contentWidth:self.nameColumn.width];
    id value = [self.viewAttribute getGestureRecognzierAttrValue:item index:self.index];
    Class clazz = [self attributeCellForType:item.type];
    CGFloat valueHeight = [clazz heightForData:value contentWidth:self.contentColumn.width];
    height = MAX(keyHeight, valueHeight);
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView * view = nil;
    id rowData = self.rowList[row];
    ADHAttrItem *item = rowData;
    if(tableColumn == self.nameColumn) {
        ViewAttributeNameCell *nameCell = [tableView makeViewWithIdentifier:NSStringFromClass([ViewAttributeNameCell class]) owner:nil];
        [nameCell setData:item.name contentWidth:tableColumn.width];
        nameCell.contextVC = self;
        view = nameCell;
    }else if(tableColumn == self.contentColumn) {
        ADHAttribute *attribute = item.attribute;
        id value = [self.viewAttribute getGestureRecognzierAttrValue:item index:self.index];
        Class clazz = [self attributeCellForType:item.type];
        ViewAttributeCell *valueCell = [tableView makeViewWithIdentifier:NSStringFromClass(clazz) owner:nil];
        valueCell.item = item;
        valueCell.attribute = attribute;
        [valueCell setData:value contentWidth:tableColumn.width];
        valueCell.delegate = self;
        valueCell.contextVC = self;
        view = valueCell;
    }
    return view;
}

#pragma mark -----------------   attribute   ----------------

- (Class)attributeCellForType: (ADHAttrType)type {
    Class clazz = nil;
    switch (type) {
        case ADHAttrTypeText:
            clazz = [ViewTextAttributeCell class];
            break;
        case ADHAttrTypeEditText:
            clazz = [ViewEditableTextAttrCell class];
            break;
        case ADHAttrTypeFrame:
            clazz = [ViewFrameAttributeCell class];
            break;
        case ADHAttrTypeColor:
            clazz = [ViewColorAttributeCell class];
            break;
        case ADHAttrTypeAutoresizing:
            clazz = [ViewAutoresizeAttributeCell class];
            break;
        case ADHAttrTypeImage:
            clazz = [ViewImageViewAttrCell class];
            break;
        case ADHAttrTypePopup:
            clazz = [ViewPopupAttributeCell class];
            break;
        case ADHAttrTypeSelect:
            clazz = [ViewSelectAttributeCell class];
            break;
        case ADHAttrTypeSlider:
            clazz = [ViewSliderAttributeCell class];
            break;
        case ADHAttrTypeStepper:
            clazz = [ViewStepperAttributeCell class];
            break;
        case ADHAttrTypeBoolean:
            clazz = [ViewBooleanAttributeCell class];
            break;
        case ADHAttrTypeValue:
            clazz = [ViewValueAttributeCell class];
            break;
        case ADHAttrTypeFont:
            clazz = [ViewFontAttributeCell class];
            break;
        case ADHAttrTypeWebNavi:
            clazz = [ViewAttriWebNaviCell class];
            break;
        case ADHAttrTypeInsets:
            clazz = [ViewInsetsAttributeCell class];
            break;
        default:
            break;
    }
    return clazz;
}

- (IBAction)closeButtonPressed:(id)sender {
    [self.presentingViewController dismissViewController:self];
}

@end
