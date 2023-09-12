//
//  ADHRemoteService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHRemoteService.h"

@implementation ADHRemoteService

//local direct
- (BOOL)isLocalDirect {
    BOOL val = NO;
    if(self.simulator) {
        val = YES;
    }
    return val;
}

@end
