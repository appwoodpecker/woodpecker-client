//
//  ToolsViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/17.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ToolsViewController.h"
#import "MacOrganizer.h"
#import "SandboxViewController.h"
#import "FileBrowserViewController.h"
#import "NetworkViewController.h"
#import "LogViewController.h"
#import "WebClientViewController.h"
#import "LocalInfoViewController.h"
#import "NotificationViewController.h"
#import "UserDefaultsViewController.h"
#import "DeviceViewController.h"
#import "LocalizationViewController.h"
#import "KeyChainViewController.h"
#import "IndexTestViewController.h"
#import "EnvtService.h"
#import "RateViewController.h"
#import "CloudViewController.h"
#import "StateMasterViewController.h"
#import "UtilityViewController.h"
#import "FirebaseViewController.h"

static NSString *const kTabTitle = @"title";
static NSString *const kTabPage = @"page";
static NSString *const kTabIcon = @"icon";
static NSString *const kTabPlugin = @"plugin";

static NSInteger const kTabTagBase = 1000;
static NSInteger const kTagLabel = 101;
static NSInteger const kTagIcon = 102;

@interface ToolsViewController ()

@property (weak) IBOutlet NSView *tabLayout;
@property (weak) IBOutlet NSScrollView *tabScrollView;
@property (strong) NSView *documentView;
@property (weak) IBOutlet NSImageView *moreImageView;

@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSView *lineView;

@property (nonatomic, strong) NSArray *nativeList;
@property (nonatomic, strong) NSArray *pluginList;
@property (nonatomic, strong) NSArray *tabList;

@property (nonatomic, assign) NSInteger currentTabIndex;

@end

@implementation ToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self loadContent];
    [self loadContentUI];
    [self addNotification];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)setupAfterXib {
    self.tabLayout.wantsLayer = YES;
    self.lineView.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)updateAppearanceUI {
    if([Appearance isDark]) {
        self.tabLayout.layer.backgroundColor = [Appearance colorWithHex:0x313234].CGColor;
        self.lineView.layer.backgroundColor = [Appearance colorWithHex:0xEEEEEE alpha:0.05].CGColor;
        self.moreImageView.image = [NSImage imageNamed:@"tool_more_shadow_dark"];
    }else {
        self.tabLayout.layer.backgroundColor = [Appearance colorWithHex:0xEBEBEB].CGColor;
        self.lineView.layer.backgroundColor = [Appearance colorWithHex:0xDFDFDF].CGColor;
        self.moreImageView.image = [NSImage imageNamed:@"tool_more_shadow"];
    }
    [self updateCurrentTab];
}

- (void)loadContent {
    self.nativeList = [self getNativeItems];
    NSArray *pluginTabs = [self getPluginItems];
    self.pluginList = pluginTabs;
    NSMutableArray *tabList = [NSMutableArray array];
    [tabList addObjectsFromArray:self.nativeList];
    [tabList addObjectsFromArray:self.pluginList];
    self.tabList = tabList;
}

- (NSArray *)getNativeItems {
    NSInteger frameworkVersion = [self.context.app frameworkVersionValue];
    NSMutableArray *nativeTabs = [NSMutableArray array];
    if(self.context.app.isAndroid) {
        [nativeTabs addObject:@{
            kTabTitle : @"Sandbox",
            kTabPage : @"SandboxViewController",
            kTabIcon : @"tool_sandbox",
        }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"SharedPrefs",
             kTabPage : @"SharedPrefsViewController",
             kTabIcon : @"tool_sandbox",
         }];
    }else if(self.context.app.isMacOS) {
        [nativeTabs addObject:
         @{
             kTabTitle : @"Sandbox",
             kTabPage : @"SandboxViewController",
             kTabIcon : @"tool_sandbox",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"UserDefaults",
             kTabPage : @"UserDefaultsViewController",
             kTabIcon : @"tool_userdefaults",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Network",
             kTabPage : @"NetworkViewController",
             kTabIcon : @"tool_network",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Bundle",
             kTabPage : @"AppBundleViewController",
             kTabIcon : @"tool_bundle",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Notification",
             kTabPage : @"NotificationViewController",
             kTabIcon : @"tool_notification",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Localization",
             kTabPage : @"LocalizationViewController",
             kTabIcon : @"tool_localization",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Logger",
             kTabPage : @"LogViewController",
             kTabIcon : @"tool_io",
         }];
#if DEBUG
        [nativeTabs addObject:
         @{
             kTabTitle : @"Test",
             kTabPage : @"IndexTestViewController",
             kTabIcon : @"tool_test",
         }];
#endif
    }else {
        if(frameworkVersion >= 127) {
            [nativeTabs addObject:
            @{
                kTabTitle : @"Home",
                kTabPage : @"HomeViewController",
                kTabIcon : @"tool_home",
            }];
        }
        [nativeTabs addObject:
         @{
             kTabTitle : @"Sandbox",
             kTabPage : @"SandboxViewController",
             kTabIcon : @"tool_sandbox",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"UserDefaults",
             kTabPage : @"UserDefaultsViewController",
             kTabIcon : @"tool_userdefaults",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"State Master",
             kTabPage : @"StateMasterIndexViewController",
             kTabIcon : @"tool_statemaster",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Network",
             kTabPage : @"NetworkViewController",
             kTabIcon : @"tool_network",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"View",
             kTabPage : @"ViewDebugViewController",
             kTabIcon : @"tool_view",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Bundle",
             kTabPage : @"AppBundleViewController",
             kTabIcon : @"tool_bundle",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Keychain",
             kTabPage : @"KeyChainViewController",
             kTabIcon : @"tool_keychain",
         }];
        if(frameworkVersion < 127) {
            [nativeTabs addObject:
            @{
                kTabTitle : @"Device",
                kTabPage : @"DeviceViewController",
                kTabIcon : @"tool_device",
            }];
        }
        [nativeTabs addObject:
         @{
             kTabTitle : @"Notification",
             kTabPage : @"NotificationViewController",
             kTabIcon : @"tool_notification",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Localization",
             kTabPage : @"LocalizationViewController",
             kTabIcon : @"tool_localization",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"Logger",
             kTabPage : @"LogViewController",
             kTabIcon : @"tool_io",
         }];
        [nativeTabs addObject:
         @{
             kTabTitle : @"iCloud",
             kTabPage : @"CloudViewController",
             kTabIcon : @"tool_icloud",
         }];
        if([self.context.app.appToolList containsObject:@"firebase"]) {
            [nativeTabs addObject:
            @{
                kTabTitle : @"Remote Config",
                kTabPage : @"FirebaseViewController",
                kTabIcon : @"tool_firebase",
            }];
        }
        [nativeTabs addObject:
        @{
            kTabTitle : @"Utility",
            kTabPage : @"UtilityViewController",
            kTabIcon : @"tool_utility",
        }];
        
#if DEBUG
        [nativeTabs addObject:
         @{
             kTabTitle : @"Test",
             kTabPage : @"IndexTestViewController",
             kTabIcon : @"tool_test",
         }];
#endif
    }
    return nativeTabs;
}

- (NSArray *)getPluginList {
    NSString * pluginPath = [[EnvtService sharedService] pluginPath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSURL *fileURL = [NSURL fileURLWithPath:pluginPath];
    NSMutableArray *pluginList = [NSMutableArray array];
    NSArray<NSURLResourceKey> * keys = @[NSURLNameKey,
                                         NSURLIsDirectoryKey,
                                         NSURLCreationDateKey,
                                         NSURLIsPackageKey
                                         ];
    NSDirectoryEnumerator<NSURL *> * enumerator = [fileManager enumeratorAtURL:fileURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    for (NSURL * itemURL in enumerator) {
        NSString *itemName = nil;
        [itemURL getResourceValue:&itemName forKey:NSURLNameKey error:nil];
        NSDate *creationDate = nil;
        [itemURL getResourceValue:&creationDate forKey:NSURLCreationDateKey error:nil];
        NSNumber *packageValue = nil;
        [itemURL getResourceValue:&packageValue forKey:NSURLIsPackageKey error:nil];
        if(![itemName hasSuffix:@"bundle"]){
            continue;
        }
        if([itemName isEqualToString:@"adh.bundle"]) {
            continue;
        }
        if(![packageValue boolValue]) {
            continue;
        }
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"name"] = itemName;
        data[@"date"] = creationDate;
        [pluginList addObject:data];
    }
    //sort by creationDate
    [pluginList sortUsingComparator:^NSComparisonResult(NSDictionary *data1, NSDictionary *data2) {
        NSDate *date1 = data1[@"date"];
        NSDate *date2 = data2[@"date"];
        return [date1 compare:date2];
    }];
    return pluginList;
}

- (NSArray *)getPluginItems {
    NSMutableArray * pluginItems = [NSMutableArray array];
    NSString * pluginPath = [[EnvtService sharedService] pluginPath];
    NSArray* pluginList = [self getPluginList];
    for (NSDictionary *itemData in pluginList) {
        NSString *fileName = itemData[@"name"];
        NSString * itemPath = [pluginPath stringByAppendingPathComponent:fileName];
        NSString * name = [fileName stringByDeletingPathExtension];
        if(name.length == 0){
            continue;
        }
        //检查是否有index.html,icon.png
        NSString * indexFilePath = [itemPath stringByAppendingPathComponent:@"index.html"];
        if(![ADHFileUtil fileExistsAtPath:indexFilePath]){
            continue;
        }
        NSString * iconFilePath = [itemPath stringByAppendingPathComponent:@"icon.png"];
        if(![ADHFileUtil fileExistsAtPath:iconFilePath]){
            continue;
        }
        //config.json
        ADHPlatform platform = ADHPlatformiOS;
        NSString *configFilePath = [itemPath stringByAppendingPathComponent:@"config.json"];
        if([ADHFileUtil fileExistsAtPath:configFilePath]) {
            NSString *text = [NSString stringWithContentsOfFile:configFilePath encoding:NSUTF8StringEncoding error:nil];
            if([text isKindOfClass:[NSString class]] && text.length > 0) {
                NSDictionary *config = [text adh_jsonObject];
                if([config isKindOfClass:[NSDictionary class]]) {
                    if(config[@"platform"]) {
                        NSString *value = config[@"platform"];
                        if([value isEqualToString:@"mac"]) {
                            platform = ADHPlatformMacOS;
                        }else if([value isEqualToString:@"android"]) {
                            platform = ADHPlatformAndroid;
                        }
                    }
                }
            }
        }
        if(self.context.app.isAndroid) {
            if(platform != ADHPlatformAndroid) {
                continue;
            }
        }else if(self.context.app.isMacOS) {
            if(platform != ADHPlatformMacOS) {
                continue;
            }
        }else {
            if(platform != ADHPlatformiOS) {
                continue;
            }
        }
        NSMutableDictionary * pluginData = [NSMutableDictionary dictionary];
        pluginData[kTabTitle] = name;
        pluginData[kTabIcon] = iconFilePath;
        pluginData[kTabPage] = indexFilePath;
        pluginData[kTabPlugin] = [NSNumber numberWithBool:YES];
        [pluginItems addObject:pluginData];
    }
    return pluginItems;
}

- (void)loadContentUI {
    [self loadTabBar];
    [self loadContentPages];
    self.currentTabIndex = 0;
    [self updateCurrentTab];
    [self.tabView selectTabViewItemAtIndex:self.currentTabIndex];
}

- (void)loadTabBar {
    CGFloat left = 20.0f;
    CGFloat itemHeight = self.tabLayout.height;
    CGFloat iconSize = 24.0f;
    NSView *documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, self.tabScrollView.height)];
    for (NSInteger i=0; i<self.tabList.count; i++) {
        NSDictionary *tabData = self.tabList[i];
        NSString *title = tabData[kTabTitle];
        NSFont *labelFont = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]-1];
        CGFloat itemWidth = [self getItemWidth:title font:labelFont];
        NSView *itemView = [[NSView alloc] initWithFrame:NSMakeRect(left, 0, itemWidth, itemHeight)];
        itemView.wantsLayer = YES;
        //state view
        NSView *stateView = [[NSView alloc] initWithFrame:itemView.bounds];
        stateView.wantsLayer = YES;
        stateView.layer.cornerRadius = 4.0f;
        [itemView addSubview:stateView];
        //label
        NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 4.0f, itemWidth, 15.0f)];
        label.drawsBackground = NO;
        label.bordered = NO;
        label.editable = NO;
        label.selectable = NO;
        label.font = labelFont;
        label.textColor = [NSColor darkGrayColor];
        label.alignment = NSTextAlignmentCenter;
        label.stringValue = title;
        label.tag = kTagLabel;
        [itemView addSubview:label];
        //icon
        CGFloat iconLeft = (itemWidth-iconSize)/2.0f;
        NSImageView *icon = [[NSImageView alloc] initWithFrame:NSMakeRect(iconLeft, label.bottom + 2.0f, iconSize, iconSize)];
        icon.imageAlignment = NSImageAlignCenter;
        icon.imageScaling = NSImageScaleProportionallyDown;
        icon.tag = kTagIcon;
        BOOL isPlugin = [tabData[kTabPlugin] boolValue];
        if(!isPlugin) {
            icon.image = [NSImage imageNamed:tabData[kTabIcon]];
        }else {
            NSString * iconPath = tabData[kTabIcon];
            icon.image = [[NSImage alloc] initWithContentsOfFile:iconPath];
        }
        [itemView addSubview:icon];
        //button
        NSButton *button = [[NSButton alloc] initWithFrame:itemView.bounds];
        button.target = self;
        button.action = @selector(tabButtonClicked:);
        button.bordered = NO;
        button.tag = kTabTagBase + i;
        button.title = @"";
        [itemView addSubview:button];
        [documentView addSubview:itemView];
        left += itemWidth;
    }
    documentView.width = left;
    self.tabScrollView.documentView = documentView;
    self.documentView = documentView;
}

- (void)resetTabBar {
    NSView *tabBar = self.documentView;
    NSArray *views = [tabBar.subviews copy];
    for (NSView *view in views) {
        [view removeFromSuperview];
    }
}

- (CGFloat)getItemWidth: (NSString *)title font: (NSFont *)font{
    NSDictionary *attributes = @{
                                 NSFontAttributeName : font,
                                 };
    CGSize textSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    CGFloat itemWidth = textSize.width + 4.0f * 2;
    itemWidth = MAX(50.0f, itemWidth);
    return itemWidth;
}

- (void)loadContentPages {
    for (NSInteger i=0; i<self.tabList.count; i++) {
        NSDictionary *tabData = self.tabList[i];
        BOOL isPlugin = [tabData[kTabPlugin] boolValue];
        NSString *page = tabData[kTabPage];
        NSString *title = tabData[kTabTitle];
        NSViewController *vc = nil;
        if(!isPlugin) {
            vc = (NSViewController *)[[NSClassFromString(page) alloc] init];
        }else {
            WebClientViewController * pluginVC = [[WebClientViewController alloc] init];
            pluginVC.pluginIdentifier = title;
            pluginVC.pluginName = title;
            pluginVC.pluginPath = page;
            vc = pluginVC;
        }
        vc.context = self.context;
        NSTabViewItem *item = [NSTabViewItem tabViewItemWithViewController:vc];
        [self.tabView addTabViewItem:item];
    }
}

- (void)resetContentPages {
    NSArray *tabViewItems = self.tabView.tabViewItems;
    NSTabViewItem *selectItem = self.tabView.selectedTabViewItem;
    for (NSTabViewItem *tabItem in tabViewItems) {
        //remove当前item时会自动把下一个item select，为了避免这个问题，最后再移除当前item
        if(tabItem == selectItem) {
            continue;
        }
        [self.tabView removeTabViewItem:tabItem];
    }
    if(selectItem) {
        [self.tabView removeTabViewItem:selectItem];
    }
}


- (void)tabButtonClicked: (NSButton *)button {
    NSInteger index = button.tag - kTabTagBase;
    self.currentTabIndex = index;
    [self updateCurrentTab];
    [self.tabView selectTabViewItemAtIndex:self.currentTabIndex];
}

- (void)updateCurrentTab {
    //update tab
    BOOL isDark = [Appearance isDark];
    NSArray *tabViews = self.documentView.subviews;
    for (NSInteger i=0; i<tabViews.count; i++) {
        NSView *itemView = tabViews[i];
        NSTextField *label = (NSTextField *)[itemView viewWithTag:kTagLabel];
        if(i == self.currentTabIndex) {
            label.textColor = [Appearance themeColor];
        }else {
            if(isDark) {
                label.textColor = [[NSColor whiteColor] colorWithAlphaComponent:0.75];
            }else {
                label.textColor = [[NSColor blackColor] colorWithAlphaComponent:0.7];
            }
        }
    }
}

- (void)onWorkAppUpdate {
    
}

//更新插件
- (void)reloadTools {
    //remove tabbar
    [self resetTabBar];
    //remove tab pages
    [self resetContentPages];
    [self loadContent];
    [self loadContentUI];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self performSelector:@selector(showRateRoutineIfNeeded) withObject:nil afterDelay:2.0];
}

- (void)showRateRoutineIfNeeded {
    if([Preference hasRated]) {
        return;
    }
    static BOOL hasShow = NO;
    if(hasShow) {
        return;
    }
    NSInteger launchTimes = [Preference getLaunchTimes];
    BOOL shouldShow = NO;
    NSInteger firstTime = 5;
    NSInteger secondTime = 50;
    NSInteger thirdTime = 100;
#if DEBUG
    firstTime = 5;
    secondTime = 8;
    thirdTime = 10;
#endif
    if(launchTimes == firstTime || launchTimes == secondTime || launchTimes == thirdTime) {
        shouldShow = YES;
    }
    if(shouldShow) {
        hasShow = YES;
        RateViewController *rateVC = [[RateViewController alloc] init];
        [self presentViewControllerAsModalWindow:rateVC];
    }
}

@end
