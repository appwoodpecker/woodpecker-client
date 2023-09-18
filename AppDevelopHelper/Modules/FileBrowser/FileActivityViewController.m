//
//  FileActivityViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/7/11.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "FileActivityViewController.h"
#import "FileBrowserActionService.h"
#import "ADHFileActivityItem.h"
#import "ADHFilePreviewController.h"
#import "MacOrganizer.h"
#import "FileBrowserService.h"

static CGFloat const kColumnFlexibleMinUnitWidth = 200.0f;

@interface FileActivityViewController ()<NSTableViewDelegate, NSTableViewDataSource,ADHBaseCellDelegate>

@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *activityLayout;
@property (weak) IBOutlet NSView *previewLayout;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *filterTextfield;

@property (nonatomic, strong) ADHFilePreviewController *previewController;

@property (nonatomic, strong) NSArray * columnList;

@property (nonatomic, strong) NSMutableArray *activityList;
//sorted
@property (nonatomic, strong) NSArray * sortedActivityList;
//filtered
@property (nonatomic, strong) NSArray * filteredActivityList;
//display
@property (nonatomic, strong) NSArray * displayActivityList;

@property (nonatomic, strong) NSSortDescriptor * sortDescriptor;
@property (nonatomic, strong) NSString * keywords;

@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *pauseButton;
@property (weak) IBOutlet NSButton *trashButton;
@property (weak) IBOutlet NSButton *activityButton;

@property (nonatomic, strong) FileBrowserService *fsService;

@property (nonatomic, assign) BOOL shouldTryStart;
@property (nonatomic, assign) BOOL stateOn;



@end

@implementation FileActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initValues];
    [self initialUI];
    [self setupNotification];
    [self tryStartRecord];
}

- (void)setupAfterXib {
    ADHFilePreviewController * previewController = [[ADHFilePreviewController alloc] init];
    NSView * previewContentView = previewController.view;
    previewContentView.frame = self.previewLayout.bounds;
    previewContentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.previewLayout addSubview:previewContentView];
    self.previewController = previewController;
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask;
    self.tableView.intercellSpacing = NSZeroSize;
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.columnAutoresizingStyle = NSTableViewNoColumnAutoresizing;
    
    [self setupSearchTextField];
    [self updateAppearanceUI];
}

- (void)setupSearchTextField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.filterTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.filterTextfield];
}

- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFileUpdate:) name:kFileBrowserActionServiceFileUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.startButton setTintColor:[Appearance actionImageColor]];
    [self.trashButton setTintColor:[Appearance actionImageColor]];
    [self.activityButton setTintColor:[Appearance actionImageColor]];
    if([Appearance isDark]) {
        
    }else {
        
    }
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [self updateColumnSize];
}

- (void)initValues {
    self.fsService = [FileBrowserService serviceWithContext:self.context];
    self.activityList = [NSMutableArray array];
    self.columnList = @[
                        @{
                            @"name" : @"Activity",
                            @"width" : @60,
                            @"sort" : @1,
                            },
                        @{
                            @"name" : @"Date",
                            @"width" : @80,
                            @"sort" : @1,
                            },
                        @{
                            @"name" : @"Path",
                            @"flexible-width" : @1.0,
                            @"sort" : @1,
                            },
                        ];
}

- (void)initialUI {
    [self setupColumns];
    [self updateStateUI];
}

- (void)setupColumns {
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
        BOOL sorted = [data[@"sort"] boolValue];
        if(sorted){
            if([name isEqualToString:@"Date"]) {
                column.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:name ascending:NO];
            }else {
                column.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:name ascending:YES];
            }
        }
        if([name isEqualToString:@"Activity"] || [name isEqualToString:@"Date"]) {
            column.headerCell.alignment = NSTextAlignmentCenter;
        }
        [self.tableView addTableColumn:column];
    }
    [self updateColumnSize];
}

- (void)updateColumnSize {
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

- (BOOL)isGroupContainer {
    return (self.fsService.containerName.length > 0);
}

#pragma mark -----------------   table source and delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.displayActivityList.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    ADHBaseCell * cell = nil;
    NSString *text = nil;
    NSString *identifier = tableColumn.identifier;
    ADHFileActivityItem *item = self.displayActivityList[row];
    if([identifier isEqualToString:@"Activity"]) {
        cell = (ADHBaseCell *)[tableView makeViewWithIdentifier:@"activityCellId" owner:nil];
        text = [item readbleActivity];
        NSImageView *fileImageView = [cell viewWithTag:100];
        NSString *fileIcon = nil;
        if(!item.isDir) {
            if(item.type != ADHFileActivityEdit) {
                fileIcon = @"icon_file";
            }else {
                fileIcon = @"icon_file_edited";
            }
        }else {
            fileIcon = NSImageNameFolder;
        }
        fileImageView.image = [NSImage imageNamed:fileIcon];
        if(!item.isDir) {
            [fileImageView setTintColor:[NSColor labelColor]];
        }
        NSImageView *activityImageView = [cell viewWithTag:101];
        NSString *activityIcon = nil;
        if(item.type == ADHFileActivityAdd) {
            activityIcon = @"icon_status_add";
        }else if(item.type == ADHFileActivityEdit) {
            activityIcon = @"";
        }else if(item.type == ADHFileActivityRemove) {
            activityIcon = @"icon_status_del";
        }
        activityImageView.image = [NSImage imageNamed:activityIcon];
    }else if([identifier isEqualToString:@"Path"]) {
        cell = (ADHBaseCell *)[tableView makeViewWithIdentifier:@"cellId" owner:nil];
        text = item.path;
        cell.textField.stringValue = text;
    }else if([identifier isEqualToString:@"Date"]) {
        cell = (ADHBaseCell *)[tableView makeViewWithIdentifier:@"cellId" owner:nil];
        text = [ADHDateUtil formatStringWithDate:item.date dateFormat:@"HH:mm:ss"];
        cell.textField.stringValue = text;
    }
    cell.delegate = self;
    return cell;
}

//排序
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    NSSortDescriptor * sortDescriptor = nil;
    if([aTableView sortDescriptors].count > 0){
        sortDescriptor = [[aTableView sortDescriptors] objectAtIndex:0];
    }
    self.sortDescriptor = sortDescriptor;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self cookList];
        [self updateDisplayList];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark -----------------   cell event   ----------------

- (void)cellClicked: (ADHBaseCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    ADHFileActivityItem *item = self.displayActivityList[row];
    [self previewItem:item];
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point {
    NSInteger row = [self.tableView rowForView:cell];
    ADHFileActivityItem *item = self.displayActivityList[row];
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    if(item.isDir) {
        if(item.type == ADHFileActivityAdd) {
            //show in finder
            NSMenuItem * finderMenu = [[NSMenuItem alloc] initWithTitle:@"Show in Finder" action:@selector(showInFinderMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
            finderMenu.target = self;
            finderMenu.representedObject = item;
            [menu addItem:finderMenu];
            [menu addItem: [NSMenuItem separatorItem]];
            //download
            NSMenuItem * downloadMenu = [[NSMenuItem alloc] initWithTitle:@"Download" action:@selector(downloadMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
            downloadMenu.target = self;
            downloadMenu.representedObject = item;
            [menu addItem:downloadMenu];
        }
    }else {
        //show in finder
        NSMenuItem * finderMenu = [[NSMenuItem alloc] initWithTitle:@"Show in Finder" action:@selector(showInFinderMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
        finderMenu.target = self;
        finderMenu.representedObject = item;
        [menu addItem:finderMenu];
        //open with extranal
        NSMenuItem * openMenu = [[NSMenuItem alloc] initWithTitle:@"Open with External App" action:@selector(openWithExternalEditor:) keyEquivalent:adhvf_const_emptystr()];
        openMenu.target = self;
        openMenu.representedObject = item;
        [menu addItem:openMenu];
        [menu addItem: [NSMenuItem separatorItem]];
        //download
        NSMenuItem * downloadMenu = [[NSMenuItem alloc] initWithTitle:@"Download" action:@selector(downloadMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
        downloadMenu.target = self;
        downloadMenu.representedObject = item;
        [menu addItem:downloadMenu];
        //upload
        NSMenuItem * uploadMenu = [[NSMenuItem alloc] initWithTitle:@"Upload" action:@selector(uploadMenuClicked:) keyEquivalent:adhvf_const_emptystr()];
        uploadMenu.target = self;
        uploadMenu.representedObject = item;
        [menu addItem:uploadMenu];
    }
    if(menu.itemArray.count > 0) {
        [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
    }
}

- (NSString *)getItemLocalPath: (ADHFileActivityItem *)item {
    NSString *appPath = nil;
    if([self isGroupContainer]) {
        appPath = [self getGroupContainerPreviewPath:self.fsService.containerName];
    }else {
        appPath = [self getPreviewAppPath];
    }
    NSString *localPath = [appPath stringByAppendingPathComponent:item.path];
    return localPath;
}

//preview
- (void)previewItem: (ADHFileActivityItem *)item {
    if(item.isDir) return;
    //检查文件是否存在，不存在下载，存在不自动更新
    NSString *filePath = [self getItemLocalPath:item];
    BOOL exists = [ADHFileUtil fileExistsAtPath:filePath];
    if(!exists) {
        if(item.type != ADHFileActivityRemove) {
            [self _downloadItem:item];
        }
    }else {
        [self _previewItem:item];
    }
}

- (void)_previewItem: (ADHFileActivityItem *)item {
    NSString *filePath = [self getItemLocalPath:item];
    ADHFilePreviewController * previewController = self.previewController;
    previewController.filePath = filePath;
    [previewController reload];
}

//download
- (void)downloadMenuClicked: (NSMenuItem *)menu {
    ADHFileActivityItem *item = menu.representedObject;
    [self _downloadItem:item];
}

- (void)_downloadItem: (ADHFileActivityItem *)item {
    if(!item.isDir) {
        [self.view showHud];
        //下载
        NSString *filePath = [self getItemLocalPath:item];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"path"] = adhvf_safestringfy(item.path);
        if([self isGroupContainer]) {
            data[kRequestContainerKey] = adhvf_safestringfy(self.fsService.containerName);
        }
        if(self.fsService.sandboxWorkpath.length > 0) {
            data[kRequestWorkDirectoryKey] = adhvf_safestringfy(self.fsService.sandboxWorkpath);
        }
        __weak typeof(self) wself = self;
        [self.apiClient requestWithService:@"adh.sandbox" action:@"readfile" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
            [wself.view hideHud];
            BOOL success = [body[@"success"] boolValue];
            if(success) {
                //存储本地
                [ADHFileUtil saveData:payload atPath:filePath];
                [wself _previewItem:item];
            }
        } onFailed:^(NSError *error) {
            [wself.view hideHud];
        }];
    }else {
        //dir
        NSString *filePath = [self getItemLocalPath:item];
        if(![ADHFileUtil dirExistsAtPath:filePath]) {
            [ADHFileUtil createDirAtPath:filePath];
        }
    }
}

//upload
- (void)uploadMenuClicked: (NSMenuItem *)menu {
    ADHFileActivityItem *item = menu.representedObject;
    NSString * filePath = [self getItemLocalPath:item];
    NSData * fileData = [[NSData alloc] initWithContentsOfFile:filePath];
    if(fileData.length == 0) {
        return;
    }
    [self.view showHud];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"path"] = adhvf_safestringfy(item.path);
    if([self isGroupContainer]) {
        data[kRequestContainerKey] = adhvf_safestringfy(self.fsService.containerName);
    }
    if(self.fsService.sandboxWorkpath.length > 0) {
        data[kRequestWorkDirectoryKey] = self.fsService.sandboxWorkpath;
    }
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.sandbox" action:@"writefile" body:data payload:fileData progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.view hideHud];
    } onFailed:^(NSError *error) {
        NSLog(@"%@",error);
        [wself.view hideHud];
    }];
}

//show in finder
- (void)showInFinderMenuClicked: (NSMenuItem *)menu {
    ADHFileActivityItem *item = menu.representedObject;
    NSString * filePath = [self getItemLocalPath:item];
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
}

//open with external
- (void)openWithExternalEditor: (NSMenuItem *)menu {
    ADHFileActivityItem *item = menu.representedObject;
    NSString * filePath = [self getItemLocalPath:item];
    [[NSWorkspace sharedWorkspace] openFile:filePath];
}

- (NSString *)getPreviewAppPath {
    //文件预览
    NSString * workPath = [[EnvtService sharedService] appFileWorkPath];
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

#pragma mark -----------------   file update notification   ----------------

- (void)onFileUpdate: (NSNotification *)notification {
    NSDictionary *data = notification.userInfo;
    AppContext *context = data[@"context"];
    if(context != self.context) {
        return;
    }
    ADHFileActivityItem *item = [ADHFileActivityItem itemWithData:data];
    if(item) {
        [self.activityList insertObject:item atIndex:0];
    }
    [self cookList];
    [self updateDisplayList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark -----------------   cook   ----------------

- (void)cookList
{
    //排序
    [self sortList];
    //搜索
    if(self.isSearching){
        //if searching, filter list
        NSString * keywords = self.keywords;
        [self filterWithKeywords:keywords];
    }
}

#pragma mark -----------------   sort   ----------------
- (void)sortList
{
    NSArray * activityList = self.activityList;
    NSSortDescriptor * descriptor = self.sortDescriptor;
    NSArray * sortedResult = activityList;
    NSString * sortKey = descriptor.key;
    BOOL ascending = descriptor.ascending;
    if([sortKey isEqualToString:@"Path"]){
        sortedResult = [activityList sortedArrayUsingComparator:^NSComparisonResult(ADHFileActivityItem * item1, ADHFileActivityItem * item2) {
            if(ascending){
                return [item1.path compare:item2.path options:NSCaseInsensitiveSearch];
            }else{
                return [item2.path compare:item1.path options:NSCaseInsensitiveSearch];
            }
        }];
    }else if([sortKey isEqualToString:@"Activity"]) {
        sortedResult = [activityList sortedArrayUsingComparator:^NSComparisonResult(ADHFileActivityItem * item1, ADHFileActivityItem * item2) {
            if(ascending){
                //order: add->edit->delete
                if(item1.type < item2.type) {
                    return NSOrderedAscending;
                }else if(item1.type > item2.type) {
                    return NSOrderedDescending;
                }else {
                    //file first, dir second
                    if(!item1.isDir && item2.isDir) {
                        return NSOrderedAscending;
                    }else if(item1.isDir && !item2.isDir){
                        return NSOrderedDescending;
                    }else {
                        return NSOrderedSame;
                    }
                }
            }else{
                if(item1.type < item2.type) {
                    return NSOrderedDescending;
                }else if(item1.type > item2.type) {
                    return NSOrderedAscending;
                }else {
                    //file first, dir second
                    if(!item1.isDir && item2.isDir) {
                        return NSOrderedAscending;
                    }else if(item1.isDir && !item2.isDir){
                        return NSOrderedDescending;
                    }else {
                        return NSOrderedSame;
                    }
                }
            }
        }];
    }else if([sortKey isEqualToString:@"Date"]) {
        sortedResult = [activityList sortedArrayUsingComparator:^NSComparisonResult(ADHFileActivityItem * item1, ADHFileActivityItem * item2) {
            if(ascending){
                return [item1.date compare:item2.date];
            }else{
                return [item2.date compare:item1.date];
            }
        }];
    }
    self.sortedActivityList = sortedResult;
}

- (void)updateDisplayList
{
    NSMutableArray * displayList = [NSMutableArray array];
    NSArray * viewList = [self viewActivityList];
    for (ADHFileActivityItem * item in viewList) {
        [displayList addObject:item];
    }
    self.displayActivityList = displayList;
}

#pragma mark -----------------   search   ----------------

- (void)searchTextDidChange:(NSNotification *)notification
{
    NSString * keywords = self.filterTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)searchTextDidEndEditing:(NSNotification *)notification
{
    NSString * keywords = self.filterTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)doSearchWithKeywords: (NSString *)keywords
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self filterWithKeywords:keywords];
        [self updateDisplayList];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)filterWithKeywords: (NSString *)keywords
{
    self.keywords = keywords;
    if(keywords.length == 0){
        self.filteredActivityList = nil;
    }else{
        NSMutableArray * activities = [NSMutableArray array];
        for (ADHFileActivityItem * item in self.sortedActivityList) {
            NSString * itemPath = item.path;
            if([itemPath rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound){
                [activities addObject:item];
            }
        }
        self.filteredActivityList = activities;
    }
}

- (NSArray *)viewActivityList
{
    NSArray * list = nil;
    if(!self.isSearching){
        list = self.sortedActivityList;
    }else{
        list = self.filteredActivityList;
    }
    return list;
}

- (BOOL)isSearching
{
    return (self.keywords.length > 0);
}


#pragma mark -----------------   other   ----------------

- (void)doOnWorkAppStateUpdate {
    if(!self.context.isConnected){
        self.stateOn = NO;
        [self updateStateUI];
    }
    if(self.shouldTryStart){
        [self tryStartRecord];
    }
}

- (void)tryStartRecord {
    if(self.context.isConnected){
        [self doStartRecord];
    }
}

- (void)doStartRecord {
    self.shouldTryStart = YES;
    [self.startButton showHud];
    __weak typeof(self) wself = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"start"] = @(1);
    if([self isGroupContainer]) {
        data[kRequestContainerKey] = adhvf_safestringfy(self.fsService.containerName);
    }
    if(self.fsService.sandboxWorkpath.length > 0) {
        data[kRequestWorkDirectoryKey] = adhvf_safestringfy(self.fsService.sandboxWorkpath);
    }
    [self.apiClient requestWithService:@"adh.sandbox" action:@"activityStart" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
        wself.stateOn = YES;
        [wself updateStateUI];
        [wself.startButton hideHud];
    } onFailed:^(NSError *error) {
        [wself.startButton hideHud];
    }];
}

- (void)doStopRecord {
    self.shouldTryStart = NO;
    [self.pauseButton showHud];
    __weak typeof(self) wself = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"start"] = @(0);
    if([self isGroupContainer]) {
        data[kRequestContainerKey] = adhvf_safestringfy(self.fsService.containerName);
    }
    if(self.fsService.sandboxWorkpath.length > 0) {
        data[kRequestWorkDirectoryKey] = adhvf_safestringfy(self.fsService.sandboxWorkpath);
    }
    [self.apiClient requestWithService:@"adh.sandbox" action:@"activityStart" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
        wself.stateOn = NO;
        [wself updateStateUI];
        [wself.pauseButton hideHud];
    } onFailed:^(NSError *error) {
        [wself.pauseButton hideHud];
    }];
}

- (IBAction)startButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    [self doStartRecord];
}

- (IBAction)pauseButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    [self doStopRecord];
}

- (IBAction)clearButtonPressed:(id)sender {
    [self.activityList removeAllObjects];
    self.filteredActivityList = nil;
    self.sortedActivityList = nil;
    [self updateDisplayList];
    [self.tableView reloadData];
}

- (void)updateStateUI
{
    self.startButton.hidden = self.stateOn;
    self.pauseButton.hidden = !self.startButton.hidden;
}

- (IBAction)changeModeButtonPressed:(id)sender {
    if(self.stateOn) {
        [self doStopRecord];
    }
    [self.container switchToTreeMode];
}

- (BOOL)isNotSandbox {
    return (self.context.app.isMacOS && !self.context.app.isSandboxed);
}

@end
