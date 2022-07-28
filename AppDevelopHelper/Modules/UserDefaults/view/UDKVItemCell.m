//
//  UDKVItemCell.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/8.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "UDKVItemCell.h"

@interface UDKVItemCell ()

@property (weak) IBOutlet NSTextField *contentLabel;
@property (weak) IBOutlet NSView *lineView;
@property (weak) IBOutlet NSTextField *contentTextfield;

@end

@implementation UDKVItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineView.wantsLayer = YES;
    [self setEditState:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEdit:) name:NSControlTextDidEndEditingNotification object:self.contentTextfield];
}

- (void)setData:(id)data {
    NSString * value = data;
    self.contentLabel.stringValue = value;
    self.contentTextfield.stringValue = value;
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
}

- (void)setTextColor: (NSColor *)color {
    self.contentLabel.textColor = color;
}

- (void)setEditState: (BOOL)canEdit {
    if(!canEdit){
        self.contentTextfield.hidden = YES;
    }else{
        self.contentTextfield.hidden = NO;
        self.contentTextfield.stringValue = self.contentLabel.stringValue;
        [self.contentTextfield becomeFirstResponder];
    }
}

- (void)setPinState: (BOOL)pin {
    if(pin) {
        self.contentLabel.font = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
    }else {
        self.contentLabel.font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    }
}

- (void)textFieldDidEndEdit: (NSNotification *)notification {
    [self setEditState:NO];
    NSString * newValue = self.contentTextfield.stringValue;
    if(self.delegate && [self.delegate respondsToSelector:@selector(udkvItemCell:contentUpdateRequest:)]){
        [(id<UDKVItemCellDelegate>)(self.delegate) udkvItemCell:self contentUpdateRequest:newValue];
    }
}

@end





