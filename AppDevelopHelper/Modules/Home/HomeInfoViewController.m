//
//  HomeInfoViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/4.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "HomeInfoViewController.h"
#import "HomeInfoCell.h"
#import "ADHInfoItem.h"
#import "DeviceUtil.h"

@interface HomeInfoViewController ()

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSTableColumn *keyColumn;
@property (weak) IBOutlet NSTableColumn *valueColumn;

@property (nonatomic, strong) NSDictionary *rootData;
@property (nonatomic, strong) ADHInfoItem * rootKVItem;

@end

@implementation HomeInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadContent];
    [self addNotification];
}

- (void)setupUI {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([HomeInfoCell class]) bundle:nil];
    [self.outlineView registerNib:nib forIdentifier:NSStringFromClass([HomeInfoCell class])];
    self.outlineView.intercellSpacing = NSZeroSize;
    self.outlineView.rowHeight = 40.0f;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];

}

- (void)updateAppearanceUI {
    if([Appearance isDark]) {
        self.outlineView.backgroundColor = [Appearance colorWithHex:0x202123];
    }else {
        self.outlineView.backgroundColor = [Appearance colorWithHex:0xF2F2F2];
    }
    [self.outlineView reloadData];
}

//load suite content
- (void)loadContent {
    if(!self.context.isConnected){
        return;
    }
    __weak typeof(self) wself = self;
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [self.apiClient requestWithService:@"adh.appinfo" action:@"basicInfo" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        NSDictionary * data = body;
        wself.rootData = data;
        ADHInfoItem * rootItem = [ADHInfoItem kvItemWithData:data];
        wself.rootKVItem = rootItem;
        [wself cookData];
        [wself.outlineView reloadData];
    } onFailed:^(NSError *error) {
        
    }];
}

- (void)onWorkAppUpdate {
    if(self.context.isConnected) {
        if(!self.rootKVItem) {
            [self loadContent];
        }
    }
}

- (void)cookData {
    if(!self.rootKVItem) {
        return;
    }
    NSArray *list = self.rootKVItem.children;
    for (ADHInfoItem *item in list) {
        if([item.keyName isEqualToString:@"Device Model"]) {
            NSString *value = item.value;
            NSString *name = [DeviceUtil getDeviceModel:value];
            item.value = name;
        }
        NSString *iconName = [self getIconWithItem:item];
        item.iconName = iconName;
    }
}

#pragma mark -----------------  OutlineView DataSource & Delegate   ----------------

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    NSInteger count = 0;
    ADHInfoItem * kvItem = item;
    if(!kvItem){
        kvItem = self.rootKVItem;
    }
    if([kvItem isContainer]){
        count = kvItem.children.count;
    }
    return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    ADHInfoItem * childItem = nil;
    ADHInfoItem * kvItem = item;
    if(!kvItem){
        kvItem = self.rootKVItem;
    }
    if([kvItem isContainer]){
        NSArray<ADHInfoItem *> *list = kvItem.children;
        if(index < list.count) {
            childItem = list[index];
        }
    }
    return childItem;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    ADHInfoItem * kvItem = item;
    if(!kvItem){
        kvItem = self.rootKVItem;
    }
    return [kvItem isContainer];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    HomeInfoCell * cell = [outlineView makeViewWithIdentifier:NSStringFromClass([HomeInfoCell class]) owner:nil];
    ADHInfoItem * kvItem = (ADHInfoItem *)item;
    NSString * strValue = nil;
    NSColor * textColor = nil;
    NSString *tipText = nil;
    NSString *iconName = nil;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if(tableColumn == self.keyColumn){
        strValue = kvItem.keyName;
        if(strValue.length == 0 && kvItem.keyIndex != NSNotFound){
            strValue = [NSString stringWithFormat:@"Item %zd",kvItem.keyIndex];
        }
        cell.key = YES;
        iconName = kvItem.iconName;
    }else if(tableColumn == self.valueColumn){
        if(![kvItem isContainer]){
            strValue = [kvItem value];
            textColor = [NSColor labelColor];
        }else{
            strValue = [NSString stringWithFormat:@"(%zd items)",kvItem.children.count];
            textColor = [NSColor secondaryLabelColor];
        }
        cell.key = NO;
        tipText = kvItem.tip;
    }
    data[@"text"] = adhvf_safestringfy(strValue);
    if(iconName) {
        data[@"iconName"] = iconName;
    }
    if(tipText) {
        data[@"tip"] = tipText;
    }
    [cell setData:data];
    [cell setTextColor:textColor];
    return cell;
}

- (NSString *)getIconWithItem: (ADHInfoItem *)item {
    NSString *iconName = nil;
    NSString *key = item.keyName;
    if([key isEqualToString:@"Device Name"]) {
        iconName = @"person.circle";
    }else if([key isEqualToString:@"Device Model"]) {
        iconName = @"tv.circle";
    }else if([key isEqualToString:@"System Name"]) {
        iconName = @"s.circle";
    }else if([key isEqualToString:@"Resolution"]) {
        iconName = @"2.square";
    }else if([key isEqualToString:@"Locale"]) {
        iconName = @"mappin.circle";
    }else if([key isEqualToString:@"Timezone"]) {
        iconName = @"globe";
    }else if([key isEqualToString:@"Calendar"]) {
        iconName = @"calendar";
    }else if([key isEqualToString:@"Network"]) {
        iconName = @"wifi";
    }else if([key isEqualToString:@"Fonts"]) {
        iconName = @"a.circle";
    }else if([key isEqualToString:@"URL Schemes"]) {
        iconName = @"antenna.radiowaves.left.and.right";
    }
    return iconName;
}

@end
