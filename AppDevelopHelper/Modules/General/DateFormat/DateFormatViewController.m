//
//  DateFormatViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/11.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "DateFormatViewController.h"
#import "DateFormatSectionView.h"
#import "DateFormatItemCell.h"

static NSString * const kDefaultFormat = @"yyyy-MM-dd HH:mm:ss";

@interface DateFormatViewController ()<NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) IBOutlet NSTextField *formatTextField;
@property (nonatomic, strong) IBOutlet NSDatePicker *datePicker;
@property (nonatomic, strong) IBOutlet NSTextField *resultLabel;

@property (weak) IBOutlet NSSegmentedControl *styleSegmentControl;
@property (weak) IBOutlet NSView *styleLayout;
@property (weak) IBOutlet NSPopUpButton *dateStylePopup;
@property (weak) IBOutlet NSPopUpButton *timeStylePopup;

@property (weak) IBOutlet NSView *lineView;
@property (weak) IBOutlet NSImageView *referIcon;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *formatColumn;
@property (weak) IBOutlet NSTableColumn *egColumn;
@property (weak) IBOutlet NSTableColumn *infoColumn;

@property (weak) IBOutlet NSButton *moreReferButton;
@property (weak) IBOutlet NSButton *linkButton;


@property (nonatomic, strong) NSArray *dateStyleList;
@property (nonatomic, strong) NSArray *timeStyleList;

//0: format string, 1: style
@property (nonatomic, assign) NSInteger formatType;

@property (nonatomic, strong) NSArray *infoList;

@end

@implementation DateFormatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValue];
    [self setupUI];
    [self initUI];
    [self addRelation];
    if([self.context.app.frameworkVersion integerValue] >= 127) {
        [self requestUpdate];
    }
}

- (void)setupUI {
    self.view.wantsLayer = YES;
    
    [self.dateStylePopup removeAllItems];
    for (NSNumber * value in self.dateStyleList) {
        NSInteger style = [value integerValue];
        NSString *text = [self readbleFormatStyle:style];
        [self.dateStylePopup addItemWithTitle:text];
    }
    [self.timeStylePopup removeAllItems];
    for (NSNumber * value in self.timeStyleList) {
        NSInteger style = [value integerValue];
        NSString *text = [self readbleFormatStyle:style];
        [self.timeStylePopup addItemWithTitle:text];
    }
    self.resultLabel.textColor = [Appearance themeColor];
    self.resultLabel.stringValue = @"";
    self.lineView.wantsLayer = YES;
    [self.referIcon setTintColor:[Appearance tipThemeColor]];
    //reference table
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([DateFormatSectionView class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([DateFormatSectionView class])];
    {
        NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([DateFormatItemCell class]) bundle:nil];
        [self.tableView registerNib:nib forIdentifier:NSStringFromClass([DateFormatItemCell class])];
    }
    self.tableView.intercellSpacing = NSZeroSize;
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask;
    self.tableView.floatsGroupRows = NO;
    
    [self updateAppearanceUI];
}

- (void)addRelation {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formatTextDidChange:) name:NSControlTextDidChangeNotification object:self.formatTextField];
    [self.datePicker setAction:@selector(datePickerValueChanged:)];
}

- (void)updateAppearanceUI {
    if([Appearance isDark]) {
        self.view.layer.backgroundColor = [Appearance colorWithHex:0x202123].CGColor;
        self.view.layer.shadowColor = [Appearance colorWithHex:0x202123 alpha:0.5].CGColor;
    }else {
        self.view.layer.backgroundColor = [Appearance colorWithHex:0xF2F2F2].CGColor;
        self.view.layer.shadowColor = [Appearance colorWithHex:0x9F9F9F alpha:0.5].CGColor;
    }
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
}

- (void)initValue {
    self.dateStyleList = @[
        @(NSDateFormatterNoStyle),
        @(NSDateFormatterShortStyle),
        @(NSDateFormatterMediumStyle),
        @(NSDateFormatterLongStyle),
        @(NSDateFormatterFullStyle),
    ];
    self.timeStyleList = @[
        @(NSDateFormatterNoStyle),
        @(NSDateFormatterShortStyle),
        @(NSDateFormatterMediumStyle),
        @(NSDateFormatterLongStyle),
        @(NSDateFormatterFullStyle),
    ];
    ///base on 2020/07/18 16:35:08 local:China
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dateformat" ofType:@"txt"];
    NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *list = [content componentsSeparatedByString:@"\n"];
    NSMutableArray *rowList = [NSMutableArray array];
    for (NSString *text in list) {
        if([text hasPrefix:@"--"]) {
            //group
            NSString *groupText = [text stringByReplacingOccurrencesOfString:@"--" withString:@""];
            [rowList addObject:@{
                @"group" : @(1),
                @"text" : adhvf_safestringfy(groupText),
            }];
        }else if([text containsString:@"--"]) {
            //row
            NSArray *components = [text componentsSeparatedByString:@"--"];
            if(components.count == 3) {
                NSString *format = components[0];
                NSString *example = components[1];
                NSString *info = components[2];
                NSDictionary *rowData = @{
                    @"f" : adhvf_safestringfy(format),
                    @"eg" : adhvf_safestringfy(example),
                    @"info" : adhvf_safestringfy(info),
                };
                [rowList addObject:rowData];
            }
        }
    }
    self.infoList = rowList;
}

- (void)initUI {
    self.formatType = [[Preference defaultValueForKey:@"formattype" inDomain:kToolModuleDateFormat] integerValue];
    [self updateFormatTypeUI];
    if(self.formatType == 0) {
        self.styleSegmentControl.selectedSegment = 0;
    }else {
        self.styleSegmentControl.selectedSegment = 1;
    }
    NSString *format = [Preference defaultValueForKey:@"format" inDomain:kToolModuleDateFormat];
    NSInteger dateStyle = [[Preference defaultValueForKey:@"datestyle" inDomain:kToolModuleDateFormat] integerValue];
    NSInteger timeStyle = [[Preference defaultValueForKey:@"timestyle" inDomain:kToolModuleDateFormat] integerValue];
    if(format.length > 0) {
        self.formatTextField.stringValue = format;
    }else {
        self.formatTextField.stringValue = kDefaultFormat;
    }
    [self.dateStylePopup selectItemAtIndex:dateStyle];
    [self.timeStylePopup selectItemAtIndex:timeStyle];
    self.datePicker.dateValue = [NSDate date];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [self.tableView reloadData];
}

- (void)updateFormatTypeUI {
    if(self.formatType == 0) {
        self.styleLayout.hidden = YES;
        self.formatTextField.hidden = NO;
    }else {
        self.styleLayout.hidden = NO;
        self.formatTextField.hidden = YES;
    }
}

- (IBAction)formatTypeValueChanged:(id)sender {
    if(self.styleSegmentControl.selectedSegment == 0) {
        self.formatType = 0;
    }else {
        self.formatType = 1;
    }
    [self updateFormatTypeUI];
    [self requestUpdate];
    [Preference setDefaultValue:[NSNumber numberWithInteger:self.formatType] forKey:@"formattype" inDomain:kToolModuleDateFormat];
}

- (IBAction)nowButtonPressed:(id)sender {
    self.datePicker.dateValue = [NSDate date];
    [self requestUpdate];
}

- (IBAction)minButtonPressed:(id)sender {
    self.datePicker.dateValue = [NSDate dateWithTimeIntervalSince1970:0];
    [self requestUpdate];
}

- (void)formatTextDidChange: (NSNotification *)noti {
    NSString *format = self.formatTextField.stringValue;
    if(!format) {
        format = @"";
    }
    [self requestUpdate];
    [Preference setDefaultValue:format forKey:@"format" inDomain:kToolModuleDateFormat];
}

- (void)datePickerValueChanged: (NSNotification *)noti {
    [self requestUpdate];
}

- (IBAction)dateStyleValueChanged:(id)sender {
    [self requestUpdate];
    NSInteger dateStyle = [self getDateStyle];
    [Preference setDefaultValue:[NSNumber numberWithInteger:dateStyle] forKey:@"datestyle" inDomain:kToolModuleDateFormat];
}

- (IBAction)timeStyleValueChanged:(id)sender {
    [self requestUpdate];
    NSInteger timeStyle = [self getTimeStyle];
    [Preference setDefaultValue:[NSNumber numberWithInteger:timeStyle] forKey:@"timestyle" inDomain:kToolModuleDateFormat];
}

- (NSInteger)getDateStyle {
    NSInteger dateIndex = self.dateStylePopup.indexOfSelectedItem;
    NSInteger dateStyle = [self.dateStyleList[dateIndex] integerValue];
    return dateStyle;
}

- (NSInteger)getTimeStyle {
    NSInteger timeIndex = self.timeStylePopup.indexOfSelectedItem;
    NSInteger timeStyle = [self.timeStyleList[timeIndex] integerValue];
    return timeStyle;
}

- (void)requestUpdate {
    if(![self doCheckConnectionRoutine]) {
        return;
    }
    if([self.context.app frameworkVersionValue] < 127) {
        [self showVersionNotSupport];
        return;
    }
    NSDate *date = self.datePicker.dateValue;
    NSString *format = nil;
    NSInteger dateStyle = 0;
    NSInteger timeStyle = 0;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if(self.formatType == 0) {
        format = self.formatTextField.stringValue;
        if(format.length == 0) {
            self.resultLabel.stringValue = @"";
            return;
        }
        data[@"format"] = format;
    }else {
        NSInteger dateIndex = self.dateStylePopup.indexOfSelectedItem;
        NSInteger timeIndex = self.timeStylePopup.indexOfSelectedItem;
        dateStyle = [self.dateStyleList[dateIndex] integerValue];
        timeStyle = [self.timeStyleList[timeIndex] integerValue];
        data[@"datestyle"] = [NSNumber numberWithInteger:dateStyle];
        data[@"timestyle"] = [NSNumber numberWithInteger:timeStyle];
    }
    NSData *payload = [NSKeyedArchiver archivedDataWithRootObject:date requiringSecureCoding:YES error:nil];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.utility" action:@"dateformat" body:data payload:payload progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        NSString *text = body[@"text"];
        wself.resultLabel.stringValue = adhvf_safestringfy(text);
    } onFailed:^(NSError *error) {
        
    }];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = self.infoList.count;
    return count;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    NSDictionary *rowData = self.infoList[row];
    BOOL isHeader = [rowData[@"group"] boolValue];
    return isHeader;
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSDictionary *rowData = self.infoList[row];
    BOOL isHeader = [rowData[@"group"] boolValue];
    if(isHeader) {
        return -1;
    }
    CGFloat height = 30.0f;
    NSString *text = rowData[@"info"];
    CGFloat columnWidth = self.infoColumn.width;
    CGFloat boundingWidth = columnWidth - 10.0 - 12.0f;
    if(boundingWidth > 50.0f) {
        CGFloat textHeight = [UIUtil measureTextSize:boundingWidth text:text font:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
        textHeight += 13.0f;
        height = MAX(textHeight, height);
    }
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = nil;
    NSInteger columnIndex = [self.tableView.tableColumns indexOfObject:tableColumn];
    NSDictionary *rowData = self.infoList[row];
    if(columnIndex == NSNotFound) {
        NSString *title = rowData[@"text"];
        DateFormatSectionView *sectionView = [tableView makeViewWithIdentifier:NSStringFromClass([DateFormatSectionView class]) owner:nil];
        [sectionView setText:title];
        cell = sectionView;
    }else {
        DateFormatItemCell *itemCell = [tableView makeViewWithIdentifier:NSStringFromClass([DateFormatItemCell class]) owner:nil];
        NSString *text = nil;
        if(tableColumn == self.formatColumn) {
            text = rowData[@"f"];
            [itemCell setText:text width:self.infoColumn.width];
        }else if(tableColumn == self.egColumn) {
            text = rowData[@"eg"];
            [itemCell setText:text width:self.infoColumn.width];
        }else if(tableColumn == self.infoColumn) {
            text = rowData[@"info"];
            [itemCell setText:text width:self.infoColumn.width];
        }
        cell = itemCell;
    }
    return cell;
}


- (NSString *)readbleFormatStyle: (NSDateFormatterStyle)style {
    NSString *text = nil;
    switch (style) {
        case NSDateFormatterNoStyle:
            text = @"No Style";
            break;
        case NSDateFormatterShortStyle:
            text = @"Short Style";
            break;
        case NSDateFormatterMediumStyle:
            text = @"Medium Style";
            break;
        case NSDateFormatterLongStyle:
            text = @"Long Style";
            break;
        case NSDateFormatterFullStyle:
            text = @"Full Style";
            break;
        default:
            break;
    }
    return text;
}

- (IBAction)linkButtonClicked:(id)sender {
    [UrlUtil openExternalUrl:@"https://www.nsdateformatter.com/"];
}


- (IBAction)referenceButtonClicked:(id)sender {
    [UrlUtil openExternalUrl:@"http://www.unicode.org/reports/tr35/tr35-dates.html#Date_Format_Patterns"];
}

- (void)showVersionNotSupport {
    NSString *tip = [NSString stringWithFormat:kLocalized(@"frameworkrequire_tip"),@"1.2.7"];
    [ADHAlert alertWithMessage:kLocalized(@"alert_title") infoText:tip confirmText:kLocalized(@"update") cancelText:kAppLocalized(@"Cancel") comfirmBlock:^{
        [UrlUtil openExternalLocalizedUrl:@"web_usage"];
    } cancelBlock:^{
        
    }];
}

@end
