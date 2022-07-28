//
//  ConnectAppCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/3/2.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ConnectItemCell.h"
#import "ConnectItem.h"

@interface ConnectItemCell ()

@property (weak) IBOutlet NSImageView *statusIcon;
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSButton *removeButton;


@end

@implementation ConnectItemCell

- (void)setData: (id)data
{
    ConnectItem * item = (ConnectItem *)data;
    NSString * name = [NSString stringWithFormat:@"%@ %@",item.appName,item.deviceName];
    self.nameLabel.stringValue = name;
    self.nameLabel.toolTip = name;
    NSString * iconName = nil;
    NSColor * textColor = nil;
    if(item.connected) {
        if(item.useStatus == UseStatusUsing) {
            iconName = @"NSStatusAvailable";
            textColor = [NSColor darkGrayColor];
        }else {
            iconName = @"NSStatusPartiallyAvailable";
            textColor = [NSColor grayColor];
        }
    }else {
        iconName = @"NSStatusUnavailable";
        textColor = [NSColor grayColor];
    }
    self.nameLabel.textColor = textColor;
    self.statusIcon.image = [NSImage imageNamed:iconName];
}

+ (CGFloat)height
{
    return 33.0f;
}

- (IBAction)removeButtonPressed:(id)sender {
}

@end
