//
//  AppContextManager.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/19.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppContext.h"
#import "MacConnector.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString *const kAppContextAppStatusUpdate;

@protocol AppContextManagerObserver;
@interface AppContextManager : NSObject <MacConnectorDelegate>

+ (AppContextManager *)manager;
//所有contextList
- (NSArray<AppContext *> *)contextList;
//UI可见的contexts
- (NSArray<AppContext *> *)visibleContextList;
- (AppContext *)contextWithTag: (NSInteger)tag;
- (AppContext *)contextWithApiClient: (ADHApiClient *)apiClient;
- (void)addObsever: (id<AppContextManagerObserver>)observer;

- (void)setTopContext: (AppContext *)context;
- (AppContext *)topContext;

- (void)removeApp: (AppContext *)context;

@end

@protocol AppContextManagerObserver <NSObject>

@optional
//new app
- (void)appDidAdd:(AppContext *)context;
//remove from list
- (void)appWillRemove:(AppContext *)context;
//connect, disconnect
- (void)appConnectionStateUpdate:(AppContext *)context;
//top app update
- (void)topContextUpdate:(AppContext *)context;

@end

NS_ASSUME_NONNULL_END
