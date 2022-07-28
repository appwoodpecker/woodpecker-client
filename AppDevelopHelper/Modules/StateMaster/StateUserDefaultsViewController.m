//
//  StateUserDefaultsViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/25.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "StateUserDefaultsViewController.h"
#import "ADHKVItem.h"
#import "UDKVItemCell.h"
#import "DeviceUtil.h"
#import "UserDefaultAddViewController.h"
#import "ADHUserDefaultUtil.h"
#import "StateMasterService.h"

@interface StateUserDefaultsViewController ()<NSOutlineViewDataSource,NSOutlineViewDelegate,ADHBaseCellDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSTableColumn *keyColumn;
@property (weak) IBOutlet NSTableColumn *typeColumn;
@property (weak) IBOutlet NSTableColumn *valueColumn;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSView *actionLayout;

@property (nonatomic, strong) NSMutableDictionary *rootData;
@property (nonatomic, strong) ADHKVItem * rootKVItem;

@end

@implementation StateUserDefaultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self setupWorkSpace];
    [self loadContent];
}

- (void)setupAfterXib {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([UDKVItemCell class]) bundle:nil];
    [self.outlineView registerNib:nib forIdentifier:NSStringFromClass([UDKVItemCell class])];
    self.outlineView.intercellSpacing = NSZeroSize;
    self.outlineView.rowHeight = 28.0f;
    self.view.wantsLayer = YES;
    self.actionLayout.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    self.view.layer.backgroundColor = [Appearance backgroundColor].CGColor;
    self.actionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    [self.addButton setTintColor:[Appearance actionImageColor]];
    [self.outlineView reloadData];
}

//update content
- (void)loadContent {
    NSString * path = [self getUserDefaultPath];
    NSDictionary * data = [[NSDictionary alloc] initWithContentsOfFile:path];
    if(!data) {
        data = @{};
    }
    self.rootData = [data mutableCopy];
    ADHKVItem * rootItem = [ADHKVItem kvItemWithData:data sort:YES];
    self.rootKVItem = rootItem;
    [self.outlineView reloadData];
}

- (void)setupWorkSpace {
    NSString *workPath = [self getWorkPath];
    if(![ADHFileUtil dirExistsAtPath:workPath]) {
        [ADHFileUtil createDirAtPath:workPath];
    }
    NSString *filePath = [self getUserDefaultPath];
    if(![ADHFileUtil fileExistsAtPath:filePath]) {
        [ADHFileUtil createFileAtPath:filePath];
    }
}

- (NSString *)getUserDefaultPath {
    NSString *workPath = [self getWorkPath];
    NSString *fileName = @"standard.plist";
    NSString *filePath = [workPath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (NSString *)getWorkPath {
    NSString *appId = @"UserDefaults";
    NSString *resultPath = [self.stateItem.workPath stringByAppendingPathComponent:appId];
    return resultPath;
}

- (void)syncDataToFile {
    NSString *path = [self getUserDefaultPath];
    [self.rootData writeToFile:path atomically:YES];
}


#pragma mark -----------------  OutlineView DataSource & Delegate   ----------------

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    NSInteger count = 0;
    ADHKVItem * kvItem = item;
    if(!kvItem){
        kvItem = self.rootKVItem;
    }
    if([kvItem isContainer]){
        count = [kvItem viewChildren].count;
    }
    return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    ADHKVItem * childItem = nil;
    ADHKVItem * kvItem = item;
    if(!kvItem){
        kvItem = self.rootKVItem;
    }
    if([kvItem isContainer]){
        NSArray<ADHKVItem *> *list = [kvItem viewChildren];
        if(index < list.count) {
            childItem = list[index];
        }
    }
    return childItem;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    ADHKVItem * kvItem = item;
    if(!kvItem){
        kvItem = self.rootKVItem;
    }
    return [kvItem isContainer];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    UDKVItemCell * cell = [outlineView makeViewWithIdentifier:NSStringFromClass([UDKVItemCell class]) owner:nil];
    ADHKVItem * kvItem = (ADHKVItem *)item;
    NSString * strValue = nil;
    NSColor * textColor = nil;
    if(tableColumn == self.keyColumn){
        strValue = kvItem.keyName;
        if(strValue.length == 0 && kvItem.keyIndex != NSNotFound){
            strValue = [NSString stringWithFormat:@"Item %zd",kvItem.keyIndex];
        }
    }else if(tableColumn == self.typeColumn){
        strValue = [ADHKVItem readbleNameWithType:kvItem.type];
    }else if(tableColumn == self.valueColumn){
        if(![kvItem isContainer]){
            strValue = [kvItem stringValue];
            textColor = [NSColor labelColor];
        }else{
            strValue = [NSString stringWithFormat:@"(%zd items)",kvItem.children.count];
            textColor = [NSColor secondaryLabelColor];
        }
    }
    [cell setData:strValue];
    [cell setTextColor:textColor];
    if(tableColumn == self.keyColumn) {
        [cell setPinState:kvItem.pin];
    }else {
        [cell setPinState:NO];
    }
    cell.delegate = self;
    return cell;
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point {
    NSInteger row = [self.outlineView rowForView:cell];
    ADHKVItem * kvItem = [self.outlineView itemAtRow:row];
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //copy key
    NSMenuItem * keyMenu = [[NSMenuItem alloc] initWithTitle:@"Copy Key" action:@selector(copyKeyMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    keyMenu.target = self;
    keyMenu.representedObject = kvItem;
    [menu addItem:keyMenu];
    if(kvItem.type != ADHKVItemTypeData){
        //copy value
        NSMenuItem *valueMenu = [[NSMenuItem alloc] initWithTitle:@"Copy Value" action:@selector(copyValueMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        valueMenu.target = self;
        valueMenu.representedObject = kvItem;
        [menu addItem:valueMenu];
    }
    //edit
    if([kvItem isEditable]){
        NSMenuItem *editMenu = [[NSMenuItem alloc] initWithTitle:@"Edit" action:@selector(editMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        editMenu.target = self;
        editMenu.representedObject = kvItem;
        [menu addItem:editMenu];
    }
    //remove
    if([self isFirstLevelItem:kvItem]) {
        NSMenuItem *removeMenu = [[NSMenuItem alloc] initWithTitle:@"Remove Item" action:@selector(removeMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        removeMenu.target = self;
        removeMenu.representedObject = kvItem;
        [menu addItem:removeMenu];
    }
    if(menu.itemArray.count > 0){
        [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
    }
}

- (void)copyValueMenuSelected: (NSMenuItem *)menu {
    ADHKVItem * item = menu.representedObject;
    NSString * strValue = nil;
    if(!item.isContainer){
        strValue = [item stringValue];
    }else{
        if([item isArray]){
            NSMutableArray * itemValues = [NSMutableArray array];
            for (ADHKVItem * subItem in item.children) {
                if(![subItem isContainer]){
                    NSString * value = [subItem stringValue];
                    [itemValues addObject:adhvf_safestringfy(value)];
                }
            }
            strValue = [itemValues componentsJoinedByString:@"\n"];
        }else if([item isDictioanry]){
            NSMutableArray * itemValues = [NSMutableArray array];
            for (ADHKVItem * subItem in item.children) {
                if(![subItem isContainer]){
                    NSString * key = subItem.keyName;
                    NSString * value = [subItem stringValue];
                    NSString * itemStrValue = [NSString stringWithFormat:@"%@ : %@",adhvf_safestringfy(key),adhvf_safestringfy(value)];
                    [itemValues addObject:itemStrValue];
                }
            }
            strValue = [itemValues componentsJoinedByString:@"\n"];
        }
    }
    if(strValue.length > 0){
        [DeviceUtil pasteText:strValue];
    }
}

- (void)copyKeyMenuSelected: (NSMenuItem *)menu {
    ADHKVItem * item = menu.representedObject;
    NSString * strValue = item.keyName;
    if(strValue.length > 0){
        [DeviceUtil pasteText:strValue];
    }
}

- (void)editMenuSelected: (NSMenuItem *)menu {
    ADHKVItem * item = (ADHKVItem *)menu.representedObject;
    NSInteger row = [self.outlineView rowForItem:item];
    if(row == NSNotFound) {
        return;
    }
    UDKVItemCell *cell = [self.outlineView viewAtColumn:2 row:row makeIfNecessary:NO];
    if(!cell) {
        return;
    }
    [cell setEditState:YES];
}

- (void)removeMenuSelected: (NSMenuItem *)menu {
    ADHKVItem * item = menu.representedObject;
    NSString * key = item.keyName;
    [self.rootData removeObjectForKey:key];
    [self syncDataToFile];
    [self loadContent];
    [self showSuccessWithText:@"Item removed"];
}

- (void)cellDoubleClicked: (ADHBaseCell *)cell {
    NSInteger row = [self.outlineView rowForView:cell];
    NSInteger column = [self.outlineView columnForView:cell];
    ADHKVItem * item = [self.outlineView itemAtRow:row];
    if([item isContainer]){
        //extand
        if(![self.outlineView isItemExpanded:item]){
            [self.outlineView expandItem:item expandChildren:NO];
        }else{
            [self.outlineView collapseItem:item collapseChildren:NO];
        }
    }else{
        if(column != 2){
            return;
        }
        if([item isEditable]){
            UDKVItemCell * kvCell = (UDKVItemCell *)cell;
            [kvCell setEditState:YES];
        }
    }
}

- (void)udkvItemCell: (UDKVItemCell *)cell contentUpdateRequest: (NSString *)newValue {
    NSInteger row = [self.outlineView rowForView:cell];
    ADHKVItem * item = [self.outlineView itemAtRow:row];
    [item setStringValue:newValue];
    [cell setData:item.stringValue];
    [cell setEditState:NO];
    //向App更新修改
    ADHKVItem * topItem = [item topItem];
    NSString * updationKey = topItem.keyName;
    id updationValue = [ADHKVItem getKVItemValue:topItem];
    [self.rootData setObject:updationValue forKey:updationKey];
    [self syncDataToFile];
    [self loadContent];
    [self showSuccessWithText:kAppLocalized(@"value_updated")];
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self loadContent];
}

- (IBAction)addButtonPressed:(NSButton *)button {
    UserDefaultAddViewController *addVC = [[UserDefaultAddViewController alloc] init];
    addVC.context = self.context;
    __weak typeof(self) wself = self;
    __weak UserDefaultAddViewController *weakAddVC = (UserDefaultAddViewController *)addVC;
    [addVC setCancelBlock:^{
        [wself dismissViewController:weakAddVC];
    }];
    [addVC setValueBlock:^(NSString * key, NSString *value) {
        [wself.rootData setObject:value forKey:key];
        [wself syncDataToFile];
        [wself loadContent];
        [wself dismissViewController:weakAddVC];
    }];
    [self presentViewController:addVC asPopoverRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMaxY behavior:NSPopoverBehaviorSemitransient];
}

- (IBAction)folderButtonPressed:(id)sender {
    NSString *targetPath = [self getWorkPath];
    [[NSWorkspace sharedWorkspace] openFile:targetPath];
}

- (BOOL)isFirstLevelItem: (ADHKVItem *)item {
    return (item.parent == self.rootKVItem);
}

- (BOOL)worksWhenModal {
    return YES;
}

@end

