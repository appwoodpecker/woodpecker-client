//
//  NotificationCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/2/17.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationCell.h"

@interface NotificationCell ()

@property (weak) IBOutlet NSTextField *contentTextfield;

@end

@implementation NotificationCell

- (void)setItem: (NotificationCellItem *)cellItem key: (NSString *)key {
    ADHNotificationItem *item = cellItem.item;
    if([key isEqualToString:@"Index"]) {
        self.contentTextfield.stringValue = [NSString stringWithFormat:@"%zd",cellItem.index];
        self.contentTextfield.alignment = NSTextAlignmentCenter;
    }else {
        NSString *text = [item readbleTextWithKey:key];
        self.contentTextfield.stringValue = adhvf_safestringfy(text);
        self.contentTextfield.alignment = NSTextAlignmentNatural;
    }
    if(cellItem.unread) {
        self.contentTextfield.textColor = [Appearance themeColor];
    }else {
        self.contentTextfield.textColor = [NSColor labelColor];
    }
    self.contentTextfield.toolTip = self.contentTextfield.stringValue;
}


@end



















