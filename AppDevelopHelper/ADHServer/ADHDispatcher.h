//
//  ADHDispatcher.h
//  ADHClient
//
//  Created by 张小刚 on 2017/10/29.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHRequest.h"
#import "ADHService.h"

@class ADHSession;
@class ADHApiClient;

typedef void (^ADHDispatchCompletion)(NSDictionary * body, NSData *, ADHSession *);

/**
 dispatcher 负责事件分发处理，并回调给protocol client
 */
@interface ADHDispatcher : NSObject

- (void)registerService: (Class)serviceClazz;

- (void)dispatchRequest: (ADHSession *)session apiClient: (ADHApiClient *)apiClient onCompletion:(ADHDispatchCompletion)completionBlock;

//private, for ADHMetaService
- (NSArray *)registeredActionList;
- (NSArray *)registeredServiceList;

@end



