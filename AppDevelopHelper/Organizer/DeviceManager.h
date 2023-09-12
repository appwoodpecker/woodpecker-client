//
//  DeviceManager.h
//  Woodpecker
//
//  Created by 张小刚 on 2023/9/9.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceManager : NSObject

+ (DeviceManager *)shared;
- (void)addClosedDeviceId:(NSNumber *)deviceId;
- (BOOL)isDeviceClosed:(NSNumber *)deviceId;

@end
