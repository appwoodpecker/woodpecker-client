//
//  StateSandboxViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/25.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "StateSandboxViewController.h"
#import "ADHFileNodeUtil.h"
#import "StateFileItemView.h"
#import "ADHFilePreviewController.h"

@interface StateSandboxViewController ()<NSSplitViewDelegate, StateFileItemViewDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSView *previewLayout;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *fsTreeLayout;
@property (weak) IBOutlet NSView *topLineView;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSView *fsActionLayout;
@property (weak) IBOutlet NSButton *folderButton;

@property (nonatomic, strong) ADHFileNode *rootNode;
@property (nonatomic, strong) ADHFilePreviewController * previewController;

@end

@implementation StateSandboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupWorkSpace];
    [self loadFSTree];
    [self updateContentUI];
}

- (void)setupUI {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:@"StateFileItemView" bundle:nil];
    [self.outlineView registerNib:nib forIdentifier:NSStringFromClass([StateFileItemView class])];
    self.outlineView.rowHeight = 30.0f;
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
    self.fsActionLayout.wantsLayer = YES;
    self.topLineView.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)updateAppearanceUI {
    self.fsActionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    self.topLineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
}

- (void)setupWorkSpace {
    NSString *workPath = [self getWorkPath];
    NSArray *defaultFolders = @[@"Documents",@"Library",@"tmp"];
    for (NSString *name in defaultFolders) {
        NSString *path = [workPath stringByAppendingPathComponent:name];
        if(![ADHFileUtil dirExistsAtPath:path]) {
            [ADHFileUtil createDirAtPath:path];
        }
    }
}

- (NSString *)getWorkPath {
    NSString *appId = @"Sandbox";
    NSString *resultPath = [self.stateItem.workPath stringByAppendingPathComponent:appId];
    return resultPath;
}

- (void)loadFSTree {
    NSString *workPath = [self getWorkPath];
    ADHFileNode *rootNode = [ADHFileNodeUtil scanFolder:workPath];
    self.rootNode = rootNode;
}

- (void)updateContentUI {
    [self.outlineView reloadData];
}

#pragma mark -----------------  OutlineView DataSource & Delegate   ----------------

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    NSInteger count = 0;
    ADHFileNode * previewItem = item;
    if(!previewItem){
        previewItem = self.rootNode;
    }
    count = previewItem.children.count;
    return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    ADHFileNode * previewItem = item;
    if(!previewItem){
        previewItem = self.rootNode;
    }
    NSArray * children = previewItem.children;
    return children[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    ADHFileNode * previewItem = item;
    if(!previewItem){
        previewItem = self.rootNode;
    }
    return previewItem.isDir;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    StateFileItemView * itemView = [outlineView makeViewWithIdentifier:NSStringFromClass([StateFileItemView class]) owner:nil];
    ADHFileNode * previewItem = item;
    itemView.delegate = self;
    [itemView setData:previewItem];
    return itemView;
}

#pragma mark -----------------   split view delegate   ----------------

- (CGFloat)fsTreePreferWidth {
    return 300.0f;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    CGFloat minWidth = proposedMinimumPosition;
    if(dividerIndex == 0){
        minWidth = [self fsTreePreferWidth];
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
        ADHFileNode * fileNode = (ADHFileNode *)[self.outlineView itemAtRow:row];
        if(!fileNode.isDir){
            [self doPreviewItem:fileNode];
        }
    }
}

//双击下载/上传
- (void)cellDoubleClicked: (ADHBaseCell *)cell {
    NSInteger row = [self.outlineView rowForView:cell];
    [self.outlineView deselectAll:nil];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
    if(row != NSNotFound && row >= 0){
        ADHFileNode * fileNode = (ADHFileNode *)[self.outlineView itemAtRow:row];
        if([fileNode isDir]) {
            if(![self.outlineView isItemExpanded:fileNode]) {
                [self.outlineView expandItem:fileNode expandChildren:NO];
            }else {
                [self.outlineView collapseItem:fileNode collapseChildren:NO];
            }
        }else {
            [self doPreviewItem:fileNode];
        }
    }
}

- (void)stateItemView: (StateFileItemView *)itemView contentUpdateRequest: (NSString *)newValue {
    NSInteger row = [self.outlineView rowForView:itemView];
    ADHFileNode * fileNode = [self.outlineView itemAtRow:row];
    ADHFileNode *parent = fileNode.parent;
    NSString *path = [self getFileNodePath:parent];
    NSString *tmpPath = [path stringByAppendingPathComponent:newValue];
    BOOL succeed = NO;
    if(![ADHFileUtil dirExistsAtPath:tmpPath]) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *oldPath = [self getFileNodePath:fileNode];
        succeed = [fm moveItemAtPath:oldPath toPath:tmpPath error:nil];
        if(succeed) {
            fileNode.name = newValue;
            [itemView setEditState:NO];
            [self.outlineView reloadItem:fileNode];
        }
    }
    if(!succeed) {
        NSString *tip = [NSString stringWithFormat:@"Could not rename \"%@\" to \"%@\".",fileNode.name,newValue];
        [ADHAlert alertWithMessage:@"Rename Failed" infoText:tip comfirmBlock:nil];
    }
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point {
    NSInteger row = [self.outlineView rowForView:cell];
    [self.outlineView deselectAll:nil];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
    ADHFileNode * fileNode = [self.outlineView itemAtRow:row];
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //open in finder
    NSMenuItem * finderMenu = [[NSMenuItem alloc] initWithTitle:@"Show in Finder" action:@selector(showInFinderMenuSelect:) keyEquivalent:adhvf_const_emptystr()];
    finderMenu.target = self;
    finderMenu.representedObject = fileNode;
    [menu addItem:finderMenu];
    //new folder
    NSMenuItem * folderMenu = [[NSMenuItem alloc] initWithTitle:@"New Folder" action:@selector(createFolderMenuSelect:) keyEquivalent:adhvf_const_emptystr()];
    folderMenu.target = self;
    folderMenu.representedObject = fileNode;
    [menu addItem:folderMenu];
    if(![self isTopNode:fileNode]) {
        //delete
        NSMenuItem * deleteMenu = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        deleteMenu.target = self;
        deleteMenu.representedObject = fileNode;
        [menu addItem:deleteMenu];
    }
    [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
}

- (void)showInFinderMenuSelect: (NSMenuItem *)menu {
    ADHFileNode * fileNode = menu.representedObject;
    NSString * path = [self getFileNodePath:fileNode];
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
}

- (void)createFolderMenuSelect: (NSMenuItem *)menu {
    ADHFileNode * fileNode = menu.representedObject;
    ADHFileNode *parent = nil;
    NSInteger index = 0;
    if(!fileNode.isDir) {
        parent = fileNode.parent;
        NSInteger thisIndex = [parent.children indexOfObject:fileNode];
        if(thisIndex != NSNotFound && thisIndex < parent.children.count) {
            index = thisIndex + 1;
        }
    }else {
        parent = fileNode;
        index = 0;
    }
    NSString * path = [self getFileNodePath:parent];
    //在file node下创建文件夹
    NSString *name = [self getValidFolderName:path];
    NSString *folderPath = [path stringByAppendingPathComponent:name];
    [ADHFileUtil createDirAtPath:folderPath];
    ADHFileNode *folderNode = [ADHFileNodeUtil scanFolder:folderPath];
    [parent addChild:folderNode atIndex:index];
    [self.outlineView reloadItem:parent reloadChildren:YES];
    [self.outlineView expandItem:parent];
    StateFileItemView *itemView = [self viewForItem:folderNode];
    [itemView setEditState:YES];
    
}

- (NSString *)getValidFolderName: (NSString *)parentPath {
    NSString *resultName = nil;
    NSInteger index = 0;
    do {
        NSString *name = @"New Folder";
        if(index > 0) {
            name = [NSString stringWithFormat:@"%@%zd",name,index];
        }
        NSString *path = [parentPath stringByAppendingPathComponent:name];
        if(![ADHFileUtil dirExistsAtPath:path]) {
            resultName = name;
        }
        index++;
    } while (resultName.length == 0);
    return resultName;
}

- (void)deleteMenuSelected: (NSMenuItem *)menu {
    ADHFileNode * fileNode = menu.representedObject;
    NSString * path = [self getFileNodePath:fileNode];
    [ADHFileUtil deleteFileAtPath:path];
    ADHFileNode *parent = fileNode.parent;
    [parent deleteChild:fileNode];
    [self.outlineView reloadItem:parent reloadChildren:YES];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldTypeSelectForEvent:(NSEvent *)event withCurrentSearchString:(NSString *)searchString {
    return YES;
}

#pragma mark -----------------   drag drop support   ----------------

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(nullable id)item proposedChildIndex:(NSInteger)index {
    NSPasteboard *pb = info.draggingPasteboard;
    NSDragOperation retValue = NSDragOperationNone;
    if(item && item != self.rootNode) {
        //only allow copy to app folder
        retValue = NSDragOperationCopy;
    }
    return retValue;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(nullable id)item childIndex:(NSInteger)index {
    ADHFileNode *fileNode = item;
    NSPasteboard *pb = info.draggingPasteboard;
    NSArray * filePaths = [pb propertyListForType:NSFilenamesPboardType];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * itemPath = [self getFileNodePath:fileNode];
    StateFileItemView *rowView = [self viewForItem:fileNode];
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
        ADHFileNode *tmpNode = [ADHFileNodeUtil scanFolder:itemPath];
        for (ADHFileNode *child in tmpNode.children) {
            child.parent = fileNode;
        }
        fileNode.children = tmpNode.children;
        dispatch_async(dispatch_get_main_queue(), ^{
            [rowView hideHud];
            [wself.outlineView reloadItem:fileNode reloadChildren:YES];
        });
    });
    return YES;
}

- (void)doPreviewItem: (ADHFileNode *)fileNode {
    ADHFilePreviewController * previewController = self.previewController;
    NSString *filePath = [self getFileNodePath:fileNode];
    previewController.filePath = filePath;
    [previewController reload];
}

- (NSString *)getFileNodePath: (ADHFileNode *)node {
    NSString *workPath = [self getWorkPath];
    workPath = [workPath stringByDeletingLastPathComponent];
    NSString *nodePath = [node getPath];
    NSString *path = [workPath stringByAppendingPathComponent:nodePath];
    return path;
}

- (StateFileItemView *)viewForItem: (ADHFileNode *)item {
    NSInteger row = [self.outlineView rowForItem:item];
    StateFileItemView *rowView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:NO];
    return rowView;
}

- (BOOL)isTopNode: (ADHFileNode *)node {
    BOOL ret = NO;
    if(node == self.rootNode) {
        ret = YES;
    }else {
        for (ADHFileNode *child in self.rootNode.children) {
            if(child == node) {
                ret = YES;
                break;
            }
        }
    }
    return ret;
}

- (IBAction)loadFSButtonPressed:(id)sender {
    [self loadFSTree];
    [self updateContentUI];
}

- (IBAction)folderButtonPressed:(id)sender {
    NSString *targetPath = [self getWorkPath];
    [[NSWorkspace sharedWorkspace] openFile:targetPath];
}

- (void)keyDown:(NSEvent *)event {
    [super keyDown:event];
    NSInteger row = self.outlineView.selectedRow;
    if(row != NSNotFound) {
        ADHFileNode *fileNode = [self.outlineView itemAtRow:row];
        if(fileNode && ![self isTopNode:fileNode] && fileNode.isDir) {
            if(event.keyCode == 36) {
                StateFileItemView *itemView = [self viewForItem:fileNode];
                [itemView setEditState:YES];
            }
        }
    }
    NSLog(@"code: %d",event.keyCode);
}

- (BOOL)worksWhenModal {
    return YES;
}

@end
