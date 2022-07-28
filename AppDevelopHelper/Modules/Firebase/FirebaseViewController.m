//
//  FirebaseViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/20.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "FirebaseViewController.h"
#import "ADHKVItem.h"
#import "UDKVItemCell.h"
#import "DeviceUtil.h"


@interface FirebaseViewController ()<NSOutlineViewDataSource,NSOutlineViewDelegate,ADHBaseCellDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSTableColumn *keyColumn;
@property (weak) IBOutlet NSTableColumn *valueColumn;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSButton *pullButton;
@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSSearchField *searchTextfield;

@property (nonatomic, strong) NSDictionary *rootData;
@property (nonatomic, strong) ADHKVItem * rootKVItem;
@property (nonatomic, strong) NSString *keywords;


@end

@implementation FirebaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self initValue];
    [self initUI];
    [self loadContent:NO];
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

- (void)setupSearchTextField {
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
    [self.pullButton setTintColor:[Appearance actionImageColor]];
    [self.outlineView reloadData];
}

- (void)initValue {
    
}

- (void)initUI {

}

- (IBAction)refreshButtonPressed:(id)sender {
    [self loadContent: YES];
}

- (void)loadContent: (BOOL)showHud {
    if(!self.context.isConnected){
        return;
    }
    [self.refreshButton showHud];
    __weak typeof(self) wself = self;
    [self.context.apiClient requestWithService:@"adh.firebase" action:@"queryall" onSuccess:^(NSDictionary *body, NSData *payload) {
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
        if(showHud) {
            [self showSuccessWithText:@"Load sucessfully"];
        }
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (IBAction)pullButtonPressed:(id)sender {
    if(!self.context.isConnected){
        return;
    }
    [self.pullButton showHud];
    __weak typeof(self) wself = self;
    [self.context.apiClient requestWithService:@"adh.firebase" action:@"fetchRemote" onSuccess:^(NSDictionary *body, NSData *payload) {
        /*
         FIRRemoteConfigFetchStatusNoFetchYet,
         FIRRemoteConfigFetchStatusSuccess,
         FIRRemoteConfigFetchStatusFailure,
         FIRRemoteConfigFetchStatusThrottled,
         */
        NSInteger status = [body[@"status"] integerValue];
        if(status == 1) {
            if(body[@"error"]) {
                [wself.pullButton hideHud];
                NSString *message = body[@"error"];
                [wself showErrorWithText:message];
            }else {
                NSDictionary * data = [NSKeyedUnarchiver unarchiveObjectWithData:payload];
                wself.rootData = data;
                ADHKVItem * rootItem = [ADHKVItem kvItemWithData:data sort:YES];
                wself.rootKVItem = rootItem;
                [wself sortWithPinlist];
                if(wself.keywords.length > 0) {
                    [wself doFilter];
                }
                [wself.outlineView reloadData];
                [wself.pullButton hideHud];
                NSDictionary *infoData = body[@"info"];
                NSTimeInterval interval = [infoData[@"lastFetchTime"] doubleValue];
                NSString *timeText = [ADHDateUtil readbleTextWithTimeInterval:interval];
                NSString *text = [NSString stringWithFormat:@"Fetch sucessfully at %@",timeText];
                [self showSuccessWithText:text];
            }
        }else {
            [wself.pullButton hideHud];
            NSString *message = body[@"error"];
            [self showErrorWithText:message];
        }
    } onFailed:^(NSError *error) {
        [wself.pullButton hideHud];
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




#pragma mark -----------------   search   ----------------

- (void)searchTextDidChange:(NSNotification *)notification {
    [self doSearchWithKeywords:self.searchTextfield.stringValue];
}

- (void)searchTextDidEndEditing:(NSNotification *)notification {
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

- (void)onWorkAppUpdate {
    if(!self.rootKVItem){
        [self loadContent:NO];
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
    [Preference setDefaultValue:mlist forKey:@"pinlist" inDomain:kToolModuleFirebase];
    [self updatePinlistContent];
}

- (void)removePinItem: (NSString *)key {
    NSArray *list = [self getPinList];
    if(list) {
        NSMutableArray *mlist = [list mutableCopy];
        [mlist removeObject:key];
        [Preference setDefaultValue:mlist forKey:@"pinlist" inDomain:kToolModuleFirebase];
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
    NSArray *list = [Preference defaultValueForKey:key inDomain:kToolModuleFirebase];
    return list;
}


@end
