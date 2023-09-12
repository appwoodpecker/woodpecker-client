//
//  ADHUsb.h
//  Woodpecker
//
//  Created by 张小刚 on 2023/9/6.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADHPTChannel;

typedef enum : NSUInteger {
    ADHUsbStateDisConnect = 0,
    ADHUsbStateConnecting,
    ADHUsbStateConnected,
} ADHUsbState;

@interface ADHUsb : NSObject

//固定编号
@property (nonatomic, strong) NSString *udid;
//连接临时设备id
@property (nonatomic, strong) NSNumber *deviceId;
//硬件是否连接
@property (nonatomic, assign) BOOL attatched;
//软件是否连接
@property (nonatomic, assign) ADHUsbState state;
@property (nonatomic, weak) ADHPTChannel *channel;


@end
