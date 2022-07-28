//
//  ConnectionViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/3/2.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ConnectionViewController.h"
#import "AppViewController.h"

@interface ConnectionViewController ()

@property (weak) IBOutlet NSView *emptyTipView;
@property (weak) IBOutlet NSButton *helpButton;

@end

@implementation ConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)setupAfterXib {
    [self updateAppearanceUI];
}

- (void)updateAppearanceUI {
    if([Appearance isDark]) {
        [self.helpButton setTextColor:[Appearance tipThemeColor]];
    }else {
        [self.helpButton setTextColor:[Appearance tipThemeColor]];
    }
}

- (IBAction)helpButtonPressed:(id)sender {
    [UrlUtil openExternalLocalizedUrl:@"web_usage"];
}

@end














