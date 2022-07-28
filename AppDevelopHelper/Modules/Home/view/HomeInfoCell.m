//
//  HomeInfoCell.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/5.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "HomeInfoCell.h"

@interface HomeInfoCell ()

@property (weak) IBOutlet NSTextField *contentLabel;
@property (weak) IBOutlet NSView *lineView;
@property (weak) IBOutlet NSImageView *iconImageView;

@end

@implementation HomeInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineView.wantsLayer = YES;
}

- (void)setData:(NSDictionary *)data {
    NSString * value = data[@"text"];
    NSString *tipText = data[@"tip"];
    NSString *iconName = data[@"iconName"];
    self.contentLabel.stringValue = value;
    [self.contentLabel sizeToFit];
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    if(iconName) {
        self.iconImageView.image = [NSImage imageNamed:iconName];
        [self.iconImageView setTintColor:[NSColor controlTextColor]];
        self.iconImageView.hidden = NO;
        self.contentLabel.left = self.iconImageView.right + 8.0f;
    }else {
        self.contentLabel.left = 0;
        self.iconImageView.hidden = YES;
    }
    if(self.key) {
        self.lineView.left = self.contentLabel.left;
        self.lineView.width = self.width;
        self.lineView.autoresizingMask = NSViewWidthSizable;
    }else {
        self.lineView.left = self.contentLabel.left;
        self.lineView.width = self.contentLabel.width + 60.0f;
        self.lineView.autoresizingMask = NSViewNotSizable;
    }
    self.contentLabel.toolTip = tipText;
}

- (void)setTextColor: (NSColor *)color {
    self.contentLabel.textColor = color;
}

@end
