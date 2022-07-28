//
//  DHObject.m
//  Flux
//
//  Created by 张小刚 on 16/4/3.
//  Copyright © 2016年 lyeah company. All rights reserved.
//

#import "NSObject+AsyncNotify.h"
#import <objc/runtime.h>

static const char * kADHNotificationInfo = "adhNotificationInfo";

//异步调用时如何 传递 notification 对象
@interface ADHNotificationInfo : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * selectorName;
@property (nonatomic, assign) BOOL async;
@property (nonatomic, assign) NSInteger asyncCallTimes;
@property (nonatomic, strong) NSNotification * asyncNotification;

@end

@implementation ADHNotificationInfo


@end

@implementation NSObject (ADHAsyncNotify)

- (NSArray *)notificationInfoList
{
    NSArray * infoList = objc_getAssociatedObject(self, kADHNotificationInfo);
    if(!infoList){
        infoList = [NSMutableArray array];
    }
    return infoList;
}

- (void)setNotificationInfoForName:(NSString *)aName selectorName:(NSString *) selectorName async:(BOOL) async
{
    ADHNotificationInfo * info = [self notificationInfoForName:aName];
    info.name = aName;
    info.selectorName = selectorName;
    info.async = async;
    [self resetAsyncCallRecordForName:aName];
}

- (void)resetAsyncCallRecordForName: (NSString *)notificationName
{
    ADHNotificationInfo * info = [self notificationInfoForName:notificationName];
    info.asyncCallTimes = 0;
    info.asyncNotification = nil;
}

- (ADHNotificationInfo *)notificationInfoForName: (NSString *)notificationName
{
    ADHNotificationInfo * info = nil;
    for (ADHNotificationInfo * aInfo in self.notificationInfoList) {
        if([aInfo.name isEqualToString:notificationName]){
            info = aInfo;
            break;
        }
    }
    if(!info){
        info = [[ADHNotificationInfo alloc] init];
        info.name = notificationName;
        info.async = NO;
        NSMutableArray * mutableList = [[self notificationInfoList] mutableCopy];
        [mutableList addObject:info];
        objc_setAssociatedObject(self, kADHNotificationInfo, mutableList, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return info;
}

- (void)adhnotificationcenter_handler: (NSNotification *)notification
{
    NSString * notificationName = notification.name;
    ADHNotificationInfo * info = [self notificationInfoForName:notificationName];
    NSString * selectorName = info.selectorName;
    BOOL async = info.async;
    SEL selector = NSSelectorFromString(selectorName);
    if(!async){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if([selectorName hasSuffix:@":"]){
            [self performSelector:selector withObject:notification];
        }else{
            [self performSelector:selector];
        }
#pragma clang diagnostic pop
    }else{
        info.asyncNotification = notification;
        info.asyncCallTimes++;
    }
}

- (void)checkNotificationFired: (NSString *)aName
{
    ADHNotificationInfo * info = [self notificationInfoForName:aName];
    if(info.async && info.asyncCallTimes > 0){
        //call target selector
        NSString * selectorName = info.selectorName;
        SEL selector = NSSelectorFromString(selectorName);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if([selectorName hasSuffix:@":"]){
            [self performSelector:selector withObject:info.asyncNotification];
        }else{
            [self performSelector:selector];
        }
#pragma clang diagnostic pop
        [self resetAsyncCallRecordForName:aName];
    }
}


@end


















