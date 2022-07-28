//
//  ADHBaseCell.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHBaseCell.h"

@implementation ADHBaseCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setData: (id)data
{
    
}

+ (CGFloat)rowHeight
{
    return 0.1;
}

+ (CGFloat)heightForData: (id)data
{
    return 0.1;
}

- (void)mouseDown:(NSEvent *)event {
    NSInteger clickCount = event.clickCount;
    if(clickCount == 1){
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellClicked:)]){
            [self.delegate cellClicked:self];
        }
        //double click时有问题
        [super mouseDown:event];
    }else if(clickCount == 2){
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellDoubleClicked:)]){
            [self.delegate cellDoubleClicked:self];
        }
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    NSPoint windowPos = [event locationInWindow];
    NSPoint point = [self convertPoint:windowPos fromView:nil];
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellRightClicked:point:)]){
        [self.delegate cellRightClicked:self point:point];
    }
    [super rightMouseDown:event];
}

@end













