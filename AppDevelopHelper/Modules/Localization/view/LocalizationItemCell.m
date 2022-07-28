//
//  LocalizationItemCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/6/24.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "LocalizationItemCell.h"

@interface LocalizationItemCell ()

@property (weak) IBOutlet NSTextField *contentTextfield;

@end

@implementation LocalizationItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.wantsLayer = YES;
}

- (void)setText: (NSString *)text {
    if(text.length == 0) {
        text = @"";
    }
    self.contentTextfield.stringValue = text;
}

- (void)setMissing: (BOOL)missing isKeyColumn: (BOOL)keyColumn {
    NSFont *font = nil;
    NSColor *backgroundColor = nil;
    NSColor *textColor = nil;
    if(keyColumn) {
        font = [NSFont systemFontOfSize:14.0f];
        textColor = [NSColor labelColor];
        backgroundColor = [NSColor clearColor];
        if(missing) {
            textColor = [NSColor systemRedColor];
        }
    }else {
        font = [NSFont systemFontOfSize:13.0f];
        textColor = [NSColor secondaryLabelColor];
        backgroundColor = [NSColor clearColor];
        if(missing) {
            backgroundColor = [Appearance colorWithRed:255 green:196 blue:186 alpha:1];
        }
    }
    self.contentTextfield.font = font;
    self.layer.backgroundColor = backgroundColor.CGColor;
    self.contentTextfield.textColor = textColor;
}

@end
    
