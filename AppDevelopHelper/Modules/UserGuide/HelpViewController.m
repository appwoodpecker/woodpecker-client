//
//  WelcomeViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/2.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpCell.h"
#import "Preference.h"

@interface HelpViewController ()<ADHBaseCellDelegate>

@property (weak) IBOutlet NSView *logoLayoutView;
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSArray * linkList;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self loadContent];
    [self.tableView reloadData];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    NSWindowStyleMask style = self.view.window.styleMask;
    style = (style & ~(NSWindowStyleMaskResizable|NSWindowStyleMaskTitled));
    self.view.window.styleMask = style;
}

- (void)setupAfterXib
{
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.logoLayoutView.wantsLayer = YES;
    self.logoLayoutView.layer.backgroundColor = [Appearance themeColor].CGColor;
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([HelpCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([HelpCell class])];
}

- (void)loadContent
{
    
    self.linkList = @[
                      @{
                          @"title" : NSLocalizedString(@"welcome_usage", nil),
                          @"link" : [self getUrl:NSLocalizedString(@"web_usage", nil)],
                          },
                      @{
                          @"title" : NSLocalizedString(@"welcome_connection", nil),
                          @"link" : [self getUrl:NSLocalizedString(@"web_connection", nil)],
                          },
                      @{
                          @"title" : NSLocalizedString(@"welcome_plugin", nil),
                          @"link" : [self getUrl:NSLocalizedString(@"web_plugin", nil)],
                          },
                      @{
                          @"title" : NSLocalizedString(@"welcome_tool_sandbox", nil),
                          @"link" : [self getUrl:NSLocalizedString(@"web_tool_sandbox", nil)],
                          },
                      @{
                          @"title" : NSLocalizedString(@"welcome_tool_network", nil),
                          @"link" : [self getUrl:NSLocalizedString(@"web_tool_network", nil)],
                          },
                      @{
                          @"title" : NSLocalizedString(@"welcome_tool_io", nil),
                          @"link" : [self getUrl:NSLocalizedString(@"web_tool_io", nil)],
                          },
                      @{
                          @"title" : NSLocalizedString(@"welcome_tool_webconsole", nil),
                          @"link" : [self getUrl:NSLocalizedString(@"web_tool_webconsole", nil)],
                          },
                      @{
                          @"title" : NSLocalizedString(@"welcome_tool_userdefaults", nil),
                          @"link" : [self getUrl:NSLocalizedString(@"web_tool_userdefaults", nil)],
                          },
                      @{
                          @"title" : NSLocalizedString(@"welcome_tool_deviceinfo", nil),
                          @"link" : [self getUrl:NSLocalizedString(@"web_tool_deviceinfo", nil)],
                          },
                      ];
    
}

- (NSString *)getUrl: (NSString *)path
{
    return [UrlUtil filteredUrl:path];
}

#pragma mark -----------------   tableview datasource & delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.linkList.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    height = [HelpCell height];
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary * data = self.linkList[row];
    HelpCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([HelpCell class]) owner:nil];
    [cell setData:data];
    cell.delegate = self;
    return cell;
}

- (void)cellClicked:(ADHBaseCell *)cell
{
    NSInteger row = [self.tableView rowForView:cell];
    NSDictionary * data = self.linkList[row];
    NSString * link = data[@"link"];
    NSURL * requestURL = [NSURL URLWithString:link];
    [[NSWorkspace sharedWorkspace] openURL:requestURL];
}

- (IBAction)closeButtonPressed:(id)sender {
    [Preference setWelcomePageShowd:YES];
    [self.presentingViewController dismissViewController:self];
}

@end





