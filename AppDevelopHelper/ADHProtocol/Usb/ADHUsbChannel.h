//
//  ADHUsbChannel.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2023/9/2.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHPTChannel.h"
#import "ADHProtocol.h"

@interface ADHUsbChannel : NSObject<ADHChannel, ADHPTChannelDelegate>

+ (ADHUsbChannel *)channel;
- (void)setUsb:(ADHPTChannel *)channel;
- (ADHPTChannel *)usb;
@property (nonatomic, weak) id <ADHChannelDelegate> delegate;

- (BOOL)isConnected;
- (void)disConnect;

@end
