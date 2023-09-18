//
//  AppBundleViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/20.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "AppBundleViewController.h"
#import "ADHFileItem.h"
#import "FileBrowserService.h"
#import "BundleItemView.h"
#import "ADHFilePreviewController.h"

@interface AppBundleViewController ()<ADHBaseCellDelegate,NSSplitViewDelegate>

@property (weak) IBOutlet NSSplitView *splitView;

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSView *previewLayout;
@property (weak) IBOutlet NSView *fsTreeLayout;
@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSView *topLine;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSButton *folderButton;
@property (weak) IBOutlet NSButton *trashButton;
@property (weak) IBOutlet NSSearchField *searchTextfield;

@property (nonatomic, strong) ADHFilePreviewController * previewController;

@property (nonatomic, strong) FileBrowserService *fsService;
@property (nonatomic, strong) NSString *appBundlePath;
@property (nonatomic, strong) ADHFileItem *rootFileItem;
@property (nonatomic, strong) ADHFilePreviewItem *rootPreviewItem;
//search
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) ADHFilePreviewItem * searchPreviewItem;

@end

@implementation AppBundleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initValue];
    [self loadContent];
    [self addNotification];
}

- (void)setupAfterXib {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:@"BundleItemView" bundle:nil];
    [self.outlineView registerNib:nib forIdentifier:NSStringFromClass([BundleItemView class])];
    self.outlineView.rowHeight = 22.0f;
    self.outlineView.usesAlternatingRowBackgroundColors = YES;
    self.fsTreeLayout.wantsLayer = YES;
    self.fsTreeLayout.layer.backgroundColor = [NSColor whiteColor].CGColor;
    CGRect fsTreeViewRect = self.fsTreeLayout.frame;
    fsTreeViewRect.size.width = [self fsTreePreferWidth];
    self.fsTreeLayout.frame = fsTreeViewRect;
    ADHFilePreviewController * previewController = [[ADHFilePreviewController alloc] init];
    NSView * previewContentView = previewController.view;
    previewContentView.frame = self.previewLayout.bounds;
    previewContentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.previewLayout addSubview:previewContentView];
    self.previewController = previewController;
    self.splitView.delegate = self;
    //没实际效果，缩放时需要实现代理方法调整子视图位置
    [self.splitView setHoldingPriority:NSLayoutPriorityDragThatCannotResizeWindow-1 forSubviewAtIndex:0];
    self.topLine.wantsLayer = YES;
    self.actionLayout.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.searchTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.searchTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    self.actionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    [self.folderButton setTintColor:[Appearance actionImageColor]];
    [self.trashButton setTintColor:[Appearance actionImageColor]];
    self.topLine.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
}

- (void)initValue {
    self.fsService = [FileBrowserService serviceWithContext:self.context];
}

- (void)loadContent {
    if(![self doCheckConnectionRoutine]) {
        return;
    }
    [self.refreshButton showHud];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.bundle" action:@"tree" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself clearupContext];
        if(body[@"content"] || [body[@"success"] boolValue]) {
            NSString * content = body[@"content"];
            NSDictionary * fsData = [content adh_jsonObject];
            wself.rootFileItem = [ADHFileItem itemWithDic:fsData];
            if(!wself.rootFileItem) {
                [wself.refreshButton hideHud];
                return;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                FileBrowserService * fbService = wself.fsService;
                NSString * appFSPath = [wself getBundlePath];
                //同步本地目录
                BOOL isSynced = [fbService isAppFolderSynced:wself.rootFileItem atLocalPath:appFSPath];
                if(!isSynced){
                    [fbService syncAppFolder:wself.rootFileItem localPath:appFSPath];
                }
                ADHFilePreviewItem * rootPreviewItem = [fbService producePreviewTree:wself.rootFileItem localPath:appFSPath];
                wself.rootPreviewItem = rootPreviewItem;
                wself.appBundlePath = [wself getBundlePath];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [wself.refreshButton hideHud];
                    [wself.outlineView reloadData];
                });
            });
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

- (void)clearupContext {
    //清除本地bundle缓存文件
    self.rootFileItem = nil;
    self.rootPreviewItem = nil;
    [ADHFileUtil deleteFileAtPath:[self getBundlePath]];
}

- (NSString *)getBundlePath {
    NSString * workPath = [[EnvtService sharedService] appBundleWorkPath];
    ADHApp * app = self.context.app;
    NSString * appPath = [NSString stringWithFormat:@"%@/%@",app.deviceName,app.bundleId];
    NSString * resultPath = [workPath stringByAppendingPathComponent:appPath];
    return resultPath;
}

- (NSString *)getLocalFilePath: (ADHFilePreviewItem *)previewItem {
    return [self.appBundlePath stringByAppendingPathComponent:[previewItem localFilePath]];
}

- (void)onWorkAppUpdate {
    //不存在内容时更新
    if(!self.rootFileItem){
        [self loadContent];
    }
}

#pragma mark -----------------   cell event   ----------------

//单击仅仅预览
- (void)cellClicked: (ADHBaseCell *)cell {
    NSInteger lastSelectedRow = [self.outlineView selectedRow];
    NSInteger row = [self.outlineView rowForView:cell];
    if(lastSelectedRow == row){
        return;
    }
    [self.outlineView deselectAll:nil];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
    if(row != NSNotFound && row >= 0){
        ADHFilePreviewItem * previewItem = (ADHFilePreviewItem *)[self.outlineView itemAtRow:row];
        if(!previewItem.isDir && previewItem.localExists){
            [self previewFsItem:previewItem];
        }
    }
}

//双击处理
- (void)cellDoubleClicked: (ADHBaseCell *)cell {
    NSInteger row = [self.outlineView rowForView:cell];
    if(row != NSNotFound && row >= 0){
        [self.outlineView deselectAll:nil];
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:row];
        [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
        ADHFilePreviewItem * previewItem = (ADHFilePreviewItem *)[self.outlineView itemAtRow:row];
        if([previewItem isDir]) {
            if(![self.outlineView isItemExpanded:previewItem]) {
                [self.outlineView expandItem:previewItem expandChildren:NO];
            }else {
                [self.outlineView collapseItem:previewItem collapseChildren:NO];
            }
        }else {
            //download
            if([previewItem localNeedSync]) {
                [self downloadPreviewItem:previewItem];
            }else {
                [self previewFsItem:previewItem];
            }
        }
    }
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point {
    NSInteger row = [self.outlineView rowForView:cell];
    [self.outlineView deselectAll:nil];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
    ADHFilePreviewItem * previewItem = [self.outlineView itemAtRow:row];
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //open in finder
    NSMenuItem * finderMenu = [[NSMenuItem alloc] initWithTitle:@"Show in Finder" action:@selector(showInFinder:) keyEquivalent:adhvf_const_emptystr()];
    finderMenu.target = self;
    finderMenu.representedObject = previewItem;
    [menu addItem:finderMenu];
    //show with extranal
    NSMenuItem * openMenu = [[NSMenuItem alloc] initWithTitle:@"Open with External App" action:@selector(openWithExternalEditor:) keyEquivalent:adhvf_const_emptystr()];
    openMenu.target = self;
    openMenu.representedObject = previewItem;
    [menu addItem:openMenu];
    [menu addItem: [NSMenuItem separatorItem]];
    
    if(previewItem.remoteExists && (!previewItem.isDir || [previewItem localNeedSync])){
        //download ,if dir only local not exists
        NSMenuItem * downloadItem = [[NSMenuItem alloc] initWithTitle:@"Download" action:@selector(downloadPreviewItemMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
        downloadItem.representedObject = previewItem;
        downloadItem.target = self;
        [menu addItem:downloadItem];
    }
    //copy file
    if(!previewItem.isDir && previewItem.localExists){
        NSMenuItem * copyFileItem = [[NSMenuItem alloc] initWithTitle:@"Copy File" action:@selector(copyPreviewFileMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
        copyFileItem.representedObject = previewItem;
        copyFileItem.target = self;
        [menu addItem:copyFileItem];
    }
    //copy file name
    NSMenuItem * copyNameItem = [[NSMenuItem alloc] initWithTitle:@"Copy File Name" action:@selector(copyPreviewFileNameMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
    copyNameItem.representedObject = previewItem;
    copyNameItem.target = self;
    [menu addItem:copyNameItem];
    [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
}

- (void)showInFinder: (NSMenuItem *)menu {
    ADHFilePreviewItem * previewItem = menu.representedObject;
    NSString * path = [self.appBundlePath stringByAppendingPathComponent:previewItem.localFileItem.path];
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
}

- (void)openWithExternalEditor: (NSMenuItem *)menu {
    ADHFilePreviewItem * previewItem = menu.representedObject;
    NSString * path = [self.appBundlePath stringByAppendingPathComponent:previewItem.localFileItem.path];
    [[NSWorkspace sharedWorkspace] openFile:path];
}

- (void)downloadPreviewItemMenuClicked: (NSMenuItem *)menu {
    //下载
    ADHFilePreviewItem * previewItem = menu.representedObject;
    [self downloadPreviewItem:previewItem];
}

- (void)copyPreviewFileMenuClicked: (NSMenuItem *)menu {
    ADHFilePreviewItem * previewItem = menu.representedObject;
    NSString * path = [self getLocalFilePath:previewItem];
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    if(fileURL){
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] writeObjects:@[fileURL]];
    }
}

- (void)copyPreviewFileNameMenuClicked: (NSMenuItem *)menu {
    ADHFilePreviewItem * previewItem = menu.representedObject;
    NSString * name = [previewItem viewFileItem].name;
    if(name){
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:name forType:NSPasteboardTypeString];
    }
}

- (BundleItemView *)viewForItem: (ADHFilePreviewItem *)item {
    NSInteger row = [self.outlineView rowForItem:item];
    BundleItemView *rowView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:NO];
    return rowView;
}

- (void)downloadPreviewItem: (ADHFilePreviewItem *)previewItem {
    ADHFileItem * fileItem = previewItem.fileItem;
    if(!fileItem.isDir){
        BundleItemView *rowView = [self viewForItem:previewItem];
        //下载
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"path"] = adhvf_safestringfy(fileItem.path);
        __weak typeof(self) wself = self;
        [self.apiClient requestWithService:@"adh.bundle" action:@"readfile" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
            [rowView hideHud];
            BOOL success = YES;
            if(body[@"success"]) {
                success = [body[@"success"] boolValue];
            }
            if(success) {
                //更新本地
                [wself.fsService syncDownloadResultWithItem:previewItem fileData:payload localPath:wself.appBundlePath exteraData:body onCompletion:^{
                    [wself.outlineView reloadItem:previewItem reloadChildren:NO];
                    [wself previewFsItem:previewItem];
                }];
            }
        } onFailed:^(NSError *error) {
            [rowView hideHud];
        }];
        [rowView showHud];
    }else{
        //更新本地
        __weak typeof(self) wself = self;
        [self.fsService syncDownloadResultWithItem:previewItem fileData:nil localPath:wself.appBundlePath exteraData:nil onCompletion:^{
            [wself.outlineView reloadItem:previewItem reloadChildren:NO];
        }];
    }
}

- (void)previewFsItem: (ADHFilePreviewItem *)fileItem {
    ADHFilePreviewController * previewController = self.previewController;
    previewController.fileItem = fileItem;
    previewController.filePath = [self.appBundlePath stringByAppendingPathComponent:fileItem.viewFileItem.path];
    [previewController reload];
}

#pragma mark -----------------  OutlineView DataSource & Delegate   ----------------

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    NSInteger count = 0;
    ADHFilePreviewItem * previewItem = item;
    if(!previewItem){
        previewItem = [self viewRootPreviewItem];
    }
    NSArray * viewSubItems = [self viewSubItems:previewItem];
    count = viewSubItems.count;
    return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    ADHFilePreviewItem * previewItem = item;
    if(!previewItem){
        previewItem = [self viewRootPreviewItem];
    }
    NSArray * viewSubItems = [self viewSubItems:previewItem];
    return viewSubItems[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    ADHFilePreviewItem * previewItem = item;
    if(!previewItem){
        previewItem = [self viewRootPreviewItem];
    }
    return previewItem.isDir;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    BundleItemView * itemView = [outlineView makeViewWithIdentifier:NSStringFromClass([BundleItemView class]) owner:nil];
    ADHFilePreviewItem * previewItem = item;
    itemView.delegate = self;
    [itemView setData:previewItem];
    return itemView;
}

- (ADHFilePreviewItem *)viewRootPreviewItem {
    ADHFilePreviewItem * viewPreviewItem = nil;
    if(self.isSearching){
        viewPreviewItem = self.searchPreviewItem;
    }else{
        viewPreviewItem = self.rootPreviewItem;
    }
    return viewPreviewItem;
}

- (NSArray *)viewSubItems: (ADHFilePreviewItem *)previewItem {
    NSArray * viewSubItems = nil;
    if(self.isSearching){
        viewSubItems = previewItem.filteredSubItems;
    }else{
        viewSubItems = previewItem.subItems;
    }
    return viewSubItems;
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
    if(subview == self.fsTreeLayout){
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
    CGFloat treeWidth = self.fsTreeLayout.bounds.size.width;
    self.fsTreeLayout.frame = CGRectMake(0, 0, treeWidth, splitHeight);
    CGFloat previewWidth = splitWidth - dividerThickness - treeWidth;
    self.previewLayout.frame = CGRectMake(treeWidth+dividerThickness, 0, previewWidth, splitHeight);
}

#pragma mark -----------------   search   ----------------

- (void)searchTextDidChange:(NSNotification *)notification {
    NSString * keywords = self.searchTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)searchTextDidEndEditing:(NSNotification *)notification {
    NSString * keywords = self.searchTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)doSearchWithKeywords: (NSString *)keywords {
    if(keywords.length == 0){
        self.isSearching = NO;
        self.searchPreviewItem = nil;
        [self.outlineView reloadData];
    }else{
        self.isSearching = YES;
        ADHFilePreviewItem * searchPreviewItem = [self.fsService searchPreviewTree:self.rootPreviewItem withKeywords:keywords];
        self.searchPreviewItem = searchPreviewItem;
        [self.outlineView reloadData];
        [self.outlineView expandItem:nil expandChildren:YES];
    }
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self loadContent];
}

- (IBAction)folderButtonPressed:(id)sender {
    NSString *targetPath = nil;
    if(self.appBundlePath) {
        //App folder
        NSString * appPath = self.appBundlePath;
        if([ADHFileUtil dirExistsAtPath:appPath]) {
            targetPath = appPath;
        }
    }
    if(!targetPath) {
        //App bundle folder
        NSString * workPath = [[EnvtService sharedService] appBundleWorkPath];
        if([ADHFileUtil dirExistsAtPath:workPath]) {
            targetPath = workPath;
        }
    }
    if(targetPath) {
        [[NSWorkspace sharedWorkspace] openFile:targetPath];
    }
}

- (IBAction)trashButtonClicked:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    NSEventModifierFlags flags = [event modifierFlags];
    //option是否摁下
    NSUInteger value = (flags & NSEventModifierFlagOption);
    BOOL deleteAll = (value > 0);
    NSString *infoText = nil;
    if(deleteAll) {
        infoText = kLocalized(@"bundle_clear_allcache");
    }else {
        infoText = kLocalized(@"bundle_clear_cache");
    }
    __weak typeof(self) wself = self;
    [ADHAlert alertWithMessage:kLocalized(@"alert_title") infoText:infoText confirmText:kLocalized(@"yes") cancelText:kLocalized(@"cancel") comfirmBlock:^{
        NSString *targetPath = nil;
        if(deleteAll) {
            //App bundle folder
            targetPath = [[EnvtService sharedService] appBundleWorkPath];
        }else {
            targetPath = wself.appBundlePath;
        }
        if(targetPath) {
            [ADHFileUtil deleteFileAtPath:targetPath];
            [wself resetContent];
        }
    } cancelBlock:^{
        
    }];
}

- (void)resetContent {
    self.rootFileItem = nil;
    self.rootPreviewItem = nil;
    self.searchPreviewItem = nil;
    [self.outlineView reloadData];
    [[EnvtService sharedService] resetAppBundleWorkPathIfNeeded];
}


@end
