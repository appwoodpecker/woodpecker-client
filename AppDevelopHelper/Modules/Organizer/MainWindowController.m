//
//  MainWindowController.m
//  WhatsInApp
//
//  Created by 张小刚 on 2017/4/30.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "MainWindowController.h"
#import "MacOrganizer.h"
#import "EnvtService.h"
#import "Preference.h"
#import "LocalInfoViewController.h"
#import "NotificationViewController.h"
#import "HelpViewController.h"
#import "PresentAnimator.h"
#import "ConnectionViewController.h"
#import "UserDefaultsViewController.h"
#import "DeviceViewController.h"
#import "UpdateInfoViewController.h"
#import "UpdateHistory.h"
#import "LocalizationViewController.h"
#import "KeyChainViewController.h"
#import "IndexTestViewController.h"
#import "ToolsViewController.h"
#import "AppViewController.h"
#import "AppContextManager.h"
#import "AppScrollView.h"
#import "TestWindowController.h"
#import "WelcomeViewController.h"
#import "DeviceUtil.h"
#import "ApiViewController.h"


static NSInteger const kProMenuTag = 100;
static NSInteger const kToolMenuTag = 101;


@interface MainWindowController ()<NSToolbarDelegate,AppContextManagerObserver>

@property (weak) IBOutlet NSView *lineView;
@property (weak) IBOutlet NSView *waitingLayout;
@property (weak) IBOutlet NSView *waitingContentView;
@property (nonatomic, strong) AppScrollView *appView;
@property (weak) IBOutlet NSTextField *versionLabel;
@property (weak) IBOutlet NSImageView *premiumIcon;
@property (weak) IBOutlet NSButton *premiumButton;

@property (nonatomic, strong) NSView *welcomeView;
@property (nonatomic, strong) WelcomeViewController *welcomeVC;

@property (nonatomic, strong) NSView * updateView;
@property (nonatomic, strong) UpdateInfoViewController *updateVC;
@property (nonatomic, strong) ApiViewController *apiVC;

@end

@implementation MainWindowController

- (void)windowWillLoad {
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self resetDebugEnv];
    [self setupWorkPath];
    [self setupAfterXib];
    [self initialValues];
    [self initUI];
    [self doBetaRoutine];
    [self startConnect];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)resetDebugEnv
{
#if DEBUG
//    [Preference clearTools];
//    [Preference setWelcomePageShowd:NO];
//    [Preference setLatestVersion:@""];
#endif
}

- (void)initialValues
{
    
}

- (void)setupAfterXib
{
    [self setupMenu];
    [self registerNotifications];
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.minSize = NSMakeSize(800, 600);
    AppViewController *appVC = [[AppViewController alloc] init];
    appVC.layoutAttribute = NSLayoutAttributeLeft;
    [self.window addTitlebarAccessoryViewController:appVC];
    NSTabViewController * tabVC = [[NSTabViewController alloc] init];
    tabVC.tabStyle = NSTabViewControllerTabStyleUnspecified;
    self.tabVC = tabVC;
    NSView *contentView = self.window.contentView;
    tabVC.view.frame = contentView.bounds;
    tabVC.view.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    [contentView addSubview:tabVC.view];
    self.lineView.wantsLayer = YES;
    self.waitingLayout.wantsLayer = YES;
    //fix10.12黑色背景
    tabVC.view.wantsLayer = YES;
    [self setupWaitingUI];
    [self updateAppearanceUI];
    [self doWelcomeRoutine];
}

//有应用连接后，设置窗口最大（只设置一次）
- (void)setWorkingWindowFrame {
    NSWindow * window = self.window;
    NSPoint screenOrigin = window.screen.frame.origin;
    CGSize screenSize = window.screen.frame.size;
    CGFloat left = 0 + screenOrigin.x;
    CGFloat top = 0 + screenOrigin.y;
    CGFloat width = screenSize.width;
    CGFloat height = screenSize.height;
    NSRect windowRect = NSMakeRect(left, top, width, height);
    [window setFrame:windowRect display:YES animate:YES];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkEnvtSetupFinish:) name:kEnvtServiceWorkEnvtSetupFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAuthStateUpdate) name:kStoreServiceAuthStateUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidLayout) name:NSWindowDidResizeNotification object:self.window];
}

- (void)setupMenu
{
    NSMenu * mainMenu = self.window.menu;
    NSMenuItem * pluginItem = [mainMenu itemWithTitle:@"Plugin"];
    NSMenu * pluginMenu = pluginItem.submenu;
    //plugin home
    NSMenuItem * homeItem = [pluginMenu itemAtIndex:0];
    homeItem.target = self;
    homeItem.action = @selector(pluginHomeMenuSelected:);
    //plugin list
    NSMenuItem * pluginlistItem = [pluginMenu itemAtIndex:1];
    pluginlistItem.target = self;
    pluginlistItem.action = @selector(pluginListMenuSelected:);
    //plugin create
    NSMenuItem * pluginCreateItem = [pluginMenu itemAtIndex:2];
    pluginCreateItem.target = self;
    pluginCreateItem.action = @selector(pluginCreateMenuSelected:);
    //plugin debug
    NSMenuItem * pluginDebugItem = [pluginMenu itemAtIndex:3];
    pluginDebugItem.target = self;
    pluginDebugItem.action = @selector(pluginDebugMenuSelected:);
    //plugin reload
    NSMenuItem * reloadItem = [pluginMenu itemAtIndex:4];
    reloadItem.target = self;
    reloadItem.action = @selector(pluginReloadMenuSelected:);
    
    //Help Menu
    NSMenuItem * helpItem = [mainMenu itemWithTitle:@"Help"];
    NSMenu * helpMenu = helpItem.submenu;
    
    //help
    NSMenuItem * helpSubItem = [helpMenu itemAtIndex:0];
    helpSubItem.target = self;
    helpSubItem.action = @selector(helpMenuSelected:);
    ///framework
    NSMenuItem * frameSubItem = [helpMenu itemAtIndex:1];
    NSMenu * frameMenu = frameSubItem.submenu;
    NSArray *frameItems = frameMenu.itemArray;
    //pod
    NSMenuItem * podSubItem = frameItems[0];
    podSubItem.target = self;
    podSubItem.action = @selector(podMenuSelected:);
    //carthage
    NSMenuItem * carthageSubItem = frameItems[1];
    carthageSubItem.target = self;
    carthageSubItem.action = @selector(carthageMenuSelected:);
    //download
    NSMenuItem * downloadSubItem = frameItems[2];
    downloadSubItem.target = self;
    downloadSubItem.action = @selector(downloadMenuSelected:);
    
    //Local IP
    NSMenuItem * ipSubItem = [helpMenu itemAtIndex:2];
    ipSubItem.target = self;
    ipSubItem.action = @selector(localIPMenuSelected:);
    //rate
    NSMenuItem * rateSubItem = [helpMenu itemAtIndex:3];
    rateSubItem.target = self;
    rateSubItem.action = @selector(rateMenuSelected:);
    //feedback
    NSMenuItem * feedbackItem = [helpMenu itemAtIndex:4];
    feedbackItem.target = self;
    feedbackItem.action = @selector(feedbackMenuSelected:);
    
    //cmd
    /*
    NSMenuItem *cmdItem = [helpMenu itemWithTag:kToolMenuTag];
    cmdItem.target = self;
    cmdItem.action = @selector(cmdMenuSelected:);
    */
    
    //pro
    [self updateProMenuUI];
}

- (void)initUI {
    [self updateConnectionStatusUI];
    [self updatePremiumUI];
}

- (void)updatePremiumUI {
    NSDictionary *infoData = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoData[@"CFBundleShortVersionString"];
    if(isPro) {
        self.premiumButton.hidden = YES;
        self.premiumIcon.hidden = YES;
        self.versionLabel.stringValue = [NSString stringWithFormat:@"Pro %@",version];
    }else {
        self.premiumButton.hidden = NO;
        self.premiumIcon.hidden = NO;
        self.versionLabel.stringValue = [NSString stringWithFormat:@"v%@",version];
    }
    NSSize textSize = [self.versionLabel sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
    self.versionLabel.width = textSize.width;
    self.versionLabel.right = self.versionLabel.superview.width - 13.0f;
    self.premiumIcon.right = self.versionLabel.left;
}

- (void)setupWorkPath
{
    [[EnvtService service] setupWorkEnvt];
}

#pragma mark -----------------   apps   ----------------

- (void)startConnect {
    [[AppContextManager sharedManager] addObsever:self];
    [[MacOrganizer organizer] start];
}

//new app
- (void)appDidAdd: (AppContext *)context {
    ToolsViewController *page = [[ToolsViewController alloc] init];
    page.context = context;
    [self.tabVC addChildViewController:page];
    [self updateConnectionStatusUI];
    
    static BOOL bSetuped = NO;
    if(!bSetuped) {
        bSetuped = YES;
        [self setWorkingWindowFrame];
        if(![Preference welcomePageShowed]) {
            [Preference setWelcomePageShowd:YES];
        }
    }
}

//remove page
- (void)appWillRemove: (AppContext *)context {
    NSArray *pages = self.tabVC.childViewControllers;
    NSInteger targetIndex = NSNotFound;
    ToolsViewController *targetPage = nil;
    for (NSInteger i =0;i<pages.count;i++) {
        ToolsViewController *page = pages[i];
        if(page.context == context) {
            targetPage = page;
            targetIndex = i;
            break;
        }
    }
    if(targetIndex != NSNotFound) {
        [self.tabVC removeChildViewControllerAtIndex:targetIndex];
    }
    [self updateConnectionStatusUI];
}

//work app update
- (void)topContextUpdate: (AppContext *)context {
    NSArray *pages = self.tabVC.childViewControllers;
    NSInteger targetIndex = NSNotFound;
    ToolsViewController *targetPage = nil;
    for (NSInteger i =0;i<pages.count;i++) {
        ToolsViewController *page = pages[i];
        if(page.context == context) {
            targetPage = page;
            targetIndex = i;
            break;
        }
    }
    if(targetIndex != NSNotFound) {
        [self.tabVC setSelectedTabViewItemIndex:targetIndex];
    }
}

- (void)updateConnectionStatusUI {
    NSInteger count = [AppContextManager sharedManager].visibleContextList.count;
    if(count == 0) {
        self.tabVC.view.hidden = YES;
        self.waitingLayout.hidden = NO;
        [self.appView setScrollEnabled:YES];
    }else {
        self.tabVC.view.hidden = NO;
        self.waitingLayout.hidden = YES;
        [self.appView setScrollEnabled:NO];
    }
}

- (void)windowDidLayout {
    self.waitingContentView.left = (self.waitingLayout.width - self.waitingContentView.width)/2.0f;
    self.waitingContentView.top = (self.waitingLayout.height - self.waitingContentView.height)/2.0f;
    if(self.welcomeView) {
        self.welcomeView.top = (self.waitingLayout.height - self.welcomeView.height)/2.0f;
        self.welcomeView.left = (self.waitingLayout.width - self.welcomeView.width)/2.0f;
    }
    if(self.updateView) {
        self.updateView.top = (self.waitingLayout.height - self.updateView.height)/2.0f;
        self.updateView.left = (self.waitingLayout.width - self.updateView.width)/2.0f;
    }
}

- (void)updateAppearanceUI {
    self.tabVC.view.layer.backgroundColor = [Appearance backgroundColor].CGColor;
    if([Appearance isDark]) {
        self.waitingLayout.layer.backgroundColor = [Appearance colorWithHex:0x202123].CGColor;
        self.lineView.layer.backgroundColor = [Appearance colorWithHex:0xEEEEEE alpha:0.05].CGColor;
    }else {
        self.waitingLayout.layer.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"connection_repeat"]].CGColor;
        self.lineView.layer.backgroundColor = [Appearance colorWithHex:0xDFDFDF].CGColor;
    }
}

#pragma mark -----------------   tool bar   ----------------

- (void)pluginHomeMenuSelected: (NSMenuItem *)menu {
    NSString * pluginPath = [[EnvtService service] pluginPath];
    [[NSWorkspace sharedWorkspace] openFile:pluginPath];
}

- (void)pluginListMenuSelected: (NSMenuItem *)menu {
    NSString * path = NSLocalizedString(@"web_pluginlist", nil);
    NSString * link = [UrlUtil filteredUrl:path];
    NSURL * requestURL = [NSURL URLWithString:link];
    [[NSWorkspace sharedWorkspace] openURL:requestURL];
}

- (void)pluginDebugMenuSelected: (NSMenuItem *)menu {
    ToolsViewController *pageVC = nil;
    AppContext *context = nil;
    NSInteger tabIndex = self.tabVC.selectedTabViewItemIndex;
    if(tabIndex != NSNotFound) {
        NSArray *pages = self.tabVC.childViewControllers;
        if(tabIndex < pages.count) {
            pageVC = [pages objectAtIndex:tabIndex];
        }
    }
    if(pageVC) {
        context = pageVC.context;
    }
    if(pageVC && context.isConnected) {
        ApiViewController *vc = [[ApiViewController alloc] initWithNibName:@"ApiViewController" bundle:nil];
        vc.context = context;
        NSView *view = vc.view;
        NSWindow * window = self.window;
        CGSize screenSize = window.screen.frame.size;
        CGSize viewSize = [Appearance getModalWindowSize:screenSize];
        view.size = viewSize;
        [pageVC presentViewControllerAsModalWindow:vc];
        self.apiVC = vc;
    }else {
        [self.window.contentView showToastWithIcon:@"icon_notconnected" statusText:@"Not Connected"];
    }
}

- (void)pluginCreateMenuSelected: (NSMenuItem *)menu {
    NSString * path = NSLocalizedString(@"web_plugin", nil);
    NSString * link = [UrlUtil filteredUrl:path];
    NSURL * requestURL = [NSURL URLWithString:link];
    [[NSWorkspace sharedWorkspace] openURL:requestURL];
}

- (void)pluginReloadMenuSelected: (NSMenuItem *)menu {
    NSArray *pages = self.tabVC.childViewControllers;
    for (ToolsViewController *page in pages) {
        [page reloadTools];
    }
}

- (void)pluginTestMenuSelected: (NSMenuItem *)menu {
    [Preference saveToolItem:@[]];
}

- (void)helpMenuSelected: (NSMenuItem *)menu { 
    NSString *link = [UrlUtil filteredUrl:NSLocalizedString(@"web_usage", nil)];
    NSURL * requestURL = [NSURL URLWithString:link];
    [[NSWorkspace sharedWorkspace] openURL:requestURL];
}

- (void)localIPMenuSelected: (NSMenuItem *)menu {
    LocalInfoViewController * infoVC = [[LocalInfoViewController alloc] init];
    [self.tabVC presentViewControllerAsModalWindow:infoVC];
}

- (void)rateMenuSelected: (NSMenuItem *)menu {
    NSString *url = @"macappstore://itunes.apple.com/app/id1333548463?action=write-review";
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:url]];
}

- (void)feedbackMenuSelected: (NSMenuItem *)menu {
    NSString *url = @"mailto:woodpeckerapp@163.com";
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:url]];
}

- (void)podMenuSelected: (NSMenuItem *)menuItem {
    NSString *pod = kPodText;
    [DeviceUtil pasteText:pod];
    [self.window.contentView showToastWithIcon:@"icon_status_ok" statusText:kLocalized(@"common_text_copied")];
}

- (void)carthageMenuSelected: (NSMenuItem *)menuItem {
    NSString *carthage = kCarthageText;
    [DeviceUtil pasteText:carthage];
    [self.window.contentView showToastWithIcon:@"icon_status_ok" statusText:kLocalized(@"common_text_copied")];
}

- (void)downloadMenuSelected: (NSMenuItem *)menuItem {
    [UrlUtil openExternalLocalizedUrl:@"web_usage"];
}

- (void)cmdMenuSelected:(NSMenuItem *)menuItem {
    NSString *path = [[[NSBundle mainBundle] sharedSupportPath] stringByAppendingPathComponent:@"install.sh"];
    NSString *cmd = [NSString stringWithFormat:@"sh %@",path];
    [DeviceUtil pasteText:cmd];
    [self.window.contentView showToastWithIcon:@"icon_status_ok" statusText:@"Script copied, Please run in the terminal"];
}

/**
 EnvtService 设置工作环境需要时间较长，设置完成后再次更新插件列表
 */
- (void)onWorkEnvtSetupFinish: (NSNotification *)noti
{
    NSDictionary * userInfo = noti.userInfo;
    BOOL pluginUpdate = [userInfo[kEnvtServiceWorkEnvtSetupUserInfoPlugin] boolValue];
    if(pluginUpdate){
        
    }
}

- (void)onAuthStateUpdate {
    [self updateProMenuUI];
    [self updatePremiumUI];
}

- (void)updateProMenuUI {
    NSMenu * mainMenu = self.window.menu;
    //Help Menu
    NSMenuItem * helpItem = [mainMenu itemWithTitle:@"Help"];
    NSMenu * helpMenu = helpItem.submenu;
    //remove old
    {
        NSMenuItem *proItem = [helpMenu itemWithTag:kProMenuTag];
        if(proItem) {
            [helpMenu removeItem:proItem];
        }
    }
    if(!isPro) {
        NSMenuItem *proItem = [[NSMenuItem alloc] initWithTitle:@"Go Pro 👑" action:@selector(goPro) keyEquivalent:@""];
        proItem.tag = kProMenuTag;
        [helpMenu addItem:proItem];
    }
}

- (void)goPro {
    doProCheckRoutine();
}

- (void)doBetaRoutine {
#if BETA
    NSDate *startDate = [Preference betaStartDate];
    if(!startDate) {
        startDate = [NSDate date];
        [Preference setBetaStartDate:startDate];
    }else {
        NSTimeInterval interval = -[startDate timeIntervalSinceNow];
        NSTimeInterval betaLife = [Preference betaLifeInterval];
        NSTimeInterval life = betaLife - interval;
        if(life < 0) {
            exit(0);
        }
    }
#endif
}

- (void)setupWaitingUI {
    AppScrollView *appView = [[AppScrollView alloc] initWithFrame:self.waitingContentView.bounds];
//    appView.wantsLayer = YES;
//    appView.layer.backgroundColor = [NSColor greenColor].CGColor;
    [self.waitingContentView addSubview:appView];
    self.appView = appView;
}

- (void)doWelcomeRoutine
{
    BOOL shouldShow = ![Preference welcomePageShowed];
    if(shouldShow){
        NSView *contentView = self.waitingLayout;
        WelcomeViewController *vc = [[WelcomeViewController alloc] init];
        NSView *view = vc.view;
        view.top = (contentView.height - view.height)/2.0f;
        view.left = (contentView.width - view.width)/2.0f;
        [contentView addSubview:view];
        self.welcomeView = view;
        self.welcomeVC = vc;
        //标记版本
        [Preference setLatestVersion:[DeviceUtil appVersion]];
    }else {
         if([[UpdateHistory shared] shouldShowUpdate]) {
             NSView *contentView = self.waitingLayout;
             UpdateInfoViewController * updateVC = [[UpdateInfoViewController alloc] init];
             NSView *view = updateVC.view;
             view.top = (contentView.height - view.height)/2.0f;
             view.left = (contentView.width - view.width)/2.0f;
             [contentView addSubview:view];
             
             self.updateView = view;
             self.updateVC = updateVC;
         }
    }
}

- (IBAction)premiumButtonPressed:(id)sender {
    [self goPro];
}

- (IBAction)waitingViewClickGestureRecognized:(id)sender {
    NSString *link = [UrlUtil filteredUrl:NSLocalizedString(@"web_usage", nil)];
    NSURL * requestURL = [NSURL URLWithString:link];
    [[NSWorkspace sharedWorkspace] openURL:requestURL];
}


@end
