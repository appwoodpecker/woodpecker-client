//
//  DeviceManager.m
//  Woodpecker
//
//  Created by 张小刚 on 2023/9/9.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import "DeviceManager.h"

@interface DeviceManager ()

@property (nonatomic, strong) NSMutableArray *mClosedDeviceIds;

@end

@implementation DeviceManager

+ (DeviceManager *)shared {
    static DeviceManager * sharedObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[DeviceManager alloc] init];
    });
    return sharedObj;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mClosedDeviceIds = [NSMutableArray array];
    }
    return self;
}

- (void)addClosedDeviceId:(NSNumber *)deviceId {
    if (deviceId == nil) {
        return;
    }
    [self.mClosedDeviceIds removeObject:deviceId];
    [self.mClosedDeviceIds addObject:deviceId];
}

- (BOOL)isDeviceClosed:(NSNumber *)deviceId {
    for (NSNumber *testId in self.mClosedDeviceIds) {
        if (testId == deviceId) {
            return YES;
        }
    }
    return NO;
}

@end
