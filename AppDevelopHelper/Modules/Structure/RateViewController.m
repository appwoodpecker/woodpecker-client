//
//  RateViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/31.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "RateViewController.h"
@import StoreKit;

@interface RateViewController ()

@property (weak) IBOutlet NSTextField *emotionLabel;
@property (weak) IBOutlet NSTextField *tipLabel;
@property (weak) IBOutlet NSView *starLayout;
@property (weak) IBOutlet NSButton *rateButton;
@property (weak) IBOutlet NSButton *feedbackButton;

@property (nonatomic, strong) NSArray *starButtons;
@property (nonatomic, assign) NSInteger rateValue;


@end

@implementation RateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValue];
    [self setupAfterXib];
    [self initUI];
}

- (void)initValue {
    self.rateValue = 0;
}

- (void)setupAfterXib {
    self.title = NSLocalizedString(@"rate_title", nil);
    //star
    CGFloat starSize = 36.0f;
    CGFloat space = 8.0f;
    NSView *layout = self.starLayout;
    NSInteger count = 5;
    NSMutableArray *starButtons = [NSMutableArray array];
    for (NSInteger i=0; i<count; i++) {
        NSImage *image = [NSImage imageNamed:@"icon_star"];
        NSButton *button = [NSButton buttonWithImage:image target:self action:@selector(starButtonPressed:)];
        button.tag = i;
        button.bordered = NO;
        button.size = CGSizeMake(starSize, starSize);
        button.left = (starSize + space) * i;
        button.top = 0;
        [layout addSubview:button];
        [starButtons addObject:button];
    }
    layout.width = count*starSize + (count-1) * space;
    layout.left = (layout.superview.width - layout.width)/2.0f;
    self.starButtons = starButtons;
}

- (void)initUI {
    [self updateRateValueUI];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    NSWindowStyleMask style = self.view.window.styleMask;
    style = (style & ~(NSWindowStyleMaskResizable));
    self.view.window.styleMask = style;
}

- (void)starButtonPressed: (NSButton *)button {
    NSInteger index = button.tag;
    for (NSInteger i=0; i<self.starButtons.count; i++) {
        NSButton *starButton = self.starButtons[i];
        if(i<=index) {
            starButton.image = [NSImage imageNamed:@"icon_star_selected"];
        }else {
            starButton.image = [NSImage imageNamed:@"icon_star"];
        }
    }
    self.rateValue = index + 1;
    [self updateRateValueUI];
}

- (void)updateRateValueUI {
    NSInteger rateIndex = self.rateValue - 1;
    if(rateIndex < 0) {
        self.emotionLabel.stringValue = @"😁";
        self.tipLabel.stringValue = NSLocalizedString(@"rate_default", nil);
        self.rateButton.hidden = NO;
        self.feedbackButton.hidden = YES;
    }else {
        NSArray *emotions = @[
                              @"😰",
                              @"😢",
                              @"😮",
                              @"😊",
                              @"😁",
                              ];
        self.emotionLabel.stringValue = emotions[rateIndex];
        if(self.rateValue < 4) {
            self.rateButton.hidden = YES;
            self.feedbackButton.hidden = NO;
            self.tipLabel.stringValue = NSLocalizedString(@"rate_value_low", nil);
        }else {
            self.rateButton.hidden = NO;
            self.feedbackButton.hidden = YES;
            self.tipLabel.stringValue = NSLocalizedString(@"rate_value_high", nil);
        }
    }
}

- (IBAction)rateButtonPressed:(id)sender {
    if (@available(macOS 10.14, *)) {
        [SKStoreReviewController requestReview];
    } else {
        NSString *url = @"macappstore://itunes.apple.com/app/id1333548463?action=write-review";
        [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:url]];
    }
    [Preference markRated:YES];
    [self dimiss];
}

- (IBAction)feedbackButtonPressed:(id)sender {
    NSString *url = @"mailto:woodpeckerapp@163.com";
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:url]];
    [self dimiss];
}


- (void)dimiss {
    [self.presentingViewController dismissViewController:self];
}

@end
