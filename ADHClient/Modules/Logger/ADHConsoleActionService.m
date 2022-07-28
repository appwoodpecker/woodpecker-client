//
//  ADHLogConsoleService.m
//  ADHClient
//
//  Created by 张小刚 on 2018/6/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHConsoleActionService.h"
#import "ADHConsoleObserver.h"

static NSInteger const kADHConsoleActionServiceMaxPackageItemCount = 100;

@interface ADHConsoleActionService ()

//接收队列
@property (nonatomic, strong) NSMutableArray<NSString *> * messages;
//发送队列
@property (nonatomic, strong) NSMutableArray<NSString *> * sendingMessages;

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_queue_t sendQueue;

@end

@implementation ADHConsoleActionService

+ (NSString *)serviceName {
    return @"adh.console";
}

+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"start" : NSStringFromSelector(@selector(onRequestStart:)),
             @"stop" : NSStringFromSelector(@selector(onRequestStop:)),
             };
}

- (void)onServiceInit {
    [super onServiceInit];
    self.messages = [NSMutableArray array];
    self.sendingMessages = [NSMutableArray array];
    self.queue = dispatch_queue_create("studio.lifebetter.service.logger", DISPATCH_QUEUE_SERIAL);
    self.sendQueue = dispatch_queue_create("studio.lifebetter.service.loggerpush", DISPATCH_QUEUE_SERIAL);
    [[ADHConsoleObserver sharedObserver] setActionService:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWorkStateUpdate) name:kADHOrganizerWorkStatusUpdate object:nil];
}

- (void)onRequestStart: (ADHRequest *)request {
    [[ADHConsoleObserver sharedObserver] start];
    [request finish];
}

- (void)onRequestStop: (ADHRequest *)request {
    [[ADHConsoleObserver sharedObserver] stop];
    [self performInReceiveQueue:^{
        [self.messages removeAllObjects];
    }];
    [self performInSendQueue:^{
        [self.sendingMessages removeAllObjects];
    }];
    [request finish];
}

- (void)performInReceiveQueue:(void (^)(void))block {
    dispatch_async(self.queue, block);
}

- (void)performInSendQueue:(void (^)(void))block {
    dispatch_async(self.sendQueue, block);
}

- (void)onReceiveNewLog: (NSString *)content {
    __weak typeof(self) wself = self;
    [self performInReceiveQueue:^{
        [wself.messages addObject:content];
        [wself tryUploadLog];
    }];
}

- (void)tryUploadLog {
#if TARGET_OS_IPHONE
    if(![[ADHOrganizer sharedOrganizer] isWorking]) return;
#elif TARGET_OS_MAC
    if(![[ADHMacClientOrganizer sharedOrganizer] isWorking]) return;
#endif
    __weak typeof(self) wself = self;
    [self performInSendQueue:^{
        //从receive队列取数据，添加到发送队列一起发出
        NSInteger count = wself.sendingMessages.count;
        NSInteger space = kADHConsoleActionServiceMaxPackageItemCount - count;
        if(space > 0) {
            if(wself.messages.count > 0) {
                NSInteger readCount = MIN(wself.messages.count,space);
                NSArray<NSString *> *sentedMessaegs = [wself.messages subarrayWithRange:NSMakeRange(0, readCount)];
                [wself.sendingMessages addObjectsFromArray:sentedMessaegs];
                
                //remove sented
                [wself performInReceiveQueue:^{
                    [wself.messages removeObjectsInArray:sentedMessaegs];
                }];
            }
        }
        [self pushLog];
    }];
}

- (void)pushLog {
    if(self.sendingMessages.count == 0) return;
    __weak typeof(self) wself = self;
    NSDictionary *body = @{
                           @"list" : self.sendingMessages,
                           };
    [[ADHApiClient sharedApi] requestWithService:@"adh.logger" action:@"console" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself performInSendQueue:^{
            [wself.sendingMessages removeAllObjects];
            [wself tryUploadLog];
        }];
    } onFailed:^(NSError *error) {
        [wself tryUploadLog];
    }];
}

- (void)onAppWorkStateUpdate {
    [self tryUploadLog];
}

@end












