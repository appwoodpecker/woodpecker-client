//
//  KeyChainValueCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/9/2.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "KeyChainValueCell.h"
#import "KeyChainItem.h"

@interface KeyChainValueCell ()

@property (weak) IBOutlet NSTextField *valueTextfield;

@property (weak) IBOutlet NSButton *actionButton;

@end

@implementation KeyChainValueCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    if(@available(macOS 10.14, *)) {
//        self.actionButton.contentTintColor = [[NSColor lightGrayColor] colorWithAlphaComponent:0.7];
//    }
}

- (NSView *)actionView {
    return self.actionButton;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self hideHud];
}

- (void)setData: (id)data {
    KeyChainItem *item = (KeyChainItem *)data;
    KeyChainItemValueStatus status = item.status;
    NSString *text = nil;
    NSString *toolTip = nil;
    if(status == KeyChainItemValueStatusUnknown) {
        self.actionButton.hidden = NO;
        text = @"";
    }else if(status == KeyChainItemValueStatusNotSet) {
        self.actionButton.hidden = YES;
        text = @"Not Set";
    }else if(status == KeyChainItemValueStatusAvailable) {
        self.actionButton.hidden = YES;
        if(item.valueText) {
            text = item.valueText;
        }else {
            //限制大小
            NSData *valueData = item.valueData;
            if(valueData.length > 100) {
                valueData = [valueData subdataWithRange:NSMakeRange(0, 100)];
            }
            text = [valueData description];
            toolTip = @"value was well encrypted. (utf-8 encoded value could be view directly for convenience)";
        }
    }
    self.valueTextfield.stringValue = text;
    self.valueTextfield.toolTip = toolTip;
}

- (IBAction)valueButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(keyChainValueCellRequestValue:)]){
        [self.delegate keyChainValueCellRequestValue:self];
    }
}

@end
