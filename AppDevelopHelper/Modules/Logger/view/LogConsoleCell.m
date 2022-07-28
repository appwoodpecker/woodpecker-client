//
//  LogConsoleCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/5/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "LogConsoleCell.h"

@interface LogConsoleCell ()

@property (weak) IBOutlet NSTextField *contentLabel;

@end

@implementation LogConsoleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentLabel.textColor = [Appearance colorWithRed:0x96 green:0x93 blue:0xAA alpha:1.0f];
}

- (void)setData: (id)data contentWidth: (CGFloat)contentWidth {
    NSString *text = (NSString *)data;
    CGFloat height = 0;
    CGFloat textHeight = 0;
    CGFloat textWidth = contentWidth - 6.0 * 2;
    NSSize boxSize = NSMakeSize(textWidth,CGFLOAT_MAX);
    self.contentLabel.stringValue = text;
    textHeight = [self.contentLabel sizeThatFits:boxSize].height;
    self.contentLabel.frame = NSMakeRect(6.0, height, ceil(textWidth),ceil(textHeight));
    if(textHeight > 0){
        height += textHeight;
    }
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth {
    static dispatch_once_t onceToken;
    static LogConsoleCell * templateCell = nil;
    dispatch_once(&onceToken, ^{
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:@"LogConsoleCell" owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[LogConsoleCell class]]){
                templateCell = object;
                break;
            }
        }
    });
    [templateCell setData:data contentWidth:contentWidth];
    CGFloat height = templateCell.frame.size.height;
    return height;
}

@end
