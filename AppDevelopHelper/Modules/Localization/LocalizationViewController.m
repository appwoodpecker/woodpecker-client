//
//  LocalizationViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/6/23.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "LocalizationViewController.h"
#import "ADHLocalizationBundle.h"
#import "LocalizationItemCell.h"
#import "LocalizationSelectionCell.h"
#import "LocalizationSectionView.h"
#import "LocalizationRow.h"
#import "MacOrganizer.h"
#import "xlsxwriter.h"

static NSString * const kColumnTitle = @"title";
static NSString * const kColumnIdentifier = @"identifier";
static NSString * const kColumnIdentifierKeys = @"keys";
static NSString *const kColumnIdentifierSelection = @"selection";
static CGFloat const kStringFileFontSize = 13.0f;

@interface LocalizationViewController ()<NSTableViewDataSource,NSTableViewDelegate,ADHBaseCellDelegate,LocalizationSelectionCellDelegate>

@property (weak) IBOutlet NSButton *refreshButton;

@property (weak) IBOutlet NSTextField *bundleTipLabel;

@property (weak) IBOutlet NSView *bundlePopupLayout;

@property (weak) IBOutlet NSPopUpButton *bundlePopup;
@property (weak) IBOutlet NSScrollView *fileScrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSScrollView *tableScrollView;

@property (weak) IBOutlet NSView *searchLayout;
@property (weak) IBOutlet NSSearchField *searchTextfield;
@property (weak) IBOutlet ADHButton *missButton;
@property (weak) IBOutlet NSView *searchLine;
@property (weak) IBOutlet NSButton *exportButton;
@property (weak) IBOutlet NSView *selectionLayout;
@property (weak) IBOutlet NSScrollView *selectionScrollView;


@property (nonatomic, strong) NSArray<ADHLocalizationBundle *> *bundles;

@property (nonatomic, strong) ADHLocalizationBundle *currentBundle;
@property (nonatomic, strong) NSArray<ADHButton *> *stringButtons;
@property (nonatomic, copy) NSArray<NSString *> *currentStringFiles;

@property (nonatomic, strong) NSArray<NSDictionary *> *columnList;
@property (nonatomic, strong) NSArray *contentList;
@property (nonatomic, strong) NSArray<LocalizationRow *> *rowList;
@property (nonatomic, strong) NSArray<LocalizationRow *> *filteredRowList;

@property (nonatomic, assign) BOOL filterBad;
@property (nonatomic, strong) NSString *keywords;

//是否在选择状态
@property (nonatomic, assign) BOOL bSelecting;
@property (nonatomic, strong) NSTableColumn *selectionColumn;

@property (nonatomic, strong) NSMutableArray *selectRowList;
@property (nonatomic, strong) NSMutableArray *selectionButtons;

@end

@implementation LocalizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initUI];
    [self addNotification];
    [self loadBundleInfo];
}

- (void)setupAfterXib {
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([LocalizationItemCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([LocalizationItemCell class])];
    {
        NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([LocalizationSelectionCell class]) bundle:nil];
        [self.tableView registerNib:nib forIdentifier:NSStringFromClass([LocalizationSelectionCell class])];
    }
    {
        NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([LocalizationSectionView class]) bundle:nil];
        [self.tableView registerNib:nib forIdentifier:NSStringFromClass([LocalizationSectionView class])];
    }
    self.tableView.rowHeight = 30.0f;
    self.tableView.intercellSpacing = NSZeroSize;
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask;
    self.tableView.floatsGroupRows = YES;
    NSView *bundlePopupLayout = self.bundlePopupLayout;
    bundlePopupLayout.wantsLayer = YES;
    bundlePopupLayout.layer.borderWidth = 1.0f;
    bundlePopupLayout.layer.cornerRadius = 2.0f;
    [self setupSearchTextField];
    //miss button
    self.missButton.selected = NO;
    [self updateMissButtonStateUI];
    self.searchLine.wantsLayer = YES;
    [self updateBundleUI];
    [self.exportButton setTarget:self];
    self.selectionLayout.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    [self.exportButton setTintColor:[Appearance actionImageColor]];
    if([Appearance isDark]) {
        self.selectionLayout.layer.backgroundColor = [Appearance colorWithHex:0x3F3F3F].CGColor;
        self.searchLayout.layer.borderColor = [Appearance colorWithHex:0x575757].CGColor;
        self.searchLayout.layer.backgroundColor = [Appearance colorWithHex:0x3F3F3F].CGColor;
        self.searchLine.layer.backgroundColor = [Appearance colorWithHex:0x3F3F3F].CGColor;
    }else {
        self.bundlePopupLayout.layer.borderColor = [[NSColor blackColor] colorWithAlphaComponent:0.2].CGColor;
        self.selectionLayout.layer.backgroundColor = [Appearance colorWithRed:200 green:200 blue:200 alpha:1.0].CGColor;
        self.searchLayout.layer.borderColor = [[NSColor blackColor] colorWithAlphaComponent:0.2].CGColor;
        self.searchLayout.layer.backgroundColor = [NSColor whiteColor].CGColor;
        self.searchLine.layer.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.1].CGColor;
    }
}

- (void)setupSearchTextField {
    NSView *searchLayout = self.searchLayout;
    searchLayout.wantsLayer = YES;
    searchLayout.layer.borderWidth = 1.0f;
    searchLayout.layer.cornerRadius = 3.0f;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.searchTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.searchTextfield];
}

- (void)initUI {
    [self showSelection:NO animate:NO];
}

- (IBAction)refreshButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) {
        return;
    }
    [self loadBundleInfo];
}

- (IBAction)bundlePopupValueChanged:(id)sender {
    NSArray<NSMenuItem*> *items = self.bundlePopup.itemArray;
    if(items.count == 0) return;
    NSInteger index = [items indexOfObject:self.bundlePopup.selectedItem];
    if(index != NSNotFound) {
        self.currentBundle = self.bundles[index];
        [self resetContent];
        [self updateCurrentBundleContent];
    }
}

- (void)loadBundleInfo {
    if(!self.context.isConnected){
        return;
    }
    __weak typeof(self) wself = self;
    [self.refreshButton showHud];
    [self.apiClient requestWithService:@"adh.localization" action:@"info" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.refreshButton hideHud];
        [wself resetContent];
        NSArray *list = body[@"bundleList"];
        NSMutableArray *bundles = [NSMutableArray array];
        for (NSDictionary *data in list) {
            ADHLocalizationBundle *bundle = [ADHLocalizationBundle bundleWithData:data];
            [bundles addObject:bundle];
        }
        wself.bundles = bundles;
        ADHLocalizationBundle *preferedBundle = nil;
        if(wself.bundles.count > 0) {
            for (ADHLocalizationBundle *bundle in wself.bundles) {
                if([bundle isMainBundle]) {
                    preferedBundle = bundle;
                    break;
                }
            }
            if(!preferedBundle) {
                preferedBundle = wself.bundles[0];
            }
        }
        wself.currentBundle = preferedBundle;
        [wself updateInfoUI];
        [wself updateCurrentBundleContent];
    } onFailed:^(NSError *error) {
        [wself.refreshButton hideHud];
    }];
}

- (void)updateCurrentBundleContent {
    [self prepareCurrentBundleInfo];
    [self updateCurrentBundleUI];
}

- (void)prepareCurrentBundleInfo {
    //column list
    NSMutableArray *columnList = [NSMutableArray array];
    [columnList addObject:@{
                            kColumnTitle : @"keys",
                            kColumnIdentifier : kColumnIdentifierKeys,
                            }];
    NSArray *languages = self.currentBundle.languages;
    for (NSString *lang in languages) {
        [columnList addObject:@{
                                kColumnTitle : adhvf_safestringfy(lang),
                                kColumnIdentifier : adhvf_safestringfy(lang),
                                }];
    }
    self.columnList = columnList;
}

- (void)resetContent {
    self.contentList = nil;
    self.columnList = nil;
    self.rowList = nil;
    self.filteredRowList = nil;
}

- (void)updateInfoUI {
    [self updateBundleUI];
}

- (void)updateCurrentBundleUI {
    [self updateStringFilesUI];
    [self updateCurrentStringFiles];
    [self.tableView reloadData];
    [self setupColumns];
    [self updateContent];
}

- (void)updateBundleUI {
    if(self.bundles.count > 0) {
        [self.bundlePopup removeAllItems];
        NSMutableArray<NSString *> *items = [NSMutableArray array];
        for (ADHLocalizationBundle *bundle in self.bundles) {
            NSString *bundleName = [bundle.name stringByDeletingPathExtension];
            [items addObject:bundleName];
        }
        [self.bundlePopup addItemsWithTitles:items];
        self.bundleTipLabel.stringValue = @"Bundle: ";
        self.bundlePopupLayout.hidden = NO;
        NSInteger currentIndex = [self.bundles indexOfObject:self.currentBundle];
        if(currentIndex != NSNotFound) {
            [self.bundlePopup selectItemAtIndex:currentIndex];
        }
    }else {
        [self.bundlePopup removeAllItems];
        self.bundleTipLabel.stringValue = @"Bundle unavailable";
        self.bundlePopupLayout.hidden = YES;
    }
}

- (void)updateStringFilesUI {
    for (NSButton *btn in self.stringButtons) {
        if([btn isKindOfClass:[NSButton class]]) {
            [btn removeFromSuperview];
        }
    }
    self.stringButtons = nil;
    if(!self.currentBundle) {
        return;
    }
    NSArray *stringFiles = self.currentBundle.stringFiles;
    CGFloat padding = 8.0f;
    CGFloat space = 8.0f;
    CGFloat left = padding;
    CGFloat itemHeight = self.fileScrollView.height;
    CGFloat itemTop = (self.fileScrollView.size.height - itemHeight)/2.0f;
    NSMutableArray *buttons = [NSMutableArray array];
    NSInteger initialIndex = NSNotFound;
    for (NSInteger i=0;i<stringFiles.count;i++) {
        NSString *fileName = stringFiles[i];
        ADHButton *button = [ADHButton buttonWithTitle:fileName target:self action:@selector(stringFileButtonPressed:)];
        button.bordered = NO;
        button.wantsLayer = YES;
        button.layer.cornerRadius = 4.0f;
        button.layer.borderWidth = 1.0f;
        button.tag = i;
        button.font = [NSFont systemFontOfSize:kStringFileFontSize];
        NSSize buttonSize = [button sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
        CGFloat width = buttonSize.width + 4.0*2;
        button.frame = NSMakeRect(left,itemTop, width, itemHeight);
        left += width;
        if(i != stringFiles.count-1) {
            left += space;
        }else {
            left += padding;
        }
        button.selected = NO;
        [self setButtonAppearanceState:button state:NO];
        [self.fileScrollView addSubview:button];
        [buttons addObject:button];
        if([fileName isEqualToString:@"Localization.string"]) {
            initialIndex = i;
        }
    }
    self.stringButtons = buttons;
    if(self.stringButtons.count > 0) {
        if(initialIndex == NSNotFound) {
            initialIndex = 0;
        }
        ADHButton *button = self.stringButtons[initialIndex];
        button.selected = YES;
        [self setButtonAppearanceState:button state:YES];
    }
}

- (void)setButtonAppearanceState: (NSButton *)button state: (BOOL)on {
    NSColor *textColor = nil;
    NSColor * borderColor = nil;
    if(on) {
        textColor = [Appearance themeColor];
        borderColor = [Appearance themeColor];
    }else {
        textColor = [NSColor grayColor];
        borderColor = [NSColor lightGrayColor];
    }
    button.layer.borderColor = borderColor.CGColor;
    [button setTextColor:textColor];
}

- (void)stringFileButtonPressed: (ADHButton *)button {
    button.selected = !button.selected;
    [self setButtonAppearanceState:button state:button.selected];
    [self updateCurrentStringFiles];
    [self updateContent];
}

- (void)updateCurrentStringFiles {
    ADHLocalizationBundle *lBundle = self.currentBundle;
    NSMutableArray *fileNames = [NSMutableArray array];
    for (ADHButton *btn in self.fileScrollView.subviews) {
        if([btn isKindOfClass:[NSButton class]] && btn.selected) {
            NSInteger index = btn.tag;
            NSString * fileName = lBundle.stringFiles[index];
            [fileNames addObject:fileName];
        }
    }
    self.currentStringFiles = fileNames;
}


- (void)updateContent {
    ADHLocalizationBundle *lBundle = self.currentBundle;
    NSString * bundleName = lBundle.name;
    NSArray * fileNames = self.currentStringFiles;
    NSArray * languages = lBundle.languages;
    [self.view showHud];
    NSDictionary *body = @{
                           @"bundleName" : adhvf_safestringfy(bundleName),
                           @"fileNames" : adhvf_safestringfy([fileNames adh_jsonPresentation]),
                           @"languages" : adhvf_safestringfy([languages adh_jsonPresentation]),
                           };
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.localization" action:@"getContent" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray * list = body[@"contents"];
            wself.contentList = list;
            [wself prepareTableContent];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.view hideHud];
                [wself.tableView reloadData];
            });
        });
    } onFailed:^(NSError *error) {
        [wself.view hideHud];
    }];
}

- (NSDictionary *)stringFileDataWithFileName: (NSString *)fileName {
    NSDictionary *fileData = nil;
    for (NSDictionary *data in self.contentList) {
        NSString *fName = data[@"fileName"];
        if([fileName isEqualToString:fName]) {
            fileData = data;
            break;
        }
    }
    return fileData;
}

- (void)prepareTableContent {
    NSArray *langs = self.currentBundle.languages;
    NSMutableArray<LocalizationRow *> *rowList = [NSMutableArray array];
    for (NSDictionary *data in self.contentList) {
        NSString *fileName = data[@"fileName"];
        NSDictionary *languageValues = data[@"languages"];
        NSMutableSet<NSString *> *keySets = [NSMutableSet set];
        [languageValues enumerateKeysAndObjectsUsingBlock:^(NSString *lang, NSDictionary *contents, BOOL * _Nonnull stop) {
            NSArray *keys = [contents allKeys];
            for (NSString *key in keys) {
                [keySets addObject:key];
            }
        }];
        NSArray<NSString *> *keyList = [keySets allObjects];
        keyList = [keyList sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
        }];
        //header
        LocalizationRow *headerRow = [[LocalizationRow alloc] init];
        headerRow.isHeader = YES;
        headerRow.count = keyList.count;
        headerRow.stringFile = fileName;
        [rowList addObject:headerRow];
        //items
        for (NSInteger i=0; i<keyList.count; i++) {
            NSString *key = keyList[i];
            NSMutableDictionary *values = [NSMutableDictionary dictionary];
            BOOL missing = NO;
            for (NSString *lang in langs) {
                NSDictionary *langItems = languageValues[lang];
                NSString *value = langItems[key];
                if(value) {
                    values[lang] = value;
                }else{
                    missing = YES;
                }
            }
            LocalizationRow *row = [[LocalizationRow alloc] init];
            row.key = key;
            row.langValues = values;
            row.missing = missing;
            row.isHeader = NO;
            [rowList addObject:row];
        }
    }
    self.rowList = rowList;
    [self doRowFilter];
}

#pragma mark- table datasource

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
        column.minWidth = 60.0f;
        column.width = 120.0f;
        column.identifier = identifier;
        if([identifier isEqualToString:kColumnIdentifierKeys]) {
            column.width = 200.0f;
        }else {
            column.width = 120.0f;
        }
        NSDictionary *attributes = @{
                                     NSFontAttributeName : [NSFont boldSystemFontOfSize:13.0f],
                                     };
        NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:title attributes:attributes];
        column.headerCell.attributedStringValue = attributeText;
        [self.tableView addTableColumn:column];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = self.filteredRowList.count;
    return count;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    LocalizationRow *rowItem = self.filteredRowList[row];
    BOOL isHeader = rowItem.isHeader;
    return isHeader;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = nil;
    NSInteger columnIndex = [self.tableView.tableColumns indexOfObject:tableColumn];
    LocalizationRow *rowItem = self.filteredRowList[row];
    if(columnIndex == NSNotFound) {
        NSString *fileName = rowItem.stringFile;
        LocalizationSectionView *sectionCell = [tableView makeViewWithIdentifier:NSStringFromClass([LocalizationSectionView class]) owner:nil];
        NSString *text = [NSString stringWithFormat:@"%@",fileName];
        [sectionCell setText:text];
        cell = sectionCell;
    }else {
        NSString *columnKey = tableColumn.identifier;
        if(![columnKey isEqualToString:kColumnIdentifierSelection]) {
            BOOL keyColumn = NO;
            BOOL missing = NO;
            LocalizationItemCell *itemCell = [tableView makeViewWithIdentifier:NSStringFromClass([LocalizationItemCell class]) owner:nil];
            if([columnKey isEqualToString:kColumnIdentifierKeys]) {
                [itemCell setText:rowItem.key];
                keyColumn = YES;
                missing = rowItem.missing;
            }else {
                NSString *lang = columnKey;
                NSString *value = rowItem.langValues[lang];
                [itemCell setText:value];
                missing = (value.length == 0);
            }
            [itemCell setMissing:missing isKeyColumn:keyColumn];
            cell = itemCell;
        }else {
            LocalizationSelectionCell *selectionCell = [tableView makeViewWithIdentifier:NSStringFromClass([LocalizationSelectionCell class]) owner:nil];
            BOOL selected = [self.selectRowList containsObject:rowItem];
            [selectionCell setSelectionState:selected];
            selectionCell.delegate = self;
            cell = selectionCell;
        }
    }
    return cell;
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
        [self doRowFilter];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark -filter

- (void)doRowFilter {
    NSString *keywords = self.keywords;
    BOOL missing = self.filterBad;
    NSMutableArray<LocalizationRow *> *filteredRowList = [NSMutableArray array];
    for (LocalizationRow *row in self.rowList) {
        BOOL pass = NO;
        if(row.isHeader) {
            pass = YES;
        }else {
            BOOL passMissing = NO;
            if(missing) {
                //如果需要检查missing
                if(row.missing) {
                    passMissing = YES;
                }
            }else {
                passMissing = YES;
            }
            if(passMissing){
                if(keywords.length > 0){
                    if([row.key rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        pass = YES;
                    }
                }else {
                    pass = YES;
                }
            }
        }
        if(pass) {
            [filteredRowList addObject:row];
        }
    }
    self.filteredRowList = filteredRowList;
}

- (IBAction)missButtonPressed:(id)sender {
    self.missButton.selected = !self.missButton.selected;
    [self updateMissButtonStateUI];
    self.filterBad = self.missButton.selected;
    [self doRowFilter];
    [self.tableView reloadData];
}

- (void)updateMissButtonStateUI {
    ADHButton *button = self.missButton;
    if(button.selected) {
        [button setImage:[NSImage imageNamed:@"icon_warn_select"]];
    }else {
        [button setImage:[NSImage imageNamed:@"icon_warn"]];
    }
}

- (void)onWorkAppUpdate {
    if(!self.bundles) {
        [self loadBundleInfo];
    }
}

/**
 * 导出excel
 * 两种模式，每个语言一个文件/合并为同一个文件
 */
- (IBAction)exportButtonPressed:(NSButton *)button {
    if(!doProCheckRoutine()) {return;}
    ADHLocalizationBundle *bundle = self.currentBundle;
    if(!bundle) return;
    //检查数据是否
    if(!self.contentList) return;
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    NSMenuItem *valueMenu = [[NSMenuItem alloc] initWithTitle:@"Export Excel" action:@selector(doExport:) keyEquivalent:adhvf_const_emptystr()];
    valueMenu.target = self;
    [menu addItem:valueMenu];
    NSMenuItem * keyMenu = [[NSMenuItem alloc] initWithTitle:@"Export Excel (Merged)" action:@selector(doExport2:) keyEquivalent:adhvf_const_emptystr()];
    keyMenu.target = self;
    [menu addItem:keyMenu];
    [menu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0, self.exportButton.height) inView:self.exportButton];
}

- (void)doExport: (NSMenuItem *)menu {
    [self doExportMerged:NO];
}

- (void)doExport2: (NSMenuItem *)menu {
    [self doExportMerged:YES];
}

- (void)doExportMerged: (BOOL)merge {
    /*
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    NSEventModifierFlags flags = [event modifierFlags];
    //option是否摁下
    NSUInteger value = (flags & NSEventModifierFlagOption);
    BOOL option = (value > 0);
     */
    ADHLocalizationBundle *bundle = self.currentBundle;
    NSSavePanel *panel = [NSSavePanel savePanel];
    NSString *fileName = [bundle.name stringByDeletingPathExtension];
    if(self.filterBad){
        fileName = [NSString stringWithFormat:@"%@(bad)",fileName];
    }
    fileName = [fileName stringByAppendingString:@".xlsx"];
    panel.nameFieldStringValue = fileName;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if(result == NSModalResponseOK) {
            NSURL *fileURL = panel.URL;
            if(!merge) {
                [self doExportToURL:fileURL];
            }else {
                [self doExportToURL2:fileURL];
            }
        }
    }];
}

/**
 * 生成导出数据
 */
- (NSDictionary *)prepareDataForExport {
    BOOL filterBad = self.filterBad;
    NSMutableDictionary *fileRows = [NSMutableDictionary dictionary];
    NSArray *langs = self.currentBundle.languages;
    NSArray<NSString *> * exportFiles = self.currentStringFiles;
    for (NSString *fileName in exportFiles) {
        NSDictionary * data = [self stringFileDataWithName:fileName];
        NSMutableArray<LocalizationRow *> *rowList = [NSMutableArray array];
        NSDictionary *languageValues = data[@"languages"];
        NSMutableSet<NSString *> *keySets = [NSMutableSet set];
        [languageValues enumerateKeysAndObjectsUsingBlock:^(NSString *lang, NSDictionary *contents, BOOL * _Nonnull stop) {
            NSArray *keys = [contents allKeys];
            for (NSString *key in keys) {
                [keySets addObject:key];
            }
        }];
        NSArray<NSString *> *keyList = [keySets allObjects];
        keyList = [keyList sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
        }];
        //items
        for (NSInteger i=0; i<keyList.count; i++) {
            NSString *key = keyList[i];
            NSMutableDictionary *values = [NSMutableDictionary dictionary];
            BOOL missing = NO;
            for (NSString *lang in langs) {
                NSDictionary *langItems = languageValues[lang];
                NSString *value = langItems[key];
                if(value) {
                    values[lang] = value;
                }else{
                    missing = YES;
                }
            }
            if(!filterBad || missing) {
                LocalizationRow *row = [[LocalizationRow alloc] init];
                row.key = key;
                row.langValues = values;
                [rowList addObject:row];
            }
        }
        fileRows[fileName] = rowList;
    }
    return fileRows;
}

- (NSDictionary *)stringFileDataWithName: (NSString *)fileName {
    NSDictionary * targetData = nil;
    for (NSDictionary *data in self.contentList) {
        NSString *name = data[@"fileName"];
        if([name isEqualToString:fileName]) {
            targetData = data;
            break;
        }
    }
    return targetData;
}

/**
 * 每个语言一个sheet
 */
- (void)doExportToURL: (NSURL *)fileURL {
    [self.exportButton showHud];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary * fileRows = [self prepareDataForExport];
        NSArray<NSString *> * exportFiles = self.currentStringFiles;
        //ready go
        const char *output =  [fileURL fileSystemRepresentation];
        lxw_workbook  *workbook   = new_workbook(output);
        for (NSString *fileName in exportFiles) {
            //create sheet for this language
            lxw_worksheet *worksheet = workbook_add_worksheet(workbook,[self cString:fileName]);
            //create column
            NSMutableArray *columnNames = [NSMutableArray array];
            [columnNames addObject:@"key"];
            NSArray<NSString *> *languages = self.currentBundle.languages;
            [columnNames addObjectsFromArray:languages];
            //strong format
            lxw_format  *strongFormat = workbook_add_format(workbook);
            format_set_bold(strongFormat);
            //左对齐
            format_set_align(strongFormat, LXW_ALIGN_LEFT);
            //垂直居中
            format_set_align(strongFormat, LXW_ALIGN_VERTICAL_CENTER);
            //normal format
            lxw_format *alignFormat = workbook_add_format(workbook);
            format_set_align(alignFormat, LXW_ALIGN_LEFT);
            format_set_align(alignFormat, LXW_ALIGN_VERTICAL_CENTER);
            worksheet_set_column(worksheet, 0, 0, LXW_DEF_COL_WIDTH*2.4, alignFormat);
            worksheet_set_column(worksheet, 1, columnNames.count, LXW_DEF_COL_WIDTH*1.6, alignFormat);
            worksheet_set_default_row(worksheet, LXW_DEF_ROW_HEIGHT*1.6, LXW_FALSE);
            for (NSInteger i=0; i<columnNames.count; i++) {
                NSString *name = columnNames[i];
                const char *text = [name cStringUsingEncoding:NSUTF8StringEncoding];
                worksheet_write_string(worksheet, 0, i, text, strongFormat);
            }
            
            //write rows
            for (NSInteger column=0; column<columnNames.count; column++) {
                if(column == 0) {
                    NSArray<LocalizationRow* > *rowList = fileRows[fileName];
                    for (NSInteger row=0;row<rowList.count; row++) {
                        LocalizationRow *lRow = rowList[row];
                        NSString *text = lRow.key;
                        int cellRow = (int)(row+1);
                        worksheet_write_string(worksheet, cellRow, column, [self cString:text], strongFormat);
                    }
                }else {
                    NSString *language = columnNames[column];
                    NSArray<LocalizationRow* > *rowList = fileRows[fileName];
                    for (NSInteger row=0;row<rowList.count; row++) {
                        LocalizationRow *lRow = rowList[row];
                        NSString *text = lRow.langValues[language];
                        if(text.length > 0) {
                            int cellRow = (int)(row+1);
                            worksheet_write_string(worksheet, cellRow, column, [self cString:text], NULL);
                        }
                    }
                }
            }
        }
        workbook_close(workbook);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.exportButton hideHud];
        });
    });
}

- (const char *)cString: (NSString *)string {
    const char *text = [string cStringUsingEncoding:NSUTF8StringEncoding];
    return text;
}

/**
 * 合并为同一个sheet
 */
- (void)doExportToURL2: (NSURL *)fileURL {
    [self.exportButton showHud];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *fileRows = [self prepareDataForExport];
        NSArray<NSString *> * exportFiles = self.currentStringFiles;
        //ready go
        const char *output =  [fileURL fileSystemRepresentation];
        lxw_workbook  *workbook   = new_workbook(output);
        //create sheet for this language
        lxw_worksheet *worksheet = workbook_add_worksheet(workbook,NULL);
        //set key column width
        worksheet_set_column(worksheet, 0, 0, 20, NULL);
        //create column
        NSMutableArray *columnNames = [NSMutableArray array];
        [columnNames addObject:@"key"];
        NSArray<NSString *> *languages = self.currentBundle.languages;
        [columnNames addObjectsFromArray:languages];
        [columnNames addObject:@"File"];
        //strong format
        lxw_format  *strongFormat = workbook_add_format(workbook);
        format_set_bold(strongFormat);
        //左对齐
        format_set_align(strongFormat, LXW_ALIGN_LEFT);
        //垂直居中
        format_set_align(strongFormat, LXW_ALIGN_VERTICAL_CENTER);
        //normal format
        lxw_format *alignFormat = workbook_add_format(workbook);
        format_set_align(alignFormat, LXW_ALIGN_LEFT);
        format_set_align(alignFormat, LXW_ALIGN_VERTICAL_CENTER);
        worksheet_set_column(worksheet, 0, 0, LXW_DEF_COL_WIDTH*2.4, alignFormat);
        worksheet_set_column(worksheet, 1, columnNames.count, LXW_DEF_COL_WIDTH*1.6, alignFormat);
        worksheet_set_default_row(worksheet, LXW_DEF_ROW_HEIGHT*1.6, LXW_FALSE);
        for (NSInteger i=0; i<columnNames.count; i++) {
            NSString *name = columnNames[i];
            const char *text = [name cStringUsingEncoding:NSUTF8StringEncoding];
            worksheet_write_string(worksheet, 0, i, text, strongFormat);
        }
        NSInteger totalCount = 0;
        for (NSString *fileName in exportFiles) {
            //write rows
            NSArray<LocalizationRow* > *rowList = fileRows[fileName];
            for (NSInteger row=0;row<rowList.count; row++) {
                int cellRow = (int)(totalCount+row+1);
                LocalizationRow *lRow = rowList[row];
                for (NSInteger column=0; column<columnNames.count; column++) {
                    int cellColumn = (int)column;
                    if(column == 0) {
                        NSString *text = lRow.key;
                        worksheet_write_string(worksheet, cellRow, cellColumn, [self cString:text], strongFormat);
                    }else if(column == columnNames.count-1) {
                        //file name
                        NSString *text = fileName;
                        worksheet_write_string(worksheet, cellRow, cellColumn, [self cString:text], NULL);
                    }else {
                        NSString *language = columnNames[column];
                        NSString *text = lRow.langValues[language];
                        if(text.length > 0) {
                            worksheet_write_string(worksheet, cellRow, cellColumn, [self cString:text], NULL);
                        }
                    }
                }
            }
            totalCount += rowList.count;
        }
        workbook_close(workbook);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.exportButton hideHud];
        });
    });
}

#pragma mark -----------------   Selection   ----------------

//selection cell update
- (void)selectionCell: (LocalizationSelectionCell *)cell selectionStateUpdate: (BOOL)selected {
    NSInteger row = [self.tableView rowForView:cell];
    if(row == NSNotFound) return;
    LocalizationRow *itemRow = self.filteredRowList[row];
    if(selected) {
        [self.selectRowList addObject:itemRow];
    }else {
        [self.selectRowList removeObject:itemRow];
    }
    [self updateSelectionItemUI];
}

- (void)updateSelectionItemUI {
    for (NSButton *btn in self.selectionButtons) {
        if([btn isKindOfClass:[NSButton class]]) {
            [btn removeFromSuperview];
        }
    }
    self.selectionButtons = nil;
    CGFloat padding = 8.0f;
    CGFloat space = 8.0f;
    CGFloat left = padding;
    CGFloat itemHeight = 20.0f;
    CGFloat itemTop = 0;
    NSMutableArray *buttons = [NSMutableArray array];
    for (NSInteger i=0;i<self.selectRowList.count;i++) {
        LocalizationRow *row = self.selectRowList[i];
        NSString *title = row.key;
        NSButton *button = [NSButton buttonWithTitle:title target:self action:@selector(selectionButtonClicked:)];
        button.bordered = NO;
        button.wantsLayer = YES;
        button.layer.cornerRadius = 4.0f;
        button.layer.borderWidth = 1.0f;
        button.layer.borderColor = [NSColor lightGrayColor].CGColor;
        button.tag = i;
        button.font = [NSFont systemFontOfSize:kStringFileFontSize];
        NSSize buttonSize = [button sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
        CGFloat width = buttonSize.width + 4.0*2;
        button.frame = NSMakeRect(left,itemTop, width, itemHeight);
        left += width;
        if(i != self.selectRowList.count-1) {
            left += space;
        }else {
            left += padding;
        }
        [self.selectionScrollView addSubview:button];
        [buttons addObject:button];
    }
    self.selectionButtons = buttons;
}

- (void)selectionButtonClicked: (NSButton *)button {
    NSInteger index = [self.selectionButtons indexOfObject:button];
    if(index == NSNotFound || index >= self.selectRowList.count) {
        return;
    }
    [self.selectRowList removeObjectAtIndex:index];
    [self updateSelectionItemUI];
    [self.tableView reloadData];
}

- (IBAction)selectButtonPressed:(id)sender {
    if(self.bSelecting) {
        return;
    }
    [self showSelection:YES animate:YES];
    [self beginSelectionMode];
    self.selectRowList = [NSMutableArray array];
}

- (void)showSelection: (BOOL)show animate: (BOOL)animate {
    CGFloat tableViewHeight = 0;
    if(show){
        CGFloat contentHeight = self.view.frame.size.height;
        CGFloat actionHeight = self.selectionLayout.frame.size.height;
        tableViewHeight = contentHeight - actionHeight - 32.0f;
    }else{
        CGFloat contentHeight = self.view.frame.size.height;
        tableViewHeight = contentHeight - 32.0f;
    }
    CGRect tableRect = self.tableScrollView.frame;
    tableRect.size.height = tableViewHeight;
    if(animate){
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.25;
            self.tableScrollView.animator.frame = tableRect;
        }completionHandler:^{
            self.tableScrollView.frame = tableRect;
        }];
    }else{
        self.tableScrollView.frame = tableRect;
    }
    
    self.bSelecting = show;
}

- (void)beginSelectionMode {
    if(!self.selectionColumn) {
        NSTableColumn * column = [[NSTableColumn alloc] init];
        column.identifier = kColumnIdentifierSelection;
        column.minWidth = 48.0f;
        column.width = 48.0f;
        NSString *title = @"";
        NSDictionary *attributes = @{
                                     NSFontAttributeName : [NSFont boldSystemFontOfSize:13.0f],
                                     };
        NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:title attributes:attributes];
        column.headerCell.attributedStringValue = attributeText;
        self.selectionColumn = column;
    }
    [self.tableView addTableColumn:self.selectionColumn];
    NSInteger columnCount = self.tableView.tableColumns.count;
    if(columnCount > 1) {
        [self.tableView moveColumn:columnCount-1 toColumn:0];
    }
}

- (void)endSelectionMode {
    if([self.tableView.tableColumns containsObject:self.selectionColumn]) {
        [self.tableView removeTableColumn:self.selectionColumn];
    }
}

- (IBAction)finishSelectButtonPressed:(id)sender {
    if(!self.bSelecting) {
        return;
    }
    [self showSelection:NO animate:YES];
    [self endSelectionMode];
}

- (IBAction)stringExportButtonPressed:(id)sender {
}

- (IBAction)selectRemoveButtonPressed:(id)sender {
}

@end
