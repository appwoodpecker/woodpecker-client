//
//  ConsoleViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/6/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ConsoleViewController.h"
#import "LogRecorder.h"
#import "MacOrganizer.h"

@interface ConsoleViewController ()

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *pauseButton;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL shouldTryStart;

@property (nonatomic, strong) NSFont *textFont;
@property (nonatomic, strong) NSColor *textColor;

@end

@implementation ConsoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initValue];
    [self initUI];
    LogRecorder *recorder = [LogRecorder recorderWithContext:self.context];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConsoleUpdate:) name:kLogRecorderConsoleUpdateNotification object:recorder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doOnWorkAppStateUpdate) name:kAppContextAppStatusUpdate object:nil];
}

- (void)setupAfterXib {
    self.textColor = [Appearance colorWithRed:0x96 green:0x93 blue:0xAA alpha:1.0f];
    self.textFont = [NSFont systemFontOfSize:14.0f]; 
    self.textView.backgroundColor = [Appearance colorWithRed:0x1F green:0x20 blue:0x29 alpha:1.0];
    self.textView.automaticLinkDetectionEnabled = YES;
    self.textView.linkTextAttributes = @{
                                         NSForegroundColorAttributeName : [Appearance themeColor],
                                         NSFontAttributeName : self.textFont,
                                         NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                         NSCursorAttributeName: [NSCursor pointingHandCursor],
                                         };
    //adjust textview top/bottom padding
    self.textView.textContainerInset = NSMakeSize(0, 4.0);
}

- (void)initValue {
    self.started = NO;
    self.shouldTryStart = YES;
}

- (void)initUI {
    [self updateStartStateUI];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    if(self.shouldTryStart) {
        [self doConsoleStart];
    }
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    if(self.started) {
        [self doConsoleStop];
    }
}

- (void)onConsoleUpdate: (NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSArray<NSString *> *list = userInfo[kLogRecorderUpdateNotificationNewConsoleItemsKey];
    NSMutableString *content = [[NSMutableString alloc] init];
    for (NSString *message in list) {
        [content appendString:message];
    }
    if(content.length > 0) {
        __weak typeof(self) wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL needScrollToBottom = [wself needScrollToBottom];
            NSTextStorage *textStorage = wself.textView.textStorage;
            NSDictionary *attributes = @{
                                         NSForegroundColorAttributeName : wself.textColor,
                                         NSFontAttributeName : wself.textFont,
                                         };
            NSInteger beforeLength = textStorage.length;
            NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:content attributes:attributes];
            [textStorage appendAttributedString:attrText];
            NSRange appendRange = NSMakeRange(beforeLength, attrText.length);
            NSRange oldSelectRange = wself.textView.selectedRange;
            [wself.textView setSelectedRange:appendRange];
            [wself.textView setEditable:YES];
            [wself.textView checkTextInSelection:nil];
            [wself.textView setEditable:NO];
            //recover selection
            [wself.textView setSelectedRange:oldSelectRange];
            if(needScrollToBottom) {
                [wself scrollToBottom];
            }
        });
    }
}

- (void)doConsoleStart {
    [self.startButton showHud];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.console" action:@"start" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.startButton hideHud];
        wself.started = YES;
        [wself updateStartStateUI];
    } onFailed:^(NSError *error) {
        [wself.startButton hideHud];
    }];
}

- (void)doConsoleStop {
    [self.pauseButton showHud];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.console" action:@"stop" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.pauseButton hideHud];
        wself.started = NO;
        [wself updateStartStateUI];
    } onFailed:^(NSError *error) {
        [wself.pauseButton hideHud];
    }];
}

- (IBAction)startButtonPressed:(id)sender {
    self.shouldTryStart = YES;
    if(![self doCheckConnectionRoutine]) return;
    [self doConsoleStart];
}

- (IBAction)pauseButtonPressed:(id)sender {
    self.shouldTryStart = NO;
    if(![self doCheckConnectionRoutine]) return;
    [self doConsoleStop];
}

- (void)updateStartStateUI {
    self.startButton.hidden = self.started;
    self.pauseButton.hidden = !self.startButton.hidden;
}

- (IBAction)trashButtonPressed:(id)sender {
    self.textView.string = @"";
}

- (void)doOnWorkAppStateUpdate
{
    if(self.context.isConnected){
        if(self.shouldTryStart){
            [self doConsoleStart];
        }
    }else {
        self.started = NO;
        [self updateStartStateUI];
    }
}

- (BOOL)needScrollToBottom {
    BOOL needScroll = NO;
    NSScrollView * scrollView = self.textView.enclosingScrollView;
    NSView * documentView = scrollView.documentView;
    CGFloat contentHeight = documentView.bounds.size.height;
    CGFloat scrolledHeight = scrollView.documentVisibleRect.origin.y;
    CGFloat frameHeight = scrollView.frame.size.height;
    CGFloat scrollableHeight = contentHeight - frameHeight;
    CGFloat leftScrollHeight = scrollableHeight - scrolledHeight;
    if(leftScrollHeight <= 70){
        needScroll = YES;
    }
    return needScroll;
}

- (void)scrollToBottom {
    [self.textView scrollToEndOfDocument:nil];
}

@end




