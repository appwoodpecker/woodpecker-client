//
//  NetworkService.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/23.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADHNetworkTransaction;
@interface NetworkService : NSObject

+ (NetworkService *)serviceWithContext: (AppContext *)context;
- (NSString *)workPath;

- (NSString *)getTransactionResponseBodyPath: (ADHNetworkTransaction *)transaction;
- (BOOL)responseBodyExistsForTransaction: (ADHNetworkTransaction *)transaction;
- (void)downloadResponseBody: (ADHNetworkTransaction *)trans onCompletion:(void (^)(NSString *path))completionBlock onError: (void (^)(NSError *))errorBlock;

+ (void)clear;

@end
