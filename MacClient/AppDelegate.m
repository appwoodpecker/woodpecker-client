//
//  AppDelegate.m
//  MacClient
//
//  Created by 张小刚 on 2019/5/25.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "AppDelegate.h"
#import "MKeyChainViewController.h"
#import "MNotificationViewController.h"
#import "MNetworkViewController.h"
#import "MLogViewController.h"
#import "MSandboxViewController.h"
#import "MSocketViewController.h"

@import UserNotifications;

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTabView *tabView;

@property (nonatomic, strong) NSViewController *controller;
@property (nonatomic, strong) NSWindow * window2;


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self addPages];
//    [self test];
    [self setupNotification];
}

//- (void)test {
//    NSWindow *window = [[NSWindow alloc] init];
//    window.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskTitled;
//    window.title = @"Woodpecker";
//    MSandboxViewController *vc = [[MSandboxViewController alloc] initWithNibName:@"MSandboxViewController" bundle:nil];
////    window.releasedWhenClosed = NO;
//    window.contentViewController = vc;
//    [window makeKeyAndOrderFront:nil];
//    self.window2 = window;
//    self.controller = vc;
//}

- (void)addPages {
    NSViewController *socketVC = [[MSocketViewController alloc] initWithNibName:@"MSocketViewController" bundle:nil];
    NSTabViewItem *socket = [NSTabViewItem tabViewItemWithViewController:socketVC];
    socket.label = @"Socket";
    [self.tabView addTabViewItem:socket];
    //sandbox
    NSViewController *sandboxVC = [[MSandboxViewController alloc] initWithNibName:@"MSandboxViewController" bundle:nil];
    NSTabViewItem *sandbox = [NSTabViewItem tabViewItemWithViewController:sandboxVC];
    sandbox.label = @"Sandbox";
    [self.tabView addTabViewItem:sandbox];
    //keychain
    NSViewController *keychainVC = [[MKeyChainViewController alloc] initWithNibName:@"MKeyChainViewController" bundle:nil];
    NSTabViewItem *keychain = [NSTabViewItem tabViewItemWithViewController:keychainVC];
    keychain.label = @"Keychain";
    [self.tabView addTabViewItem:keychain];
    //notification
    NSViewController *notiVC = [[MNotificationViewController alloc] initWithNibName:@"MNotificationViewController" bundle:nil];
    NSTabViewItem *noti = [NSTabViewItem tabViewItemWithViewController:notiVC];
    noti.label = @"Notification";
    [self.tabView addTabViewItem:noti];
    //network
    NSViewController *networkVC = [[MNetworkViewController alloc] initWithNibName:@"MNetworkViewController" bundle:nil];
    NSTabViewItem *network = [NSTabViewItem tabViewItemWithViewController:networkVC];
    network.label = @"Network";
    [self.tabView addTabViewItem:network];
    //log
    NSViewController *logVC = [[MLogViewController alloc] initWithNibName:@"MLogViewController" bundle:nil];
    NSTabViewItem *logger = [NSTabViewItem tabViewItemWithViewController:logVC];
    logger.label = @"Logger";
    [self.tabView addTabViewItem:logger];
    
    
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

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark -----------------   notification   ----------------

- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"application did register remote");
}

- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did fail to register remote notifiation: %@",error);
}

/** The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
 
 用户在前台时收到此消息，并决定如何处理
 可以用系统通知框或者自定义操作（不使用系统UI，自己做其他处理）
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"will present notification");
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionBadge);
}

/** The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
 
 应用在前台，用户操作通知(open(default),dismiss,custom action)
 应用在后台运行，用户操作通知
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSLog(@"did receive notification: %@",response.actionIdentifier);
    completionHandler();
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"didReceiveNotificationResponse"];
}


@end
