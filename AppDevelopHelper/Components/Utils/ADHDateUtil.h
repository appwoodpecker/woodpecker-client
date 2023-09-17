//
//  DateUtil.h
//  magapp-x
//
//  Created by 张小刚 on 2017/1/1.
//  Copyright © 2017年 lyeah. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface ADHDateUtil : NSObject

+ (NSTimeInterval)currentTimeInterval;

+ (NSString *)formatStringWithTimeInterval: (NSTimeInterval)intervalSince1970 dateFormat: (NSString *)format;
+ (NSString *)formatStringWithDate: (NSDate *)date dateFormat: (NSString *)format;

+ (NSDate *)dayDateWithDate: (NSDate *)date;
+ (NSDate *)nowDayDate;
+ (NSInteger)hourComponentInHMInterval: (NSTimeInterval)hmInterval;
+ (NSInteger)minuteComponentInHMInterval: (NSTimeInterval)hmInterval;
+ (BOOL)isFutureDate: (NSDate *)date;
+ (NSCalendar *)calendar;

+ (NSString *)readbleTextWithTimeInterval: (NSTimeInterval)interval;
+ (NSString *)readbleTextWithTimeInterval2: (NSTimeInterval)interval;

@end
NS_ASSUME_NONNULL_END
