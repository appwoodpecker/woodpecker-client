//
//  UNLegacyNotificationTrigger.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/9/9.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#ifndef UNLegacyNotificationTrigger_h
#define UNLegacyNotificationTrigger_h

@interface UNLegacyNotificationTrigger: NSObject

// timer-based scheduling
@property(nullable, nonatomic,readonly) NSDate *date;
// the time zone to interpret fireDate in. pass nil if fireDate is an absolute GMT time (e.g. for an egg timer).
// pass a time zone to interpret fireDate as a wall time to be adjusted automatically upon time zone changes (e.g. for an alarm clock).
@property(nullable, nonatomic,readonly) NSTimeZone *timeZone;

@property(nonatomic, readonly) NSCalendarUnit repeatInterval;      // 0 means don't repeat
@property(nullable, nonatomic,readonly) NSCalendar *repeatCalendar;

@end

#endif /* UNLegacyNotificationTrigger_h */
