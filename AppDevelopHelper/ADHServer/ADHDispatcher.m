//
//  ADHDispatcher.m
//  ADHClient
//
//  Created by 张小刚 on 2017/10/29.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHDispatcher.h"
#import "ADHSession.h"
#import "ADHRequestPrivate.h"

@interface ADHDispatcher()

@property (nonatomic, strong) NSMutableDictionary * serviceList;
@property (nonatomic, strong) NSMutableArray * actionList;

@property (nonatomic, strong) NSMutableArray<ADHRequest *> * requestList;
@property (nonatomic, strong) NSMutableArray<ADHService *> * sharedServiceInstances;

@end

@implementation ADHDispatcher

- (instancetype)init {
    self = [super init];
    if (self) {
        self.actionList = [NSMutableArray array];
        self.serviceList = [NSMutableDictionary dictionary];
        self.requestList = [NSMutableArray array];
        self.sharedServiceInstances = [NSMutableArray array];
    }
    return self;
}

- (void)registerService: (Class)serviceClazz {
    NSString * serviceName = [(id)serviceClazz serviceName];
    if(self.serviceList[serviceName]){
        NSLog(@"[Woodpecker]: service \"%@\" already exists",serviceName);
        return;
    }
    self.serviceList[serviceName] = serviceClazz;
    NSDictionary<NSString *,NSString *> * actionList = (NSDictionary<NSString *,NSString *> *)[(id)serviceClazz actionList];
    [actionList enumerateKeysAndObjectsUsingBlock:^(NSString * action, NSString * handler, BOOL * _Nonnull stop) {
        [self registerAction:serviceName name:action handler:handler];
    }];
}

- (void)registerAction: (NSString *)serviceName name: (NSString *)actionName handler: (NSString *)handler {
    ADHAction * action = [ADHAction actionWithService:serviceName name:actionName handler:handler];
    [self.actionList addObject:action];
}

//Dispatch
- (ADHService *)sharedServiceWithClazz: (Class)clazz {
    ADHService * targetService = nil;
    for (ADHService * instance in self.sharedServiceInstances) {
        if([instance isKindOfClass:clazz]){
            targetService = instance;
            break;
        }
    }
    if(!targetService){
        targetService = [self produceServiceWithClazz:clazz];
        [self.sharedServiceInstances addObject:targetService];
    }
    return targetService;
}

- (ADHService *)produceServiceWithClazz: (Class)clazz {
    ADHService * instance = [[clazz alloc] init];
    [instance onServiceInit];
    return instance;
}

- (void)dispatchRequest: (ADHSession *)session apiClient: (ADHApiClient *)apiClient onCompletion:(ADHDispatchCompletion)completionBlock {
    ADHPResponse * response = session.response;
    NSDictionary * body = response.body;
    NSData * payload = response.payload;
    NSDictionary * api = body[@"api"];
    NSString * serviceName = api[@"service"];
    NSString * actionName = api[@"action"];
    NSDictionary * userInfo = body[@"userinfo"];
    if(serviceName.length == 0){
        serviceName = @"adh.default";
    }
    if(actionName.length == 0){
        actionName = @"echo";
    }
    ADHAction * targetAction = nil;
    for (ADHAction * action in self.actionList) {
        if([action.service isEqualToString:serviceName] && [action.name isEqualToString:actionName]){
            targetAction = action;
            break;
        }
    }
    if(!targetAction) {
        //如果未找到，使用adh.default:echo
        serviceName = @"adh.default";
        actionName = @"echo";
        for (ADHAction * action in self.actionList) {
            if([action.service isEqualToString:serviceName] && [action.name isEqualToString:actionName]){
                targetAction = action;
                break;
            }
        }
    }
    if(targetAction){
        ADHRequest * actionRequest = [[ADHRequest alloc] init];
        actionRequest.service = serviceName;
        actionRequest.action = actionName;
        actionRequest.body = userInfo;
        actionRequest.payload = payload;
        actionRequest.tSession = session;
        [self.requestList addObject:actionRequest];
        Class serviceClazz = self.serviceList[targetAction.service];
        ADHService * serviceInstance = nil;
        if([serviceClazz isShared]){
            serviceInstance = [self sharedServiceWithClazz:serviceClazz];
        }else{
            serviceInstance = [self produceServiceWithClazz:serviceClazz];
        }
        actionRequest.serviceObj = serviceInstance;
        SEL selector = NSSelectorFromString(targetAction.handler);
        __weak typeof(self) wself = self;
        ADHActionResponseBlock responseBlock = ^(NSDictionary * body,NSData * payload, ADHRequest * request){
            //这里没有切回工作queue，因为后续马上会切回
            ADHSession * tSession = request.tSession;
            if(completionBlock){
                completionBlock(body,payload,tSession);
            }
            [wself cleanupOnRequestFinish:request];
        };
        actionRequest.responseBlock = responseBlock;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if([targetAction.handler rangeOfString:@":context:"].location != NSNotFound) {
            //provide request object, and apiclient info
            [serviceInstance performSelector:selector withObject:actionRequest withObject:apiClient];
        }else {
            //provide request object only
            [serviceInstance performSelector:selector withObject:actionRequest];
        }
#pragma clang diagnostic pop
    }
}

/**
 * request.responseBlock执行时，将其从requestlist remove可能会引起内存问题
 * 因此先将request加入待remove队列，然后在几秒后，统一移除
 */
- (void)cleanupOnRequestFinish: (ADHRequest *)request {
     @try {
         request.serviceObj = nil;
         [self.requestList removeObject:request];
     } @catch (NSException *exception) {
         
     } @finally {
         
     }
}

#pragma mark -----------------   private   ----------------

//private, for ADHMetaService
- (NSArray *)registeredActionList
{
    NSMutableArray * list = [NSMutableArray array];
    for (ADHAction * action in self.actionList) {
        NSDictionary * data = @{
                                @"action" : adhvf_safestringfy(action.name),
                                @"service" : adhvf_safestringfy(action.service),
                                };
        [list addObject:data];
    }
    return list;
}

- (NSArray *)registeredServiceList
{
    NSArray * serviceList = [self.serviceList allKeys];
    serviceList = [serviceList sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull str1, NSString *  _Nonnull str2) {
        return [str1 compare:str2 options:NSCaseInsensitiveSearch];
    }];
    return serviceList;
}

@end














