//
//  ADHApp.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHApp.h"

@implementation ADHApp

//本地工作路径
- (NSString *)basePath
{
    return nil;
}

- (BOOL)isValid
{
    return (self.deviceName.length > 0 && self.appName.length > 0 && self.bundleId.length > 0);
}

- (NSInteger)majorVersion {
    NSArray *numbers = [self.systemVersion componentsSeparatedByString:@"."];
    NSInteger version = 0;
    if(numbers.count > 0) {
        version = [numbers[0] integerValue];
    }
    return version;
}

- (NSInteger)minorVersion {
    NSArray *numbers = [self.systemVersion componentsSeparatedByString:@"."];
    NSInteger version = 0;
    if(numbers.count > 1) {
        version = [numbers[1] integerValue];
    }
    return version;
}

//framework版本
- (NSInteger)frameworkVersionValue {
    NSInteger value = 0;
    if(self.frameworkVersion) {
        NSString * versionText = [self.frameworkVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
        value = [versionText integerValue];
    }
    return value;
}

- (BOOL)isMacOS {
    return (self.platform == ADHPlatformMacOS);
}

- (BOOL)isAndroid {
    return (self.platform == ADHPlatformAndroid);
}

@end
