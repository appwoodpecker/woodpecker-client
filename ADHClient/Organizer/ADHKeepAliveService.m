//
//  ADHKeepAliveService.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/10/13.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ADHKeepAliveService.h"
#import "ADHAppConnector.h"
#if TARGET_OS_IPHONE
#import "ADHOrganizerPrivate.h"
#elif TARGET_OS_MAC
#import "ADHMacClientOrganizerPrivate.h"
#endif

//测试大概10s左右会自动断开链接，这里设置心跳为5s
static NSTimeInterval const kPingSendInterval = 5;

@interface ADHKeepAliveService ()

@property (nonatomic, strong) NSTimer *pingTimer;

@end

@implementation ADHKeepAliveService

+ (ADHKeepAliveService *)service {
    static dispatch_once_t onceToken;
    static ADHKeepAliveService *sharedService = nil;
    dispatch_once(&onceToken, ^{
        sharedService = [[ADHKeepAliveService alloc] init];
    });
    return sharedService;
}

- (void)start {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusUpdate:) name:kADHConnectorConnectStatusUpdate object:nil];
}

- (void)onConnectionStatusUpdate: (NSNotification *)noti {
    ADHAppConnector *connector = nil;
    #if TARGET_OS_IPHONE
    connector = [[ADHOrganizer sharedOrganizer] connector];
    #elif TARGET_OS_MAC
    connector = [[ADHMacClientOrganizer sharedOrganizer] connector];
    #endif
    if([connector isSocketConnected]) {
        [self pingStart];
    }else {
        [self pingStop];
    }
}

- (void)pingStart {
    if(!self.pingTimer) {
        self.pingTimer = [NSTimer timerWithTimeInterval:kPingSendInterval target:self selector:@selector(ping) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.pingTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)pingStop {
    if(self.pingTimer) {
        [self.pingTimer invalidate];
        self.pingTimer = nil;
    }
}

- (void)ping {
//    NSLog(@"ping....");
    [self pingStop];
    __weak typeof(self) wself = self;
    [[ADHApiClient sharedApi] requestWithService:@"adh.default" action:@"p" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself pingStart];
    } onFailed:^(NSError *error) {
       //connection may loss
    }];
}

@end
