//
//  ADHRemoteService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHRemoteService.h"
#import "ADHAllowDeviceUtil.h"

@implementation ADHRemoteService

//allowed
- (BOOL)isRuleMatch {
#if TARGET_OS_IPHONE
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceName = [device name];
    NSDictionary *ruleData = self.ruleData;
    BOOL match = [ADHAllowDeviceUtil checkName:deviceName matchRule:ruleData];
    return match;
#elif TARGET_OS_MAC
    return NO;
#endif
}

//not disallowed
- (BOOL)isNotDisallowed {
#if TARGET_OS_IPHONE
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceName = [device name];
    NSDictionary *ruleData = self.ruleData;
    BOOL pass = [ADHAllowDeviceUtil checkName:deviceName notDisallowed:ruleData];
    return pass;
#elif TARGET_OS_MAC
    return YES;
#endif
}

//local direct
- (BOOL)isLocalDirect {
    BOOL val = NO;
    if(self.simulator) {
        val = YES;
    }
    return val;
}

@end
