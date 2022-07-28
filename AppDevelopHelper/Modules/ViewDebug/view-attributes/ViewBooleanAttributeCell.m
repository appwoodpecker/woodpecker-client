//
//  ViewBooleanAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/6.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewBooleanAttributeCell.h"

@interface ViewBooleanAttributeCell ()

@property (weak) IBOutlet NSButton *checkButton;

@end

@implementation ViewBooleanAttributeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.checkButton setTitle:@"NO"];
    [self.checkButton setTitle:@"YES"];
}

- (void)setData:(id)data contentWidth:(CGFloat)contentWidth {
    BOOL value = [data boolValue];
    if(value) {
        self.checkButton.state = NSControlStateValueOn;
    }else {
        self.checkButton.state = NSControlStateValueOff;
    }
}

- (IBAction)checkButtonClicked:(id)sender {
    BOOL value = (self.checkButton.state == NSControlStateValueOn);
    
    [self.delegate valueUpdateRequest:self value:[NSNumber numberWithBool:value] info:nil];
}

+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 32.0f;
}

@end
