//
//  HomeViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/4.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeInfoViewController.h"
#import "ScreenshotViewController.h"
#import "DeviceUtil.h"

@interface HomeViewController ()

@property (nonatomic, strong) IBOutlet NSView *contentView;
@property (nonatomic, strong) IBOutlet NSImageView *iconImageView;
@property (nonatomic, strong) IBOutlet NSTextField *nameLabel;
@property (nonatomic, strong) IBOutlet NSTextField *bundleLabel;
@property (nonatomic, strong) IBOutlet NSTextField *versionLabel;
@property (nonatomic, strong) IBOutlet NSTextField *frameversionLabel;


@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *screenshotLayout;
@property (weak) IBOutlet NSView *infoLayout;

@property (nonatomic, strong) IBOutlet NSView *lineView;

@property (nonatomic, strong) IBOutlet NSButton *snapshotButton;
@property (nonatomic, strong) IBOutlet NSButton *previewButton;
@property (nonatomic, strong) IBOutlet NSButton *refreshButton;

@property (nonatomic, strong) NSDictionary *appData;
@property (nonatomic, strong) NSData *iconData;
@property (nonatomic, strong) NSDictionary *infoData;

@property (nonatomic, strong) ScreenshotViewController * screenshotVC;
@property (nonatomic, strong) HomeInfoViewController *infoVC;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initValue];
    [self initUI];
    [self addNotification];
    [self loadDashboardData];
}

- (void)setupUI {
    self.view.wantsLayer = YES;
    NSView *contentView = self.contentView;
    contentView.wantsLayer = YES;
    contentView.layer.cornerRadius = 6.0f;
    contentView.layer.masksToBounds = NO;
    contentView.layer.shadowOffset = CGSizeMake(1, -1);
    contentView.layer.shadowRadius = 2.0f;
    contentView.layer.shadowOpacity = 1.0f;
    self.iconImageView.wantsLayer = YES;
    self.iconImageView.layer.cornerRadius = 6.0f;
    self.lineView.wantsLayer = YES;
    //split
    CGRect ssViewRect = self.screenshotLayout.frame;
    ssViewRect.size.width = [self screenshotPreferWidth];
    self.screenshotLayout.frame = ssViewRect;
    
    ScreenshotViewController * scVC = [[ScreenshotViewController alloc] init];
    scVC.context = self.context;
    NSView * scView = scVC.view;
    scView.frame = self.screenshotLayout.bounds;
    scView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.screenshotLayout addSubview:scView];
    self.screenshotVC = scVC;
    
    HomeInfoViewController *infoVC = [[HomeInfoViewController alloc] init];    infoVC.context = self.context;
    NSView * infoView = infoVC.view;
    infoView.frame = self.infoLayout.bounds;
    infoView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.infoLayout addSubview:infoView];
    self.infoVC = infoVC;
        
    [self updateAppearanceUI];
}

- (void)initValue {
    
}

- (void)initUI {
    self.nameLabel.stringValue = @"";
    self.bundleLabel.stringValue = @"";
    self.versionLabel.stringValue = @"";
    self.frameversionLabel.stringValue = @"";
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    NSView *contentView = self.contentView;
    if([Appearance isDark]) {
        self.view.layer.backgroundColor = [Appearance colorWithHex:0x323232].CGColor;
        contentView.layer.backgroundColor = [Appearance colorWithHex:0x202123].CGColor;
        contentView.layer.shadowColor = [Appearance colorWithHex:0x202123 alpha:0.5].CGColor;
        self.iconImageView.layer.backgroundColor = [Appearance colorWithHex:0x202123].CGColor;
        self.iconImageView.layer.shadowColor = [Appearance colorWithHex:0x202123 alpha:0.5].CGColor;
    }else {
        contentView.layer.backgroundColor = [Appearance colorWithHex:0xF2F2F2].CGColor;
        contentView.layer.shadowColor = [Appearance colorWithHex:0x9F9F9F alpha:0.5].CGColor;
        self.view.layer.backgroundColor = [Appearance colorWithHex:0xE6E6E6].CGColor;
    }
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    [self.snapshotButton setTintColor:[Appearance actionImageColor]];
    [self.previewButton setTintColor:[Appearance actionImageColor]];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    CGFloat viewWidth = self.view.width;
    CGFloat maxWidth = 1200.0f;
    CGFloat padding = 160.0f;
    CGFloat contentWidth = viewWidth - padding*2;
    contentWidth = MIN(maxWidth, contentWidth);
    self.contentView.width = contentWidth;
    self.contentView.left = (viewWidth - self.contentView.width)/2.0f;
}

- (void)loadDashboardData {
    [self.view showHud];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.appinfo" action:@"dashboard" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.view hideHud];
        wself.appData = body;
        wself.iconData = payload;
        [wself updateAppUI];
    } onFailed:^(NSError *error) {
        [wself showError];
    }];
}

- (void)updateAppUI {
    if(self.iconData) {
        NSImage * image = [[NSImage alloc] initWithData:self.iconData];
        self.iconImageView.image = image;
    }
    NSDictionary *data = self.appData;
    if(data[@"appName"]) {
        self.nameLabel.stringValue = adhvf_safestringfy(data[@"appName"]);
        self.bundleLabel.stringValue = adhvf_safestringfy(data[@"bundleId"]);
        self.versionLabel.stringValue = [NSString stringWithFormat:@"%@ (%@)",data[@"version"],data[@"build"]];
    }
    ADHApp *app = self.context.app;
    if(app.frameworkVersion) {
        NSString *version = app.frameworkVersion;
        self.frameversionLabel.stringValue = version;
        NSString *requiredKey = @"WoodpeckeriOS";
        if(self.context.app.isMacOS) {
            requiredKey = @"WoodpeckerMacOS";
        }
        NSString * requiredVersion = [[EnvtService service] configWithKey:requiredKey];
        NSString * requiredVersionText = [requiredVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSInteger requiredValue = [requiredVersionText integerValue];
        //当前版本
        NSString * versionText = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSInteger currentValue = [versionText integerValue];
        if(requiredValue > currentValue) {
            self.frameversionLabel.stringValue = [NSString stringWithFormat:@"Framework: %@\n Required: %@",version,requiredVersion];
            self.frameversionLabel.textColor = [NSColor secondaryLabelColor];
        }else {
            self.frameversionLabel.stringValue = [NSString stringWithFormat:@"Framework: %@",version];
            self.frameversionLabel.textColor = [NSColor tertiaryLabelColor];
        }
    }else {
        self.frameversionLabel.stringValue = @"";
    }
}

- (void)onWorkAppUpdate {
    if(!self.appData) {
        [self loadDashboardData];
    }
}

- (CGFloat)screenshotPreferWidth {
    CGFloat width = 320.0f;
    return width;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
    //如果splitview大小发生变化，计算子视图位置
    CGFloat splitWidth = splitView.bounds.size.width;
    CGFloat splitHeight = splitView.bounds.size.height;
    
    CGFloat dividerThickness = splitView.dividerThickness;
    CGFloat ssWidth = self.screenshotLayout.bounds.size.width;
    self.screenshotLayout.frame = CGRectMake(0, 0, ssWidth, splitHeight);
    
    CGFloat infoWidth = splitWidth - dividerThickness - ssWidth;
    self.infoLayout.frame = CGRectMake(ssWidth+dividerThickness, 0, infoWidth, splitHeight);
}




@end
