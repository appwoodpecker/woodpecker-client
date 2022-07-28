//
//  ADHAllowDeviceUtil.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/23.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHAllowDeviceUtil.h"

@implementation ADHAllowDeviceUtil

//allowed
+ (BOOL)checkName: (NSString *)name matchRule: (NSDictionary *)ruleData {
    NSString * deviceName = [name lowercaseString];
    NSArray *allowList = ruleData[@"a"];
    BOOL match = NO;
    for (NSDictionary *data in allowList) {
        NSString *name = [data[@"n"] lowercaseString];
        NSString *type = data[@"t"];
        if([type isEqualToString:@"e"]) {
            match = [deviceName isEqualToString:name];
        }else if([type isEqualToString:@"c"]) {
            match = ([deviceName rangeOfString:name].location != NSNotFound);
        }
        if(match) {
            break;
        }
    }
    return match;
}

//not disallowed
+ (BOOL)checkName: (NSString *)name notDisallowed: (NSDictionary *)ruleData {
    BOOL pass = NO;
    NSString * deviceName = [name lowercaseString];
    NSArray *allowList = ruleData[@"a"];
    BOOL match = NO;
    for (NSDictionary *data in allowList) {
        NSString *name = [data[@"n"] lowercaseString];
        NSString *type = data[@"t"];
        if([type isEqualToString:@"e"]) {
            match = [deviceName isEqualToString:name];
        }else if([type isEqualToString:@"c"]) {
            match = ([deviceName rangeOfString:name].location != NSNotFound);
        }
        if(match) {
            break;
        }
    }
    if(match) {
        pass = YES;
    }else {
        NSArray *disallowList = ruleData[@"da"];
        BOOL disallowOthers = [ruleData[@"do"] boolValue];
        //not in disallow list
        if(!disallowOthers) {
            BOOL disallowed = NO;
            for (NSDictionary *data in disallowList) {
                NSString *name = [data[@"n"] lowercaseString];
                NSString *type = data[@"t"];
                if([type isEqualToString:@"e"]) {
                    disallowed = [deviceName isEqualToString:name];
                }else if([type isEqualToString:@"c"]) {
                    disallowed = ([deviceName rangeOfString:name].location != NSNotFound);
                }
                if(disallowed) {
                    break;
                }
            }
            if(!disallowed) {
                pass = YES;
            }
        }else {
            //disallow others
        }
    }
    return pass;
}

@end
