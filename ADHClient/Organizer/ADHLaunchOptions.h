//
//  ADHLaunchOptions.h
//  ADHClient
//
//  Created by zhangxiaogang on 2018/8/6.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHLaunchOptions : NSObject

@property (nonatomic, assign) BOOL autoConnectEnabled;
@property (nonatomic, assign) BOOL uiGestureEnabled;
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSString *hostAddress;
@property (nonatomic, assign) uint16_t hostPort;

- (BOOL)isHostAddressValid;
- (BOOL)isHostNameValid;

@end
