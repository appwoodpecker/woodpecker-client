//
//  ADHTableView.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHTableView.h"

@implementation ADHTableView

/**
 让每一个cell都接收mouse事件
 */

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event
{
    return YES;
}


@end
