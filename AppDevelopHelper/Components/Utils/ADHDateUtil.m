//
//  DateUtil.m
//  magapp-x
//
//  Created by 张小刚 on 2017/1/1.
//  Copyright © 2017年 lyeah. All rights reserved.
//

#import "ADHDateUtil.h"

@implementation ADHDateUtil

+ (NSTimeInterval)currentTimeInterval
{
    return [[NSDate date] timeIntervalSince1970];
}

+ (NSString *)formatStringWithDate: (NSDate *)date dateFormat: (NSString *)format
{
    NSString * result = nil;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    if([format isEqualToString:@"date"]){
        [formatter setDateFormat:@"yyyy-MM-dd"];
        result = [formatter stringFromDate:date];
    }else if([format isEqualToString:@"time"]){
        [formatter setDateFormat:@"HH:mm"];
        result = [formatter stringFromDate:date];
    }else if([format isEqualToString:@"full"]){
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        result = [formatter stringFromDate:date];
    }else if([format isEqualToString:@"relative"] || (format.length == 0)){
        // default relative
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];           //距离现在的秒数
        NSTimeInterval MINUTE_INTERVAL = 60;
        NSTimeInterval HOUR_INTERVAL = MINUTE_INTERVAL * 60;
        NSTimeInterval DAY_INTERVAL = HOUR_INTERVAL * 24;
        if(interval > 4 * DAY_INTERVAL){
            [formatter setDateFormat:@"yyyy-MM-dd"];
            result = [formatter stringFromDate:date];
        }else if(interval > 3 * DAY_INTERVAL){
            result = @"3天前";
        }else if(interval > 2 * DAY_INTERVAL){
            result = @"2天前";
        }else if(interval >  DAY_INTERVAL){
            [formatter setDateFormat:@"昨天 HH:mm"];
            result = [formatter stringFromDate:date];
        }else if(interval > HOUR_INTERVAL){
            int hour = (int)(interval / HOUR_INTERVAL);
            result = [NSString stringWithFormat:@"%d小时前",hour];
        }else if(interval > 10 * MINUTE_INTERVAL){
            //大于10分钟
            int minute = (int)(interval / MINUTE_INTERVAL);
            result = [NSString stringWithFormat:@"%d分钟前",minute];
        }else{
            //小于10分钟
            result = @"刚刚";
        }
    }else{
        [formatter setDateFormat:format];
        result = [formatter stringFromDate:date];
    }
    if([result isEqualToString:@"1970-01-01"]) result = @"";
    return result;
}

+ (NSString *)formatStringWithTimeInterval: (NSTimeInterval)intervalSince1970 dateFormat: (NSString *)format
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:intervalSince1970];
    return [ADHDateUtil formatStringWithDate:date dateFormat:format];
    
}

+ (NSDate *)dayDateWithDate: (NSDate *)date
{
    NSCalendar * calendar = [ADHDateUtil calendar];
    NSDateComponents * components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDate * dayDate = [calendar dateFromComponents:components];
    return dayDate;
}

+ (NSDate *)nowDayDate
{
    NSDate * now = [NSDate date];
    return [ADHDateUtil dayDateWithDate:now];
}

+ (NSInteger)hourComponentInHMInterval: (NSTimeInterval)hmInterval
{
    NSTimeInterval value = hmInterval;
    NSInteger hour = value / (60 * 60);
    return hour;
}

+ (NSInteger)minuteComponentInHMInterval: (NSTimeInterval)hmInterval
{
    NSTimeInterval value = hmInterval;
    NSInteger hour = value / (60 * 60);
    NSTimeInterval left = value - hour * 60 * 60;
    NSInteger minute = left / 60;
    return minute;
}

+ (BOOL)isFutureDate: (NSDate *)date
{
    NSDate * now = [NSDate date];
    return ([date laterDate:now] == date);
}

+ (NSCalendar *)calendar
{
    return [NSCalendar currentCalendar];
}

+ (NSString *)readbleTextWithTimeInterval: (NSTimeInterval)interval {
    return [ADHDateUtil formatStringWithTimeInterval:interval dateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSString *)readbleTextWithTimeInterval2: (NSTimeInterval)interval {
    return [ADHDateUtil formatStringWithTimeInterval:interval dateFormat:@"yyyy_MM_dd~HH_mm_ss"];
}

@end







