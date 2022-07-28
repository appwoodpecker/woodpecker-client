//
//  StateCollectionAddItem.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/6/1.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "StateCollectionAddItem.h"

@interface StateCollectionAddItem ()

@property (nonatomic, strong) IBOutlet NSTextField *addLabel;

@end

@implementation StateCollectionAddItem

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.addLabel.stringValue = kLocalized(@"state_add_title");
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
}

- (void)setData: (NSDictionary *)data {
    [self updateAppearanceUI];
}

- (IBAction)addButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(stateCollectionAddRequest:)]){
        [self.delegate stateCollectionAddRequest:self];
    }
}

@end
