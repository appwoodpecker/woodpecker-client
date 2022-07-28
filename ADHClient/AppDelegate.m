//
//  AppDelegate.m
//  ADHClient
//
//  Created by 张小刚 on 2017/10/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "AppDelegate.h"
#import "TestViewController.h"
@import UserNotifications;
@import UserNotificationsUI;


@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /*
    //host name
    [[NSUserDefaults standardUserDefaults] setObject:@"李雷" forKey:kADHHostName];
    //host address
    [[NSUserDefaults standardUserDefaults] setObject:@"192.168.1.101:9999" forKey:kADHHostAddress];
    //disable auto connect
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kADHAutoConnectEnabled];
    //not show setting page
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kADHShowOnConnectionFailed];
     //ui gesture disable
     [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kADHUIGestureEnabled];
    */
    UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor whiteColor];
    TestViewController * testVC = [[TestViewController alloc] init];
    UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:testVC];
    window.rootViewController = nvc;
    [window makeKeyAndVisible];
    self.window = window;
    [self setupNotification];
    [self otherSetting];
    return YES;
}

- (void)setupNotification {
    UNUserNotificationCenter * notiCenter = [UNUserNotificationCenter currentNotificationCenter];
    notiCenter.delegate = self;
    
    UNNotificationAction *openAction = [UNNotificationAction actionWithIdentifier:UNNotificationDefaultActionIdentifier title:@"Okay" options:0];
    UNNotificationAction *customAction = [UNNotificationAction actionWithIdentifier:@"customaction" title:@"Do Something" options:0];
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"actionCategory" actions:@[openAction,customAction] intentIdentifiers:@[] options:0];
    NSSet *set = [NSSet setWithObjects:category, nil];
    [notiCenter setNotificationCategories:set];
}

- (void)otherSetting {
//    [FIRApp configure];
//    [[FIRRemoteConfig remoteConfig] setDefaultsFromPlistFileName:@"RemoteConfigDefaults"];
}

#pragma mark -----------------   notification   ----------------

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    [[ADHNotificationService sharedService] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"did fail to register remote notifiation: %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
//    [[ADHNotificationService sharedService] didReceiveRemoteNotification:userInfo];
    NSLog(@"%@",userInfo);
}

/** The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
 
 用户在前台时收到此消息，并决定如何处理
 可以用系统通知框或者自定义操作（不使用系统UI，自己做其他处理）
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSLog(@"will present notification");
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionBadge);
}

/** The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
 
 应用在前台，用户操作通知(open(default),dismiss,custom action)
 应用在后台运行，用户操作通知
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler
{
    NSLog(@"did receive notification: %@",response.actionIdentifier);
    completionHandler();
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"didReceiveNotificationResponse"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end













