//
//  AppScrollView.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/12/13.
//  Copyright © 2018 lifebetter. All rights reserved.
//

@import CoreVideo;
#import "AppScrollView.h"

static NSString *const kTabTitle = @"title";
static NSString *const kTabPage = @"page";
static NSString *const kTabIcon = @"icon";
static NSString *const kTabPlugin = @"plugin";

@interface AppScrollView ()
{
    CVDisplayLinkRef displayLinkRef;
}
@property (strong) NSView *appView;
@property (nonatomic, strong) NSImageView *coverImageView;
@property (nonatomic, assign) BOOL bScrollEnabled;
@property (nonatomic, assign) BOOL bMouseIn;
@property (nonatomic, assign) BOOL bWindowActive;

@end

@implementation AppScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initValue];
        [self addContents];
        [self setupDisplayLink];
    }
    return self;
}

- (void)initValue {
    self.bScrollEnabled = YES;
    self.bMouseIn = NO;
    self.bWindowActive = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)addContents {
    NSView *appView = [[NSView alloc] initWithFrame:self.bounds];
    NSImageView *coverImageView = [[NSImageView alloc] initWithFrame:self.bounds];
    self.coverImageView = coverImageView;
    [self updateAppearanceUI];
    [self addSubview:appView];
    [self addSubview:coverImageView];
    self.appView = appView;
    NSView *contentView = self.appView;
    CGFloat itemSize = contentView.height;
    CGFloat padding = itemSize;
    CGFloat space = itemSize/2.0f;
    NSArray *appList = [self getAppList];
    CGFloat left = padding;
    for (NSInteger i=0; i<appList.count; i++) {
        NSDictionary *data = appList[i];
        BOOL isPlugin = [data[kTabPlugin] boolValue];
        NSImageView *imageView = [[NSImageView alloc] init];
        if(!isPlugin) {
            NSImage *image = [NSImage imageNamed:data[kTabIcon]];
            imageView.image = image;
        }else {
            NSString * iconPath = data[kTabIcon];
            imageView.image = [[NSImage alloc] initWithContentsOfFile:iconPath];
        }
        imageView.left = left;
        imageView.size = NSMakeSize(itemSize, itemSize);
        imageView.toolTip = data[kTabTitle];
        left += imageView.width;
        if(i != appList.count-1) {
            left += space;
        }
        imageView.layer.backgroundColor = [NSColor clearColor].CGColor;
        [contentView addSubview:imageView];
    }
    left += padding;
    self.appView.width = left;
    NSTrackingArea* trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:self.bounds
                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                    owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)updateAppearanceUI {
    if([Appearance isDark]) {
        self.coverImageView.image = [NSImage imageNamed:@"cover_waiting_dark"];
    }else {
        self.coverImageView.image = [NSImage imageNamed:@"cover_waiting"];
    }
}


- (NSArray *)getAppList
{
    NSArray *nativeList = @[
                         @{
                             kTabTitle : @"Sandbox",
                             kTabPage : @"SandboxViewController",
                             kTabIcon : @"tool_sandbox",
                             },
                         @{
                             kTabTitle : @"UserDefaults",
                             kTabPage : @"UserDefaultsViewController",
                             kTabIcon : @"tool_userdefaults",
                             },
                         @{
                             kTabTitle : @"State Master",
                             kTabPage : @"StateMasterIndexViewController",
                             kTabIcon : @"tool_statemaster",
                         },
                         @{
                             kTabTitle : @"Network",
                             kTabPage : @"NetworkViewController",
                             kTabIcon : @"tool_network",
                             },
                         @{
                             kTabTitle : @"View",
                             kTabPage : @"ViewDebugViewController",
                             kTabIcon : @"tool_view",
                             },
                         @{
                             kTabTitle : @"Bundle",
                             kTabPage : @"AppBundleViewController",
                             kTabIcon : @"tool_bundle",
                             },
                         @{
                             kTabTitle : @"Keychain",
                             kTabPage : @"KeyChainViewController",
                             kTabIcon : @"tool_keychain",
                             },
                         @{
                             kTabTitle : @"Device",
                             kTabPage : @"DeviceViewController",
                             kTabIcon : @"tool_device",
                             },
                         @{
                             kTabTitle : @"Notification",
                             kTabPage : @"NotificationViewController",
                             kTabIcon : @"tool_notification",
                             },
                         @{
                             kTabTitle : @"Localization",
                             kTabPage : @"LocalizationViewController",
                             kTabIcon : @"tool_localization",
                             },
                         @{
                             kTabTitle : @"Logger",
                             kTabPage : @"LogViewController",
                             kTabIcon : @"tool_io",
                             },
                         @{
                             kTabTitle : @"iCloud",
                             kTabPage : @"CloudViewController",
                             kTabIcon : @"tool_icloud",
                             },
                         ];
    NSArray *pluginTabs = [self getPluginItems];
    NSArray *pluginList = pluginTabs;
    NSMutableArray *tabList = [NSMutableArray array];
    [tabList addObjectsFromArray:nativeList];
    [tabList addObjectsFromArray:pluginList];
    tabList = tabList;
    return tabList;
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

- (NSArray *)getPluginItems
{
    NSString * pluginPath = [[EnvtService sharedService] pluginPath];
    NSArray* pluginList = [self getPluginList];
    NSMutableArray * pluginItems = [NSMutableArray array];
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
        NSMutableDictionary * pluginData = [NSMutableDictionary dictionary];
        pluginData[kTabTitle] = name;
        pluginData[kTabIcon] = iconFilePath;
        pluginData[kTabPage] = indexFilePath;
        pluginData[kTabPlugin] = [NSNumber numberWithBool:YES];
        [pluginItems addObject:pluginData];
    }
    return pluginItems;
}



- (void)setupDisplayLink {
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLinkRef);
    CVDisplayLinkSetOutputCallback(displayLinkRef, displayLinkOutputCallback, (__bridge void *)self);
    CVDisplayLinkStart(displayLinkRef);
}

CVReturn displayLinkOutputCallback(CVDisplayLinkRef displayLink,
                                   const CVTimeStamp *inNow,
                                   const CVTimeStamp *inOutputTime,
                                   CVOptionFlags flagsIn,
                                   CVOptionFlags *flagsOut,
                                   void *displayLinkContext)
{
    @autoreleasepool {
        AppScrollView *wself = (__bridge AppScrollView *)displayLinkContext;
        [wself animate];
    }
    return kCVReturnSuccess;
}


- (void)animate {
    static BOOL toLeft = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSView *scrollView = self.appView;
        CGFloat contentWidth = self.width;
        CGFloat speed = 6;
        CGFloat offset = 1.0/60.0f * speed;
        CGFloat minX = -(scrollView.width-contentWidth);
        CGFloat maxX = 0;
        if(toLeft) {
            CGFloat targetX = scrollView.left + (-offset);
            if(targetX > minX) {
                scrollView.left = targetX;
            }else {
                toLeft = NO;
                targetX = scrollView.left + offset;
                scrollView.left = targetX;
            }
        }else {
            CGFloat targetX = scrollView.left + offset;
            if(targetX < maxX) {
                scrollView.left = targetX;
            }else {
                toLeft = YES;
                targetX = scrollView.left + (-offset);
                scrollView.left = targetX;
            }
        }
        
    });
}

- (void)mouseEntered:(NSEvent *)event {
    self.bMouseIn = YES;
    [self updateScrollStateUI];

}

- (void)mouseExited:(NSEvent *)event {
    self.bMouseIn = NO;
    [self updateScrollStateUI];
}

- (void)setScrollEnabled: (BOOL)scroll {
    self.bScrollEnabled = scroll;
    [self updateScrollStateUI];
}

- (void)updateScrollStateUI {
    BOOL shouldScroll = NO;
    if(self.bScrollEnabled && !self.bMouseIn && self.bWindowActive) {
        shouldScroll = YES;
    }
    
    if(shouldScroll) {
        CVDisplayLinkStart(displayLinkRef);
    }else {
        CVDisplayLinkStop(displayLinkRef);
    }
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeActive) name:NSWindowDidBecomeKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeInActive) name:NSWindowDidResignKeyNotification object:self.window];
    
}

- (void)windowBecomeActive {
    self.bWindowActive = YES;
    [self updateScrollStateUI];
}

- (void)windowBecomeInActive {
    self.bWindowActive = NO;
    [self updateScrollStateUI];
}

@end
