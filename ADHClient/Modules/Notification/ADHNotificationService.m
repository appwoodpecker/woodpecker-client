//
//  ADHNotificationService.m
//  ADHClient
//
//  Created by 张小刚 on 2018/2/27.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHNotificationService.h"
#import "ADHNotificationItem.h"
#import "UNLegacyNotificationTrigger.h"

@import CoreLocation;

@interface ADHNotificationService ()

@property (nonatomic, strong) NSMutableArray *receivedNotifications;
@property (nonatomic, strong) NSMutableArray *sendingNotifications;
@property (nonatomic, strong) dispatch_queue_t sendQueue;

@end

@implementation ADHNotificationService

+ (ADHNotificationService *)sharedService
{
    static ADHNotificationService *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[ADHNotificationService alloc] init];
    });
    return sharedService;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.receivedNotifications = [NSMutableArray array];
        self.sendingNotifications = [NSMutableArray array];
        self.sendQueue = dispatch_queue_create("studio.lifebetter.service.notification", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWorkStateUpdate) name:kADHOrganizerWorkStatusUpdate object:nil];
    }
    return self;
}

- (void)willPresentNotification: (UNNotification*)notification 
API_AVAILABLE(ios(10.0),macos(10.14)){
    if (@available(iOS 10.0, macOS 10.14, *)) {
        UNNotificationRequest * request = notification.request;
        ADHNotificationItem * item = [self itemWithRequest:request];
        item.source = @"willPresentNotification:";
        item.fireTimeinterval = [notification.date timeIntervalSince1970];
        [self didReceiveNotificationItem:item];
    }
}

- (void)didReceiveNotificationResponse: (UNNotificationResponse*)response
API_AVAILABLE(ios(10.0),macos(10.14)) {
    if (@available(iOS 10.0,macOS 10.14, *)) {
        //actionIdentifier + notification
        UNNotification * notification = response.notification;
        UNNotificationRequest * request = notification.request;
        ADHNotificationItem * item = [self itemWithRequest:request];
        item.source = @"didReceiveNotificationResponse:";
        item.fireTimeinterval = [notification.date timeIntervalSince1970];
        item.actionIdentifier = response.actionIdentifier;
        [self didReceiveNotificationItem:item];
    }
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    self.apsToken = token;
}

/**
 在前台时willPresentNotification 和 didReceiveRemoteNotification:fetchCompletionHandler都会被调用
 在后台仅didReceiveRemoteNotification:fetchCompletionHandler会调用
 因此仅处理在后台情况，避免重复
 */
- (void)didReceiveRemoteNotification: (NSDictionary *)userInfo
{
#if TARGET_OS_IPHONE
    [self performInMainThread:^{
        UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
        if(appState == UIApplicationStateBackground) {
            ADHNotificationItem * item = [self itemWithRemoteUserInfo:userInfo];
            item.fireTimeinterval = [[NSDate date] timeIntervalSince1970];
            item.source = @"didReceiveRemoteNotification:fetchCompletionHandler:";
            [self didReceiveNotificationItem:item];
        }
    }];
#elif TARGET_OS_MAC
    
#endif
}

- (void)performInMainThread: (void (^)(void))block {
    if([[NSThread currentThread] isMainThread]) {
        if(block){
            block();
        }
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(block){
                block();
            }
        });
    }
}

- (void)didReceiveNotificationItem: (ADHNotificationItem *)item
{
    [self.receivedNotifications addObject:item];
    [self uploadNotificationRequest];
}

- (void)uploadNotificationRequest {
#if TARGET_OS_IPHONE
    if(![[ADHOrganizer sharedOrganizer] isWorking]) {
        return;
    }
#elif TARGET_OS_MAC
    if(![[ADHMacClientOrganizer sharedOrganizer] isWorking]) {
        return;
    }
#endif
    if(self.receivedNotifications.count == 0 && self.sendingNotifications.count == 0) return;
    __weak typeof(self) wself = self;
    dispatch_async(self.sendQueue, ^{
        NSMutableArray *dataList = [NSMutableArray array];
        if(self.receivedNotifications.count > 0) {
            //将接收区内容添加到发送区
            [self.sendingNotifications addObjectsFromArray:self.receivedNotifications];
            [self.receivedNotifications removeAllObjects];
        }
        for (ADHNotificationItem *item in self.sendingNotifications) {
            NSDictionary * data = [item dicPresentation];
            [dataList addObject:data];
        }
        NSDictionary * body = @{
                                @"list" : dataList,
                                };
        [[ADHApiClient sharedApi] requestWithService:@"adh.notification" action:@"notificationReceived" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
            [wself.sendingNotifications removeAllObjects];
        } onFailed:^(NSError *error) {
            
        }];
    });
}

/**
 https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html#//apple_ref/doc/uid/TP40008194-CH17-SW1
 */
- (ADHNotificationItem *)itemWithRemoteUserInfo: (NSDictionary *)userInfo {
    ADHNotificationItem * item = [[ADHNotificationItem alloc] init];
    NSDictionary *aps = userInfo[@"aps"];
    id alert = aps[@"alert"];
    NSString * body = nil;
    NSString * title = nil;
    NSString * launchImageName = nil;
    if([alert isKindOfClass:[NSDictionary class]]) {
        body = adhvf_safestringfy(alert[@"body"]);
        title = adhvf_safestringfy(alert[@"title"]);
        launchImageName = adhvf_safestringfy(alert[@"launch-image"]);
    }else {
        body = alert;
    }
    NSString *sound = adhvf_safestringfy(aps[@"sound"]);
    NSNumber *badge = aps[@"badge"] ;
    NSString *category = adhvf_safestringfy(alert[@"category"]);
    item.body = body;
    item.title = title;
    if(badge) {
        item.badge = [NSString stringWithFormat:@"%@",badge];
    }else {
        item.badge = adhvf_const_emptystr();
    }
    item.sound = sound;
    item.launchImageName = launchImageName;
    item.userInfo = userInfo;
    item.categoryIdentifier = category;
    item.userInfo = userInfo;
    item.triggerType = ADHNotificationTriggerTypePush;
    
    return item;
}

- (ADHNotificationItem *)itemWithRequest: (UNNotificationRequest *)request
API_AVAILABLE(ios(10.0),macos(10.14)){
    if (@available(iOS 10.0,macOS 10.14, *)) {
        ADHNotificationItem * item = [[ADHNotificationItem alloc] init];
        UNNotificationContent * content = request.content;
        item.identifier = request.identifier;
        item.body = content.body;
        item.title = content.title;
        item.subtitle = content.subtitle;
        if(content.badge) {
            item.badge = [NSString stringWithFormat:@"%@",content.badge];
        }
#if TARGET_OS_IPHONE
        item.launchImageName = content.launchImageName;
#endif
        item.userInfo = content.userInfo;
        item.categoryIdentifier = content.categoryIdentifier;
        if(content.attachments){
            NSMutableArray * attachments = [NSMutableArray array];
            for (UNNotificationAttachment * attachment in content.attachments) {
                NSDictionary * data = [self readbleTextFromAttachment:attachment];
                [attachments addObject:data];
            }
            item.attachments = attachments;
        }
        UNNotificationTrigger*  trigger = request.trigger;
        ADHNotificationTriggerType triggerType = ADHNotificationTriggerTypeNone;
        NSString * triggerDetail = nil;
        BOOL triggerRepeat = NO;
        NSTimeInterval nextTriggerTimeinterval = 0;
        if([trigger isKindOfClass:[UNTimeIntervalNotificationTrigger class]]){
            //倒计时
            UNTimeIntervalNotificationTrigger * intervalTrigger = (UNTimeIntervalNotificationTrigger *)trigger;
            triggerType = ADHNotificationTriggerTypeTimeInterval;
            triggerDetail = [NSString stringWithFormat:@"%.f seconds",intervalTrigger.timeInterval];
            triggerRepeat = intervalTrigger.repeats;
            nextTriggerTimeinterval = [[intervalTrigger nextTriggerDate] timeIntervalSince1970];
        }else if([trigger isKindOfClass:[UNCalendarNotificationTrigger class]]){
            //日历
            UNCalendarNotificationTrigger * calendarTrigger = (UNCalendarNotificationTrigger *)trigger;
            triggerType = ADHNotificationTriggerTypeCalendar;
            triggerDetail = [self readableTextFromDateComponents:calendarTrigger.dateComponents];
            triggerDetail = [NSString stringWithFormat:@"%@",triggerDetail];
            triggerRepeat = calendarTrigger.repeats;
            nextTriggerTimeinterval = [[calendarTrigger nextTriggerDate] timeIntervalSince1970];
        }
        
#if TARGET_OS_IPHONE
        else if([trigger isKindOfClass:[UNLocationNotificationTrigger class]]){
            //位置
            UNLocationNotificationTrigger * locationTrigger = (UNLocationNotificationTrigger *)trigger;
            triggerType = ADHNotificationTriggerTypeLocation;
            triggerDetail = [self readbleTextFromCLRegion:locationTrigger.region];
            triggerDetail = [NSString stringWithFormat:@"%@",triggerDetail];
            triggerRepeat = locationTrigger.repeats;
        }
#elif TARGET_OS_MAC
        
#endif
        else if([trigger isKindOfClass:[UNPushNotificationTrigger class]]){
            //Push
            triggerType = ADHNotificationTriggerTypePush;
            triggerDetail = @"Remote Push";
        }else if([trigger isKindOfClass:[UNLegacyNotificationTrigger class]]) {
            //UILocalNotification（非region类型）
            UNLegacyNotificationTrigger *legacyTrigger = (UNLegacyNotificationTrigger *)trigger;
            triggerType = ADHNotificationTriggerTypeLegacyCalendar;
            triggerDetail = [self readbleTextFromCalendarUnit:legacyTrigger.repeatInterval calendar:legacyTrigger.repeatCalendar];
            triggerDetail = [NSString stringWithFormat:@"%@",triggerDetail];
            triggerRepeat = (legacyTrigger.repeatInterval > 0);
            nextTriggerTimeinterval = [legacyTrigger.date timeIntervalSince1970];
        }
        item.triggerType = triggerType;
        item.triggerRepeat = triggerRepeat;
        item.triggerDetail = triggerDetail;
        item.nextTriggerTimeinterval = nextTriggerTimeinterval;
        return item;
    }else {
        return nil;
    }
}

/**
 NSCalendarUnit -> Readble String
 */
- (NSString *)readbleTextFromCalendarUnit: (NSCalendarUnit)calendarUnit calendar: (NSCalendar *)calendar {
    NSMutableArray * contents = [NSMutableArray array];
    NSString *unit = nil;
    if(calendarUnit > 0) {
        switch (calendarUnit) {
            case NSCalendarUnitYear:
                unit = @"Year";
                break;
            case NSCalendarUnitMonth:
                unit = @"Month";
                break;
            case NSCalendarUnitDay:
                unit = @"Day";
                break;
            case NSCalendarUnitHour:
                unit = @"Hour";
                break;
            case NSCalendarUnitWeekday:
                unit = @"Week";
                break;
            default:
                unit = [NSString stringWithFormat:@"%lu",(unsigned long)calendarUnit];
                break;
        }
        if(unit) {
            [contents addObject:[NSString stringWithFormat:@"Unit: %@",unit]];
        }
    }
    if(calendar) {
        [contents addObject:[NSString stringWithFormat:@"Calendar: %@",calendar.calendarIdentifier]];
    }
    NSString * result = [contents componentsJoinedByString:@"  "];
    return result;
}

/*
 DateComponents -> Readble String
 */
- (NSString *)readableTextFromDateComponents: (NSDateComponents *)components
{
    NSMutableArray * contents = [NSMutableArray array];
    if(components.calendar){
        //TODO
        [contents addObject:[NSString stringWithFormat:@"Calendar: %@",components.calendar.calendarIdentifier]];
    }
    if(components.timeZone){
        [contents addObject:[NSString stringWithFormat:@"TimeZone: %@",components.timeZone]];
    }
    if(components.era != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Era: %zd",components.era]];
    }
    if(components.year != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Year: %zd",components.year]];
    }
    if(components.month != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Month: %zd",components.month]];
    }
    if(components.day != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Day: %zd",components.day]];
    }
    if(components.hour != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Hour: %zd",components.hour]];
    }
    if(components.minute != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Minute: %zd",components.minute]];
    }
    if(components.second != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Second: %zd",components.second]];
    }
    if(components.nanosecond != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Nanosecond: %zd",components.nanosecond]];
    }
    if(components.weekday != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Weekday: %zd",components.weekday]];
    }
    if(components.weekdayOrdinal != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"WeekdayOrdinal: %zd",components.weekdayOrdinal]];
    }
    if(components.quarter != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"Quarter: %zd",components.quarter]];
    }
    if(components.weekOfMonth != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"WeekOfMonth: %zd",components.weekOfMonth]];
    }
    if(components.weekOfYear != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"WeekOfYear: %zd",components.weekOfYear]];
    }
    if(components.yearForWeekOfYear != NSIntegerMax){
        [contents addObject:[NSString stringWithFormat:@"YearForWeekOfYear: %zd",components.yearForWeekOfYear]];
    }
    if(components.isLeapMonth){
        [contents addObject:[NSString stringWithFormat:@"leapMonth: YES"]];
    }
    NSString * result = [contents componentsJoinedByString:@"  "];
    return result;
}

- (NSString *)readbleTextFromCLRegion: (CLRegion *)region
{
    CLCircularRegion * circleRegion = (CLCircularRegion *)region;
    CLLocationCoordinate2D center = circleRegion.center;
    CLLocationDistance radius = circleRegion.radius;
    NSString * identifier = adhvf_safestringfy(circleRegion.identifier);
    BOOL notifyOnEntry = circleRegion.notifyOnEntry;
    BOOL notifyOnExit = circleRegion.notifyOnExit;
    NSMutableArray * components = [NSMutableArray array];
    [components addObject:[NSString stringWithFormat:@"( Latitude: %f,  Longitude: %f )",center.longitude,center.latitude]];
    [components addObject:[NSString stringWithFormat:@"Radius: %.2f meters",radius]];
    if(notifyOnEntry){
        [components addObject:[NSString stringWithFormat:@"NotifyOnEntry: YES"]];
    }
    if(notifyOnExit){
        [components addObject:[NSString stringWithFormat:@"NotifyOnExit: YES"]];
    }
    [components addObject:[NSString stringWithFormat:@"Identifier: %@",identifier]];
    NSString * result = [components componentsJoinedByString:@"  "];
    return result;
}

- (NSDictionary *)readbleTextFromAttachment: (UNNotificationAttachment *)attachment
API_AVAILABLE(ios(10.0),macos(10.14)){
    if (@available(iOS 10.0,macOS 10.14, *)) {
        NSMutableDictionary * data = [NSMutableDictionary dictionary];
        data[@"identifier"] = adhvf_safestringfy(attachment.identifier);
        data[@"URL"] = adhvf_safestringfy(attachment.URL);
        data[@"type"] = adhvf_safestringfy(attachment.type);
        return data;
    }else {
        return nil;
    }
}

- (void)onAppWorkStateUpdate {
    if(self.receivedNotifications.count > 0) {
#if TARGET_OS_IPHONE
        if([[ADHOrganizer sharedOrganizer] isWorking]) {
            [self uploadNotificationRequest];
        }
#elif TARGET_OS_MAC
        if([[ADHMacClientOrganizer sharedOrganizer] isWorking]) {
            [self uploadNotificationRequest];
        }
#endif
    }
}

@end








