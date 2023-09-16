//
//  NetworkActionService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NetworkActionService.h"
#import "ADHNetworkTransaction.h"

NSString * const kNetworkTransactionUpdateNotification = @"kNetworkTransactionUpdateNotification";
NSString * const kNetworkTransactionUpdateUserInfoUpdateList = @"recordlist";

@implementation NetworkActionService

//filebrowser
+ (NSString *)serviceName
{
    return @"adh.network";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"transactionUpdate" : NSStringFromSelector(@selector(onTransactionUpdate:context:)),
             };
}

/*
 Transaction update
 ADHNetworkTransferRecord
*/
- (void)onTransactionUpdate: (ADHRequest *)request context:(ADHApiClient *)apiClient
{
    NSDictionary * data = request.body;
    NSArray * dataList = data[@"list"];
    if(dataList.count == 0) return;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    AppContext *context = [[AppContextManager sharedManager] contextWithApiClient:apiClient];
    if(context) {
        userInfo[@"context"] = context;
    }
    userInfo[kNetworkTransactionUpdateUserInfoUpdateList] = dataList;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkTransactionUpdateNotification object:self userInfo:userInfo];
    [request finish];
}




@end












