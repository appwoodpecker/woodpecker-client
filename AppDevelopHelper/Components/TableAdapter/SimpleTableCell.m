//
//  SimpleTableCell.m
//  ADHClient
//
//  Created by 张小刚 on 2018/5/14.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "SimpleTableCell.h"

@interface SimpleTableCell ()

@property (weak) IBOutlet NSTextField *contentTextField;

@end

@implementation SimpleTableCell

- (void)setValue: (NSString *)value {
    self.contentTextField.stringValue = value;
}

- (void)setTextColor: (NSColor *)color {
    self.contentTextField.textColor = color;
}

- (void)setTextAlignment: (NSTextAlignment)alignment {
    self.contentTextField.alignment = alignment;
}

@end
