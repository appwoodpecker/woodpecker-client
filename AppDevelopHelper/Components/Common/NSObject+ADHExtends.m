//
//  NSObject+ADHExtends.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/24.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "NSObject+ADHExtends.h"
#import "WeakProxyObject.h"
#import "AppContextManager.h"
#import <objc/runtime.h>

static const char * kADHAppContext = "ADHAppContext";

@implementation NSObject (ADHExtends)

- (void)setContext: (AppContext *)context {
    WeakProxyObject *proxy = [[WeakProxyObject alloc] initWithObject:context];
    objc_setAssociatedObject(self, kADHAppContext, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AppContext *)context {
    WeakProxyObject *proxy = objc_getAssociatedObject(self, kADHAppContext);
    return proxy.object;
}

- (ADHApiClient *)apiClient {
    AppContext *context = [self context];
    return context.apiClient;
}

@end
