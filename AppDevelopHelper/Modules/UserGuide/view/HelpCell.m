//
//  WelcomeCell.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/1.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "HelpCell.h"

@interface HelpCell ()

@property (weak) IBOutlet NSTextField *linkTextfield;

@end

@implementation HelpCell

- (void)setData: (id)data
{
    NSString * text = data[@"title"];
    self.linkTextfield.stringValue = text;
}

+ (CGFloat)height
{
    return 60.0f;
}

@end
