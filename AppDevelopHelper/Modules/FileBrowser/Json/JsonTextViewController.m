//
//  JsonTextViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/5/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "JsonTextViewController.h"
#import "ADHKVItem.h"
#import "JsonKVCell.h"
#import "NetworkService.h"
#import "NSData+Compress.h"
#import "DeviceUtil.h"

@interface JsonTextViewController ()<NSOutlineViewDelegate,NSOutlineViewDataSource,ADHBaseCellDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSTableColumn *tableColumn;

@property (nonatomic, strong) ADHKVItem *rootKVItem;

@end

@implementation JsonTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self loadContent];
}

- (void)setupAfterXib {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([JsonKVCell class]) bundle:nil];
    [self.outlineView registerNib:nib forIdentifier:NSStringFromClass([JsonKVCell class])];
    self.outlineView.intercellSpacing = NSZeroSize;
    //default 16.0f
    self.outlineView.indentationPerLevel = 20.0f;
    self.outlineView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    self.tableColumn.maxWidth = self.outlineView.width;
    self.tableColumn.width = self.outlineView.width;
    [self.outlineView reloadData];
}

- (void)loadContent
{
    //检查本地是否存在，如果不存在加载
    BOOL shouldLoad = NO;
    if(self.filePath) {
        shouldLoad = NO;
    }else if(self.transaction) {
        if(self.bRequestBody) {
            shouldLoad = NO;
        }else {
            BOOL fileExists = [[NetworkService serviceWithContext:self.context] responseBodyExistsForTransaction:self.transaction];
            if(self.transaction.receivedDataLength > 0 && !fileExists){
                shouldLoad = YES;
            }
            if(fileExists) {
                self.filePath = [[NetworkService serviceWithContext:self.context] getTransactionResponseBodyPath:self.transaction];
            }
        }
    }
    //preview or load
    if(shouldLoad){
        [self dataRequest];
    }else{
        [self doPreviewResponseBody];
    }
}

- (void)doPreviewResponseBody
{
    NSString * content = nil;
    if(self.filePath) {
        NSError *error = nil;
        NSStringEncoding encoding = 0;
        content = [[NSString alloc] initWithContentsOfFile:self.filePath usedEncoding:&encoding error:&error];
    }else if(self.bRequestBody) {
        NSData *body = self.transaction.requestBody;
        NSString *bodyEncoding = [self.transaction requestContentEncoding];
        body = [body inflateWithEncodeName:bodyEncoding];
        content = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    }
    id container = [content adh_jsonObject];
    if([container isKindOfClass:[NSDictionary class]] || [container isKindOfClass:[NSArray class]]) {
        ADHKVItem *kvItem = [ADHKVItem kvItemWithData:container];
        self.rootKVItem = kvItem;
    }
    [self.outlineView reloadData];
    if(self.rootKVItem) {
        [self.outlineView expandItem:self.rootKVItem];
    }
}

- (void)dataRequest
{
    [self.view showHud];
    __weak typeof(self) wself = self;
    [[NetworkService serviceWithContext:self.context] downloadResponseBody:self.transaction onCompletion:^(NSString *path) {
        [wself.view hideHud];
        self.filePath = [[NetworkService serviceWithContext:self.context] getTransactionResponseBodyPath:self.transaction];
        [wself doPreviewResponseBody];
    } onError:^(NSError * error) {
        [wself.view hideHud];
    }];
}

#pragma mark -----------------   cell delegate   ----------------

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point {
    NSInteger row = [self.outlineView rowForView:cell];
    if(row < 0) return;
    ADHKVItem *kvItem = [self.outlineView itemAtRow:row];
    if(!kvItem) return;
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //copy name
    if(kvItem.keyName.length > 0 && kvItem.parent) {
        NSMenuItem * keyItem = [[NSMenuItem alloc] initWithTitle:@"Copy Key" action:@selector(copyKeyMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        keyItem.target = self;
        keyItem.representedObject = kvItem;
        [menu addItem:keyItem];
    }
    
    //copy value
    if(!kvItem.isContainer && kvItem.type != ADHKVItemTypeData) {
        NSMenuItem * valueItem = [[NSMenuItem alloc] initWithTitle:@"Copy Value" action:@selector(copyValueMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        valueItem.target = self;
        valueItem.representedObject = kvItem;
        [menu addItem:valueItem];
    }
    if(menu.itemArray.count > 0) {
        [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
    }
}

- (void)cellDoubleClicked:(ADHBaseCell *)cell {
    NSInteger row = [self.outlineView rowForView:cell];
    if(row < 0) return;
    ADHKVItem *kvItem = [self.outlineView itemAtRow:row];
    if(!kvItem) return;
    if(kvItem.isContainer) {
        //extand
        if(![self.outlineView isItemExpanded:kvItem]){
            [self.outlineView expandItem:kvItem expandChildren:NO];
        }else{
            [self.outlineView collapseItem:kvItem collapseChildren:NO];
        }
    }
}

- (void)copyKeyMenuSelected: (NSMenuItem *)menu {
    ADHKVItem *kvItem = menu.representedObject;
    if(kvItem.keyName.length > 0) {
        [DeviceUtil pasteText:kvItem.keyName];
    }
}

- (void)copyValueMenuSelected: (NSMenuItem *)menu {
    ADHKVItem *kvItem = menu.representedObject;
    if(kvItem.stringValue.length > 0) {
        [DeviceUtil pasteText:kvItem.stringValue];
    }
}

#pragma mark -----------------  OutlineView DataSource & Delegate   ----------------

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    NSInteger count = 0;
    ADHKVItem * kvItem = item;
    if(!kvItem){
        if(self.rootKVItem) {
            count = 1;
        }
    }else {
        if([kvItem isContainer]){
            count = kvItem.children.count;
        }
    }
    return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    ADHKVItem * childItem = nil;
    ADHKVItem * kvItem = item;
    if(!kvItem){
        if(self.rootKVItem) {
            childItem = self.rootKVItem;
        }
    }else {
        if([kvItem isContainer]){
            childItem = kvItem.children[index];
        }
    }
    return childItem;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    BOOL expandable = NO;
    ADHKVItem * kvItem = item;
    if(!kvItem){
        if(self.rootKVItem) {
            expandable = YES;
        }
    }else {
        expandable = [kvItem isContainer];
    }
    return expandable;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    JsonKVCell * cell = [outlineView makeViewWithIdentifier:NSStringFromClass([JsonKVCell class]) owner:nil];
    ADHKVItem * kvItem = (ADHKVItem *)item;
    CGFloat level = [outlineView levelForItem:kvItem];
    CGFloat indentWidth = [self markerWidth] + level * [outlineView indentationPerLevel];
    CGFloat contentWidth = tableColumn.width - indentWidth;
    [cell setData:kvItem contentWidth:contentWidth];
    cell.delegate = self;
    return cell;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    CGFloat level = [outlineView levelForItem:item];
    CGFloat indentWidth = [self markerWidth] + level * [outlineView indentationPerLevel];
    CGFloat contentWidth = self.tableColumn.width - indentWidth;
    CGFloat rowHeight = [JsonKVCell heightForData:item contentWidth:contentWidth];
    return rowHeight;
}

//row最前面的level intendent marker宽度
- (CGFloat)markerWidth {
    return 16.0f;
}

@end











