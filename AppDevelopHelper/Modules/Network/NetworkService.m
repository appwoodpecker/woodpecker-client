//
//  NetworkService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/23.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NetworkService.h"
#import "ADHNetworkTransaction.h"

static NSMutableArray *serviceList = nil;

@implementation NetworkService

+ (NetworkService *)serviceWithContext: (AppContext *)context {
    if(!serviceList) {
        serviceList = [NSMutableArray array];
    }
    NetworkService *targetService = nil;
    for (NetworkService *service in serviceList) {
        if(service.context == context) {
            targetService = service;
            break;
        }
    }
    if(!targetService) {
        NetworkService *service = [[NetworkService alloc] init];
        service.context = context;
        [serviceList addObject:service];
        targetService = service;
    }
    return targetService;
}

- (NSString *)workPath {
    NSString * networkPath = [[EnvtService service] networkWorkPath];
    return networkPath;
}

#pragma mark -----------------   response body   ----------------


- (NSString *)getTransactionResponseBodyPath: (ADHNetworkTransaction *)transaction {
    NSString * networkPath = [[EnvtService service] networkWorkPath];
    NSString * suggestedFilename = [transaction.response suggestedFilename];
    NSString * fileName = [NSString stringWithFormat:@"%@_%@",transaction.requestID,suggestedFilename];
    NSString * path = [networkPath stringByAppendingPathComponent:fileName];
    return path;
}

- (void)downloadResponseBody: (ADHNetworkTransaction *)trans onCompletion:(void (^)(NSString *path))completionBlock onError: (void (^)(NSError *))errorBlock {
    NSDictionary * data = @{
                            @"requestId" : adhvf_safestringfy(trans.requestID),
                            };
    __weak typeof(self) wself = self;
    [self.context.apiClient requestWithService:@"adh.network" action:@"requestResponseBody" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
        BOOL success = [body[@"success"] boolValue];
        if(success){
            NSData * responseBody = payload;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString * path = [wself getTransactionResponseBodyPath:trans];
                [ADHFileUtil saveData:responseBody atPath:path];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(completionBlock){
                        completionBlock(path);
                    }
                });
            });
        }else{
            if(errorBlock){
                errorBlock(nil);
            }
        }
    } onFailed:^(NSError *error) {
        if(errorBlock) {
            errorBlock(error);
        }
    }];
}

- (BOOL)responseBodyExistsForTransaction: (ADHNetworkTransaction *)transaction {
    NSString * path = [self getTransactionResponseBodyPath:transaction];
    return [ADHFileUtil fileExistsAtPath:path];
}

+ (void)clear {
    static BOOL bCleared = NO;
    if(!bCleared) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * networkPath = [[EnvtService service] networkWorkPath];
            [ADHFileUtil emptyDir:networkPath];
        });
        bCleared = YES;
    }
}



@end
