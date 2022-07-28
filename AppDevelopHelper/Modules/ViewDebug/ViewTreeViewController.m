//
//  ViewTreeViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewTreeViewController.h"
#import "ViewDebugViewController.h"
#import "ViewTreeCell.h"
#import "ADHViewDebugUtil.h"
#import "DeviceUtil.h"

@interface ViewTreeViewController ()<ADHBaseCellDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource>

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSTableColumn *tableColumn;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSSearchField *searchTextField;
@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSView *bottomActionLayout;
@property (weak) IBOutlet NSView *topLineView;
@property (weak) IBOutlet NSView *bottomLineView;

@property (nonatomic, strong) ADHViewNode *filterViewNode;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL isManualExpand;

@end

@implementation ViewTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self loadContent];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNodeSelectStateUpdate:) name:kViewDebugNodeSelectStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.searchTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.searchTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)setupAfterXib {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([ViewTreeCell class]) bundle:nil];
    [self.outlineView registerNib:nib forIdentifier:NSStringFromClass([ViewTreeCell class])];
    self.outlineView.rowHeight = 22.0f;
    self.topLineView.wantsLayer = YES;
    self.bottomLineView.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)updateAppearanceUI {
    self.topLineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    self.bottomLineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    self.actionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    self.bottomActionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
}

- (void)updateUI {
    [self.outlineView reloadData];
    self.isManualExpand = YES;
    [self.outlineView expandItem:nil expandChildren:YES];
    self.isManualExpand = NO;
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self loadContent];
}

- (void)loadContent {
    if(!self.context.isConnected){
        return;
    }
    [self.refreshButton showHud];
    __weak typeof(self) wself = self;
    [self.context.apiClient requestWithService:@"adh.viewdebug" action:@"view" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.refreshButton hideHud];
        BOOL success = [body[@"success"] boolValue];
        if(success && payload) {
            NSString *serviceAddr = body[@"serviceAddr"];
            wself.domain.serviceAddr = serviceAddr;
            NSString *windowSize = body[@"size"];
            NSArray *values = [windowSize componentsSeparatedByString:@","];
            if(values.count >= 2) {
                CGFloat width = [values[0] floatValue];
                CGFloat height = [values[1] floatValue];
                wself.domain.appWindowSize = CGSizeMake(width, height);
            }
            wself.domain.appWindowScale = [body[@"scale"] floatValue];
            [wself updateNodeScale];
            NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithData:payload];
            ADHViewNode *node = [ADHViewNode nodeWithData:data];
            wself.domain.rootNode = node;
            [wself.domain resetSnapshot];
            [wself updateUI];
            //发出通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kViewDebugRootNodeUpdateNotification object:wself];
            //请求snapshot
            [wself.domain loadSnapshotData];
        }else {
            if(body[@"client"]) {
                [wself showVersionNotSupport];
            }else {
                [wself showErrorWithText:@"load failed"];
            }
        }
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (void)showVersionNotSupport {
    NSString *tip = [NSString stringWithFormat:kLocalized(@"frameworkrequire_tip"),@"1.1.9"];
    [ADHAlert alertWithMessage:kLocalized(@"alert_title") infoText:tip confirmText:kLocalized(@"update") cancelText:kAppLocalized(@"Cancel") comfirmBlock:^{
        [UrlUtil openExternalLocalizedUrl:@"web_usage"];
    } cancelBlock:^{
        
    }];
}

- (void)updateNodeScale {
    NSScreen *screen = self.view.window.screen;
    CGSize screenSize = screen.frame.size;
    CGFloat contentWidth = screenSize.width - 244.0f - 232.0f;
    CGFloat contentHeight = screenSize.height - 100.0f;
    CGFloat appWidth = self.domain.appWindowSize.width;
    CGFloat appHeight = self.domain.appWindowSize.height;
    //size factor
    CGFloat factor = 1.0f;
    //假设base scale时，node显示尺寸和app point大小为1:1，计算时只考虑mac容器尺寸和app尺寸比例即可
    if(contentWidth > 0 && contentHeight > 0 && appWidth > 0 && appHeight > 0) {
        CGFloat scaleFactor = 0.62;
        CGFloat mWidth = contentWidth * scaleFactor;
        CGFloat mHeight = contentHeight * scaleFactor;
        BOOL potraitMode = (appHeight / contentHeight) > (appWidth > contentWidth);
        if(potraitMode) {
            factor = (mHeight/appHeight);
        }else {
            factor = (mWidth/appWidth);
        }
    }
    if(factor > 1.0) {
        factor = 1.0;
    }
    //node scale
    self.domain.nodeScale = factor * kBaseNodeScale;
}

- (void)onNodeSelectStateUpdate: (NSNotification *)noti {
    if(noti.object == self) {
        return;
    }
    ADHViewNode *node = noti.userInfo[@"node"];
    if(node) {
        ADHViewNode *parent = node.parent;
        NSMutableArray *expandList = [NSMutableArray array];
        while (parent != nil) {
            if(![self.outlineView isItemExpanded:parent]) {
                [expandList addObject:parent];
            }
            parent = parent.parent;
        }
        for (NSInteger i=0; i<expandList.count; i++) {
            NSInteger index = expandList.count-1-i;
            ADHViewNode *node = expandList[index];
            [self.outlineView expandItem:node];
        }
        [self.outlineView deselectAll:nil];
        NSInteger row = [self.outlineView rowForItem:node];
        if(row != NSNotFound) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
            [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
        }
    }else {
        [self.outlineView deselectAll:nil];
    }
}

/**
 workApp更新
 */
- (void)onWorkAppUpdate {
    //不存在内容时更新
    if(!self.domain.rootNode){
        [self loadContent];
    }
}

#pragma mark -----------------   cell delegate   ----------------

- (void)cellClicked: (ADHBaseCell *)cell {
    NSInteger row = [self.outlineView rowForView:cell];
    if(row != NSNotFound) {
        ADHViewNode *node = [self.outlineView itemAtRow:row];
        if(node) {
            NSDictionary *info = @{
                                   @"node" : node,
                                   };
            [[NSNotificationCenter defaultCenter] postNotificationName:kViewDebugNodeSelectStateNotification object:self userInfo:info];
        }
    }
}

- (void)cellDoubleClicked: (ADHBaseCell *)cell {
    NSInteger row = [self.outlineView rowForView:cell];
    if(row != NSNotFound) {
        ADHViewNode *node = [self.outlineView itemAtRow:row];
        if(node) {
            //extand
            if(![self.outlineView isItemExpanded:node]){
                [self.outlineView expandItem:node expandChildren:NO];
            }else{
                [self.outlineView collapseItem:node collapseChildren:NO];
            }
        }
    }
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point {
    NSInteger row = [self.outlineView rowForView:cell];
    [self.outlineView deselectAll:nil];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
    ADHViewNode *node = [self.outlineView itemAtRow:row];
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //open in finder
    NSMenuItem * copyMenu = [[NSMenuItem alloc] initWithTitle:@"Copy Name" action:@selector(doCopyName:) keyEquivalent:adhvf_const_emptystr()];
    copyMenu.target = self;
    copyMenu.representedObject = node;
    [menu addItem:copyMenu];
    [menu addItem: [NSMenuItem separatorItem]];
    [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
}

- (void)doCopyName:(NSMenuItem *)menu {
    ADHViewNode *node = menu.representedObject;
    NSString *text = node.className;
    [DeviceUtil pasteText:text];
}

#pragma mark -----------------   search   ----------------

- (void)searchTextDidChange:(NSNotification *)notification {
    NSString * keywords = self.searchTextField.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)searchTextDidEndEditing:(NSNotification *)notification {
    NSString * keywords = self.searchTextField.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)doSearchWithKeywords: (NSString *)keywords {
    if(keywords.length == 0){
        self.isSearching = NO;
        self.filterViewNode = nil;
        [self.outlineView reloadData];
    }else{
        self.isSearching = YES;
        ADHViewNode * filterViewNode = [self.domain searchPreviewTree:self.domain.rootNode withKeywords:keywords];
        self.filterViewNode = filterViewNode;
        [self.outlineView reloadData];
        [self.outlineView expandItem:nil expandChildren:YES];
    }
}

- (ADHViewNode *)viewRootNode {
    ADHViewNode * node = nil;
    if(self.isSearching){
        node = self.filterViewNode;
    }else{
        node = self.domain.rootNode;
    }
    return node;
}

- (NSArray *)viewSubNodes: (ADHViewNode *)node {
    NSArray * childNods = nil;
    if(self.isSearching){
        childNods = node.filteredChildNodes;
    }else{
        childNods = node.childNodes;
    }
    return childNods;
}

#pragma mark -----------------  OutlineView DataSource & Delegate   ----------------

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    NSInteger count = 0;
    ADHViewNode * viewNode = item;
    if(!viewNode) {
        count = 1;
    }else {
        NSArray *children = [self viewSubNodes:viewNode];
        count = children.count;
    }
    return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    ADHViewNode * viewNode = item;
    if(!viewNode){
        return [self viewRootNode];
    }else {
        NSArray * children = [self viewSubNodes:viewNode];
        return children[index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    ADHViewNode * viewNode = item;
    if(!viewNode){
        viewNode = [self viewRootNode];
    }
    NSInteger count = [self viewSubNodes:viewNode].count;
    return (count > 0);
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    ViewTreeCell * cell = [outlineView makeViewWithIdentifier:NSStringFromClass([ViewTreeCell class]) owner:nil];
    ADHViewNode * viewNode = item;
    cell.delegate = self;
    [cell setData:viewNode];
    return cell;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
    BOOL result = NO;
    ADHViewNode *node = item;
    NSArray *childNodes = [self viewSubNodes:node];
    if(self.isManualExpand) {
        result = (childNodes.count > 0 && node.level <= 5);
    }else {
        result = (childNodes.count > 0);
    }
    return result;
}

@end
