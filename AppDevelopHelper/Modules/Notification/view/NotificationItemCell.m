//
//  NotificationItemCell.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/2/27.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationItemCell.h"

@interface NotificationItemCell ()

@property (weak) IBOutlet NSTextField *titleTextfield;

@end

@implementation NotificationItemCell

- (void)setData: (id)data contentWidth: (CGFloat)contentWidth
{
    CGFloat height = 0.0f;
    height += 4.0f;
    NSString * value = data;
    CGFloat textHeight = 0;
    CGFloat textWidth = contentWidth - (6.0f+4.0f);
    NSSize boxSize = NSMakeSize(textWidth,CGFLOAT_MAX);
    self.titleTextfield.stringValue = value;
    textHeight = [self.titleTextfield sizeThatFits:boxSize].height;
    if(textHeight < 17.0f) {
        textHeight = 17.0f;
    }
    self.titleTextfield.frame = NSMakeRect(4.0f, height, ceil(textWidth),ceil(textHeight));
    height += textHeight;
    height += 4.0f;
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth
{
    static dispatch_once_t onceToken;
    static NotificationItemCell * templateCell = nil;
    dispatch_once(&onceToken, ^{
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NotificationItemCell class]) owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[NotificationItemCell class]]){
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
