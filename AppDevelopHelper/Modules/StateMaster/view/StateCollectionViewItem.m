//
//  StateCollectionViewItem.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/31.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "StateCollectionViewItem.h"
#import "CircularProgressView.h"
#import "ADHClickTextField.h"

@interface StateCollectionViewItem ()<ADHClickTextFieldDelegate>

@property (nonatomic, strong) IBOutlet ADHClickTextField *titleTextField;
@property (nonatomic, strong) IBOutlet NSButton *moreButton;
@property (nonatomic, strong) IBOutlet NSTextField *sharedLabel;
@property (nonatomic, strong) IBOutlet NSButton *syncButton;
@property (nonatomic, strong) IBOutlet NSButton *pauseButton;
@property (nonatomic, strong) IBOutlet CircularProgressView *progressView;

@end

@implementation StateCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self.titleTextField setEditState:NO];
    self.titleTextField.adhDelegate = self;
}

- (void)setupUI {
    NSView *bgView = self.view;
    bgView.wantsLayer = YES;
    bgView.layer.cornerRadius = 6.0f;
    bgView.layer.masksToBounds = NO;
    bgView.layer.shadowOffset = CGSizeMake(1, -1);
    bgView.layer.shadowRadius = 2.0f;
    bgView.layer.shadowOpacity = 1.0f;
    
}

- (void)updateAppearanceUI {
    NSView *bgView = self.view;
    if([Appearance isDark]) {
        bgView.layer.backgroundColor = [Appearance colorWithHex:0x202123].CGColor;
        bgView.layer.shadowColor = [Appearance colorWithHex:0x202123 alpha:0.5].CGColor;
    }else {
        bgView.layer.backgroundColor = [Appearance colorWithHex:0xF2F2F2].CGColor;
        bgView.layer.shadowColor = [Appearance colorWithHex:0x9F9F9F alpha:0.5].CGColor;
    }
    [self.moreButton setTintColor:[Appearance actionImageColor]];
}

- (void)setData: (StateItem *)item {
    [self updateAppearanceUI];
    NSString *title = item.title;
#if DEBUG
//    if(!item.isAdd) {
//        NSString *dateText = [ADHDateUtil formatStringWithDate:item.updateDate dateFormat:@"MM-dd hh:mm:ss"];
//        title = [NSString stringWithFormat:@"%@ %@",title,dateText];
//    }
#endif
    self.titleTextField.stringValue = title;
    self.sharedLabel.hidden = !item.isShared;
    [self setSyncState:NO];
}

- (void)setSyncState: (BOOL)syncing {
    if(syncing) {
        self.syncButton.hidden = YES;
        self.progressView.hidden = NO;
        self.pauseButton.hidden = NO;
    }else {
        self.progressView.hidden = YES;
        self.pauseButton.hidden = YES;
        self.syncButton.hidden = NO;
        [self.progressView resetProgress];
    }
}

- (void)setProgress: (float)progress {
    [self.progressView setProgress:progress];
}

- (void)clickTextFieldTextChanged: (ADHClickTextField *)textField {
    NSString *title = self.titleTextField.stringValue;
    if(self.delegate && [self.delegate respondsToSelector:@selector(stateCollectionViewItem:titleUpdate:)]){
        [self.delegate stateCollectionViewItem:self titleUpdate:title];
    }
}

- (IBAction)moreButtonClicked:(id)sender {
    NSPoint point = [self.moreButton convertPoint:NSMakePoint(self.moreButton.width, 0) toView:self.view];
    if(self.delegate && [self.delegate respondsToSelector:@selector(stateCollectionViewItemMore:atPosition:)]){
        [self.delegate stateCollectionViewItemMore:self atPosition:point];
    }
}

- (IBAction)syncButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(stateCollectionViewItemSyncRequest:)]){
        [self.delegate stateCollectionViewItemSyncRequest:self];
    }
}

- (IBAction)pauseButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(stateCollectionViewItemPauseRequest:)]){
        [self.delegate stateCollectionViewItemPauseRequest:self];
    }
}

@end
