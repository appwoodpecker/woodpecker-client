
//
//  AppContext.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/18.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "AppContext.h"
#import "MacDefaultActionService.h"
#import "NetworkActionService.h"
#import "LogActionService.h"
#import "NotificationActionService.h"
#import "WebActionService.h"
#import "FileBrowserActionService.h"

@interface AppContext ()

@property (nonatomic, strong) ADHApiClient *mApiClient;
@property (nonatomic, strong) ADHProtocol *mProtocol;
@property (nonatomic, strong) ADHDispatcher *mDispatcher;
@property (nonatomic, weak) ADHApp *mApp;

@end

@implementation AppContext

+ (AppContext *)context {
    AppContext *context = [[AppContext alloc] init];
    return context;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ADHApiClient *client = [[ADHApiClient alloc] init];
        ADHProtocol *protocol = [[ADHProtocol alloc] init];
        ADHDispatcher *dispatcher = [[ADHDispatcher alloc] init];
        [client setProtocol:protocol];
        [client setDispatcher:dispatcher];
        _mApiClient = client;
        _mProtocol = protocol;
        _mDispatcher = dispatcher;
    }
    [self registerService:_mDispatcher];
    return self;
}

- (void)registerService: (ADHDispatcher *)dispatcher {
    [dispatcher registerService:[MacDefaultActionService class]];
    [dispatcher registerService:[NetworkActionService class]];
    [dispatcher registerService:[LogActionService class]];
    [dispatcher registerService:[NotificationActionService class]];
    [dispatcher registerService:[WebActionService class]];
    [dispatcher registerService:[FileBrowserActionService class]];
}

- (ADHApiClient *)apiClient {
    return self.mApiClient;
}

- (ADHApiClient *)getApiClient {
    return self.mApiClient;
}

- (ADHProtocol *)protocol {
    return self.mProtocol;
}

- (void)setApp: (ADHApp *)app {
    [self.mProtocol setSocket:app.socket];
    self.mApp = app;
}

- (void)unsetApp {
    [self.mProtocol setSocket:nil];
    self.mApp = nil;
}

- (ADHApp *)app {
    return self.mApp;
}

@end
