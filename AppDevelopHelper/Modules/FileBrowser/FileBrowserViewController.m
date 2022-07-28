//
//  FileBrowserViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/29.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "FileBrowserViewController.h"
#import "FSItemView.h"
#import "FileBrowserService.h"
#import "MacOrganizer.h"
#import "ADHFilePreviewController.h"
#import "SandboxContainerViewController.h"
#import "ADHFileBrowserUtil.h"
#import "DeviceUtil.h"
#import "SandboxWorkpathViewController.h"
#import "StateMasterService.h"


@interface FileBrowserViewController ()<NSOutlineViewDataSource,NSOutlineViewDelegate,ADHBaseCellDelegate,NSSplitViewDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) ADHFileItem * rootFileItem;
@property (nonatomic, strong) ADHFilePreviewItem * rootPreviewItem;
@property (nonatomic, strong) NSString * appFsPath;
@property (weak) IBOutlet NSView *previewLayout;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *fsTreeLayout;
@property (weak) IBOutlet NSSearchField *searchTextField;
@property (weak) IBOutlet NSView *topLineView;
@property (weak) IBOutlet NSView *bottomLineView;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSView *fsActionLayout;
@property (weak) IBOutlet NSView *bottomActionLayout;
@property (weak) IBOutlet NSButton *containerButton;
@property (weak) IBOutlet NSButton *workpathButton;
@property (weak) IBOutlet NSButton *folderButton;
@property (weak) IBOutlet NSButton *trashButton;
@property (weak) IBOutlet NSButton *activityButton;


@property (nonatomic, strong) ADHFilePreviewController * previewController;

@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) ADHFilePreviewItem * searchPreviewItem;

@property (nonatomic, strong) FileBrowserService *fsService;

@end

@implementation FileBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initValue];
    [self initUI];
    [self loadContent];
    [self addNotification];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.searchTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.searchTextField];
}

- (void)setupAfterXib
{
    NSNib * nib = [[NSNib alloc] initWithNibNamed:@"FSItemView" bundle:nil];
    [self.outlineView registerNib:nib forIdentifier:NSStringFromClass([FSItemView class])];
    self.outlineView.rowHeight = 22.0f;
    self.outlineView.usesAlternatingRowBackgroundColors = YES;
    CGRect fsTreeViewRect = self.fsTreeLayout.frame;
    fsTreeViewRect.size.width = [self fsTreePreferWidth];
    self.fsTreeLayout.frame = fsTreeViewRect;
    ADHFilePreviewController * previewController = [[ADHFilePreviewController alloc] init];
    previewController.editable = YES;
    NSView * previewContentView = previewController.view;
    previewContentView.frame = self.previewLayout.bounds;
    previewContentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.previewLayout addSubview:previewContentView];
    self.previewController = previewController;
    self.splitView.delegate = self;
    //没实际效果，缩放时需要实现代理方法调整子视图位置
    [self.splitView setHoldingPriority:NSLayoutPriorityDragThatCannotResizeWindow-1 forSubviewAtIndex:0];
    //允许拖拽类型，指定为文件
    [self.outlineView registerForDraggedTypes:@[NSFilenamesPboardType]];
    self.fsTreeLayout.wantsLayer = YES;
    self.fsActionLayout.wantsLayer = YES;
    self.bottomActionLayout.wantsLayer = YES;
    self.topLineView.wantsLayer = YES;
    self.bottomLineView.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)updateAppearanceUI {
    self.fsTreeLayout.layer.backgroundColor = [Appearance backgroundColor].CGColor;
    self.fsActionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    self.bottomActionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    self.topLineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    self.bottomLineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    [self.workpathButton setTintColor:[Appearance actionImageColor]];
    [self.containerButton setTintColor:[Appearance actionImageColor]];
    [self.folderButton setTintColor:[Appearance actionImageColor]];
    [self.trashButton setTintColor:[Appearance actionImageColor]];
    [self.activityButton setTintColor:[Appearance actionImageColor]];
    
}

- (void)initValue {
    self.fsService = [FileBrowserService serviceWithContext:self.context];
    if([self isNotSandbox]) {
        self.fsService.sandboxWorkpath = [self.fsService getCustomWorkpath];
    }
}

- (void)initUI {
    [self updateContainerUI];
    [self updateWorkpathStateUI];
}

- (void)loadContent {
    if(self.context.isConnected){
        if([self isNotSandbox]) {
            if(self.fsService.sandboxWorkpath.length > 0) {
                [self loadFSContent];
            }
        }else if(self.fsService.containerName.length > 0) {
            [self loadFSGroupContaienrContent];
        }else {
            [self loadFSContent];
        }
        
    }
}

- (void)loadFSContent
{
    [self.refreshButton showHud];
    __weak typeof(self) wself = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if(self.fsService.sandboxWorkpath.length > 0) {
        data[kRequestWorkDirectoryKey] = self.fsService.sandboxWorkpath;
    }
    [self.apiClient requestWithService:@"adh.sandbox" action:@"sandbox" body:data progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        NSString * content = body[@"content"];
        NSDictionary * fsData = [content adh_jsonObject];
        wself.rootFileItem = [ADHFileItem itemWithDic:fsData];
        if(!wself.rootFileItem) {
            [wself.refreshButton hideHud];
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            FileBrowserService * fbService = wself.fsService;
            NSString * appFSPath = [wself getPreviewAppPath];
            //同步本地目录
            BOOL isSynced = [fbService isAppFolderSynced:wself.rootFileItem atLocalPath:appFSPath];
            if(!isSynced){
                [fbService syncAppFolder:wself.rootFileItem localPath:appFSPath];
            }
            ADHFilePreviewItem * rootPreviewItem = [fbService producePreviewTree:wself.rootFileItem localPath:appFSPath];
            wself.rootPreviewItem = rootPreviewItem;
            wself.appFsPath = appFSPath;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [wself.refreshButton hideHud];
                [wself reloadDataOnSuccess];
            });
        });
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (void)loadFSGroupContaienrContent {
    [self.refreshButton showHud];
    __weak typeof(self) wself = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if(self.fsService.containerName.length > 0) {
        data[kRequestContainerKey] = adhvf_safestringfy(self.fsService.containerName);
    }
    NSString *containerName = self.fsService.containerName;
    [self.apiClient requestWithService:@"adh.sandbox" action:@"sandbox" body:data progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        NSString * content = body[@"content"];
        NSDictionary * fsData = [content adh_jsonObject];
        wself.rootFileItem = [ADHFileItem itemWithDic:fsData];
        if(!wself.rootFileItem) return;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            FileBrowserService * fbService = wself.fsService;
            NSString * containerFSPath = [wself getGroupContainerPreviewPath:containerName];
            //同步本地目录
            BOOL isSynced = [fbService isAppFolderSynced:wself.rootFileItem atLocalPath:containerFSPath];
            if(!isSynced){
                [fbService syncAppFolder:wself.rootFileItem localPath:containerFSPath];
            }
            ADHFilePreviewItem * rootPreviewItem = [fbService producePreviewTree:wself.rootFileItem localPath:containerFSPath];
            wself.rootPreviewItem = rootPreviewItem;
            wself.appFsPath = containerFSPath;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [wself.refreshButton hideHud];
                [wself reloadDataOnSuccess];
            });
        });
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (BOOL)isGroupContainer {
    return (self.fsService.containerName.length > 0);
}

- (void)reloadDataOnSuccess {
    [self doSearchWithKeywords:self.searchTextField.stringValue];
    __weak typeof(self) wself = self;
    [self.fsService monitorLocalFileStatus:self.rootPreviewItem localPath:self.appFsPath onUpdate:^(NSArray<ADHFilePreviewItem *> *items) {
        NSInteger selectedRow = [wself.outlineView selectedRow];
        [wself.outlineView reloadItem:nil reloadChildren:YES];
        if(selectedRow != NSNotFound) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:selectedRow];
            [wself.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
        }
    }];
}

#pragma mark -----------------  OutlineView DataSource & Delegate   ----------------

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    NSInteger count = 0;
    ADHFilePreviewItem * previewItem = item;
    if([self isGroupContainer]) {
        if(!previewItem) {
            count = 1;
        }else {
            NSArray * viewSubItems = [self viewSubItems:previewItem];
            count = viewSubItems.count;
        }
    }else {
        if(!previewItem){
            previewItem = [self viewRootPreviewItem];
        }
        NSArray * viewSubItems = [self viewSubItems:previewItem];
        count = viewSubItems.count;
    }
    return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    ADHFilePreviewItem * previewItem = item;
    if([self isGroupContainer]) {
        if(!previewItem){
            return [self viewRootPreviewItem];
        }else {
            NSArray * viewSubItems = [self viewSubItems:previewItem];
            return viewSubItems[index];
        }
    }else {
        if(!previewItem){
            previewItem = [self viewRootPreviewItem];
        }
        NSArray * viewSubItems = [self viewSubItems:previewItem];
        return viewSubItems[index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    ADHFilePreviewItem * previewItem = item;
    if(!previewItem){
        previewItem = [self viewRootPreviewItem];
    }
    return previewItem.isDir;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    FSItemView * itemView = [outlineView makeViewWithIdentifier:NSStringFromClass([FSItemView class]) owner:nil];
    ADHFilePreviewItem * previewItem = item;
    itemView.delegate = self;
    [itemView setData:previewItem];
    return itemView;
}

#pragma mark -----------------   cell event   ----------------

//单击仅仅预览
- (void)cellClicked: (ADHBaseCell *)cell
{
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

//双击下载/上传
- (void)cellDoubleClicked: (ADHBaseCell *)cell
{
    NSInteger row = [self.outlineView rowForView:cell];
    [self.outlineView deselectAll:nil];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
    if(row != NSNotFound && row >= 0){
        ADHFilePreviewItem * previewItem = (ADHFilePreviewItem *)[self.outlineView itemAtRow:row];
        if([previewItem isDir]) {
            if([previewItem remoteNeedSync]) {
                //需要上传
                if(!doProCheckRoutine()) {return;}
                [self doFileItemSelected:previewItem];
            }else if([previewItem localNeedSync]) {
                //需要下载
                [self doFileItemSelected:previewItem];
            }else {
                //已同步，展开/收起
                if(![self.outlineView isItemExpanded:previewItem]) {
                    [self.outlineView expandItem:previewItem expandChildren:NO];
                }else {
                    [self.outlineView collapseItem:previewItem collapseChildren:NO];
                }
            }
        }else {
            //上传需要pro
            if([previewItem remoteNeedSync]){
                if(!doProCheckRoutine()) {return;}
            }
            [self doFileItemSelected:previewItem];
        }
    }
}


- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point
{
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
    if(previewItem.localExists && (!previewItem.isDir || [previewItem remoteNeedSync])){
        //upload
        NSMenuItem * uploadItem = [[NSMenuItem alloc] initWithTitle:@"Upload" action:@selector(uploadPreviewItemMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
        uploadItem.representedObject = previewItem;
        uploadItem.target = self;
        [menu addItem:uploadItem];
    }
    //refresh
    NSMenuItem * refreshItem = [[NSMenuItem alloc] initWithTitle:@"Refresh" action:@selector(refreshMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
    refreshItem.representedObject = previewItem;
    refreshItem.target = self;
    [menu addItem:refreshItem];
    //delete
    if([self isGroupContainer]) {
        if(previewItem.parent) {
            //disallow delete top level
            NSMenuItem * copyNameItem = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(removeMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
            copyNameItem.representedObject = previewItem;
            copyNameItem.target = self;
            [menu addItem:copyNameItem];
        }
    }else {
        if((previewItem.parent && previewItem.parent != [self viewRootPreviewItem]) || [self isNotSandbox]) {
            //disallow delete top level
            NSMenuItem * copyNameItem = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(removeMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
            copyNameItem.representedObject = previewItem;
            copyNameItem.target = self;
            [menu addItem:copyNameItem];
        }
    }
    
    [menu addItem: [NSMenuItem separatorItem]];
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
    //copy file path
    NSMenuItem * copyPathItem = [[NSMenuItem alloc] initWithTitle:@"Copy File Path" action:@selector(copyFilePathMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
    copyPathItem.representedObject = previewItem;
    copyPathItem.target = self;
    [menu addItem:copyPathItem];
    //sync to state master
    if(!previewItem.isDir && previewItem.localExists) {
        StateMasterService *stateService = [StateMasterService serviceWithContext:self.context];
        if(stateService) {
            [menu addItem: [NSMenuItem separatorItem]];
            NSMenuItem *stateMasterMenu = [stateService makeStateMasterMenu:self action:@selector(stateMasterMenuClicked:)];
            if(stateMasterMenu) {
                stateMasterMenu.representedObject = previewItem;
                [menu addItem:stateMasterMenu];
            }
        }
    }
    [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
}

- (void)showInFinder: (NSMenuItem *)menu {
    ADHFilePreviewItem * previewItem = menu.representedObject;
    NSString * path = [[self appFsPath] stringByAppendingPathComponent:previewItem.localFileItem.path];
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
}

- (void)openWithExternalEditor: (NSMenuItem *)menu
{
    ADHFilePreviewItem * previewItem = menu.representedObject;
    NSString * path = [[self appFsPath] stringByAppendingPathComponent:previewItem.localFileItem.path];
    [[NSWorkspace sharedWorkspace] openFile:path];
}

- (void)downloadPreviewItemMenuClicked: (NSMenuItem *)menu
{
    //下载
    ADHFilePreviewItem * previewItem = menu.representedObject;
    [self downloadPreviewItem:previewItem];
}

- (void)uploadPreviewItemMenuClicked: (NSMenuItem *)menu
{
    if(!doProCheckRoutine()) {return;}
    ADHFilePreviewItem * previewItem = menu.representedObject;
    [self uploadPreviewItem:previewItem];
}

- (void)refreshMenuClicked: (NSMenuItem *)menu {
    ADHFilePreviewItem * previewItem = menu.representedObject;
    FSItemView *rowView = [self viewForItem:previewItem];
    __weak typeof(self) wself = self;
    [self.fsService refreshPreviewItemState:previewItem localPath:self.appFsPath onCompletion:^{
        [rowView hideHud];
        [wself.outlineView reloadItem:previewItem reloadChildren:YES];
    } onError:^(NSError *error) {
       [rowView hideHud];
    }];
    [rowView showHud];
}

- (void)copyPreviewFileMenuClicked: (NSMenuItem *)menu
{
    ADHFilePreviewItem * previewItem = menu.representedObject;
    NSString * path = [self getLocalFilePath:previewItem];
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    if(fileURL){
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] writeObjects:@[fileURL]];
    }
}

- (void)copyPreviewFileNameMenuClicked: (NSMenuItem *)menu
{
    ADHFilePreviewItem * previewItem = menu.representedObject;
    NSString * name = [previewItem viewFileItem].name;
    if(name){
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:name forType:NSPasteboardTypeString];
    }
}

- (void)copyFilePathMenuClicked: (NSMenuItem *)menu {
    ADHFilePreviewItem * previewItem = menu.representedObject;
    NSString * path = [previewItem viewFileItem].path;
    if(path){
        [DeviceUtil pasteText:path];
    }
}

- (void)stateMasterMenuClicked: (NSMenuItem *)menu {
    NSMenuItem *parentItem = menu.parentItem;
    StateItem *stateItem = menu.representedObject;
    ADHFilePreviewItem * previewItem = parentItem.representedObject;
    ADHFileItem *fileItem = previewItem.fileItem;
    StateMasterService *stateService = [StateMasterService serviceWithContext:self.context];
    NSString * filePath = [self getLocalFilePath:previewItem];
    [stateService addFileAtPath:filePath toState:stateItem statePath:fileItem.path];
    [self showSuccessWithText:@"Sync Done"];
}

//remove
- (void)removeMenuClicked: (NSMenuItem *)menu
{
    if(!doProCheckRoutine()) {return;}
    ADHFilePreviewItem * previewItem = menu.representedObject;
    [self removePreviewItem:previewItem];
}

- (void)doFileItemSelected: (ADHFilePreviewItem *)previewItem
{
    if([previewItem needSync]){
        [self syncPreviewItem:previewItem];
    }else{
        if(!previewItem.isDir){
            [self previewFsItem:previewItem];
        }
    }
}

/**
 同步FSPreviewItem
 */
- (void)syncPreviewItem: (ADHFilePreviewItem *)previewItem
{
    if([previewItem localNeedSync]){
        //下载
        [self downloadPreviewItem:previewItem];
    }else if([previewItem remoteNeedSync]){
        //上传
        if(!previewItem.isDir){
            [self previewFsItem:previewItem];
        }
        [self uploadPreviewItem:previewItem];
    }
}

- (FSItemView *)viewForItem: (ADHFilePreviewItem *)item {
    NSInteger row = [self.outlineView rowForItem:item];
    FSItemView *rowView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:NO];
    return rowView;
}

- (void)downloadPreviewItem: (ADHFilePreviewItem *)previewItem {
    ADHFileItem * fileItem = previewItem.fileItem;
    if(!fileItem.isDir){
        FSItemView *rowView = [self viewForItem:previewItem];
        //下载
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"path"] = adhvf_safestringfy(fileItem.path);
        if(self.fsService.containerName.length > 0) {
            data[kRequestContainerKey] = adhvf_safestringfy(self.fsService.containerName);
        }
        if(self.fsService.sandboxWorkpath.length > 0) {
            data[kRequestWorkDirectoryKey] = adhvf_safestringfy(self.fsService.sandboxWorkpath);
        }
        __weak typeof(self) wself = self;
        [self.apiClient requestWithService:@"adh.sandbox" action:@"readfile" body:data progressChanged:^(float progress){
            
        } onSuccess:^(NSDictionary *body, NSData *payload) {
            [rowView hideHud];
            BOOL success = YES;
            if(body[@"success"]) {
                success = [body[@"success"] boolValue];
            }
            if(success) {
                //更新本地
                [wself.fsService syncDownloadResultWithItem:previewItem fileData:payload localPath:[wself appFsPath] exteraData:body onCompletion:^{
                    [wself.outlineView reloadItem:previewItem reloadChildren:NO];
                    [wself previewFsItem:previewItem];
                }];
            }
        } onFailed:^(NSError *error) {
            NSLog(@"%@",error);
            [rowView hideHud];
        }];
        [rowView showHud];
    }else{
        //更新本地
        __weak typeof(self) wself = self;
        [self.fsService syncDownloadResultWithItem:previewItem fileData:nil localPath:[wself appFsPath] exteraData:nil onCompletion:^{
            [wself.outlineView reloadItem:previewItem reloadChildren:NO];
        }];
    }
}

- (void)uploadPreviewItem: (ADHFilePreviewItem *)previewItem
{
    FSItemView *rowView = [self viewForItem:previewItem];
    if(!previewItem.isDir){
        __weak typeof(self) wself = self;
        ADHFileItem *fileItem = previewItem.localFileItem;
        NSString * filePath = [[self appFsPath] stringByAppendingPathComponent:fileItem.path];
        NSTimeInterval updateTime = [ADHFileUtil getFileModificationTime:filePath];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"path"] = adhvf_safestringfy(fileItem.path);
        data[@"updateTime"] = [NSString stringWithFormat:@"%.5f",updateTime];
        if(self.fsService.containerName.length > 0) {
            data[kRequestContainerKey] = adhvf_safestringfy(self.fsService.containerName);
        }
        if(self.fsService.sandboxWorkpath.length > 0) {
            data[kRequestWorkDirectoryKey] = adhvf_safestringfy(self.fsService.sandboxWorkpath);
        }
        NSData * fileData = [[NSData alloc] initWithContentsOfFile:filePath];
        if(!fileData) return;
        [self.apiClient requestWithService:@"adh.sandbox" action:@"writefile" body:data payload:fileData progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
            [rowView hideHud];
            BOOL success = [body[@"success"] boolValue];
            if(success){
                //更新本地
                [wself.fsService syncUploadResultWithItem:previewItem];
                [wself.outlineView reloadItem:previewItem reloadChildren:NO];
            }
        } onFailed:^(NSError *error) {
            NSLog(@"%@",error);
            [rowView hideHud];
        }];
        [rowView showHud];
    }else{
        __weak typeof(self) wself = self;
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"path"] = adhvf_safestringfy(previewItem.localFileItem.path);
        data[@"isdir"] = @1;
        if(self.fsService.containerName.length > 0) {
            data[kRequestContainerKey] = adhvf_safestringfy(self.fsService.containerName);
        }
        if(self.fsService.sandboxWorkpath.length > 0) {
            data[kRequestWorkDirectoryKey] = adhvf_safestringfy(self.fsService.sandboxWorkpath);
        }
        [self.apiClient requestWithService:@"adh.sandbox" action:@"writefile" body:data payload:nil progressChanged:^(float progress){
            NSLog(@"progress: %.3f",progress);
        } onSuccess:^(NSDictionary *body, NSData *payload) {
            [rowView hideHud];
            BOOL success = [body[@"success"] boolValue];
            if(success){
                //更新本地
                [wself.fsService syncUploadResultWithItem:previewItem];
                [wself.outlineView reloadItem:previewItem reloadChildren:NO];
                
            }
        } onFailed:^(NSError *error) {
            [rowView hideHud];
        }];
        [rowView showHud];
    }
}

#pragma mark -----------------   delete   ----------------

- (void)removePreviewItem: (ADHFilePreviewItem *)previewItem {
    if([self isNotSandbox]) {
        [self performSelector:@selector(_removePreviewItemWithAlert:) withObject:previewItem afterDelay:0.3];
    }else {
        [self _removePreviewItem:previewItem];
    }
}

- (void)_removePreviewItemWithAlert: (ADHFilePreviewItem *)previewItem {
    __weak typeof(self) wself = self;
    [ADHAlert alertWithMessage:kLocalized(@"sandbox_delete_file") infoText:@"" comfirmBlock:^{
        [wself _removePreviewItem:previewItem];
    } cancelBlock:nil];
}

- (void)_removePreviewItem: (ADHFilePreviewItem *)previewItem {
    if([previewItem remoteExists]) {
        ADHFileItem *fileItem = previewItem.fileItem;
        FSItemView *rowView = [self viewForItem:previewItem];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"path"] = adhvf_safestringfy(fileItem.path);
        data[@"isDir"] = [NSNumber numberWithBool:fileItem.isDir];
        if(self.fsService.containerName.length > 0) {
            data[kRequestContainerKey] = adhvf_safestringfy(self.fsService.containerName);
        }
        if(self.fsService.sandboxWorkpath.length > 0) {
            data[kRequestWorkDirectoryKey] = adhvf_safestringfy(self.fsService.sandboxWorkpath);
        }
        //下载
        __weak typeof(self) wself = self;
        [self.apiClient requestWithService:@"adh.sandbox" action:@"removefile" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
            [rowView hideHud];
            BOOL success = [body[@"success"] boolValue];
            if(success) {
                //删除本地
                ADHFilePreviewItem *parent = previewItem.parent;
                [wself.fsService removePreviewItem:previewItem localPath:[wself appFsPath]];
                if(parent.parent == nil || parent == [wself viewRootPreviewItem]) {
                    [wself.outlineView reloadItem:nil reloadChildren:YES];
                }else {
                    [wself.outlineView reloadItem:parent reloadChildren:YES];
                }
            }
        } onFailed:^(NSError *error) {
            [rowView hideHud];
        }];
        [rowView showHud];
    }else {
        //删除本地
        ADHFilePreviewItem *parent = previewItem.parent;
        [self.fsService removePreviewItem:previewItem localPath:[self appFsPath]];
        [self.outlineView reloadItem:parent reloadChildren:YES];
    }
}

- (void)previewFsItem: (ADHFilePreviewItem *)fileItem
{
    ADHFilePreviewController * previewController = self.previewController;
    previewController.fileItem = fileItem;
    previewController.filePath = [self.appFsPath stringByAppendingPathComponent:fileItem.viewFileItem.path];
    [previewController reload];
}

#pragma mark -----------------   drag drop support   ----------------

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(nullable id)item proposedChildIndex:(NSInteger)index {
    NSPasteboard *pb = info.draggingPasteboard;
    NSArray * filePaths = [pb propertyListForType:NSFilenamesPboardType];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL pass = YES;
    for (NSString *path in filePaths) {
        BOOL isDir = NO;
        [fm fileExistsAtPath:path isDirectory:&isDir];
        if(isDir) {
            pass = NO;
            break;
        }
    }
    NSDragOperation retValue = NSDragOperationNone;
    if(pass) {
        if(item && item != [self viewRootPreviewItem]) {
            //only allow copy to app folder
            retValue = NSDragOperationCopy;
        }
    }
    return retValue;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(nullable id)item childIndex:(NSInteger)index {
    ADHFilePreviewItem *previewItem = item;
    NSPasteboard *pb = info.draggingPasteboard;
    NSArray * filePaths = [pb propertyListForType:NSFilenamesPboardType];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * itemPath = [self getLocalFilePath:previewItem];
    FSItemView *rowView = [self viewForItem:previewItem];
    [rowView showHud];
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *path in filePaths) {
            NSString *name = [path lastPathComponent];
            NSString *targetPath = [itemPath stringByAppendingPathComponent:name];
            if(name.length > 0) {
                NSError *error = nil;
                if([ADHFileUtil fileExistsAtPath:targetPath]) {
                    [ADHFileUtil deleteFileAtPath:targetPath];
                }
                [fm copyItemAtPath:path toPath:targetPath error:&error];
            }
        }
        [wself.fsService refreshLocalPreviewItemState:previewItem localPath:self.appFsPath onCompletion:^{
            [rowView hideHud];
            [wself.outlineView reloadItem:previewItem reloadChildren:YES];
        }];
    });
    return YES;
}

- (NSString *)getPreviewAppPath {
    NSString * workPath = [[EnvtService service] appFileWorkPath];
    ADHApp * app = self.context.app;
    NSString * appPath = [NSString stringWithFormat:@"%@/%@",app.deviceName,app.bundleId];
    NSString * resultPath = [workPath stringByAppendingPathComponent:appPath];
    return resultPath;
}

- (NSString *)getGroupContainerPreviewPath: (NSString *)containerName {
    NSString *appPath = [self getPreviewAppPath];
    NSString *containerRootPath = [appPath stringByAppendingPathComponent:[ADHFileUtil containerRootName]];
    return [containerRootPath stringByAppendingPathComponent:containerName];
}

- (NSString *)getLocalFilePath: (ADHFilePreviewItem *)previewItem
{
    return [self.appFsPath stringByAppendingPathComponent:[previewItem localFilePath]];
}


#pragma mark -----------------   split view delegate   ----------------

- (CGFloat)fsTreePreferWidth
{
    return 300.0f;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    CGFloat minWidth = proposedMinimumPosition;
    if(dividerIndex == 0){
        minWidth = [self fsTreePreferWidth];
    }
    return minWidth;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
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

- (void)searchTextDidChange:(NSNotification *)notification
{
    NSString * keywords = self.searchTextField.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)searchTextDidEndEditing:(NSNotification *)notification
{
    NSString * keywords = self.searchTextField.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)doSearchWithKeywords: (NSString *)keywords
{
    if(!self.rootPreviewItem) {
        return;
    }
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

- (ADHFilePreviewItem *)viewRootPreviewItem
{
    ADHFilePreviewItem * viewPreviewItem = nil;
    if(self.isSearching){
        viewPreviewItem = self.searchPreviewItem;
    }else{
        viewPreviewItem = self.rootPreviewItem;
    }
    return viewPreviewItem;
}

- (NSArray *)viewSubItems: (ADHFilePreviewItem *)previewItem
{
    NSArray * viewSubItems = nil;
    if(self.isSearching){
        viewSubItems = previewItem.filteredSubItems;
    }else{
        viewSubItems = previewItem.subItems;
    }
    return viewSubItems;
}

#pragma mark -----------------   action   ----------------

- (IBAction)loadFSButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    if([self isNotSandbox]) {
        if(self.fsService.sandboxWorkpath.length == 0) {
            //需要设置工作目录
            __weak typeof(self) wself = self;
            [ADHAlert alertWithMessage:kLocalized(@"sandbox_wordir_alert") infoText:kLocalized(@"sandbox_wordir_info") comfirmBlock:^{
                [wself doWorkpathSetup];
            } cancelBlock:^{
                
            }];
            return;
        }
    }
    if([DeviceUtil isOptionPressed]) {
        //delete cache when option pressed
        NSString *targetPath = [self getPreviewAppPath];
        if(targetPath) {
            [ADHFileUtil deleteFileAtPath:targetPath];
        }
    }
    [self loadContent];
}

- (IBAction)folderButtonPressed:(id)sender {
    NSString *targetPath = nil;
    //app work path
    if([ADHFileUtil dirExistsAtPath:self.appFsPath]) {
        targetPath = self.appFsPath;
    }
    if(!targetPath) {
        //sandbox work path
        NSString *sandboxPath = [[EnvtService service] appFileWorkPath];
        if([ADHFileUtil dirExistsAtPath:sandboxPath]) {
            targetPath = sandboxPath;
        }
    }
    if(targetPath) {
        [[NSWorkspace sharedWorkspace] openFile:targetPath];
    }
}

- (IBAction)trashButtonPressed:(id)sender {
    BOOL deleteAll = [DeviceUtil isOptionPressed];
    NSString *infoText = nil;
    if(deleteAll) {
        infoText = kLocalized(@"sandbox_clear_allcache");
    }else {
        infoText = kLocalized(@"sandbox_clear_cache");
    }
    __weak typeof(self) wself = self;
    [ADHAlert alertWithMessage:kLocalized(@"alert_title") infoText:infoText confirmText:kLocalized(@"yes") cancelText:kLocalized(@"cancel") comfirmBlock:^{
        NSString *targetPath = nil;
        if(deleteAll) {
            targetPath = [[EnvtService service] appFileWorkPath];
        }else {
            targetPath = [wself getPreviewAppPath];
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
    [[EnvtService service] resetAppfileWorkPathIfNeeded];
}


- (IBAction)activityButtonPressed:(id)sender {
    [self.container switchToActivityMode];
}

/**
 workApp更新
 */
- (void)onWorkAppUpdate
{
    //不存在内容时更新
    if(!self.rootFileItem){
        [self loadContent];
    }
}

// @"group.lifebetter.woodpecker.keyboardtest";
- (IBAction)containerButtonPressed:(NSButton *)button {
    SandboxContainerViewController *containerVC = [[SandboxContainerViewController alloc] init];
    containerVC.context = self.context;
    containerVC.currentContainerName = self.fsService.containerName;
    __weak typeof(self) wself = self;
    __weak SandboxContainerViewController *wContainerVC = (SandboxContainerViewController* )containerVC;
    [containerVC setCompletionBlock:^(NSString * _Nonnull containerName) {
        wself.fsService.containerName = containerName;
        [wself updateContainerUI];
        [wself loadContent];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself dismissViewController:wContainerVC];
        });
    }];
    [self presentViewController:containerVC asPopoverRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorSemitransient];
}

- (void)updateContainerUI {
    if(self.fsService.containerName.length == 0) {
        self.containerButton.toolTip = @"Select Group Container";
        [self.containerButton setImage:[NSImage imageNamed:@"icon_container"]];
    }else {
        self.containerButton.toolTip = self.fsService.containerName;
        [self.containerButton setImage:[NSImage imageNamed:@"icon_container_selected"]];
    }
}

- (IBAction)workpathButtonClicked:(NSButton *)button {
    [self doWorkpathSetup];
}

- (void)doWorkpathSetup {
    SandboxWorkpathViewController *workpathVC = [[SandboxWorkpathViewController alloc] init];
    workpathVC.context = self.context;
    workpathVC.service = self.fsService;
    __weak typeof(self) wself = self;
    __weak SandboxWorkpathViewController *weakVC = (SandboxWorkpathViewController* )workpathVC;
    [workpathVC setCompletionBlock:^(NSString * _Nonnull path) {
        wself.fsService.sandboxWorkpath = path;
        [wself updateWorkpathUI];
        if(wself.fsService.sandboxWorkpath.length > 0) {
            [wself loadContent];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself dismissViewController:weakVC];
        });
    }];
    [workpathVC setUpdationBlock:^(NSString *path) {
        wself.fsService.sandboxWorkpath = path;
        [wself updateWorkpathUI];
    }];
    //需要使用NSPopoverBehaviorSemitransient，防止打开openpanel时popover被close
    [self presentViewController:workpathVC asPopoverRelativeToRect:self.workpathButton.bounds ofView:self.workpathButton preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorSemitransient];
}

- (void)updateWorkpathStateUI {
    if([self.context.app isMacOS] && ![self.context.app isSandboxed]) {
        self.workpathButton.hidden = NO;
        self.containerButton.hidden = YES;
        [self updateWorkpathUI];
    }else {
        self.containerButton.hidden = NO;
        self.workpathButton.hidden = YES;
    }
}

- (void)updateWorkpathUI {
    if(self.fsService.sandboxWorkpath.length == 0) {
        [self.workpathButton setImage:[NSImage imageNamed:@"icon_workpath"]];
    }else {
        [self.workpathButton setImage:[NSImage imageNamed:@"icon_workpath_selected"]];
    }
}

- (BOOL)isNotSandbox {
    return (self.context.app.isMacOS && !self.context.app.isSandboxed);
}

@end
