//
//  DBItemCell.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DBItemCell.h"
#import "DBItem.h"

@interface DBItemCell ()<NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *contentLabel;
@property (weak) IBOutlet NSTextField *contentTextfield;

@end

@implementation DBItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setEditState:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEdit:) name:NSControlTextDidEndEditingNotification object:self.contentTextfield];
}

- (void)setData:(DBItem *)item {
    NSString * strValue = nil;
    if(!item.isBLOB){
        strValue = [NSString stringWithFormat:@"%@",item.stringValue];
    }else{
        strValue = @"Binary";
    }
    self.contentLabel.stringValue = strValue;
    self.contentTextfield.stringValue = strValue;
}

+ (CGFloat)rowHeight {
    return 29.0f;
}

- (void)setEditState: (BOOL)canEdit {
    if(!canEdit){
        self.contentTextfield.hidden = YES;
        self.contentLabel.hidden = NO;
    }else{
        self.contentTextfield.hidden = NO;
        self.contentLabel.hidden = YES;
        self.contentTextfield.stringValue = self.contentLabel.stringValue;
        [self.contentTextfield becomeFirstResponder];
    }
}

- (void)textFieldDidEndEdit: (NSNotification *)notification {
    [self setEditState:NO];
    NSString * newValue = self.contentTextfield.stringValue;
    BOOL updated = ![newValue isEqualToString:self.contentLabel.stringValue];
    if(updated){
        if(self.delegate && [self.delegate respondsToSelector:@selector(dbItemCell:contentUpdateRequest:)]){
            [(id<DBItemCellDelegate>)(self.delegate) dbItemCell:self contentUpdateRequest:newValue];
        }
    }
}




@end












