//
//  AppContextManager.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/19.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "AppContextManager.h"
#import "MacOrganizer.h"
#import "ConnectItem.h"

NSString *const kAppContextAppStatusUpdate = @"kAppContextAppStatusUpdate";

@interface AppContextManager ()

@property (nonatomic, strong) NSMutableArray * mContextList;
@property (nonatomic, strong) NSMutableArray * mObserverList;

@end

@implementation AppContextManager

+ (AppContextManager *)manager {
    static AppContextManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AppContextManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mContextList = [NSMutableArray array];
        self.mObserverList = [NSMutableArray array];
    }
    return self;
}

- (NSInteger)createTag {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSInteger tag = (NSInteger)interval;
    tag += arc4random() % 10000;
    return tag;
}

//有新App连接
- (void)connectorClientDidConnect: (ADHApp *)app {
    AppContext *context = [self matchContextWithApp:app];
    if(!context){
        context = [AppContext context];
        context.tag = [self createTag];
        context.deviceName = app.deviceName;
        context.appName = app.appName;
        context.bundleId = app.bundleId;
        context.visible = YES;
        context.connected = YES;
        [context setApp:app];
        [self.mContextList addObject:context];
        if(self.mContextList.count == 1){
            context.topApp = YES;
        }
        for (id<AppContextManagerObserver> observer in self.mObserverList) {
            if([observer respondsToSelector:@selector(appDidAdd:)]) {
                [observer appDidAdd:context];
            }
        }
    }else {
        context.connected = YES;
        [context setApp:app];
        for (id<AppContextManagerObserver> observer in self.mObserverList) {
            if([observer respondsToSelector:@selector(appConnectionStateUpdate:)]) {
                [observer appConnectionStateUpdate:context];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppContextAppStatusUpdate object:self userInfo:nil];
}

- (AppContext *)matchContextWithApp: (ADHApp *)app {
    AppContext * targetContext = nil;
    for (AppContext * context in self.mContextList) {
        if([context.deviceName isEqualToString:app.deviceName] && [context.bundleId isEqualToString:app.bundleId]){
            targetContext = context;
            break;
        }
    }
    return targetContext;
}

- (ADHApp *)matchAppWithContext: (AppContext *)context {
    ADHApp * targetApp = nil;
    NSArray<ADHApp *> * appList = [[MacOrganizer organizer].connector appList];
    for (ADHApp * app in appList) {
        if([context.deviceName isEqualToString:app.deviceName] && [context.bundleId isEqualToString:app.bundleId]){
            targetApp = app;
            break;
        }
    }
    return targetApp;
}

- (void)connectorClientDidDisConnect: (ADHApp *)app {
    AppContext *context = [self matchContextWithApp:app];
    if(context){
        context.connected = NO;
        [context unsetApp];
    }
    for (id<AppContextManagerObserver> observer in self.mObserverList) {
        if([observer respondsToSelector:@selector(appConnectionStateUpdate:)]) {
            [observer appConnectionStateUpdate:context];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppContextAppStatusUpdate object:self userInfo:nil];
}

- (void)addObsever: (id<AppContextManagerObserver>)observer {
    [self.mObserverList addObject:observer];
}

- (NSArray<AppContext *> *)contextList {
    return self.mContextList;
}

- (NSArray<AppContext *> *)visibleContextList {
    NSMutableArray *visibleList = [NSMutableArray array];
    for (AppContext *context in self.mContextList) {
        if(context.isVisible) {
            [visibleList addObject:context];
        }
    }
    return visibleList;
}

- (void)setTopContext: (AppContext *)topContext {
    for (NSInteger i=0;i<self.mContextList.count;i++) {
        AppContext *context = self.mContextList[i];
        if(context == topContext) {
            context.topApp = YES;
        }else {
            context.topApp = NO;
        }
    }
    for (id<AppContextManagerObserver> observer in self.mObserverList) {
        if([observer respondsToSelector:@selector(topContextUpdate:)]) {
            [observer topContextUpdate:topContext];
        }
    }
}

- (AppContext *)topContext {
    AppContext *targetContext = nil;
    for (NSInteger i=0;i<self.mContextList.count;i++) {
        AppContext *context = self.mContextList[i];
        if(context.isTopApp) {
            targetContext = context;
            break;
        }
    }
    return targetContext;
}

- (AppContext *)contextWithTag: (NSInteger)tag {
    AppContext *targetContext = nil;
    for (AppContext *context in self.mContextList) {
        if(context.tag == tag) {
            targetContext = context;
            break;
        }
    }
    return targetContext;
}

- (AppContext *)contextWithApiClient: (ADHApiClient *)apiClient {
    AppContext *targetContext = nil;
    for (AppContext *context in self.mContextList) {
        if(context.apiClient == apiClient) {
            targetContext = context;
            break;
        }
    }
    return targetContext;
}


#pragma mark -----------------   remove app   ----------------

- (void)removeApp: (AppContext *)context {
    [self removeAppView:context];
    if([context isConnected]) {
        __weak typeof(self) wself = self;
        //tell app that it will closed, and do not auto-connect.
        [[context getApiClient] requestWithService:@"adh.appinfo" action:@"closeapp" onSuccess:^(NSDictionary *body, NSData *payload) {
            [wself removeAppConnection:context];
        } onFailed:^(NSError *error) {
            [wself removeAppConnection:context];
        }];
    }else {
        [self removeAppConnection:context];
    }
}

- (void)removeAppView: (AppContext *)context {
    context.visible = NO;
    //remove page
    for (id<AppContextManagerObserver> observer in self.mObserverList) {
        if([observer respondsToSelector:@selector(appWillRemove:)]) {
            [observer appWillRemove:context];
        }
    }
}

- (void)removeAppConnection: (AppContext *)context {
    //close socket if needed
    MacConnector * connector = [[MacOrganizer organizer] connector];
    [connector disConnectApp:context.app];
    //remove from list
    [self.mContextList removeObject:context];
}


@end
