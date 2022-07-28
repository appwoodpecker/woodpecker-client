//
//  ADHView.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/25.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ADHView.h"

@implementation ADHView

- (void)rightMouseDown:(NSEvent *)event {
    NSPoint windowPos = [event locationInWindow];
    NSPoint point = [self convertPoint:windowPos fromView:nil];
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellRightClicked:point:)]){
        [self.delegate cellRightClicked:self point:point];
    }
    [super rightMouseDown:event];
}

@end


@implementation ADHTextField

- (NSView *)hitTest:(NSPoint)point {
    if (self.userInteractionDisabled) {
        return nil;
    } else {
        return [super hitTest:point];
    }
}

@end
