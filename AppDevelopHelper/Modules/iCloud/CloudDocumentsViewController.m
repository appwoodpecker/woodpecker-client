//
//  CloudDocumentsViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/9/16.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "CloudDocumentsViewController.h"
#import "ADHCloudItem.h"
#import "CloudItemView.h"
#import "ADHFilePreviewController.h"
#import "CloudService.h"
#import "CloudContainerViewController.h"

@interface CloudDocumentsViewController ()<NSOutlineViewDataSource,NSOutlineViewDelegate,ADHBaseCellDelegate,NSSplitViewDelegate>
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSView *previewLayout;
@property (weak) IBOutlet NSView *treeLayout;
@property (weak) IBOutlet NSView *topActionLayout;
@property (weak) IBOutlet NSView *bottomActionLayout;
@property (weak) IBOutlet NSView *treeLineView;

@property (nonatomic, strong) NSString *containerId;
@property (nonatomic, strong) ADHCloudItem *rootItem;
@property (nonatomic, strong) ADHFilePreviewController *previewController;
@property (weak) IBOutlet NSView *bottomLineView;

@property (weak) IBOutlet NSSearchField *searchTextfield;
@property (weak) IBOutlet NSButton *containerButton;

@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) ADHCloudItem * searchRootItem;
@property (nonatomic, strong) CloudService *cloudService;

@end

@implementation CloudDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self initValue];
    [self initUI];
    [self loadContent];
}

- (void)setupAfterXib {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:@"CloudItemView" bundle:nil];
    [self.outlineView registerNib:nib forIdentifier:NSStringFromClass([CloudItemView class])];
    self.outlineView.rowHeight = 30.0f;
    self.outlineView.usesAlternatingRowBackgroundColors = YES;
    //允许拖拽类型，指定为文件
    [self.outlineView registerForDraggedTypes:@[NSFilenamesPboardType]];
    CGRect fsTreeViewRect = self.treeLayout.frame;
    fsTreeViewRect.size.width = [self fsTreePreferWidth];
    self.treeLayout.frame = fsTreeViewRect;
    ADHFilePreviewController * previewController = [[ADHFilePreviewController alloc] init];
    NSView * previewContentView = previewController.view;
    previewContentView.frame = self.previewLayout.bounds;
    previewContentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.previewLayout addSubview:previewContentView];
    self.previewController = previewController;
    self.splitView.delegate = self;
    //没实际效果，缩放时需要实现代理方法调整子视图位置
    [self.splitView setHoldingPriority:NSLayoutPriorityDragThatCannotResizeWindow-1 forSubviewAtIndex:0];
    self.treeLineView.wantsLayer = YES;
    self.bottomLineView.wantsLayer = YES;
    self.topActionLayout.wantsLayer = YES;
    self.bottomActionLayout.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.searchTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.searchTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    [self.containerButton setTintColor:[Appearance actionImageColor]];
    self.treeLineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    self.bottomLineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    self.topActionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    self.bottomActionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
}

- (void)initValue {
    CloudService *service = [CloudService serviceWithContext:self.context];
    self.cloudService = service;
    self.cloudService.containerId = nil;
}

- (void)initUI {
    [self updateContainerUI];
}

- (void)loadContent {
    if(!self.context.isConnected) {
        return;
    }
    if(self.context.app.isSimulator) {
        return;
    }
    [self.refreshButton showHud];
    __weak typeof(self) wself = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if(self.cloudService.containerId) {
        data[@"containerId"] = adhvf_safestringfy(self.cloudService.containerId);
    }
    [self.context.apiClient requestWithService:@"adh.icloud" action:@"tree" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
        BOOL success = [body[@"success"] boolValue];
        if(success) {
            NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithData:payload];
            ADHCloudItem *rootItem = [ADHCloudItem itemWithDic:data];
            wself.rootItem = rootItem;
            [wself updateContentUI];
            [wself resetWorkPathIfNeeded];
        }else {
            NSString *msg = body[@"msg"];
            NSInteger code = [body[@"code"] integerValue];
            if(code > 0) {
                [ADHAlert alertWithMessage:@"Alert" infoText:msg comfirmBlock:nil];
            }else {
                if(body[@"client"]) {
                    [self showVersionNotSupport];
                }else {
                    [self showErrorWithText:msg];
                }
            }
        }
        [wself.refreshButton hideHud];
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (void)showVersionNotSupport {
    NSString *tip = [NSString stringWithFormat:kLocalized(@"frameworkrequire_tip"),@"1.2.3"];
    [ADHAlert alertWithMessage:kLocalized(@"alert_title") infoText:tip confirmText:kLocalized(@"update") cancelText:kAppLocalized(@"Cancel") comfirmBlock:^{
        [UrlUtil openExternalLocalizedUrl:@"web_usage"];
    } cancelBlock:^{
        
    }];
}

- (IBAction)refreshButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    if(self.context.app.isSimulator) {
        [ADHAlert alertWithMessage:@"Alert" infoText:@"iCloud is not supported on simulator" comfirmBlock:nil];
        return;
    }
    [self loadContent];
}

- (void)updateContentUI {
    [self.outlineView reloadData];
    
}

#pragma mark -----------------  OutlineView DataSource & Delegate   ----------------

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    NSInteger count = 0;
    ADHCloudItem * previewItem = item;
    if(!previewItem){
        previewItem = [self viewRootItem];
    }
    NSArray * viewSubItems = [self viewSubItems:previewItem];
    count = viewSubItems.count;
    return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    ADHCloudItem * previewItem = item;
    if(!previewItem){
        previewItem = [self viewRootItem];
    }
    NSArray * viewSubItems = [self viewSubItems:previewItem];
    return viewSubItems[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    ADHCloudItem * previewItem = item;
    if(!previewItem){
        previewItem = [self viewRootItem];
    }
    return previewItem.isDir;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    CloudItemView * itemView = [outlineView makeViewWithIdentifier:NSStringFromClass([CloudItemView class]) owner:nil];
    ADHCloudItem * previewItem = item;
    itemView.delegate = self;
    [itemView setData:previewItem];
    return itemView;
}

- (void)cellClicked:(ADHBaseCell *)cell {
    NSInteger row = [self.outlineView rowForView:cell];
    ADHCloudItem * cloudItem = [self.outlineView itemAtRow:row];
    if(cloudItem.cacheFilePath) {
        [self.previewController setFilePath:cloudItem.cacheFilePath];
        [self.previewController reload];
    }else {
        [self.previewController setFilePath:nil];
        [self.previewController reload];
    }
}

- (void)cellRightClicked:(ADHBaseCell *)cell point:(NSPoint)point {
    NSInteger row = [self.outlineView rowForView:cell];
    ADHCloudItem * cloudItem = [self.outlineView itemAtRow:row];
    if(cloudItem.isDir) {
        return;
    }
    [self.outlineView deselectAll:nil];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //preview
    NSMenuItem * previewMenu = [[NSMenuItem alloc] initWithTitle:@"Preview" action:@selector(previewMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
    previewMenu.target = self;
    previewMenu.representedObject = cloudItem;
    [menu addItem:previewMenu];
    //download
    NSMenuItem * downloadMenu = [[NSMenuItem alloc] initWithTitle:@"Download" action:@selector(downloadMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
    downloadMenu.target = self;
    downloadMenu.representedObject = cloudItem;
    [menu addItem:downloadMenu];
    //save
    if(cloudItem.cacheFilePath) {
        NSMenuItem * saveMenu = [[NSMenuItem alloc] initWithTitle:@"Save" action:@selector(saveMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
        saveMenu.target = self;
        saveMenu.representedObject = cloudItem;
        [menu addItem:saveMenu];
    }
    [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
}

- (void)cellDoubleClicked: (ADHBaseCell *)cell {
    NSInteger row = [self.outlineView rowForView:cell];
    ADHCloudItem *item = [self.outlineView itemAtRow:row];
    if(item.isDir) {
        //fold/unfold
        if(![self.outlineView isItemExpanded:item]) {
            [self.outlineView expandItem:item expandChildren:NO];
        }else {
            [self.outlineView collapseItem:item collapseChildren:NO];
        }
    }else {
        [self previewItem:item];
    }
}

- (void)previewMenuClicked: (NSMenuItem *)menu {
    ADHCloudItem *item = menu.representedObject;
    [self previewItem:item];
}

- (void)downloadMenuClicked: (NSMenuItem *)menu {
    ADHCloudItem *item = menu.representedObject;
    [self downloadItem:item];
}

- (void)saveMenuClicked: (NSMenuItem *)menu {
    ADHCloudItem *item = menu.representedObject;
    [self saveItem:item];
}

//preview
- (void)previewItem: (ADHCloudItem *)item {
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if(self.cloudService.containerId) {
        body[@"containerId"] = adhvf_safestringfy(self.cloudService.containerId);
    }
    __weak typeof(self) wself = self;
    body[@"path"] = adhvf_safestringfy(item.path);
    [self.context.apiClient requestWithService:@"adh.icloud" action:@"readfile" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.previewLayout hideHud];
        BOOL success = [body[@"success"] boolValue];
        if(success) {
            NSString *filePath = [wself getItemLocalPath:item];
            [ADHFileUtil saveData:payload atPath:filePath];
            [wself.previewController setFilePath:filePath];
            [wself.previewController reload];
            item.cacheFilePath = filePath;
        }else {
            NSString *msg = adhvf_safestringfy(body[@"msg"]);
            [wself.previewLayout showToastWithIcon:@"icon_status_error" statusText:msg];
        }
    } onFailed:^(NSError *error) {
        [wself.previewLayout hideHud];
    }];
    [wself.previewLayout showHud];
}

- (void)downloadItem: (ADHCloudItem *)item {
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if(self.containerId) {
        body[@"container"] = adhvf_safestringfy(self.containerId);
    }
    __weak typeof(self) wself = self;
    body[@"path"] = adhvf_safestringfy(item.path);
    [self.context.apiClient requestWithService:@"adh.icloud" action:@"readfile" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.previewLayout hideHud];
        BOOL success = [body[@"success"] boolValue];
        if(success) {
            NSString *filePath = [wself getItemLocalPath:item];
            [ADHFileUtil saveData:payload atPath:filePath];
            [wself.previewController setFilePath:filePath];
            [wself.previewController reload];
            item.cacheFilePath = filePath;
            //then we save it
            [wself saveItem:item];
        }else {
            NSString *msg = adhvf_safestringfy(body[@"msg"]);
            [wself.previewLayout showToastWithIcon:@"icon_status_error" statusText:msg];
        }
    } onFailed:^(NSError *error) {
        [wself.previewLayout hideHud];
    }];
    [wself.previewLayout showHud];
}

- (void)saveItem: (ADHCloudItem *)item {
    if(!item.cacheFilePath) {
        return;
    }
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:item.cacheFilePath];
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.nameFieldStringValue = item.name;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if(result == NSModalResponseOK) {
            NSURL *fileURL = panel.URL;
            NSError *error = nil;
            if(![fileData writeToURL:fileURL options:0 error:&error]) {
//                NSLog(@"%@",error);
            }
        }
    }];
}

#pragma mark -----------------   info   ----------------

- (NSString *)getWorkPath {
    NSString * workPath = [[EnvtService service] iCloudWorkPath];
    ADHApp * app = self.context.app;
    NSString * appPath = [NSString stringWithFormat:@"%@/%@",app.deviceName,app.bundleId];
    NSString * resultPath = [workPath stringByAppendingPathComponent:appPath];
    return resultPath;
}

- (NSString *)getItemLocalPath: (ADHCloudItem *)item {
    NSString * path = [self getWorkPath];
    NSString *dateText = [ADHDateUtil readbleTextWithTimeInterval2:[ADHDateUtil currentTimeInterval]];
    NSString *fileName = [NSString stringWithFormat:@"%@~%@",dateText,item.name];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)resetWorkPathIfNeeded {
    NSString *path = [self getWorkPath];
    if([ADHFileUtil dirExistsAtPath:path]) {
        [ADHFileUtil emptyDir:path];
    }
}

#pragma mark -----------------   split view delegate   ----------------

- (CGFloat)fsTreePreferWidth {
    return 360.0f;
}

- (CGFloat)fsTreeMinWidth {
    return 200.0f;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    BOOL ret = NO;
    if(subview == self.treeLayout){
        ret = YES;
    }
    return ret;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    CGFloat minWidth = proposedMinimumPosition;
    if(dividerIndex == 0){
        minWidth = [self fsTreeMinWidth];
    }
    return minWidth;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
    //如果splitview大小发生变化，计算子视图位置
    CGFloat splitWidth = splitView.bounds.size.width;
    CGFloat splitHeight = splitView.bounds.size.height;
    
    CGFloat dividerThickness = splitView.dividerThickness;
    CGFloat treeWidth = self.treeLayout.bounds.size.width;
    self.treeLayout.frame = CGRectMake(0, 0, treeWidth, splitHeight);
    CGFloat previewWidth = splitWidth - dividerThickness - treeWidth;
    self.previewLayout.frame = CGRectMake(treeWidth+dividerThickness, 0, previewWidth, splitHeight);
}

#pragma mark -----------------   search   ----------------

- (void)searchTextDidChange: (NSNotification *)noti {
    NSString * keywords = self.searchTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)searchTextDidEndEditing: (NSNotification *)noti {
    NSString * keywords = self.searchTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)doSearchWithKeywords: (NSString *)keywords {
    if(!self.rootItem) {
        return;
    }
    if(keywords.length == 0){
        self.isSearching = NO;
        self.searchRootItem = nil;
        [self.outlineView reloadData];
    }else{
        self.isSearching = YES;
        ADHCloudItem * searchPreviewItem = [self.cloudService searchPreviewTree:self.rootItem withKeywords:keywords];
        self.searchRootItem = searchPreviewItem;
        [self.outlineView reloadData];
        [self.outlineView expandItem:nil expandChildren:YES];
    }
}

- (ADHCloudItem *)viewRootItem {
    ADHCloudItem * viewRootItem = nil;
    if(self.isSearching){
        viewRootItem = self.searchRootItem;
    }else{
        viewRootItem = self.rootItem;
    }
    return viewRootItem;
}

- (NSArray *)viewSubItems: (ADHCloudItem *)cloudItem {
    NSArray * viewSubItems = nil;
    if(self.isSearching){
        viewSubItems = cloudItem.filteredSubItems;
    }else{
        viewSubItems = cloudItem.subItems;
    }
    return viewSubItems;
}


- (IBAction)containerButtonPressed:(id)sender {
    CloudContainerViewController *containerVC = [[CloudContainerViewController alloc] init];
    containerVC.context = self.context;
    containerVC.currentContainerId = self.cloudService.containerId;
    __weak typeof(self) wself = self;
    __weak CloudContainerViewController *wContainerVC = (CloudContainerViewController* )containerVC;
    [containerVC setCompletionBlock:^(NSString * containerId) {
        wself.cloudService.containerId = containerId;
        [wself updateContainerUI];
        [wself loadContent];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself dismissViewController:wContainerVC];
        });
    }];
    [self presentViewController:containerVC asPopoverRelativeToRect:self.containerButton.bounds ofView:self.containerButton preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorSemitransient];
}

- (void)updateContainerUI {
    if(self.cloudService.containerId.length == 0) {
        self.containerButton.toolTip = @"Select Ubiquity Container Id";
        [self.containerButton setImage:[NSImage imageNamed:@"icon_container"]];
    }else {
        self.containerButton.toolTip = self.cloudService.containerId;
        [self.containerButton setImage:[NSImage imageNamed:@"icon_container_selected"]];
    }
}

- (void)onWorkAppUpdate {
    //错误时alert弹框，因此这里暂时没处理
}

@end


