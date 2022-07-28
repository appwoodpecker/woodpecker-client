//
//  ADHLaunchOptions.m
//  ADHClient
//
//  Created by 张小刚 on 2018/8/6.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ADHLaunchOptions.h"

NSString *const kADHAutoConnectEnabled          = @"ADHAutoConnectEnabled";
NSString *const kADHShowOnConnectionFailed      = @"ADHShowOnConnectionFailed";
NSString *const kADHHostName                    = @"ADHHostName";
NSString *const kADHHostAddress                 = @"ADHHostAddress";
NSString *const kADHUIGestureEnabled            = @"ADHUIGestureEnabled";

@implementation ADHLaunchOptions

- (instancetype)init {
    self = [super init];
    if (self) {
        _autoConnectEnabled = YES;
        _uiGestureEnabled = YES;
    }
    return self;
}

- (BOOL)isHostAddressValid {
    return (self.hostAddress.length > 0 && self.hostPort > 0);
}

- (BOOL)isHostNameValid {
    return (self.hostName.length > 0);
}

@end
