//
//  UserDefaultsViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/8.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "UserDefaultsViewController.h"
#import "ADHKVItem.h"
#import "UDKVItemCell.h"
#import "DeviceUtil.h"
#import "MacOrganizer.h"
#import "UserDefaultAddViewController.h"
#import "UserDefaultSuiteViewController.h"
#import "StateMasterService.h"

@interface UserDefaultsViewController ()<NSOutlineViewDataSource,NSOutlineViewDelegate,ADHBaseCellDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSTableColumn *keyColumn;
@property (weak) IBOutlet NSTableColumn *typeColumn;
@property (weak) IBOutlet NSTableColumn *valueColumn;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *suiteButton;
@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSSearchField *searchTextfield;

@property (nonatomic, strong) NSDictionary *rootData;
@property (nonatomic, strong) ADHKVItem * rootKVItem;
@property (nonatomic, strong) NSString *keywords;
@property (nonatomic, strong) NSString *suiteName;

@end

@implementation UserDefaultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self initValue];
    [self initUI];
    [self loadContent];
}

- (void)setupAfterXib {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([UDKVItemCell class]) bundle:nil];
    [self.outlineView registerNib:nib forIdentifier:NSStringFromClass([UDKVItemCell class])];
    self.outlineView.intercellSpacing = NSZeroSize;
    self.outlineView.rowHeight = 28.0f;
    [self setupSearchTextField];
    self.view.wantsLayer = YES;
    self.actionLayout.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)setupSearchTextField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.searchTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.searchTextfield];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    self.view.layer.backgroundColor = [Appearance backgroundColor].CGColor;
    self.actionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    [self.addButton setTintColor:[Appearance actionImageColor]];
    [self.suiteButton setTintColor:[Appearance actionImageColor]];
    [self.outlineView reloadData];
}

- (void)initValue {
    
}

- (void)initUI {
    [self updateSuiteUI];
}

//load suite content
- (void)loadContent {
    if(!self.context.isConnected){
        return;
    }
    [self.refreshButton showHud];
    __weak typeof(self) wself = self;
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if(self.suiteName.length > 0) {
        body[@"suitename"] = adhvf_safestringfy(self.suiteName);
    }
    [self.apiClient requestWithService:@"adh.userdefaults" action:@"requestData" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        NSDictionary * data = [NSKeyedUnarchiver unarchiveObjectWithData:payload];
        wself.rootData = data;
        ADHKVItem * rootItem = [ADHKVItem kvItemWithData:data sort:YES];
        wself.rootKVItem = rootItem;
        [wself sortWithPinlist];
        if(wself.keywords.length > 0) {
            [wself doFilter];
        }
        [wself.outlineView reloadData];
        [wself.refreshButton hideHud];
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (void)sortWithPinlist {
    NSArray *pinList = [self getPinList];
    [self.rootKVItem sortWithPinlist:pinList];
}

- (void)updatePinlistContent {
    [self sortWithPinlist];
    if(self.keywords.length > 0) {
        [self doFilter];
    }
    [self.outlineView reloadData];
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

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
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

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    ADHKVItem * kvItem = item;
    if(!kvItem){
        kvItem = self.rootKVItem;
    }
    return [kvItem isContainer];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
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
    [cell setPinState:kvItem.pin];
    cell.delegate = self;
    return cell;
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point
{
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
    //focus key
    NSMenuItem *focusMenu = [[NSMenuItem alloc] initWithTitle:@"Focus" action:@selector(focusMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    focusMenu.target = self;
    focusMenu.representedObject = kvItem;
    [menu addItem:focusMenu];
    //Pin item
    if(![self isItemCollected:kvItem]) {
        NSMenuItem *favMenu = [[NSMenuItem alloc] initWithTitle:@"Pin" action:@selector(pinMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        favMenu.target = self;
        favMenu.representedObject = kvItem;
        [menu addItem:favMenu];
    }else {
        NSMenuItem *unfavMenu = [[NSMenuItem alloc] initWithTitle:@"Unpin" action:@selector(unpinMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        unfavMenu.target = self;
        unfavMenu.representedObject = kvItem;
        [menu addItem:unfavMenu];
    }
    //state master
    if([self isFirstLevelItem:kvItem]) {
        StateMasterService *stateService = [StateMasterService serviceWithContext:self.context];
        if(stateService) {
            [menu addItem: [NSMenuItem separatorItem]];
            NSMenuItem *stateMasterMenu = [stateService makeStateMasterMenu:self action:@selector(stateMasterMenuClicked:)];
            if(stateMasterMenu) {
                stateMasterMenu.representedObject = kvItem;
                [menu addItem:stateMasterMenu];
            }
        }
    }
    if(menu.itemArray.count > 0){
        [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
    }
}

- (BOOL)isItemCollected: (ADHKVItem *)item {
    ADHKVItem *topItem = [item topItem];
    NSString *key = topItem.keyName;
    BOOL collect = [self isKeyPined:key];
    return collect;
}

- (void)pinMenuSelected: (NSMenuItem *)menu {
    ADHKVItem * item = menu.representedObject;
    ADHKVItem *topItem = [item topItem];
    NSString *key = topItem.keyName;
    [self addPinItem:key];
}

- (void)unpinMenuSelected: (NSMenuItem *)menu {
    ADHKVItem * item = menu.representedObject;
    ADHKVItem *topItem = [item topItem];
    NSString *key = topItem.keyName;
    [self removePinItem:key];
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
    if(!doProCheckRoutine()) {
        return;
    }
    ADHKVItem * item = menu.representedObject;
    NSString * key = item.keyName;
    [ADHAlert alertWithMessage:@"Remove item" infoText:@"Are you sure to remove it" comfirmBlock:^{
        //request
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"key"] = adhvf_safestringfy(key);
        if(self.suiteName.length > 0) {
            data[@"suitename"] = adhvf_safestringfy(self.suiteName);
        }
        __weak typeof(self) wself = self;
        [self.apiClient requestWithService:@"adh.userdefaults" action:@"remove" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
            [wself.view hideHud];
            BOOL success = [body[@"success"] integerValue];
            if(success) {
                [wself showSuccessWithText:@"Item removed"];
                [wself loadContent];
            }else {
                [wself showErrorWithText:@"Item not exists"];
            }
        } onFailed:^(NSError *error) {
            [wself.view hideHud];
            [wself showError];
        }];
        [wself.view showHud];
    }cancelBlock:nil];
}

- (void)stateMasterMenuClicked: (NSMenuItem *)menu {
    ADHKVItem * item = menu.parentItem.representedObject;
    StateItem *stateItem = menu.representedObject;
    NSString * keyValue = item.keyName;
    id value = [ADHKVItem getKVItemValue:item];
    if(keyValue && value) {
        StateMasterService *stateService = [StateMasterService serviceWithContext:self.context];
        [stateService addUserDefaultsItem:keyValue value:value toState:stateItem];
        [self showSuccessWithText:@"Sync Done"];
    }else {
        [self showErrorWithText:@"Invalid Item"];
    }
}

- (void)focusMenuSelected: (NSMenuItem *)menu {
    ADHKVItem * item = menu.representedObject;
    NSString * strValue = item.keyName;
    self.searchTextfield.stringValue = strValue;
    [self doSearchWithKeywords:strValue];
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
    if(!doProCheckRoutine()) {
        [cell setEditState:NO];
        return;
    }
    [item setStringValue:newValue];
    [cell setData:item.stringValue];
    [cell setEditState:NO];
    //向App更新修改
    [self requestUpdateItem:item];
}

- (void)requestUpdateItem: (ADHKVItem *)item {
    //获取修改路径
    ADHKVItem * topItem = [item topItem];
    NSString * updationKey = topItem.keyName;
    id updationValue = [ADHKVItem getKVItemValue:topItem];
    NSData * payload = [NSKeyedArchiver archivedDataWithRootObject:updationValue];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"key"] = updationKey;
    if(self.suiteName.length > 0) {
        body[@"suitename"] = adhvf_safestringfy(self.suiteName);
    }
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.userdefaults" action:@"updateValue" body:body payload:payload progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself showSuccessWithText:kAppLocalized(@"value_updated")];
    } onFailed:^(NSError *error) {
        
    }];
}

- (IBAction)refreshButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    [self loadContent];
}

- (void)onWorkAppUpdate {
    if(!self.rootKVItem){
        [self loadContent];
    }
}

#pragma mark -----------------   search   ----------------

- (void)searchTextDidChange:(NSNotification *)notification
{
    [self doSearchWithKeywords:self.searchTextfield.stringValue];
}

- (void)searchTextDidEndEditing:(NSNotification *)notification
{
    [self doSearchWithKeywords:self.searchTextfield.stringValue];
}

- (void)doSearchWithKeywords: (NSString *)keywords {
    self.keywords = keywords;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doFilter];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.outlineView reloadData];
        });
    });
}

- (void)doFilter {
    NSString * keywords = self.keywords;
    if(keywords.length > 0) {
        [self.rootKVItem searchChildWithText:keywords];
    }else{
        [self.rootKVItem resetSearchResult];
    }
}

- (void)doMannulSearch: (NSString *)keywords {
    self.searchTextfield.stringValue = keywords;
    self.keywords = keywords;
    [self loadContent];
}

- (IBAction)addButtonPressed:(NSButton *)button {
    UserDefaultAddViewController *addVC = [[UserDefaultAddViewController alloc] init];
    addVC.suiteName = self.suiteName;
    addVC.context = self.context;
    __weak typeof(self) wself = self;
    __weak UserDefaultAddViewController *weakAddVC = (UserDefaultAddViewController *)addVC;
    [addVC setCancelBlock:^{
        [wself dismissViewController:weakAddVC];
    }];
    [addVC setCompletionBlock:^(NSString * _Nonnull key) {
        [wself dismissViewController:weakAddVC];
        [wself doMannulSearch:key];
    }];
    [self presentViewController:addVC asPopoverRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMaxY behavior:NSPopoverBehaviorSemitransient];
}

- (IBAction)suiteButtonClicked:(NSButton *)button {
    UserDefaultSuiteViewController *suiteVC = [[UserDefaultSuiteViewController alloc] init];
    suiteVC.context = self.context;
    suiteVC.currentSuiteName = self.suiteName;
    __weak typeof(self) wself = self;
    __weak UserDefaultSuiteViewController *wSuiteVC = (UserDefaultSuiteViewController* )suiteVC;
    [suiteVC setCompletionBlock:^(NSString * _Nonnull suiteName) {
        wself.suiteName = suiteName;
        [wself updateSuiteUI];
        [wself loadContent];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself dismissViewController:wSuiteVC];
        });
    }];
    [self presentViewController:suiteVC asPopoverRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMaxY behavior:NSPopoverBehaviorSemitransient];
}

- (void)updateSuiteUI {
    if(self.suiteName.length == 0) {
        self.suiteButton.toolTip = @"Select Suite";
        [self.suiteButton setImage:[NSImage imageNamed:@"icon_container"]];
    }else {
        self.suiteButton.toolTip = self.suiteName;
        [self.suiteButton setImage:[NSImage imageNamed:@"icon_container_selected"]];
    }
}

#pragma mark -----------------   favouriate   ----------------

- (void)addPinItem: (NSString *)key {
    NSArray *list = [self getPinList];
    if(!list) {
        list = @[];
    }
    NSMutableArray *mlist = [list mutableCopy];
    [mlist insertObject:key atIndex:0];
    [Preference setDefaultValue:mlist forKey:@"pinlist" inDomain:kToolModuleUserDefaults];
    [self updatePinlistContent];
}

- (void)removePinItem: (NSString *)key {
    NSArray *list = [self getPinList];
    if(list) {
        NSMutableArray *mlist = [list mutableCopy];
        [mlist removeObject:key];
        [Preference setDefaultValue:mlist forKey:@"pinlist" inDomain:kToolModuleUserDefaults];
    }
    [self updatePinlistContent];
}

- (BOOL)isKeyPined: (NSString *)key {
    NSArray *list = [self getPinList];
    BOOL exists = [list containsObject:key];
    return exists;
}

- (NSArray *)getPinList {
    NSString *key = @"pinlist";
    NSArray *list = [Preference defaultValueForKey:key inDomain:kToolModuleUserDefaults];
    return list;
}

- (BOOL)isFirstLevelItem: (ADHKVItem *)item {
    return (item.parent == self.rootKVItem);
}

@end
