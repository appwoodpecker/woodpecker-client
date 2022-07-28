//
//  DailyViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/11.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "UtilityViewController.h"
#import "DateFormatViewController.h"
#import "ADHFlipView.h"


@interface UtilityViewController ()

@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;
@property (nonatomic, strong) DateFormatViewController *dateformat;

@end

@implementation UtilityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadContent];
    [self addNotification];
}

- (void)setupUI {
    self.view.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    if([Appearance isDark]) {
        self.view.layer.backgroundColor = [Appearance colorWithHex:0x323232].CGColor;
    }else {
        self.view.layer.backgroundColor = [Appearance colorWithHex:0xE6E6E6].CGColor;
    }
}

- (void)viewDidLayout {
    [super viewDidLayout];
    CGFloat viewWidth = self.view.width;
    CGFloat maxWidth = 1200.0f;
    CGFloat padding = 160.0f;
    CGFloat contentWidth = viewWidth - padding*2;
    contentWidth = MIN(maxWidth, contentWidth);
    self.scrollView.width = contentWidth;
    self.scrollView.left = (viewWidth - self.scrollView.width)/2.0f;
}

- (void)loadContent {
    NSClipView *contentView = self.scrollView.contentView;
    NSView *documentView = contentView.documentView;
    //date formatter
    {
        DateFormatViewController *dateformat = [[DateFormatViewController alloc] initWithNibName:@"DateFormatViewController" bundle:nil];
        dateformat.context = self.context;
        self.dateformat = dateformat;
        NSView *view = dateformat.view;
        view.autoresizingMask = NSViewWidthSizable;
        view.width = documentView.width;
        view.wantsLayer = YES;
        view.layer.cornerRadius = 6.0f;
        view.layer.masksToBounds = NO;
        view.layer.shadowOffset = CGSizeMake(1, -1);
        view.layer.shadowRadius = 2.0f;
        view.layer.shadowOpacity = 1.0f;
        [documentView addSubview:view];
    }
}




@end
