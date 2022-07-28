//
//  MNotificationViewController.m
//  MacClient
//
//  Created by 张小刚 on 2019/5/26.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "MNotificationViewController.h"
@import UserNotifications;
@import CoreLocation;

@interface MNotificationViewController ()


@end

@implementation MNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)registerAPNSButtonClicked:(id)sender {
    [[NSApplication sharedApplication] registerForRemoteNotifications];
    
}

- (IBAction)requestAuthButtonClicked:(id)sender {
    UNUserNotificationCenter * notiCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notiCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(granted){
            NSLog(@"granted");
        }else{
            NSLog(@"not granted. error: %@",error);
        }
    }];
}

- (IBAction)addLocalButtonClicked:(id)sender {
    UNUserNotificationCenter * notiCenter = [UNUserNotificationCenter currentNotificationCenter];
    NSString * identifier = [NSString stringWithFormat:@"%d",arc4random()];
    NSString * requestIdentifier = [NSString stringWithFormat:@"request%@",identifier];
    UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
    content.badge = [NSNumber numberWithInteger:arc4random()%10];
    content.body = [NSString stringWithFormat:@"This is content %@",identifier];
    content.title = [NSString stringWithFormat:@"This is title %@",identifier];
    content.subtitle = [NSString stringWithFormat:@"This is subtitle %@",identifier];
    content.userInfo = @{
                         @"identifier" : identifier,
                         };
    content.categoryIdentifier = @"actionCategory";
    //至少60以上(每分钟repeat一次)
    UNTimeIntervalNotificationTrigger * trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
    [notiCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"add local notification error: %@",error);
        }else{
            NSLog(@"add local notification success");
        }
    }];
}

- (IBAction)calendarButtonClicked:(id)sender {
    UNUserNotificationCenter * notiCenter = [UNUserNotificationCenter currentNotificationCenter];
    NSString * identifier = [NSString stringWithFormat:@"%d",arc4random()];
    NSString * requestIdentifier = [NSString stringWithFormat:@"request%@",identifier];
    UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
    content.badge = [NSNumber numberWithInteger:arc4random()%10];
    content.body = [NSString stringWithFormat:@"This is calendar content %@",identifier];
    content.title = [NSString stringWithFormat:@"This is calendar title %@",identifier];
    content.subtitle = [NSString stringWithFormat:@"This is calendar subtitle %@",identifier];
    content.userInfo = @{
                         @"identifier" : identifier,
                         };
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.calendar = [NSCalendar currentCalendar];
    components.timeZone = [NSTimeZone systemTimeZone];
    //    components.minute = 0;
    components.second = 1;
    UNCalendarNotificationTrigger * trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
    [notiCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"add local notification error: %@",error);
        }else{
            NSLog(@"add local notification success");
        }
    }];
}

- (IBAction)clearButtonClicked:(id)sender {
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}


@end
