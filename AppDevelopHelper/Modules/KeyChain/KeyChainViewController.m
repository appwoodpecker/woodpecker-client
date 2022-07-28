//
//  KeyChainViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/9/1.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "KeyChainViewController.h"
#import "KeyChainValueCell.h"
#import "KeyChainItem.h"
#import "MacOrganizer.h"

static NSString * const kColumnTitle            = @"title";
static NSString * const kColumnIdentifier       = @"identifier";
static NSString * const kColumnWidth            = @"width";
static NSString * const kColumnFlexibleWidth    = @"flexible-width";
static CGFloat const kColumnFlexibleMinUnitWidth = 200.0f;

@interface KeyChainViewController () <NSTableViewDelegate,NSTableViewDataSource,KeyChainValueCellDelegate>

@property (weak) IBOutlet NSSegmentedControl *segmentControl;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *refreshButton;

@property (nonatomic, strong) NSArray<KeyChainItem *> *contentList;
@property (nonatomic, strong) NSArray *columnList;

//0 generic, 1 internet password
@property (nonatomic, assign) NSInteger type;

@end

@implementation KeyChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initValue];
    [self initUI];
    [self loadContent];
    [self addNotification];
}

- (void)setupAfterXib {
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([KeyChainValueCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([KeyChainValueCell class])];
    self.tableView.rowHeight = 28.0f;
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask;
    self.tableView.intercellSpacing = NSZeroSize;
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.columnAutoresizingStyle = NSTableViewNoColumnAutoresizing;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    self.segmentControl.left = (self.segmentControl.superview.width - self.segmentControl.width)/2.0f;
    [self updateColumnSize];
}

- (void)initValue {
    self.type = 0;
}

- (void)initUI {
    self.segmentControl.selectedSegment = self.type;
    [self updateTypeUI];
}

- (IBAction)segmentControlValueChanged:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    if(self.segmentControl.selectedSegment == 1) {
        self.type = 1;
    }else {
        self.type = 0;
    }
    [self updateTypeUI];
    self.contentList = nil;
    [self updateContentUI];
    [self loadContent];
}

- (IBAction)refreshButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    [self loadContent];
}

- (void)loadContent {
    if(!self.context.isConnected){
        return;
    }
    [self.refreshButton showHud];
    NSDictionary *params = @{
                             @"type" : [NSNumber numberWithInteger:self.segmentControl.selectedSegment],
                             };
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.keychain" action:@"list" body:params onSuccess:^(NSDictionary *body, NSData *payload) {
        NSString *content = body[@"list"];
        NSArray *list = [content adh_jsonObject];
        NSMutableArray *itemList = [NSMutableArray array];
        for (NSDictionary *data in list) {
            KeyChainItem *item = [KeyChainItem itemWithData:data];
            [itemList addObject:item];
        }
        wself.contentList = itemList;
        [wself updateContentUI];
        [wself.refreshButton hideHud];
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (void)prepareTypeValue {
    NSMutableArray *columnList = [NSMutableArray array];
    if(self.type == 1) {
        //internet password
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrLabel),
                                kColumnIdentifier : occf(kSecAttrLabel),
                                kColumnWidth: @(150),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrAccount),
                                kColumnIdentifier : occf(kSecAttrAccount),
                                kColumnWidth: @(150),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrPath),
                                kColumnIdentifier : occf(kSecAttrPath),
                                kColumnWidth: @(300),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrAuthenticationType),
                                kColumnIdentifier : occf(kSecAttrAuthenticationType),
                                kColumnWidth: @(120),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrCreationDate),
                                kColumnIdentifier : occf(kSecAttrCreationDate),
                                kColumnWidth: @(160),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrModificationDate),
                                kColumnIdentifier : occf(kSecAttrModificationDate),
                                kColumnWidth: @(160),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrAccessGroup),
                                kColumnIdentifier : occf(kSecAttrAccessGroup),
                                kColumnWidth: @(280),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrAccessible),
                                kColumnIdentifier : occf(kSecAttrAccessible),
                                kColumnWidth: @(200),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrSynchronizable),
                                kColumnIdentifier : occf(kSecAttrSynchronizable),
                                kColumnWidth: @(120),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecValueData),
                                kColumnIdentifier : occf(kSecValueData),
                                kColumnFlexibleWidth: @(1.0),
                                }];
    }else {
        //generic
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrLabel),
                                kColumnIdentifier : occf(kSecAttrLabel),
                                kColumnWidth: @(150),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrAccount),
                                kColumnIdentifier : occf(kSecAttrAccount),
                                kColumnWidth: @(150),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrService),
                                kColumnIdentifier : occf(kSecAttrService),
                                kColumnWidth: @(150),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrCreationDate),
                                kColumnIdentifier : occf(kSecAttrCreationDate),
                                kColumnWidth: @(160),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrModificationDate),
                                kColumnIdentifier : occf(kSecAttrModificationDate),
                                kColumnWidth: @(160),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrAccessGroup),
                                kColumnIdentifier : occf(kSecAttrAccessGroup),
                                kColumnWidth: @(280),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrAccessible),
                                kColumnIdentifier : occf(kSecAttrAccessible),
                                kColumnWidth: @(200),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecAttrSynchronizable),
                                kColumnIdentifier : occf(kSecAttrSynchronizable),
                                kColumnWidth: @(120),
                                }];
        [columnList addObject:@{
                                kColumnTitle : readbleName(kSecValueData),
                                kColumnIdentifier : occf(kSecValueData),
                                kColumnFlexibleWidth: @(1.0),
                                }];
    }
    self.columnList = columnList;
}

- (void)setupColumns
{
    NSArray *columns = [self.tableView.tableColumns mutableCopy];
    for (NSTableColumn * column in columns) {
        [self.tableView removeTableColumn:column];
    }
    for (NSDictionary * data in self.columnList) {
        NSString * title = data[kColumnTitle];
        NSString *identifier = data[kColumnIdentifier];
        NSTableColumn * column = [[NSTableColumn alloc] init];
        column.identifier = identifier;
        NSString *adjustTitle = [NSString stringWithFormat:@"  %@",title];
        column.title = adjustTitle;
        [self.tableView addTableColumn:column];
    }
    [self updateColumnSize];
}

- (void)updateColumnSize {
    CGFloat contentWidth = self.tableView.frame.size.width;
    CGFloat totalFixWidth = 0;
    float flexibleUnits = 0;
    for (NSDictionary * columnData in self.columnList) {
        if(columnData[kColumnWidth]){
            CGFloat fixWidth = [columnData[kColumnWidth] floatValue];
            totalFixWidth += fixWidth;
        }else if(columnData[kColumnFlexibleWidth]){
            float flexibleUnit = [columnData[kColumnFlexibleWidth] floatValue];
            flexibleUnits += flexibleUnit;
        }
    }
    CGFloat flexibleWidth = contentWidth - totalFixWidth;
    CGFloat unitWidth = (flexibleWidth /flexibleUnits);
    unitWidth = MAX(unitWidth, kColumnFlexibleMinUnitWidth);
    NSArray *columns = [self.tableView.tableColumns mutableCopy];
    for (NSInteger i=0;i<columns.count;i++) {
        NSTableColumn *column = columns[i];
        NSDictionary *data = self.columnList[i];
        column.minWidth = 60.0f;
        if(data[kColumnWidth]){
            column.width = [data[kColumnWidth] floatValue];
        }else if(data[kColumnFlexibleWidth]){
            float units = [data[kColumnFlexibleWidth] floatValue];
            column.width = units * unitWidth;
        }else {
            column.width = 150.0f;
        }
    }
}

- (void)updateTypeUI {
    [self prepareTypeValue];
    [self setupColumns];
}

- (void)updateContentUI {
    [self.tableView reloadData];
}

#pragma mark -----------------   table datasource   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = self.contentList.count;
    return count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView * cell = nil;
    NSString *identifier = tableColumn.identifier;
    if([identifier isEqualToString:occf(kSecValueData)]) {
        KeyChainValueCell *valueCell = [tableView makeViewWithIdentifier:NSStringFromClass([KeyChainValueCell class]) owner:nil];
        valueCell.delegate = self;
        KeyChainItem *item = self.contentList[row];
        [valueCell setData:item];
        cell = valueCell;
    }else {
        cell = [tableView makeViewWithIdentifier:@"cellId" owner:nil];
        KeyChainItem *item = self.contentList[row];;
        NSString *key = tableColumn.identifier;
        NSString *value = [self valueWithIdentifier:key data:item];
        cell.textField.stringValue = value;
    }
    return cell;
}


#pragma mark -----------------   cell delegate   ----------------

- (void)keyChainValueCellRequestValue: (KeyChainValueCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    KeyChainItem *item = self.contentList[row];
    NSDictionary *data = item.attrData;
    NSString * content = data[occf(kSecValuePersistentRef)];
    if(content.length > 0) {
        [cell.actionView showHud];
        NSDictionary *body = @{
                               occf(kSecValuePersistentRef) : content,
                               @"type" : [NSNumber numberWithInteger:self.segmentControl.selectedSegment],
                               };
        [self.apiClient requestWithService:@"adh.keychain" action:@"getPassword" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
            NSString *value = body[occf(kSecValueData)];
            if(value) {
                NSData *valueData = [[NSData alloc] initWithBase64EncodedString:value options:0];
                if(valueData) {
                    item.status = KeyChainItemValueStatusAvailable;
                    item.valueData = valueData;
                    //try to decode
                    NSString *utf8 = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
                    if(utf8) {
                        item.valueText = utf8;
                    }
                }
            }else {
                item.status = KeyChainItemValueStatusNotSet;
            }
            [cell setData:item];
            [cell.actionView hideHud];
        } onFailed:^(NSError *error) {
            [cell.actionView hideHud];
        }];
    }
}

#pragma mark -----------------   other   ----------------

- (NSString *)valueWithIdentifier: (NSString *)identifier data: (KeyChainItem *)item {
    NSDictionary *data = item.attrData;
    NSString * text = nil;
    if([identifier isEqualToString:occf(kSecAttrCreationDate)]) {
        NSTimeInterval interval = [data[identifier] doubleValue];
        text = [ADHDateUtil readbleTextWithTimeInterval:interval];
    }else if([identifier isEqualToString:occf(kSecAttrModificationDate)]) {
        NSTimeInterval interval = [data[identifier] doubleValue];
        text = [ADHDateUtil readbleTextWithTimeInterval:interval];
    }else if([identifier isEqualToString:occf(kSecValueData)]) {
        if(data[occf(kSecValuePersistentRef)]) {
            text = data[occf(kSecValuePersistentRef)];
        }else {
            text = @"";
        }
    }else if([identifier isEqualToString:occf(kSecAttrSynchronizable)]) {
        //default false, no problem
        BOOL value = [data[occf(kSecAttrSynchronizable)] boolValue];
        if(value) {
            text = @"YES";
        }else {
            text = @"NO";
        }
    }else if([identifier isEqualToString:occf(kSecAttrAccessible)]) {
        NSString *value = data[identifier];
        if([value isEqualToString:occf(kSecAttrAccessibleWhenUnlocked)]) {
            text = @"Unlocked";
        }else if([value isEqualToString:occf(kSecAttrAccessibleAfterFirstUnlock)]) {
            text = @"After first unlock";
        }else if([value isEqualToString:occf(kSecAttrAccessibleAlways)]) {
            text = @"Always";
        }else if([value isEqualToString:occf(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)]) {
            text = @"Passcode set, this device only";
        }else if([value isEqualToString:occf(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)]) {
            text = @"Unlocked, this device only";
        }else if([value isEqualToString:occf(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)]) {
            text = @"After first unlock, this device only";
        }else if([value isEqualToString:occf(kSecAttrAccessibleAlwaysThisDeviceOnly)]) {
            text = @"Always, this device only";
        }
    }else if([identifier isEqualToString:occf(kSecAttrPath)]) {
        //internet server
        NSString *protocol = data[occf(kSecAttrProtocol)];
        NSString *server = data[occf(kSecAttrServer)];
        NSString *path = data[occf(kSecAttrPath)];
        NSNumber *port = data[occf(kSecAttrPort)];
        NSMutableString *content = [NSMutableString string];
        if(protocol) {
            [content appendFormat:@"%@://",protocol];
        }
        if(server) {
            [content appendFormat:@"%@",server];
        }
        if(path) {
            if(![path hasPrefix:@"/"]) {
                [content appendFormat:@"/"];
            }
            [content appendFormat:@"%@",path];
        }
        if(port) {
            [content appendFormat:@":%@",port];
        }
        text = content;
    }else if([identifier isEqualToString:occf(kSecAttrAuthenticationType)]) {
        //internet auth type
        NSString *authType = data[occf(kSecAttrAuthenticationType)];
        if([authType isEqualToString:occf(kSecAttrAuthenticationTypeNTLM)]) {
            text = @"NTLM";
        }else if([authType isEqualToString:occf(kSecAttrAuthenticationTypeMSN)]) {
            text = @"MSN";
        }else if([authType isEqualToString:occf(kSecAttrAuthenticationTypeDPA)]) {
            text = @"DPA";
        }else if([authType isEqualToString:occf(kSecAttrAuthenticationTypeRPA)]) {
            text = @"RPA";
        }else if([authType isEqualToString:occf(kSecAttrAuthenticationTypeHTTPBasic)]) {
            text = @"HTTP Basic";
        }else if([authType isEqualToString:occf(kSecAttrAuthenticationTypeHTTPDigest)]) {
            text = @"HTTP Digest";
        }else if([authType isEqualToString:occf(kSecAttrAuthenticationTypeHTMLForm)]) {
            text = @"HTML Form";
        }else if([authType isEqualToString:occf(kSecAttrAuthenticationTypeDefault)]) {
            text = @"";
        }
    }else {
        text = data[identifier];
    }
    text = adhvf_safestringfy(text);
    return text;
}


NSString *readbleName(CFStringRef attr) {
    NSString *key = occf(attr);
    NSString *text = nil;
    if([key isEqualToString:occf(kSecAttrLabel)]) {
        text = @"Label";
    }else if([key isEqualToString:occf(kSecAttrAccount)]) {
        text = @"Account";
    }else if([key isEqualToString:occf(kSecAttrService)]) {
        text = @"Service";
    }else if([key isEqualToString:occf(kSecAttrCreationDate)]) {
        text = @"Create Date";
    }else if([key isEqualToString:occf(kSecAttrModificationDate)]) {
        text = @"Modification Date";
    }else if([key isEqualToString:occf(kSecValueData)]) {
        text = @"Value";
    }else if([key isEqualToString:occf(kSecAttrAccessGroup)]) {
        text = @"Access Group";
    }else if([key isEqualToString:occf(kSecAttrAccessible)]) {
        text = @"Accessible";
    }else if([key isEqualToString:occf(kSecAttrSynchronizable)]) {
        text = @"Synchronizable";
    }else if([key isEqualToString:occf(kSecAttrPath)]) {
        //internet server
        text = @"Path";
    }else if([key isEqualToString:occf(kSecAttrAuthenticationType)]) {
        //internet auth type
        text = @"Authentication";
    }else {
        text = key;
    }
    return text;
}

#pragma mark -----------------   connection   ----------------
- (void)onWorkAppUpdate
{
    if(!self.contentList){
        [self loadContent];
    }
}

#pragma mark -----------------   util   ----------------

id occf(CFTypeRef cfObject) {
    return (__bridge id)cfObject;
}

CFTypeRef cfoc(id object) {
    return  (__bridge CFTypeRef)object;
}

@end
