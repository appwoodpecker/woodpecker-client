//
//  ADHProtocol.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHSession.h"
#import "ADHPackage.h"
#import "ADHGCDAsyncSocket.h"
#import "ADHDefine.h"
#import "ADHProtocol.h"

@interface ADHSocketChannel : NSObject<ADHChannel, ADHGCDAsyncSocketDelegate>

+ (ADHSocketChannel *)channel;

/**
 传输底层socket
 对于Mac端来说，可以同时与多个App通信，每个app有自己的socket
 对于App端，只有一个socket
 */
- (void)setSocket:(ADHGCDAsyncSocket *)socket;
- (ADHGCDAsyncSocket *)socket;
@property (nonatomic, weak) id <ADHChannelDelegate> delegate;
- (dispatch_queue_t)workQueue;

@end
