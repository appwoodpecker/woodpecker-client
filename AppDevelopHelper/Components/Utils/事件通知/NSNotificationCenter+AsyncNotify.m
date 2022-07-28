//
//  DHNotificationCenter.m
//  Flux
//
//  Created by 张小刚 on 16/4/3.
//  Copyright © 2016年 lyeah company. All rights reserved.
//

#import "NSNotificationCenter+AsyncNotify.h"

@implementation NSNotificationCenter (ADHAsyncNotify)

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSString *)aName object:(nullable id)anObject async: (BOOL)async
{
    NSObject * dhObserver = observer;
    NSString * selectorName = NSStringFromSelector(aSelector);
    [dhObserver setNotificationInfoForName:aName selectorName:selectorName async:async];
    //call common handler;
    SEL proxySelector = NSSelectorFromString(@"adhnotificationcenter_handler:");
    [self addObserver:observer selector:proxySelector name:aName object:anObject];
}

@end
