//
//  WelcomeViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/4/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "WelcomeViewController.h"
#import "DeviceUtil.h"

@interface WelcomeViewController ()
@property (weak) IBOutlet NSView *page1;
@property (unsafe_unretained) IBOutlet NSTextView *desTextView;
@property (weak) IBOutlet NSLayoutConstraint *desTextViewHeightConstraint;

@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSView *privacyPage;
@property (weak) IBOutlet NSView *page2;

@property (weak) IBOutlet NSTextField *privacyTitleLabel;
@property (weak) IBOutlet NSTextField *privacyDescLabel;
@property (weak) IBOutlet NSButton *privacyNextButton;
@property (weak) IBOutlet NSTextField *privacyLabel1;
@property (weak) IBOutlet NSTextField *privacyLabel2;

@property (weak) IBOutlet NSTextField *runLabel;
@property (weak) IBOutlet NSButton *helpButton;
@property (weak) IBOutlet NSTextField *des2Label;
@property (weak) IBOutlet NSLayoutConstraint *page1Leading;
@property (weak) IBOutlet NSLayoutConstraint *privacyLeading;
@property (weak) IBOutlet NSLayoutConstraint *page2Leading;


@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
}

- (void)setupAfterXib {
    self.view.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    BOOL dark = [Appearance isDark];
    NSColor *defaultColor = nil;
    if(dark) {
        defaultColor = [NSColor secondaryLabelColor];
    }else {
        defaultColor = [Appearance colorWithHex:0x616161];
    }
    //page1
    NSMutableParagraphStyle *pstyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    pstyle.lineSpacing += 4.0f;
    CGFloat fontSize = 16.0f;
    NSDictionary *defaultAttr = @{
                                  NSForegroundColorAttributeName : defaultColor,
                                  NSFontAttributeName : [NSFont systemFontOfSize:fontSize weight:NSFontWeightLight],
                                  NSParagraphStyleAttributeName : pstyle,
                                  };
    NSDictionary *strongAttr = @{
                                  NSForegroundColorAttributeName : [NSColor labelColor],
                                  NSFontAttributeName : [NSFont systemFontOfSize:fontSize weight:NSFontWeightLight],
                                  NSParagraphStyleAttributeName : pstyle,
                                  };
    NSDictionary *linkAttr = @{
                                 NSForegroundColorAttributeName : [Appearance themeColor],
                                 NSFontAttributeName : [NSFont systemFontOfSize:fontSize weight:NSFontWeightLight],
                                 NSParagraphStyleAttributeName : pstyle,
                                 };
    self.desTextView.linkTextAttributes = linkAttr;
    NSAttributedString *content = nil;
    if([LocalizationUtil isChinese]) {
        self.desTextViewHeightConstraint.constant = 50.0f;
        NSMutableAttributedString * attrText = [[NSMutableAttributedString alloc] initWithString:@"在开始之前，您需要集成framework到您的项目，请选择合适的方式，您也可以下载 demo 项目立即体验" attributes:defaultAttr];
        NSString *text = attrText.string;
        NSRange strongRange = [text rangeOfString:@"集成framework"];
        [attrText setAttributes:strongAttr range:strongRange];
        NSRange linkRange = [text rangeOfString:@" demo "];
        [attrText addAttribute:NSLinkAttributeName value:kDemoUrl range:linkRange];
        content = attrText;
    }else {
        self.desTextViewHeightConstraint.constant = 72.0;
        NSMutableAttributedString * attrText = [[NSMutableAttributedString alloc] initWithString:@"Before start, you should integrate framework to you app, please choose one of the methods you prefer, or start with the demo project" attributes:defaultAttr];
        NSString *text = attrText.string;
        NSRange strongRange = [text rangeOfString:@"integrate framework"];
        [attrText setAttributes:strongAttr range:strongRange];
        NSRange linkRange = [text rangeOfString:@" demo "];
        [attrText addAttribute:NSLinkAttributeName value:kDemoUrl range:linkRange];
        content = attrText;
    }
    [self.desTextView.textStorage setAttributedString:content];
    //privacy
    NSButton *nextButton = self.privacyNextButton;
    nextButton.wantsLayer = YES;
    nextButton.layer.cornerRadius = 6.0f;
    nextButton.layer.borderWidth = 1.0f;
    nextButton.layer.borderColor = [Appearance themeColor].CGColor;
    [nextButton setTextColor:[Appearance themeColor]];
    self.privacyTitleLabel.textColor = [Appearance themeColor];
    if([LocalizationUtil isChinese]) {
        {
            NSMutableAttributedString * content = [[NSMutableAttributedString alloc] initWithString:@"我们支持USB或本地Wifi进行通信，如果您使用本地Wifi进行通信，由于iOS 14对本地网络使用增加了权限，因此需要您在App应用的Info.plist增加以下两项：" attributes:defaultAttr];
            NSString *text = content.string;
            NSRange strongRange1 = [text rangeOfString:@"USB"];
            NSRange strongRange2 = [text rangeOfString:@"本地Wifi"];
            [content setAttributes:linkAttr range:strongRange1];
            [content setAttributes:linkAttr range:strongRange2];
            self.privacyDescLabel.attributedStringValue = content;
        }
        
        NSMutableAttributedString * content1 = [[NSMutableAttributedString alloc] initWithString:@"1. 在Privacy - Local Network Usage Description添加本地网络描述" attributes:defaultAttr];
        NSString *text = content1.string;
        NSRange strongRange = [text rangeOfString:@"Privacy - Local Network Usage Description"];
        [content1 setAttributes:strongAttr range:strongRange];
        self.privacyLabel1.attributedStringValue = content1;
        
        NSMutableAttributedString * content2 = [[NSMutableAttributedString alloc] initWithString:@"2. 在Bonjour services列表添加 _adhp._tcp" attributes:defaultAttr];
        NSString *text2 = content2.string;
        NSRange strongRange2 = [text2 rangeOfString:@"Bonjour services"];
        [content2 setAttributes:strongAttr range:strongRange2];
        strongRange2 = [text2 rangeOfString:@"_adhp._tcp"];
        [content2 setAttributes:strongAttr range:strongRange2];
        self.privacyLabel2.attributedStringValue = content2;
    }else {
        {
            NSMutableAttributedString * content = [[NSMutableAttributedString alloc] initWithString:@"We support USB or Local Wifi to transfer data, If you choose wifi to transfer data between mac and your app, on iOS 14, system add a new privacy about local network usage,  we need add two keys in your app's Info.plist file:" attributes:defaultAttr];
            NSString *text = content.string;
            NSRange strongRange1 = [text rangeOfString:@"USB"];
            NSRange strongRange2 = [text rangeOfString:@"Local Wifi"];
            [content setAttributes:linkAttr range:strongRange1];
            [content setAttributes:linkAttr range:strongRange2];
            self.privacyDescLabel.attributedStringValue = content;
        }
        NSMutableAttributedString * content1 = [[NSMutableAttributedString alloc] initWithString:@"1.  Add description in Privacy - Local Network Usage Description" attributes:defaultAttr];
        NSString *text = content1.string;
        NSRange strongRange = [text rangeOfString:@"Privacy - Local Network Usage Description"];
        [content1 setAttributes:strongAttr range:strongRange];
        self.privacyLabel1.attributedStringValue = content1;
        
        NSMutableAttributedString * content2 = [[NSMutableAttributedString alloc] initWithString:@"2. Add _adhp._tcp in Bonjour services list" attributes:defaultAttr];
        NSString *text2 = content2.string;
        NSRange strongRange2 = [text2 rangeOfString:@"Bonjour services"];
        [content2 setAttributes:strongAttr range:strongRange2];
        strongRange2 = [text2 rangeOfString:@"_adhp._tcp"];
        [content2 setAttributes:strongAttr range:strongRange2];
        self.privacyLabel2.attributedStringValue = content2;
    }
    
    //page2
    nextButton = self.nextButton;
    nextButton.wantsLayer = YES;
    nextButton.layer.cornerRadius = 6.0f;
    nextButton.layer.borderWidth = 1.0f;
    nextButton.layer.borderColor = [Appearance themeColor].CGColor;
    [nextButton setTextColor:[Appearance themeColor]];
    self.runLabel.textColor = [Appearance themeColor];
    [self.helpButton setTextColor:[Appearance themeColor]];
    NSString *des2 = self.des2Label.stringValue;
    NSAttributedString *content2 = [[NSAttributedString alloc] initWithString:des2 attributes:defaultAttr];
    self.des2Label.attributedStringValue = content2;
    
    
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
    }
}

- (IBAction)nextButtonClicked:(id)sender {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.36;
        context.allowsImplicitAnimation = YES;
        CGFloat contentWidth = self.view.width;
        self.page1Leading.constant = - contentWidth;
        self.privacyLeading.constant = 0;
        self.page1.alphaValue = 0;
        self.privacyPage.alphaValue = 1;
        [self.page1.superview layoutSubtreeIfNeeded];
    } completionHandler:^{
        
    }];
}

- (IBAction)privacyNextButtonClicked:(id)sender {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.36;
        context.allowsImplicitAnimation = YES;
        CGFloat contentWidth = self.view.width;
        self.privacyLeading.constant = - contentWidth;
        self.page2Leading.constant = 0;
        self.privacyPage.alphaValue = 0;
        self.page2.alphaValue = 1;
        [self.page1.superview layoutSubtreeIfNeeded];
    } completionHandler:^{
        
    }];
}

- (IBAction)helpButtonClicked:(id)sender {
    [UrlUtil openExternalLocalizedUrl:@"web_usage"];
}

- (IBAction)podButtonClicked:(id)sender {
    NSString *pod = kPodText;
    [DeviceUtil pasteText:pod];
    [self showSuccessWithText:kLocalized(@"common_text_copied")];
}

- (IBAction)carthageButtonClicked:(id)sender {
    NSString *carthage = kCarthageText;
    [DeviceUtil pasteText:carthage];
    [self showSuccessWithText:kLocalized(@"common_text_copied")];
}

- (IBAction)manuallyButtonClicked:(id)sender {
    [UrlUtil openExternalLocalizedUrl:@"web_usage"];
}

- (IBAction)previousButtonPressed:(id)sender {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.36;
        context.allowsImplicitAnimation = YES;
        CGFloat contentWidth = self.view.width;
        self.privacyLeading.constant = 0;
        self.page2Leading.constant = contentWidth;
        self.privacyPage.alphaValue = 1;
        self.page2.alphaValue = 0;
        [self.page1.superview layoutSubtreeIfNeeded];
    } completionHandler:^{
        
    }];
}

- (IBAction)privacyPreviousButtonPressed:(id)sender {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.36;
        context.allowsImplicitAnimation = YES;
        CGFloat contentWidth = self.view.width;
        self.page1Leading.constant = 0;
        self.privacyLeading.constant = contentWidth;
        self.page1.alphaValue = 1;
        self.privacyPage.alphaValue = 0;
        [self.page1.superview layoutSubtreeIfNeeded];
    } completionHandler:^{
        
    }];
}

- (IBAction)privacyItem1Clicked: (NSGestureRecognizer *)recognizer {
    NSString *text = @"Privacy - Local Network Usage Description";
    [DeviceUtil pasteText:text];
    [self showSuccessWithText:kLocalized(@"common_text_copied")];
}

- (IBAction)privacyItem2Clicked: (NSGestureRecognizer *)recognizer {
    NSString *text = @"_adhp._tcp";
    [DeviceUtil pasteText:text];
    [self showSuccessWithText:kLocalized(@"common_text_copied")];
}

@end
