//
//  PayViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2022/4/16.
//  Copyright © 2022 lifebetter. All rights reserved.
//

#import "PayViewController.h"
#import "PayService.h"

@interface PayViewController ()

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSView *bottomView;

@property (weak) IBOutlet NSTextField *yearLabel;
@property (weak) IBOutlet NSTextField *foreverLabel;
@property (weak) IBOutlet NSTextField *yearTipLabel;
@property (weak) IBOutlet NSTextField *foreverTipLabel;

@property (weak) IBOutlet NSButton *restoreButton;
@property (weak) IBOutlet NSButton *privacyButton;
@property (weak) IBOutlet NSButton *termsOfUseButton;

@property (nonatomic, assign) BOOL viewAppeared;


@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValue];
}

- (void)initValue {
    
}

- (void)setupAfterXib {
    BOOL isChinese = [LocalizationUtil isChinese];
    if ([Appearance isDark]) {
        self.scrollView.backgroundColor = [Appearance backgroundColor];
    } else {
        self.scrollView.backgroundColor = [Appearance colorWithHex:0xF3F3F3];
    }
    NSColor *layoutColor = nil;
    if([Appearance isDark]) {
        layoutColor = [Appearance colorWithHex:0x202123];
    }else {
        layoutColor = [NSColor whiteColor];
    }
    NSView *contentView = self.scrollView.contentView.documentView;
    CGFloat width = self.view.width;
    CGFloat padding = 54.0f;
    CGFloat contentWidth = width - padding * 2;
    CGFloat cornerRadius = 16.0f;
    NSColor *shadowColor = [Appearance colorWithHex:0x000000 alpha:0.06];
    CGSize shadowOffset = CGSizeMake(0, -2);
    //title
    NSTextField *titleLabel = [UIUtil label];
    titleLabel.font = [NSFont systemFontOfSize:35 weight:NSFontWeightHeavy];
    titleLabel.stringValue = kLocalized(@"pro_thanks");
    [titleLabel sizeToFit];
    titleLabel.left = (contentView.width - titleLabel.width)/2.0f;
    titleLabel.top = 32.0;
    [contentView addSubview:titleLabel];
    ///author
    ADHFlipView *authorLayout = [[ADHFlipView alloc] init];
    authorLayout.width = contentWidth;
    authorLayout.height = 100;
    authorLayout.wantsLayer = YES;
    authorLayout.layer.cornerRadius = cornerRadius;
    authorLayout.layer.backgroundColor = [Appearance colorWithHex:0x228652].CGColor;
    authorLayout.top = titleLabel.bottom + 32.0f;
    authorLayout.left = padding;
    [contentView addSubview:authorLayout];
    //author text
    CGFloat authoPaddingLeft = 36.0f;
    CGFloat authoPaddingRight = 110.0f;
    NSTextField *authorLabel = [UIUtil label];
    authorLabel.textColor = [Appearance colorWithHex:0xFFFFFF];
    NSString *text = @">>>  嗨，开发者你好！\n\nWoodpecker已经3岁了，经过数十个更新迭代目前已经有13个高效工具，得到了众多iOS开发者的喜爱，为了保证持续高质量升级迭代，现在推出高级版本，专属的效率工具可以节省您宝贵的时间，协助您产出更高质量的产品，提升日常开发幸福感，值得拥有！\n\n免费用户可以继续使用基础功能，我们将继续推出高质量效率工具，也随时欢迎您的宝贵建议";
    if (!isChinese) {
        text = @">>> Hi developers!\n\nWoodpecker is 3 years old. After dozens of upgrade, there are currently 13 efficient tools, which are loved by many iOS developers. In order to ensure continuous high-quality upgrade, an advanced version is now available. The exclusive efficiency tools can save your precious time, help you to produce higher quality apps, improve the happiness of daily development.\n\nFree users can still continue to use the basic features, your suggestions are also very important about the future of this app.";
    }
    NSAttributedString *authorText = [UIUtil attributeStringWithText:text font:[NSFont systemFontOfSize:15.0] lineSpacing:4.0];
    authorLabel.attributedStringValue = authorText;
    authorLabel.maximumNumberOfLines = 0;
    CGFloat authorTextWidth = contentWidth - authoPaddingLeft - authoPaddingRight;
    authorLabel.size = [authorLabel sizeThatFits:NSMakeSize(authorTextWidth, CGFLOAT_MAX)];
    authorLabel.top = 36.0f;
    authorLabel.left = authoPaddingLeft;
    [authorLayout addSubview:authorLabel];
    authorLayout.height = authorLabel.bottom + 40.0;
    //author icon
    NSImageView *authorIcon = [[NSImageView alloc] init];
    authorIcon.width = 56.0f;
    authorIcon.height = 56.0f;
    authorIcon.image = [NSImage imageNamed:@"AppIcon"];
    authorIcon.imageAlignment = NSImageAlignCenter;
    authorIcon.imageScaling = NSImageScaleProportionallyDown;
    authorIcon.top = 24.0f;
    authorIcon.right = authorLayout.width - 32.0f;
    [authorLayout addSubview:authorIcon];
    ///feature
    NSArray *featureList = nil;
    if (isChinese) {
        featureList = @[
            @"1. 编辑、上传沙盒文件",
            @"2. 编辑UserDefaults内容",
            @"3. 导出应用Localization文本项到Excel表格",
            @"4. 编辑应用iCloud内容",
            @"5. 无限制使用State Master快速存储和恢复应用数据",
            @"6. 更多专属功能陆续增加中...",
        ];
    } else {
        featureList = @[
            @"1. Edit, upload sandbox files",
            @"2. Edit UserDefault items",
            @"3. Export localization strings to excel ",
            @"4. Edit your app's iCloud contents",
            @"5. Save and restore app's data quickly using State Master",
            @"6. More features will coming soon...",
        ];
    }
    NSTextField *featureLabel = [UIUtil label];
    featureLabel.font = [NSFont systemFontOfSize:16.0f];
    featureLabel.textColor = [NSColor placeholderTextColor];
    featureLabel.stringValue = kLocalized(@"pro_feature_title");
    [featureLabel sizeToFit];
    featureLabel.left = padding + 4.0f;
    featureLabel.top = authorLayout.bottom + 40;
    [contentView addSubview:featureLabel];
    //feature layout
    NSView *featureLayout = [[ADHFlipView alloc] init];
    featureLayout.width = contentWidth;
    featureLayout.wantsLayer = YES;
    featureLayout.layer.cornerRadius = cornerRadius;
    featureLayout.layer.backgroundColor = layoutColor.CGColor;
    featureLayout.top = featureLabel.bottom + 20.0;
    featureLayout.left = padding;
    [featureLayout setShadowWithColor:shadowColor offset:shadowOffset radius:0];
    [contentView addSubview:featureLayout];
    CGFloat featureItemHeight = 32.0f;
    CGFloat featureItemBaseTop = 40.0f;
    featureLayout.height = featureItemBaseTop*2-12.0 + featureList.count*featureItemHeight;
    //feature rocket
    NSImageView *rocketIcon = [UIUtil iconNamed:@"icon_pay_rocket"];
    rocketIcon.size = CGSizeMake(60.0f, 60.0f);
    rocketIcon.right = featureLayout.width - 40.0f;
    rocketIcon.bottom = featureLayout.height - 40.0f;
    if ([Appearance isDark]) {
        rocketIcon.alphaValue = 0.16;
    }
    [featureLayout addSubview:rocketIcon];
    for (NSInteger i=0; i<featureList.count; i++) {
        NSString *text = featureList[i];
        NSImageView *checkIcon = [UIUtil iconNamed:@"icon_pay_check"];
        checkIcon.size = CGSizeMake(16.0, 16.0f);
        checkIcon.left = 36.0f;
        checkIcon.top = featureItemBaseTop + featureItemHeight * i;
        [featureLayout addSubview:checkIcon];
        NSTextField *itemLabel = [UIUtil label];
        itemLabel.font = [NSFont systemFontOfSize:15.0f];
        if ([Appearance isDark]) {
            itemLabel.textColor = [NSColor secondaryLabelColor];
        } else {
            itemLabel.textColor = [Appearance colorWithHex:0x4C4646];
        }
        itemLabel.stringValue = text;
        [itemLabel sizeToFit];
        itemLabel.left = 64.0f;
        itemLabel.top = (checkIcon.height - itemLabel.height)/2.0f + checkIcon.top;
        [featureLayout addSubview:itemLabel];
    }
    ///review
    NSTextField *reviewLabel = [UIUtil label];
    reviewLabel.font = [NSFont systemFontOfSize:16.0f];
    reviewLabel.textColor = [NSColor placeholderTextColor];
    reviewLabel.stringValue = kLocalized(@"pro_rate_title");
    [reviewLabel sizeToFit];
    reviewLabel.left = padding + 4.0f;
    reviewLabel.top = featureLayout.bottom + 40;
    [contentView addSubview:reviewLabel];
    //review items
    NSArray *reviewList = nil;
    if (isChinese) {
        reviewList = @[
            @{
                @"title" : @"神器一枚！墙裂推荐！",
                @"content" : @"绝对的生产力工具。因为新的App对内容管理比较复杂，调试的时候有可视化的sandbox和userDefaults真的省事好多！不多说，绝对推荐！",
                @"author" : @"25码的笨笨"
            },
            @{
                @"title" : @"真的太好用了！",
                @"content" : @"一直在寻找这样一个软件，不用越狱设备连接查看我的文件，竟然在这找到了，另外，sqlite文件直接查看和编辑让人惊喜！",
                @"author" : @"melochale"
            },
            @{
                @"title" : @"真的非常好用",
                @"content" : @"在喵神的微博上看到的，真的是非常好用的一款调试工具，十分感谢开发者。",
                @"author" : @"兔子米有斯基"
            },
            @{
                @"title" : @"Amazing!!!",
                @"content" : @"Our entire team was blown away by Woodpecker feature set! This is a absolutely must-have quality of life changing tool for every iOS developer!",
                @"author" : @"Serzhas"
            },
        ];
    } else {
        reviewList = @[
            @{
                @"title" : @"Super useful for debugging on physical devices",
                @"content" : @"I'm so happy I stumbled across this tool. As an iOS developer, I can tell that this was built by another iOS developer who has run into so many of the same problems I run into every day. It gives you the kind of access to your app's data that you might be used to on the simulator, but has always been locked away when trying to debug on physical devices. I've just been using the sandbox, user defaults, and logger tools so far, and it would be worth the Pro price just for that, easily!",
                @"author" : @"Oshu"
            },
            @{
                @"title" : @"Amazing!!!",
                @"content" : @"Our entire team was blown away by Woodpecker feature set! This is a absolutely must-have quality of life changing tool for every iOS developer!",
                @"author" : @"Serzhas"
            },
            @{
                @"title" : @"Awesome",
                @"content" : @"Really a great app. Keep adding more features to debug the app development.",
                @"author" : @"iLikeApps2000"
            },
        ];
    }
    NSScrollView *reviewScrollView = [[NSScrollView alloc] init];
    reviewScrollView.drawsBackground = NO;
    reviewScrollView.contentView.documentView = [[ADHFlipView alloc] init];
    reviewScrollView.width = contentWidth;
    reviewScrollView.height = 240.0;
    if (!isChinese) {
        reviewScrollView.height = 400.0;
    }
    reviewScrollView.left = padding;
    reviewScrollView.top = reviewLabel.bottom + 20.0;
    reviewScrollView.verticalScrollElasticity = NO;
    [contentView addSubview:reviewScrollView];
    CGFloat reviewItemWidth = 300.0f;
    if (!isChinese) {
        reviewItemWidth = 360.0f;
    }
    CGFloat reviewItemHeight = reviewScrollView.height;
    CGFloat reviewItemSpacing = 20.0f;
    CGFloat reviewPadding = 24.0f;
    for (NSInteger i=0; i<reviewList.count; i++) {
        NSDictionary *data = reviewList[i];
        NSView *view = [[ADHFlipView alloc] init];
        view.width = reviewItemWidth;
        view.height = reviewItemHeight;
        view.wantsLayer = YES;
        view.layer.backgroundColor = layoutColor.CGColor;
        view.layer.cornerRadius = cornerRadius;
        [view setShadowWithColor:shadowColor offset:shadowOffset radius:0];
        view.left = (reviewItemWidth + reviewItemSpacing) * i;
        [reviewScrollView.contentView.documentView addSubview:view];
        NSTextField *titleLabel = [UIUtil label];
        titleLabel.maximumNumberOfLines = 0;
        titleLabel.font = [NSFont systemFontOfSize:15.0 weight:NSFontWeightBold];
        if ([Appearance isDark]) {
            titleLabel.textColor = [NSColor labelColor];
        } else {
            titleLabel.textColor = [Appearance colorWithHex:0x333333];
        }
        titleLabel.stringValue = data[@"title"];
        CGFloat contentWidth = view.width - reviewPadding * 2;
        titleLabel.size = [titleLabel sizeThatFits:NSMakeSize(contentWidth, CGFLOAT_MAX)];
        titleLabel.top = reviewPadding;
        titleLabel.left = reviewPadding;
        [view addSubview:titleLabel];
        //content
        NSTextField *contentLabel = [UIUtil label];
        contentLabel.maximumNumberOfLines = 0;
        if ([Appearance isDark]) {
            contentLabel.textColor = [NSColor secondaryLabelColor];
        } else {
            contentLabel.textColor = [Appearance colorWithHex:0x666666];
        }
        NSAttributedString *contentText = [UIUtil attributeStringWithText:data[@"content"] font:[NSFont systemFontOfSize:15.0] lineSpacing:4.0];
        contentLabel.attributedStringValue = contentText;
        contentLabel.size = [contentLabel sizeThatFits:NSMakeSize(contentWidth, CGFLOAT_MAX)];
        contentLabel.top = titleLabel.bottom + 16.0;
        contentLabel.left = reviewPadding;
        [view addSubview:contentLabel];
        //author
        NSTextField *authorLabel = [UIUtil label];
        authorLabel.font = [NSFont systemFontOfSize:15.0];
        if ([Appearance isDark]) {
            authorLabel.textColor = [NSColor tertiaryLabelColor];
        } else {
            authorLabel.textColor = [Appearance colorWithHex:0x999999];
        }
        authorLabel.stringValue = data[@"author"];
        [authorLabel sizeToFit];
        authorLabel.bottom = view.height - reviewPadding;
        authorLabel.right = view.width - reviewPadding;
        [view addSubview:authorLabel];
    }
    CGFloat reviewWidth = (reviewItemWidth + reviewItemSpacing) * reviewList.count;
    reviewScrollView.contentView.documentView.size = CGSizeMake(reviewWidth, reviewScrollView.height);
    //footer
    NSView *footerView = [[NSView alloc] init];
    footerView.width = width;
    footerView.height = 60.0f;
    footerView.top = reviewScrollView.bottom;
    [contentView addSubview:footerView];
    self.scrollView.contentView.documentView.size = NSMakeSize(width, footerView.bottom);
    //action view
    NSView *bottomView = self.bottomView;
    bottomView.wantsLayer = YES;
    bottomView.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    NSColor *bottomShadowColor = [Appearance colorWithHex:0x000000 alpha:0.06];
    if ([Appearance isDark]) {
        bottomShadowColor = [Appearance colorWithHex:0x000000 alpha:0.1];
    }
    [bottomView setShadowWithColor:bottomShadowColor offset:CGSizeMake(0, 3) radius:0];
    if ([Appearance isDark]) {
        [self.restoreButton setTextColor:[Appearance colorWithHex:0x999999]];
        [self.privacyButton setTextColor:[Appearance colorWithHex:0x999999]];
        [self.termsOfUseButton setTextColor:[Appearance colorWithHex:0x999999]];
    } else {
        [self.restoreButton setTextColor:[Appearance colorWithHex:0xAAAAAA]];
        [self.privacyButton setTextColor:[Appearance colorWithHex:0xAAAAAA]];
        [self.termsOfUseButton setTextColor:[Appearance colorWithHex:0xAAAAAA]];
    }
    self.yearTipLabel.stringValue = kLocalized(@"pro_yeartip");
    self.foreverTipLabel.stringValue = kLocalized(@"pro_forevertip");
    [self.restoreButton setTitle:kLocalized(@"pro_restore")];
    [self.privacyButton setTitle:kLocalized(@"pro_privacy")];
    [self.termsOfUseButton setTitle:kLocalized(@"pro_termsofuse")];
}


- (void)initUI {
    [self updatePriceUI];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    NSWindowStyleMask style = self.view.window.styleMask;
    style = (style & ~(NSWindowStyleMaskResizable));
    self.view.window.styleMask = style;
    self.view.window.title = @"";
    if (!self.viewAppeared) {
        NSWindow * window = self.view.window;
        NSPoint screenOrigin = window.screen.frame.origin;
        CGSize screenSize = window.screen.frame.size;
        CGFloat maxHeight = screenSize.height - 60.0f;
        CGFloat width = 800;
        CGFloat height = ceil(width / (screenSize.width/screenSize.height));
        height += 280.0;
        height = MIN(height, maxHeight);
        CGFloat left = ceilf(screenSize.width-width)/2.0f + screenOrigin.x;
        CGFloat top = ceilf(screenSize.height-height)/2.0f + 30 + screenOrigin.y;
        NSRect windowRect = NSMakeRect(left, top, width, height);
        [window setFrame:windowRect display:NO];
        [self setupAfterXib];
        [self initUI];
    }
    self.viewAppeared = YES;
}

- (void)updatePriceUI {
    NSString *yearPrice = [[PayService shared] getProductPrice:kIapYearlyId];
    NSString *foreverPrice = [[PayService shared] getProductPrice:kIapForeverId];
    if ([LocalizationUtil isChinese]) {
        if (yearPrice.length == 0) {
            yearPrice = @"¥25.00";
        }
        if (foreverPrice.length == 0) {
            foreverPrice = @"¥68.00";
        }
        self.yearLabel.stringValue = [NSString stringWithFormat:@"%@ / 每年",yearPrice];
        self.foreverLabel.stringValue = [NSString stringWithFormat:@"%@ / 永久",foreverPrice];
    } else {
        if (yearPrice.length == 0) {
            yearPrice = @"$3.99";
        }
        if (foreverPrice.length == 0) {
            foreverPrice = @"$9.99";
        }
        self.yearLabel.stringValue = [NSString stringWithFormat:@"%@ / year",yearPrice];
        self.foreverLabel.stringValue = [NSString stringWithFormat:@"%@ / forever",foreverPrice];
    }
}


- (IBAction)yearButtonClicked:(id)sender {
    __weak typeof(self) wself = self;
    NSString *iapId = kIapYearlyId;
    [PayService.shared addPayment:iapId success:^(NSString *productId) {
//        NSLog(@"pay succeed: %@",productId);
        [wself.view hideHud];
        [wself closePayUI];
        [wself showSuccessAlert];
    } failure:^(NSString *productId, NSError *error) {
//        NSLog(@"pay %@ failed: %@",productId, error);
        [wself.view hideHud];
    }];
    [self.view showHud];
}

- (IBAction)foreverButtonClicked:(id)sender {
    __weak typeof(self) wself = self;
    [PayService.shared addPayment:kIapForeverId success:^(NSString *productId) {
//        NSLog(@"pay succeed: %@",productId);
        [wself.view hideHud];
        [wself closePayUI];
        [wself showSuccessAlert];
    } failure:^(NSString *productId, NSError *error) {
//        NSLog(@"pay %@ failed: %@",productId, error);
        [wself.view hideHud];
    }];
    [self.view showHud];
}

- (IBAction)restoreButtonPressed:(id)sender {
    __weak typeof(self) wself = self;
    [PayService.shared restoreTransactionsOnSuccess:^(BOOL pro, BOOL adRemove) {
        if (pro) {
            [wself.view hideHud];
            [wself closePayUI];
            [wself showSuccessAlert];
//            NSLog(@"restore succeed");
        } else {
//            NSLog(@"restore failed");
            [wself.view hideHud];
        }
    } failure:^(NSError *error) {
//        NSLog(@"restore failed");
        [wself.view hideHud];
    }];
    [self.view showHud];
}

- (void)showSuccessAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = kLocalized(@"pro_success_title");
    alert.informativeText = kLocalized(@"pro_success_info");
    [alert addButtonWithTitle:kLocalized(@"pro_success_start")];
    [alert runModal];
}

- (void)closePayUI {
    [self.presentingViewController dismissViewController:self];
}

- (IBAction)privacyButtonPressed:(id)sender {
    NSString *link = [UrlUtil filteredUrl:NSLocalizedString(@"web_privacy", nil)];
    NSURL * requestURL = [NSURL URLWithString:link];
    [[NSWorkspace sharedWorkspace] openURL:requestURL];
}

- (IBAction)termsOfUseButtonPressed:(id)sender {
    NSString *link = [UrlUtil filteredUrl:NSLocalizedString(@"web_termsofuse", nil)];
    NSURL * requestURL = [NSURL URLWithString:link];
    [[NSWorkspace sharedWorkspace] openURL:requestURL];
    
}

@end
