//
//  StateMasterIndexViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/30.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "StateMasterIndexViewController.h"
#import "StateMasterViewController.h"
#import "StateMasterService.h"
#import "StateCollectionViewItem.h"
#import "StateCollectionAddItem.h"
#import "StateCollectionSectionView.h"
#import "StateItem.h"
#import "NSObject+ADHUtil.h"
#import "DeviceUtil.h"

//第一个默认需要(其实多少都没关系)
static NSInteger kFirstSortIndex = 10000;

static CGFloat const kPadding = 60.0f;
static CGFloat const kItemWidth = 220;
static CGFloat const kItemHeight = 160.0f;
static CGFloat const kSpacing = 30.0f;
//免费用户最多允许添加2个
static NSInteger const kMaxEncodeCount = 2;

@interface StateMasterIndexViewController ()<NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout, StateCollectionAddItemDelegate,StateCollectionViewItemDelegate>

@property (nonatomic, strong) IBOutlet NSCollectionView *collectionView;
@property (nonatomic, strong) IBOutlet NSCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) StateMasterService * service;
@property (nonatomic, strong) NSArray<StateItem *> *list;
@property (nonatomic, strong) NSArray<StateItem *> *sharedList;

@property (nonatomic, strong) StateCollectionSectionView *shareHeaderView;

@end

@implementation StateMasterIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValue];
    [self setupUI];
    [self addNotification];
    [self updateContent];
}

- (void)initValue {
    StateMasterService *service = [StateMasterService serviceWithContext:self.context];
    self.service = service;
}

- (void)setupUI {
    self.view.wantsLayer = YES;
    self.collectionView.wantsLayer = YES;
    NSCollectionViewFlowLayout *flowLayout = self.flowLayout;
    flowLayout.sectionInset = NSEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding);
    flowLayout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    flowLayout.minimumLineSpacing = kSpacing;
    //实际会调整为60
    flowLayout.minimumInteritemSpacing = 0;
    [self.collectionView registerClass:[StateCollectionViewItem class] forItemWithIdentifier:NSStringFromClass([StateCollectionViewItem class])];
    [self.collectionView registerClass:[StateCollectionAddItem class] forItemWithIdentifier:NSStringFromClass([StateCollectionAddItem class])];
    [self.collectionView registerClass:[StateCollectionSectionView class] forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:NSStringFromClass([StateCollectionSectionView class])];
    [self updateAppearanceUI];
    
    [self.collectionView registerForDraggedTypes:@[NSPasteboardTypeString]];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    if([Appearance isDark]) {
        self.collectionView.layer.backgroundColor = [Appearance colorWithHex:0x323232].CGColor;
    }else {
        self.collectionView.layer.backgroundColor = [Appearance colorWithHex:0xE6E6E6].CGColor;
    }
    self.view.layer.backgroundColor = self.collectionView.layer.backgroundColor;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    NSSize size = self.view.size;
    CGFloat width = size.width;
    CGFloat itemWidth = kItemWidth;
    CGFloat spacing = kSpacing;
    CGFloat padding = kPadding;
    CGFloat oneSize = itemWidth + spacing;
    NSInteger capacity = width / oneSize;
    CGFloat needWidth = capacity * itemWidth + padding*2;
    if(capacity > 1) {
        needWidth += (capacity-1) * spacing;
    }
    if(width < needWidth) {
        capacity -= 1;
    }
    if(capacity <= 1) {
        capacity = 1;
    }
    CGFloat centerWidth = capacity * itemWidth + (capacity-1) * spacing;
    CGFloat leftSpace = width - centerWidth;
    CGFloat actualPadding = leftSpace/2;
    self.flowLayout.sectionInset = NSEdgeInsetsMake(kPadding, actualPadding, kSpacing, actualPadding);
    [self.collectionView reloadData];
    [self.view.window makeFirstResponder:self.collectionView];
}

- (void)updateContent {
    [self updateContentOnCompletion:nil];
}

- (void)updateContentOnCompletion: (void (^)(void))completionBlock {
    __weak typeof(self) wself = self;
    [self.service refreshStateWithCompletion:^{
        NSArray<StateItem *> *list = [wself.service getAppItems];
        if(!isPro) {
            if(list.count > kMaxEncodeCount) {
                list = [list subarrayWithRange:NSMakeRange(0, kMaxEncodeCount)];
            }
        }
        NSMutableArray<StateItem *> *appList = [list mutableCopy];
        //add item
        StateItem *addItem = [[StateItem alloc] init];
        addItem.add = YES;
        [appList addObject:addItem];
        wself.list = appList;
        /*
        NSArray<StateItem *> * sharedList = [wself.service getSharedItems];
        wself.sharedList = sharedList;
         */
        [wself updateUI];
        if(completionBlock) {
            completionBlock();
        }
    }];
}

- (void)updateUI {
    [self.collectionView reloadData];
}

#pragma mark -----------------   collection view   ----------------


- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event {
    return YES;
}

- (nullable id <NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath {
    StateItem *stateItem = self.list[indexPath.item];
    return [NSString stringWithFormat:@"%zd",indexPath.item];
    
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(nullable id)item proposedChildIndex:(NSInteger)index {
    return YES;
}

/*
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    NSSize size;
    if(section == 1) {
        size = NSMakeSize(collectionView.width, 30.0f);
    }else {
        size = NSZeroSize;
    }
    return size;
}
 
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    NSInteger count = 1;
    if(self.sharedList.count > 0) {
        count += 1;
    }
    return count;
}

- (NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSView *sectionView = nil;
    if(section == 1) {
        if(!self.shareHeaderView) {
            StateCollectionSectionView *headerView = [collectionView makeSupplementaryViewOfKind:kind withIdentifier:NSStringFromClass([StateCollectionSectionView class]) forIndexPath:indexPath];
            self.shareHeaderView = headerView;
        }
        [self.shareHeaderView setData:@{
            @"title" : @"Shared items",
        }];
        sectionView = self.shareHeaderView;
    }else {
        sectionView = [[NSView alloc] init];
    }
    return sectionView;
}
*/

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if(section == 1) {
        count = self.sharedList.count;
    }else {
        count = self.list.count;
    }
    return count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger itemIndex = indexPath.item;
    StateItem *item = nil;
    if(section == 1) {
        item = self.sharedList[itemIndex];
    }else {
        item = self.list[itemIndex];
    }
    NSCollectionViewItem *viewItem = nil;
    if(item.isAdd) {
        StateCollectionAddItem *addViewItem = [collectionView makeItemWithIdentifier:NSStringFromClass([StateCollectionAddItem class]) forIndexPath:indexPath];
        [addViewItem setData:nil];
        addViewItem.delegate = self;
        viewItem = addViewItem;
    }else {
        StateCollectionViewItem *stateViewItem = [collectionView makeItemWithIdentifier:NSStringFromClass([StateCollectionViewItem class]) forIndexPath:indexPath];
        [stateViewItem setData:item];
        stateViewItem.delegate = self;
        viewItem = stateViewItem;
    }
    return viewItem;
}

- (void)stateCollectionAddRequest: (StateCollectionAddItem *)addItem {
    NSInteger count = self.list.count;
    if(count >= (kMaxEncodeCount+1)) {
        if(!doProCheckRoutine()) {
            return;
        }
    }
    NSString *workPath = [self getWorkPath];
    NSString *name = [self getValidFolderName:workPath preferedName:@"New Item"];
    NSString *folderName = [self getTimeBasedFileName];
    NSString *statePath = [workPath stringByAppendingPathComponent:folderName];
    //创建目录
    [ADHFileUtil createDirAtPath:statePath];
    //创建配置文件
    NSArray *subFolders = @[kStateItemSandbox,kStateItemUserDefaults];
    for (NSString *folder in subFolders) {
        NSString *path = [statePath stringByAppendingPathComponent:folder];
        [ADHFileUtil createDirAtPath:path];
    }
    NSString *configPath = [statePath stringByAppendingPathComponent:kStateConfigName];
    [ADHFileUtil createFileAtPath:configPath];
    NSMutableDictionary *configData = [NSMutableDictionary dictionary];
    configData[kStateConfigTitleKey] = name;
    NSInteger sortIndex = 0;
    if(self.list.count > 1) {
        StateItem *firstItem = self.list[0];
        sortIndex = firstItem.sortIndex-1;
    }else {
        sortIndex = kFirstSortIndex;
    }
    configData[kStateConfigSortKey] = [NSNumber numberWithInteger:sortIndex];
    [configData writeToFile:configPath atomically:YES];
    __weak typeof(self) wself = self;
    [self updateContentOnCompletion:^{
        //创建后，打开编辑页
        if(wself.list.count > 0) {
            StateItem *stateItem = wself.list[0];
            [wself showStateContent:stateItem index:0];
        }
    }];
}

- (void)stateCollectionViewItem: (StateCollectionViewItem *)viewItem titleUpdate: (NSString *)title {
    NSIndexPath *indexPath = [self.collectionView indexPathForItem:viewItem];
    NSInteger section = indexPath.section;
    NSInteger itemIndex = indexPath.item;
    StateItem *stateItem = nil;
    if(section == 1) {
        stateItem = self.sharedList[itemIndex];
    }else {
        stateItem = self.list[itemIndex];
    }
    if(![stateItem.title isEqualToString:title]) {
        stateItem.title = title;
        [self saveStateItemData:stateItem];
    }
}

//sync
- (void)stateCollectionViewItemSyncRequest: (StateCollectionViewItem *)viewItem {
    if(![self doCheckConnectionRoutine]){
        return;
    }
    //这里检测不够完善，version有可能为0
    NSInteger version = [self.context.app frameworkVersionValue];
    if(version > 0 && version < 126) {
        [self showVersionNotSupport];
        return;
    }
    NSIndexPath *indexPath = [self.collectionView indexPathForItem:viewItem];
    NSInteger section = indexPath.section;
    NSInteger itemIndex = indexPath.item;
    StateItem *stateItem = nil;
    if(section == 1) {
        stateItem = self.sharedList[itemIndex];
    }else {
        stateItem = self.list[itemIndex];
    }
    [viewItem setSyncState:YES];
    //默认progress
    [viewItem setProgress:0.05];
    __weak typeof(self) wself = self;
    [self.service syncStateAtPath:stateItem.workPath onProgress:^(float progress) {
        [viewItem setProgress:progress];
    } onCompletion:^{
        [viewItem setSyncState:NO];
        [wself showSuccessWithText:kLocalized(@"state_sync_succeed")];
    } onFailed:^(BOOL paused){
        [viewItem setSyncState:NO];
        if(!paused) {
            [wself showErrorWithText:kLocalized(@"state_sync_failed")];
        }
    }];
}

- (void)stateCollectionViewItemPauseRequest: (StateCollectionViewItem *)viewItem {
    [self.service pauseCurrentSync];
    [viewItem setSyncState:NO];
}

- (void)showStateContent: (StateItem *)stateItem index: (NSInteger)index {
    StateMasterViewController *vc = [[StateMasterViewController alloc] init];
    vc.context = self.context;
    vc.stateItem = stateItem;
    vc.tabIndex = index;
    NSWindow *window = self.view.window;
    CGRect winFrame = window.frame;
    CGFloat factor = 0.75;
    CGSize preferSize = CGSizeMake(factor*CGRectGetWidth(winFrame), factor*CGRectGetHeight(winFrame));
    vc.view.frame = CGRectMake(0, 0, preferSize.width, preferSize.height);
    [self presentViewControllerAsModalWindow:vc];
}

//edit, copy, shared, show in finder, delete
- (void)stateCollectionViewItemMore: (StateCollectionViewItem *)viewItem atPosition:(NSPoint)pos {
    NSIndexPath *indexPath = [self.collectionView indexPathForItem:viewItem];
    NSInteger section = indexPath.section;
    NSInteger itemIndex = indexPath.item;
    StateItem *stateItem = nil;
    if(section == 1) {
        stateItem = self.sharedList[itemIndex];
    }else {
        stateItem = self.list[itemIndex];
    }
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //edit
    {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Edit Content" action:@selector(editMenuSelect:) keyEquivalent:adhvf_const_emptystr()];
        menuItem.target = self;
        menuItem.representedObject = stateItem;
        [menu addItem:menuItem];
    }
    //show in finder
    {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Show in Finder" action:@selector(showInFinderMenuSelect:) keyEquivalent:adhvf_const_emptystr()];
        menuItem.target = self;
        menuItem.representedObject = stateItem;
        [menu addItem:menuItem];
    }
    //copy
    {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Duplicate" action:@selector(duplicateMenuSelect:) keyEquivalent:adhvf_const_emptystr()];
        menuItem.target = self;
        menuItem.representedObject = stateItem;
        [menu addItem:menuItem];
    }
    //shared
//    {
//        if(!stateItem.isShared) {
//            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Shared" action:@selector(sharedMenuSelect:) keyEquivalent:adhvf_const_emptystr()];
//            menuItem.target = self;
//            menuItem.representedObject = stateItem;
//            [menu addItem:menuItem];
//        }
//    }
    //Delete
    {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMenuSelect:) keyEquivalent:adhvf_const_emptystr()];
        menuItem.target = self;
        menuItem.representedObject = stateItem;
        [menu addItem:menuItem];
    }
    //sort
       {
           if(itemIndex != 0) {
               NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Move Forward" action:@selector(moveForwardMenuSelect:) keyEquivalent:adhvf_const_emptystr()];
               menuItem.target = self;
               menuItem.representedObject = stateItem;
               [menu addItem:menuItem];
           }
       }
    [menu popUpMenuPositioningItem:nil atLocation:pos inView:viewItem.view];
}

- (void)editMenuSelect: (NSMenuItem *)menu {
    StateItem *stateItem = menu.representedObject;
    if([DeviceUtil isOptionPressed]) {
        NSString *statePath = stateItem.workPath;
        NSString *path = [statePath stringByAppendingPathComponent:kStateItemSandbox];
        [UrlUtil openInFinder:path];
    }else {
        [self showStateContent:stateItem index:0];
    }
}

- (void)duplicateMenuSelect: (NSMenuItem *)menu {
    NSInteger count = self.list.count;
    if(count >= (kMaxEncodeCount+1)) {
        if(!doProCheckRoutine()) {
            return;
        }
    }
    StateItem *stateItem = menu.representedObject;
    NSString *name = [NSString stringWithFormat:@"%@ Duplicated",stateItem.title];
    NSString *title = [self getValidFolderName:stateItem.workPath preferedName:name];
    NSString *workPath = [self getWorkPath];
    NSString *folderName = [self getTimeBasedFileName];
    NSString *statePath = [workPath stringByAppendingPathComponent:folderName];
    //创建目录
    [ADHFileUtil createDirAtPath:statePath];
    //创建配置文件
    NSString *configPath = [statePath stringByAppendingPathComponent:kStateConfigName];
    [ADHFileUtil createFileAtPath:configPath];
    NSMutableDictionary *configData = [NSMutableDictionary dictionary];
    configData[kStateConfigTitleKey] = title;
    //sort
    NSInteger sortIndex = 0;
    if(self.list.count > 1) {
        StateItem *firstItem = self.list[0];
        sortIndex = firstItem.sortIndex-1;
    }else {
        sortIndex = kFirstSortIndex;
    }
    configData[kStateConfigSortKey] = [NSNumber numberWithInteger:sortIndex];
    [configData writeToFile:configPath atomically:YES];
    //拷贝内容
    NSArray *oldItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:stateItem.workPath error:nil];
    for (NSString *oldItem in oldItems) {
        if(![oldItem isEqualToString:kStateConfigName]) {
            NSString *oldPath = [stateItem.workPath stringByAppendingPathComponent:oldItem];
            NSString *toPath = [statePath stringByAppendingPathComponent:oldItem];
            [[NSFileManager defaultManager] copyItemAtPath:oldPath toPath:toPath error:nil];
        }
    }
    //update
    [self updateContent];
}

- (void)sharedMenuSelect: (NSMenuItem *)menu {
    StateItem *stateItem = menu.representedObject;
    NSString *sharedPath = [self getSharedPath];
    NSString *fromPath = stateItem.workPath;
    NSString *folderName = [stateItem.workPath lastPathComponent];
    NSString *targetPath = [sharedPath stringByAppendingPathComponent:folderName];
    BOOL succeed = [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:targetPath error:nil];
    if(succeed) {
        stateItem.shared = YES;
        NSInteger sortIndex = 0;
        if(self.sharedList.count > 0) {
            StateItem *firstItem = self.sharedList[0];
            sortIndex = firstItem.sortIndex-1;
        }
        stateItem.sortIndex = sortIndex;
        stateItem.workPath = targetPath;
        [self saveStateItemData:stateItem];
        [self updateContent];
    }else {
        [self showError];
    }
}

- (void)moveForwardMenuSelect: (NSMenuItem *)menu {
    StateItem *stateItem = menu.representedObject;
    [self.service moveStateItemForward:stateItem];
    [self updateContent];
}

- (void)saveStateItemData: (StateItem *)item {
    [self.service saveStateItemData:item];
}

- (void)showInFinderMenuSelect: (NSMenuItem *)menu {
    StateItem *stateItem = menu.representedObject;
    [UrlUtil openInFinder:stateItem.workPath];
}

- (void)deleteMenuSelect: (NSMenuItem *)menu {
    __weak typeof(self) wself = self;
    [ADHAlert alertWithMessage:@"Alert" infoText:@"Are you sure to delete it" comfirmBlock:^{
        StateItem *stateItem = menu.representedObject;
        NSString *statePath = stateItem.workPath;
        [ADHFileUtil deleteFileAtPath:statePath];
        [wself updateContent];
    } cancelBlock:^{
        
    }];
}

- (NSString *)getValidFolderName: (NSString *)parentPath preferedName: (NSString *)preferedName {
    NSString *resultName = nil;
    NSInteger index = 0;
    do {
        NSString *name = preferedName;
        if(index > 0) {
            name = [NSString stringWithFormat:@"%@%zd",name,index];
        }
        BOOL exists = NO;
        for (StateItem *item in self.list) {
            if([item.title isEqualToString:name]) {
                exists = YES;
                break;
            }
        }
        if(!exists) {
            resultName = name;
        }
        index++;
    } while (resultName.length == 0);
    return resultName;
}

- (NSString *)getTimeBasedFileName {
    NSTimeInterval time = [ADHDateUtil currentTimeInterval];
    NSString *timeStr = [NSString stringWithFormat:@"%f",time];
    NSString *md5 = [timeStr md5Digest];
    return md5;
}

- (NSString *)getWorkPath {
    NSString * rootPath = [EnvtService.service stateMasterPath];
    ADHApp * app = self.context.app;
    NSString *appPath = app.bundleId;
    NSString * resultPath = [rootPath stringByAppendingPathComponent:appPath];
    return resultPath;
}

- (NSString *)getSharedPath {
    NSString * rootPath = [EnvtService.service stateMasterPath];
    NSString *resultPath = [rootPath stringByAppendingPathComponent:@"shared"];
    return resultPath;
}

- (void)showVersionNotSupport {
    NSString *tip = [NSString stringWithFormat:kLocalized(@"frameworkrequire_tip"),@"1.2.6"];
    [ADHAlert alertWithMessage:kLocalized(@"alert_title") infoText:tip confirmText:kLocalized(@"update") cancelText:kAppLocalized(@"Cancel") comfirmBlock:^{
        [UrlUtil openExternalLocalizedUrl:@"web_usage"];
    } cancelBlock:^{
        
    }];
}

@end
