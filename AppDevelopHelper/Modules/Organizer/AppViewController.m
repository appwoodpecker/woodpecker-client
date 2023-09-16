//
//  AppViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/17.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "AppViewController.h"
#import "MacConnector.h"
#import "MacOrganizer.h"
#import "AppContext.h"
#import "AppContextManager.h"
#import "ConnectionViewController.h"
#import "DeviceUtil.h"

NSString * const kConnectionItemStatusUpdate = @"kConnectionItemStatusUpdate";

static CGFloat const kTabItemWidth = 240.0f;

@interface AppViewController ()<AppContextManagerObserver, ADHViewDelegate>

@property (strong) IBOutlet NSView *connectionView;
@property (weak) IBOutlet NSImageView *connectionStatusIcon;
@property (weak) IBOutlet NSTextField *connectionStatusLabel;
@property (weak) IBOutlet NSView *tabLayout;


@end

@implementation AppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self initUI];
}

- (void)setupAfterXib {
    self.connectionView.wantsLayer = YES;
    self.connectionView.layer.cornerRadius = 3.0f;
    self.connectionView.layer.borderWidth = 1.0;
    NSString * iconName = @"NSStatusNone";
    NSString * title = @"waiting connect";
    self.connectionStatusIcon.image = [NSImage imageNamed:iconName];
    self.connectionStatusLabel.stringValue = title;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[AppContextManager sharedManager] addObsever:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLayout) name:NSWindowDidResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)initUI {
    [self updateConnectionCountUI];
    [self updateLayout];
}

- (void)updateLayout {
    NSWindow *window = self.view.window;
    CGFloat width = window.frame.size.width;
    //72 is the close/min/max width
    CGFloat tabWidth = width - 72.0f - 10.0f;
    CGFloat minWidth = self.connectionView.width+10.0f;
    tabWidth = MAX(tabWidth, minWidth);
    self.view.width = tabWidth;
}

- (void)updateAppearanceUI {
    if([Appearance isDark]) {
        self.connectionView.layer.borderColor = [Appearance colorWithRed:200 green:200 blue:200 alpha:0.15].CGColor;
        self.connectionStatusLabel.textColor = [NSColor secondaryLabelColor];
    }else {
        self.connectionView.layer.borderColor = [Appearance colorWithRed:200 green:200 blue:200 alpha:0.7].CGColor;
        self.connectionStatusLabel.textColor = [NSColor secondaryLabelColor];
    }
    [self updateTabStateUI];
}

#pragma mark -----------------   connection   ----------------

//new app
- (void)appDidAdd: (AppContext *)context {
    //add to tablist
    [self addTab:context];
    [self updateTabStateUI];
    [self updateConnectionCountUI];
}

- (void)updateConnectionCountUI {
    NSArray *contextList = [AppContextManager sharedManager].visibleContextList;
    if(contextList.count >0) {
        self.connectionView.hidden = YES;
        self.tabLayout.hidden = NO;
    }else {
        self.connectionView.hidden = NO;
        self.tabLayout.hidden = YES;
    }
}

//connect, disconnect
- (void)appConnectionStateUpdate: (AppContext *)context {
    [self updateTabStateUI];
}

- (void)addTab: (AppContext *)context {
    NSArray *oldItemViews = self.tabLayout.subviews;
    CGFloat itemWidth = kTabItemWidth;
    CGFloat itemHeight = self.tabLayout.height - 1.0f;
    CGFloat left = oldItemViews.count * itemWidth;
    CGFloat statusSize = 14.0f;
    NSView *contentView = self.tabLayout;
    ADHView *itemView = [[ADHView alloc] initWithFrame:NSMakeRect(left, 1.0, itemWidth, itemHeight)];
    itemView.vtag = context.tag;
    itemView.delegate = self;
    
    //add skin
    NSImageView *skinView = [[NSImageView alloc] initWithFrame:itemView.bounds];
    [itemView addSubview:skinView];
         
    //icon
    NSImageView *statusIcon = [[NSImageView alloc] initWithFrame:NSMakeRect(8.0f, (itemHeight-statusSize)/2.0f, statusSize, statusSize)];
    statusIcon.imageAlignment = NSImageAlignCenter;
    statusIcon.imageScaling = NSImageScaleProportionallyDown;
    [itemView addSubview:statusIcon];
    //label
    CGFloat labelWidth = itemWidth - (statusIcon.right + 2.0f+20.0f);
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(statusIcon.right + 2.0f, (itemHeight-18.0f)/2.0f, labelWidth, 18.0f)];
    label.drawsBackground = NO;
    label.bordered = NO;
    label.editable = NO;
    label.selectable = NO;
    label.font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    label.textColor = [NSColor darkGrayColor];
    label.alignment = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    NSString * title = [NSString stringWithFormat:@"%@ %@",context.appName,context.deviceName];
    label.stringValue = title;
    label.toolTip = title;
    [itemView addSubview:label];
    //button
    NSButton *button = [[NSButton alloc] initWithFrame:itemView.bounds];
    button.target = self;
    button.action = @selector(tabButtonClicked:);
    button.bordered = NO;
    button.title = @"";
    [itemView addSubview:button];
    //close button
    NSButton *closeButton = [NSButton buttonWithImage:[NSImage imageNamed:@"icon_navi_close"] target:self action:@selector(closeButtonClicked:)];
    closeButton.bordered = NO;
    closeButton.size = CGSizeMake(12.0, 12.0f);
    closeButton.bottom = itemHeight - 6.0f;
    closeButton.right = itemWidth - 8.0f;
    closeButton.toolTip = @"Close";
    [itemView addSubview:closeButton];
    [contentView addSubview:itemView];
    
}

- (NSView *)itemViewWithTag: (NSInteger)tag {
    ADHView *targetView = nil;
    NSArray *itemViews = self.tabLayout.subviews;
    for (ADHView *itemView in itemViews) {
        if(itemView.vtag == tag) {
            targetView = itemView;
            break;
        }
    }
    return targetView;
}

- (void)removeTabWithTag: (NSInteger)tag {
    NSView *thisItemView = [self itemViewWithTag:tag];
    NSArray *itemViews = [self.tabLayout.subviews copy];
    for (NSInteger i=0; i<itemViews.count; i++) {
        NSView *itemView = itemViews[i];
        CGFloat delta = itemView.left - thisItemView.left;
        if(delta < -0.1) {
            //do nothing
        }else if(delta < CGFLOAT_MIN) {
            [itemView removeFromSuperview];
        }else if(delta > 0.1) {
            itemView.left -= itemView.width;
        }
    }
}

- (void)updateTabStateUI {
    NSArray *itemViews = self.tabLayout.subviews;
    BOOL isDark = [Appearance isDark];
    NSColor *topColor = nil;
    NSColor *normalColor = nil;
    if(isDark) {
        topColor = [[NSColor whiteColor] colorWithAlphaComponent:0.8];
        normalColor = [[NSColor whiteColor] colorWithAlphaComponent:0.5];
    }else {
        topColor = [[NSColor blackColor] colorWithAlphaComponent:0.75];
        normalColor = [[NSColor blackColor] colorWithAlphaComponent:0.5];
    }
    for (NSInteger i=0; i<itemViews.count; i++) {
        ADHView *itemView = itemViews[i];
        AppContext *context = [[AppContextManager sharedManager] contextWithTag:itemView.vtag];
        NSArray *subviews = itemView.subviews;
        NSImageView *skinImageView = subviews[0];
        NSImageView *statusIcon = subviews[1];
        NSTextField *label = subviews[2];
        NSString * iconName = nil;
        NSColor * textColor = nil;
        BOOL bTopTab = NO;
        if([context isConnected]){
            if([context isTopApp]) {
                textColor = topColor;
                iconName = @"NSStatusAvailable";
                bTopTab = YES;
            }else {
                iconName = @"NSStatusPartiallyAvailable";
                textColor = normalColor;
            }
        }else{
            iconName = @"NSStatusUnavailable";
            if([context isTopApp]) {
                textColor = topColor;
                bTopTab = YES;
            }else {
                textColor = normalColor;
            }
        }
        if(isDark) {
            skinImageView.image = [NSImage imageNamed:@"navi_selected_dark"];
        }else {
            skinImageView.image = [NSImage imageNamed:@"navi_selected"];
        }
        statusIcon.image = [NSImage imageNamed:iconName];
        label.textColor = textColor;
        skinImageView.hidden = !bTopTab;
    }
}

- (void)tabButtonClicked: (NSButton *)button {
    ADHView *itemView = (ADHView *)button.superview;
    NSInteger tag = itemView.vtag;
    AppContext *context = [[AppContextManager sharedManager] contextWithTag:tag];
    [[AppContextManager sharedManager] setTopContext:context];
    [self updateTabStateUI];
}

- (void)closeButtonClicked: (NSButton *)closeButton {
    ADHView *itemView = (ADHView *)closeButton.superview;
    NSInteger tag = itemView.vtag;
    NSInteger nextTag = [self getNearestTab:tag];
    AppContext *context = [[AppContextManager sharedManager] contextWithTag:tag];
    [[AppContextManager sharedManager] removeApp:context];
    [self removeTabWithTag:tag];
    if(nextTag != NSNotFound) {
        AppContext *nextContext = [[AppContextManager sharedManager] contextWithTag:nextTag];
        [[AppContextManager sharedManager] setTopContext:nextContext];
        [self updateTabStateUI];
    }
    [self updateConnectionCountUI];
}

- (NSInteger)getNearestTab: (NSInteger)vtag {
    NSInteger thisIndex = NSNotFound;
    NSArray *itemViews = self.tabLayout.subviews;
    for (NSInteger i=0;i<itemViews.count;i++) {
        ADHView *itemView = itemViews[i];
        if(itemView.vtag == vtag) {
            thisIndex = i;
            break;
        }
    }
    NSInteger targetIndex = NSNotFound;
    NSInteger tabCount = itemViews.count;
    if(thisIndex != NSNotFound) {
        //get right first
        NSInteger theIndex = thisIndex + 1;
        if(theIndex < tabCount) {
            targetIndex = theIndex;
        }
        //get left
        if(targetIndex == NSNotFound) {
            theIndex = thisIndex - 1;
            if(theIndex >= 0) {
                targetIndex = theIndex;
            }
        }
    }
    NSInteger targetTag = NSNotFound;
    if(targetIndex != NSNotFound) {
        ADHView *itemView = itemViews[targetIndex];
        targetTag = itemView.vtag;
    }
    return targetTag;
}

- (void)cellRightClicked: (ADHView *)itemView point: (NSPoint)point {
   //do nothing
}

- (IBAction)connectionButtonPressed:(id)sender {
    //检查是否已弹出
    NSViewController * targetVC = nil;
    NSArray * presentedVCs = self.presentedViewControllers;
    for (NSViewController * vc in presentedVCs) {
        if([vc isKindOfClass:[ConnectionViewController class]]){
            targetVC = vc;
            break;
        }
    }
    if(targetVC){
        [self dismissViewController:targetVC];
        return;
    }
    ConnectionViewController * connectVC = [[ConnectionViewController alloc] init];
    NSRectEdge rectEdge = NSRectEdgeMaxY;
    [self presentViewController:connectVC asPopoverRelativeToRect:self.connectionView.bounds ofView:self.connectionView preferredEdge:rectEdge behavior:NSPopoverBehaviorSemitransient];
}
            

@end


