//
//  ADHNotificationObserver.m
//  ADHClient
//
//  Created by 张小刚 on 2018/6/2.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHNotificationObserver.h"

#if TARGET_OS_IPHONE
@import UIKit;
#elif TARGET_OS_MAC

#endif
#import <UserNotifications/UserNotifications.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dispatch/queue.h>
#import "ADHNetworkUtility.h"
#import "ADHNotificationService.h"


@interface ADHNotificationObserver (UNUserNotificationCenterDelegateHelper)

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler API_AVAILABLE(ios(10.0),macos(10.14));

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler API_AVAILABLE(ios(10.0),macos(10.14));

@end


@interface ADHNotificationObserver (ApplicationDelegate)
#if TARGET_OS_IPHONE
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
#elif TARGET_OS_MAC
- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
#endif

@end


@implementation ADHNotificationObserver

+ (ADHNotificationObserver *)sharedObserver {
    static ADHNotificationObserver *sharedObserver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObserver = [[ADHNotificationObserver alloc] init];
    });
    return sharedObserver;
}

- (void)start {
    if(@available(iOS 10,macOS 10.14, *)) {
        [ADHNotificationObserver injectUNUserNotificationCenterDelegate];
        [ADHNotificationObserver injectApplicationDelegate];
    }
}

+ (void)injectUNUserNotificationCenterDelegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Swizzle any classes that implement one of these selectors.
        const SEL selectors[] = {
            @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:),
            @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:),
        };
        const int numSelectors = sizeof(selectors) / sizeof(SEL);
        Class *classes = NULL;
        int numClasses = objc_getClassList(NULL, 0);
        if (numClasses > 0) {
            classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (NSInteger classIndex = 0; classIndex < numClasses; ++classIndex) {
                Class class = classes[classIndex];
                
                if (class == [ADHNotificationObserver class]) {
                    continue;
                }
                // Use the runtime API rather than the methods on NSObject to avoid sending messages to
                // classes we're not interested in swizzling. Otherwise we hit +initialize on all classes.
                // NOTE: calling class_getInstanceMethod() DOES send +initialize to the class. That's why we iterate through the method list.
                unsigned int methodCount = 0;
                Method *methods = class_copyMethodList(class, &methodCount);
                BOOL matchingSelectorFound = NO;
                for (unsigned int methodIndex = 0; methodIndex < methodCount; methodIndex++) {
                    for (int selectorIndex = 0; selectorIndex < numSelectors; ++selectorIndex) {
                        if (method_getName(methods[methodIndex]) == selectors[selectorIndex]) {
                            [self injectIntoUNUserNotificationCenterDelegateClass:class];
                            matchingSelectorFound = YES;
                            break;
                        }
                    }
                    if (matchingSelectorFound) {
                        break;
                    }
                }
                free(methods);
            }
            free(classes);
        }
    });
}

+ (void)injectIntoUNUserNotificationCenterDelegateClass:(Class)cls {
     if (@available(iOS 10.0,macOS 10.14, *)) {
         [self injectUserNotificationWillPresentNotification:cls];
         [self injectUserNotificationDidReceiveNotificationResponse:cls];
     }
}

+ (void)injectUserNotificationWillPresentNotification:(Class)cls API_AVAILABLE(ios(10.0),macos(10.14)){
    if (@available(iOS 10.0,macOS 10.14, *)) {
        SEL selector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
        SEL swizzledSelector = [ADHNetworkUtility swizzledSelectorForSelector:selector];
        Protocol *protocol = @protocol(UNUserNotificationCenterDelegate);
        struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
        
        typedef void (^UserNotificationWillPresentCompletionHandler)(UNNotificationPresentationOptions);
        
        typedef void (^UserNotificationCenterWillPresentNotification)(id <UNUserNotificationCenterDelegate> slf, UNUserNotificationCenter *center, UNNotification *notification, UserNotificationWillPresentCompletionHandler completionHandler);
        
        UserNotificationCenterWillPresentNotification undefinedBlock = ^(id <UNUserNotificationCenterDelegate> slf, UNUserNotificationCenter *center, UNNotification *notification, UserNotificationWillPresentCompletionHandler completionHandler) {
            [[ADHNotificationObserver sharedObserver] userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
        };
        UserNotificationCenterWillPresentNotification implementationBlock = ^(id <UNUserNotificationCenterDelegate> slf, UNUserNotificationCenter *center, UNNotification *notification, UserNotificationWillPresentCompletionHandler completionHandler) {
            [ADHNetworkUtility sniffWithoutDuplicationForObject:center selector:selector sniffingBlock:^{
                undefinedBlock(slf,center,notification,completionHandler);
            } originalImplementationBlock:^{
                ((void(*) (id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, center, notification, completionHandler);
            }];
        };
        [ADHNetworkUtility replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
    }
}

+ (void)injectUserNotificationDidReceiveNotificationResponse:(Class)cls API_AVAILABLE(ios(10.0),macos(10.14)) {
    if (@available(iOS 10.0,macOS 10.14, *)) {
        SEL selector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
        SEL swizzledSelector = [ADHNetworkUtility swizzledSelectorForSelector:selector];
        Protocol *protocol = @protocol(UNUserNotificationCenterDelegate);
        struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
        
        typedef void(^UserNotificationDidReceiveCompletionHandler)(void);
        typedef void (^UserNotificationDidReceiveNotificationResponse)(id <UNUserNotificationCenterDelegate> slf, UNUserNotificationCenter *center, UNNotificationResponse *response, UserNotificationDidReceiveCompletionHandler completionHandler);
        
        UserNotificationDidReceiveNotificationResponse undefinedBlock = ^(id <UNUserNotificationCenterDelegate> slf, UNUserNotificationCenter *center, UNNotificationResponse *response, UserNotificationDidReceiveCompletionHandler completionHandler) {
            [[ADHNotificationObserver sharedObserver] userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
        };
        UserNotificationDidReceiveNotificationResponse implementationBlock = ^(id <UNUserNotificationCenterDelegate> slf, UNUserNotificationCenter *center, UNNotificationResponse *response, UserNotificationDidReceiveCompletionHandler completionHandler) {
            [ADHNetworkUtility sniffWithoutDuplicationForObject:center selector:selector sniffingBlock:^{
                undefinedBlock(slf,center,response,completionHandler);
            } originalImplementationBlock:^{
                ((void(*) (id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, center, response, completionHandler);
            }];
        };
        [ADHNetworkUtility replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
    }
}

- (void)doNothing {
    NSLog(@"nothing will happen");
}

+ (void)injectApplicationDelegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Swizzle any classes that implement one of these selectors.
        const SEL selectors[] = {
#if TARGET_OS_IPHONE
            @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:),
            @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:),
#elif TARGET_OS_MAC
            @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:),
#endif
        };
        const int numSelectors = sizeof(selectors) / sizeof(SEL);
        Class *classes = NULL;
        int numClasses = objc_getClassList(NULL, 0);
        if (numClasses > 0) {
            classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (NSInteger classIndex = 0; classIndex < numClasses; ++classIndex) {
                Class class = classes[classIndex];
                
                if (class == [ADHNotificationObserver class]) {
                    continue;
                }
                // Use the runtime API rather than the methods on NSObject to avoid sending messages to
                // classes we're not interested in swizzling. Otherwise we hit +initialize on all classes.
                // NOTE: calling class_getInstanceMethod() DOES send +initialize to the class. That's why we iterate through the method list.
                unsigned int methodCount = 0;
                Method *methods = class_copyMethodList(class, &methodCount);
                BOOL matchingSelectorFound = NO;
                for (unsigned int methodIndex = 0; methodIndex < methodCount; methodIndex++) {
                    for (int selectorIndex = 0; selectorIndex < numSelectors; ++selectorIndex) {
                        if (method_getName(methods[methodIndex]) == selectors[selectorIndex]) {
                            [self injectIntoApplicationDelegateClass:class];
                            matchingSelectorFound = YES;
                            break;
                        }
                    }
                    if (matchingSelectorFound) {
                        break;
                    }
                }
                free(methods);
            }
            free(classes);
        }
    });
}


+ (void)injectIntoApplicationDelegateClass: (Class)cls {
#if TARGET_OS_IPHONE
    [self injectIntoDidRegisterForRemoteNotificationsWithDeviceToken:cls];
    [self injectIntoDidReceiveFetchRemoteNotification:cls];
#elif TARGET_OS_MAC
    [self injectIntoDidRegisterForRemoteNotificationsWithDeviceToken:cls];
#endif
    
}

#if TARGET_OS_IPHONE

+ (void)injectIntoDidRegisterForRemoteNotificationsWithDeviceToken: (Class)cls {
    SEL selector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
    SEL swizzledSelector = [ADHNetworkUtility swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(UIApplicationDelegate);
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^DidRegisterDeviceTokenBlock)(id <UIApplicationDelegate> slf, UIApplication *app, NSData *deviceToken);
    DidRegisterDeviceTokenBlock undefinedBlock = ^(id <UIApplicationDelegate> slf, UIApplication *app, NSData *deviceToken){
        [[ADHNotificationObserver sharedObserver] application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    };
    DidRegisterDeviceTokenBlock implementationBlock = ^(id <UIApplicationDelegate> slf, UIApplication *app, NSData *deviceToken){
        [ADHNetworkUtility sniffWithoutDuplicationForObject:app selector:selector sniffingBlock:^{
            undefinedBlock(slf,app,deviceToken);
        } originalImplementationBlock:^{
            ((void(*) (id, SEL, id, id))objc_msgSend)(slf, swizzledSelector, app, deviceToken);
        }];
    };
    [ADHNetworkUtility replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

+ (void)injectIntoDidReceiveFetchRemoteNotification: (Class)cls {
    SEL selector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
    SEL swizzledSelector = [ADHNetworkUtility swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(UIApplicationDelegate);
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^DidReceiveRemoteFetchCompleteHandler)(UIBackgroundFetchResult);
    typedef void (^DidReceiveRemoteFetchRemoteBlock)(id <UIApplicationDelegate> slf, UIApplication *app, NSDictionary *userInfo, DidReceiveRemoteFetchCompleteHandler completeHandler);
    DidReceiveRemoteFetchRemoteBlock undefinedBlock = ^(id <UIApplicationDelegate> slf, UIApplication *app, NSDictionary *userInfo, DidReceiveRemoteFetchCompleteHandler completeHandler){
        [[ADHNotificationObserver sharedObserver] application:app didReceiveRemoteNotification:userInfo fetchCompletionHandler:completeHandler];
    };
    DidReceiveRemoteFetchRemoteBlock implementationBlock = ^(id <UIApplicationDelegate> slf, UIApplication *app, NSDictionary *userInfo, DidReceiveRemoteFetchCompleteHandler completeHandler){
        [ADHNetworkUtility sniffWithoutDuplicationForObject:app selector:selector sniffingBlock:^{
            undefinedBlock(slf,app,userInfo,completeHandler);
        } originalImplementationBlock:^{
            ((void(*) (id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, app, userInfo, completeHandler);
        }];
    };
    [ADHNetworkUtility replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[ADHNotificationService sharedService] didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[ADHNotificationService sharedService] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

#elif TARGET_OS_MAC
+ (void)injectIntoDidRegisterForRemoteNotificationsWithDeviceToken: (Class)cls {
    SEL selector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
    SEL swizzledSelector = [ADHNetworkUtility swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(NSApplicationDelegate);
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^DidRegisterDeviceTokenBlock)(id <NSApplicationDelegate> slf, NSApplication *app, NSData *deviceToken);
    DidRegisterDeviceTokenBlock undefinedBlock = ^(id <NSApplicationDelegate> slf, NSApplication *app, NSData *deviceToken){
        [[ADHNotificationObserver sharedObserver] application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    };
    DidRegisterDeviceTokenBlock implementationBlock = ^(id <NSApplicationDelegate> slf, NSApplication *app, NSData *deviceToken){
        [ADHNetworkUtility sniffWithoutDuplicationForObject:app selector:selector sniffingBlock:^{
            undefinedBlock(slf,app,deviceToken);
        } originalImplementationBlock:^{
            ((void(*) (id, SEL, id, id))objc_msgSend)(slf, swizzledSelector, app, deviceToken);
        }];
    };
    
    [ADHNetworkUtility replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[ADHNotificationService sharedService] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
#endif

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    [[ADHNotificationService sharedService] willPresentNotification:notification];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    [[ADHNotificationService sharedService] didReceiveNotificationResponse:response];
}


@end










