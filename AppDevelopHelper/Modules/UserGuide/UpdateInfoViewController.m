//
//  UpdateInfoViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/6/3.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "UpdateInfoViewController.h"
#import "UpdateInfoCell.h"
#import "Preference.h"
#import "UpdateHistory.h"
#import "DeviceUtil.h"

@interface UpdateInfoViewController ()<ADHBaseCellDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *updateTextfield;
@property (nonatomic, strong) NSArray * viewList;
@property (weak) IBOutlet NSButton *startButton;

@end

@implementation UpdateInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self loadContent];
    [self.tableView reloadData];
}

- (void)setupAfterXib {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([UpdateInfoCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([UpdateInfoCell class])];
    self.tableView.wantsLayer = YES;
    self.updateTextfield.stringValue = [NSString stringWithFormat:kLocalized(@"update_tip"),[DeviceUtil appVersion]];
    self.updateTextfield.textColor = [Appearance themeColor];
    NSButton *startButton = self.startButton;
    startButton.wantsLayer = YES;
    startButton.layer.cornerRadius = 6.0f;
    startButton.layer.borderWidth = 1.0f;
    startButton.layer.borderColor = [Appearance themeColor].CGColor;
    [startButton setTitle:kLocalized(@"start")];
    [startButton setTextColor:[Appearance themeColor]];
    self.view.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    NSView *view = self.view;
    if([Appearance isDark]) {
        CALayer *layer = view.layer;
        layer.masksToBounds = NO;
        layer.backgroundColor = [Appearance colorWithHex:0x323232].CGColor;
        layer.cornerRadius = 6.0f;
        layer.borderColor = [Appearance colorWithHex:0x171717 alpha:1.0].CGColor;
        layer.borderWidth = 1.0f;

        layer.shadowColor = [Appearance colorWithHex:0x171717].CGColor;
        layer.shadowOffset = CGSizeMake(1, -1);
        layer.shadowRadius = 3.0f;
        layer.shadowOpacity = 1.0f;
        self.tableView.backgroundColor = [Appearance colorWithHex:0x323232];
    }else {
        CALayer *layer = view.layer;
        layer.masksToBounds = NO;
        layer.backgroundColor = [NSColor whiteColor].CGColor;
        layer.cornerRadius = 6.0f;
        layer.borderColor = [Appearance colorWithHex:0xAEAEAE alpha:0.5].CGColor;
        layer.borderWidth = 1.0f;
        
        layer.shadowColor = [Appearance colorWithHex:0xDEDEDE].CGColor;
        layer.shadowOffset = CGSizeMake(1, -1);
        layer.shadowRadius = 3.0f;
        layer.shadowOpacity = 1.0f;
        self.tableView.backgroundColor = [NSColor whiteColor];
    }
}

- (void)loadContent {
    NSArray *updateList = [[UpdateHistory shared] updationList];
    NSMutableArray *viewList = [NSMutableArray array];
    for (NSInteger i=0; i<updateList.count; i++) {
        NSDictionary *data = updateList[i];
        NSMutableDictionary *mData = [data mutableCopy];
        if(updateList.count > 1) {
            mData[@"title"] = [NSString stringWithFormat:@"%zd. %@",i+1,data[@"title"]];
        }
        [viewList addObject:mData];
    }
    self.viewList = viewList;
}

#pragma mark -----------------   tableview datasource & delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.viewList.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat height = 0.0f;
    NSDictionary * data = self.viewList[row];
    height = [UpdateInfoCell heightForData:data contentWidth:tableView.width];
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary * data = self.viewList[row];
    UpdateInfoCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([UpdateInfoCell class]) owner:nil];
    [cell setData:data contentWidth:tableView.width];
    cell.delegate = self;
    return cell;
}

- (void)cellClicked:(ADHBaseCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    NSDictionary * data = self.viewList[row];
    NSString * link = data[@"link"];
    if(link) {
        NSURL * requestURL = [NSURL URLWithString:link];
        [[NSWorkspace sharedWorkspace] openURL:requestURL];
    }
}

- (IBAction)startButtonClicked:(id)sender {
    [Preference setLatestVersion:[DeviceUtil appVersion]];
    [self.view removeFromSuperview];
}

- (IBAction)historyButtonClicked:(id)sender {
    [UrlUtil openExternalLocalizedUrl:@"web_versionlist"];
}

@end





