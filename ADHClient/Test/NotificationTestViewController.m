//
//  NotificationTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/2/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationTestViewController.h"
@import UserNotifications;
@import UserNotificationsUI;
@import CoreLocation;
#import "ADHNotificationService.h"

@interface NotificationTestViewController ()

@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation NotificationTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
}

/**
 授权通知提醒后，才可以注册remote notification
 */
- (IBAction)requestAuthButtonPressed:(id)sender {
    UNUserNotificationCenter * notiCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notiCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(granted){
            NSLog(@"granted");
        }else{
            NSLog(@"not granted. error: %@",error);
        }
    }];
}

- (IBAction)registerButtonPressed:(id)sender {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (IBAction)scheduleLocalButtonPressed:(id)sender {
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

- (IBAction)calendarTriggerButtonPressed:(id)sender {
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

- (void)testDateComponents
{
    NSDateComponents * components = [[NSDateComponents alloc] init];
    NSLog(@"%@",components);
}

- (IBAction)locationTriggerButtonPressed:(id)sender {
    UNUserNotificationCenter * notiCenter = [UNUserNotificationCenter currentNotificationCenter];
    NSString * identifier = [NSString stringWithFormat:@"%d",arc4random()];
    NSString * requestIdentifier = [NSString stringWithFormat:@"request%@",identifier];
    UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
    content.badge = [NSNumber numberWithInteger:arc4random()%10];
    content.body = [NSString stringWithFormat:@"This is location content %@",identifier];
    content.title = [NSString stringWithFormat:@"This is location title %@",identifier];
    content.subtitle = [NSString stringWithFormat:@"This is location subtitle %@",identifier];
    content.userInfo = @{
                         @"identifier" : identifier,
                         };
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = 111.85694444444445;
    coordinate.latitude = 34.466388888888886;
    CLCircularRegion * region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:3 identifier:[NSString stringWithFormat:@"regionId%d",arc4random()]];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    UNLocationNotificationTrigger * trigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
    UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
    [notiCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"add local notification error: %@",error);
        }else{
            NSLog(@"add local notification success");
        }
    }];
}

- (IBAction)clearLocalButtonPressed:(id)sender {
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}

- (IBAction)locationAuthButtonPressed:(id)sender {
    [self.locationManager requestAlwaysAuthorization];
}

//支持iOS10之前的UILocalNotification 和 APNS
- (IBAction)localNotificationButtonPressed:(id)sender {
    /*
    fireDate
    timeZone
    repeatInterval
    repeatCalendar
    region
    regionTriggersOnce
    alertBody
    hasAction
    alertAction
    alertLaunchImage
    alertTitle
    soundName
    applicationIconBadgeNumber
    userInfo
    category
    */
    [self addIntervalLocalNotification];
}

- (IBAction)regionLocalNotificationButtonPressed:(id)sender {
    [self addRegionLocalNotification];
}

- (void)addIntervalLocalNotification {
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    noti.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    noti.repeatInterval = NSCalendarUnitWeekday;
    NSString *identifier = [NSString stringWithFormat:@"%d",arc4random()];
    noti.alertBody = [NSString stringWithFormat:@"%@ %@",@"This is alert body",identifier];
    noti.hasAction = YES;
    noti.alertAction = [NSString stringWithFormat:@"%@ %@",@"This is alert Action",identifier];
    noti.alertTitle = [NSString stringWithFormat:@"%@ %@",@"This is alert title",identifier];
    noti.soundName = UILocalNotificationDefaultSoundName;
    noti.applicationIconBadgeNumber = 3;
    noti.userInfo = @{
                      [NSString stringWithFormat:@"%@ %@",@"key",identifier] : [NSString stringWithFormat:@"%@ %@",@"value",identifier],
                      };
    noti.category = @"actionCategory";
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
}

- (void)addRegionLocalNotification {
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    NSString *identifier = [NSString stringWithFormat:@"%d",arc4random()];
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = 111.85694444444445;
    coordinate.latitude = 34.466388888888886;
    CLCircularRegion * region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:3 identifier:[NSString stringWithFormat:@"regionId%@",identifier]];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    noti.region = region;
    noti.alertBody = [NSString stringWithFormat:@"%@ %@",@"This is alert body",identifier];
    noti.hasAction = YES;
    noti.alertAction = [NSString stringWithFormat:@"%@ %@",@"This is alert Action",identifier];
    noti.alertTitle = [NSString stringWithFormat:@"%@ %@",@"This is alert title",identifier];
    noti.soundName = UILocalNotificationDefaultSoundName;
    noti.applicationIconBadgeNumber = 3;
    noti.userInfo = @{
                      [NSString stringWithFormat:@"%@ %@",@"key",identifier] : [NSString stringWithFormat:@"%@ %@",@"value",identifier],
                      };
    noti.category = @"actionCategory";
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
