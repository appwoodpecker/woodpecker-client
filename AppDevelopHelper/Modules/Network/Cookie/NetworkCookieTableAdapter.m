//
//  NetworkCookieTableAdapter.m
//  ADHClient
//
//  Created by 张小刚 on 2018/5/14.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NetworkCookieTableAdapter.h"

@interface NetworkCookieTableAdapter ()

@property (nonatomic, strong) NSArray *titleList;
@property (nonatomic, strong) NSArray<SimpleTableColumn *> * mColumnList;
@property (nonatomic, strong) NSArray<ADHNetworkCookie *> * cookList;

@end

@implementation NetworkCookieTableAdapter

- (void)prepareHeader: (CGFloat)tableWidth {
    //header
    NSArray * titles = @[
                       @{
                           @"name" : @" Name",
                           @"key" : kADHNetworkCookieName,
                           @"width" : @1,
                           },
                       @{
                           @"name" : @" Value",
                           @"key" : kADHNetworkCookieValue,
                           @"width" : @2,
                           },
                       @{
                           @"name" : @" Domain",
                           @"key" : kADHNetworkCookieDomain,
                           @"width" : @1.6,
                           },
                       @{
                           @"name" : @" Path",
                           @"key" : kADHNetworkCookiePath,
                           @"width" : @1,
                           },
                       @{
                           @"name" : @" Expire date",
                           @"key" : kADHNetworkCookieExpiresDate,
                           @"width" : @1,
                           }
                       ];
    self.titleList = titles;
    CGFloat unitWidth = 0;
    float units = 0;
    for (NSDictionary * data in titles) {
        float unit = [data[@"width"] floatValue];
        units += unit;
    }
    unitWidth = tableWidth/units;
    NSMutableArray<SimpleTableColumn *> *columnList = [NSMutableArray array];
    for (NSDictionary * data in titles) {
        NSString * name = data[@"name"];
        NSString * key = data[@"key"];
        float unit = [data[@"width"] floatValue];
        SimpleTableColumn *column = [[SimpleTableColumn alloc] init];
        column.title = name;
        column.key = key;
        column.width = unitWidth * unit;
        column.headerTextAlignment = NSTextAlignmentLeft;
        column.cellTextAlignment = NSTextAlignmentLeft;
        [columnList addObject:column];
    }
    self.mColumnList = columnList;
}

- (void)setData: (NSArray<ADHNetworkCookie *> *)dataList {
    self.cookList = dataList;
    [self updateRows];
}

#pragma mark -----------------   data source   ----------------

- (NSArray<SimpleTableColumn *>*) columnList {
    return self.mColumnList;
}

- (NSInteger)numberOfRows {
    return self.cookList.count;
}

- (NSString *)valueAtRow: (NSInteger)row columnKey: (NSString *)key {
    NSString *value = nil;
    ADHNetworkCookie *cookie = self.cookList[row];
    if([key isEqualToString:kADHNetworkCookieName]) {
        value = cookie.name;
    }else if([key isEqualToString:kADHNetworkCookieValue]) {
        value = cookie.value;
    }else if([key isEqualToString:kADHNetworkCookieExpiresDate]) {
        if(cookie.expiresDate) {
            value = [ADHDateUtil formatStringWithDate:cookie.expiresDate dateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
    }else if([key isEqualToString:kADHNetworkCookieDomain]) {
        value = cookie.domain;
    }else if([key isEqualToString:kADHNetworkCookiePath]) {
        value = cookie.path;
    }else if([key isEqualToString:kADHNetworkCookiePortList]) {
        value = [cookie.portList componentsJoinedByString:@","];
    }else if([key isEqualToString:kADHNetworkCookieSecure]) {
        value = cookie.secure ? @"YES":@"";
    }else if([key isEqualToString:kADHNetworkCookieHTTPOnly]) {
        value = cookie.HTTPOnly ? @"YES":@"";
    }else if([key isEqualToString:kADHNetworkCookieComment]) {
        value = cookie.comment;
    }
    return adhvf_safestringfy(value);
}


@end

















