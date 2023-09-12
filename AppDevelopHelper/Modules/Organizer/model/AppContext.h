//
//  AppContext.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/18.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHApiClient.h"
#import "ADHApp.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppContext : NSObject

@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *bundleId;
//是否处于连接状态
@property (nonatomic, assign,getter=isConnected) BOOL connected;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign, getter=isTopApp) BOOL topApp;
//UI只显示visible app
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, assign) BOOL notworking;

+ (AppContext *)context;
- (ADHApiClient *)apiClient;
- (ADHProtocol *)protocol;
- (ADHApp *)app;
- (void)setApp:(ADHApp *)app;
- (void)unsetApp;

@end

NS_ASSUME_NONNULL_END
