//
//  NetworkItemCell.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/16.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NetworkItemCell.h"

@interface NetworkItemCell ()

@property (weak) IBOutlet NSTextField *titleTextfield;

@end

@implementation NetworkItemCell

+ (CGFloat)rowHeight
{
    return 20.0f;
}

- (void)setData:(id)data
{
    NSString * text = adhvf_const_emptystr();
    if(data[@"key"]){
        text = data[@"key"];
        self.titleTextfield.alignment = NSTextAlignmentRight;
        self.titleTextfield.textColor = [NSColor secondaryLabelColor];
        self.titleTextfield.font = [NSFont boldSystemFontOfSize:13.0f];
        self.titleTextfield.stringValue = text;
    }else{
        text = data[@"value"];
        self.titleTextfield.alignment = NSTextAlignmentLeft;
        self.titleTextfield.textColor = [NSColor labelColor];
        self.titleTextfield.font = [NSFont systemFontOfSize:13.0f];
        self.titleTextfield.stringValue = text;
    }
}



@end






