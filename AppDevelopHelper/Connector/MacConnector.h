//
//  ServerConnector.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/25.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHGCDAsyncSocket.h"
#import "ADHApp.h"

@protocol MacConnectorDelegate;
@interface MacConnector : NSObject

@property (nonatomic, weak) id <MacConnectorDelegate> delegate;

//发布服务
- (void)startService;

- (NSArray<ADHApp *> *)appList;

//端口号
- (NSString *)localPort;

- (void)disConnectApp: (ADHApp *)app;

- (void)updateAllowDevice;

@end


@protocol MacConnectorDelegate <NSObject>

- (void)connectorClientDidConnect: (ADHApp *)app;
- (void)connectorClientDidDisConnect: (ADHApp *)app;

@end
