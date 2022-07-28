//
//  ADHNetworkCookie.m
//  ADHClient
//
//  Created by 张小刚 on 2018/5/14.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHNetworkCookie.h"

NSString *const kADHNetworkCookieName           = @"name";
NSString *const kADHNetworkCookieValue          = @"value";
NSString *const kADHNetworkCookieExpiresDate    = @"expiresDate";
NSString *const kADHNetworkCookieDomain         = @"domain";
NSString *const kADHNetworkCookiePath           = @"path";
NSString *const kADHNetworkCookiePortList       = @"portList";
NSString *const kADHNetworkCookieSecure         = @"secure";
NSString *const kADHNetworkCookieHTTPOnly       = @"HTTPOnly";
NSString *const kADHNetworkCookieComment        = @"comment";

@implementation ADHNetworkCookie

+ (instancetype)cookieWithHttpCookie: (NSHTTPCookie *)httpCookie {
    ADHNetworkCookie *cookie = [[ADHNetworkCookie alloc] init];
    cookie.name = httpCookie.name;
    cookie.value = httpCookie.value;
    cookie.expiresDate = httpCookie.expiresDate;
    cookie.domain = httpCookie.domain;
    cookie.path = httpCookie.path;
    cookie.portList = httpCookie.portList;
    cookie.secure = httpCookie.secure;
    cookie.HTTPOnly = httpCookie.HTTPOnly;
    cookie.comment = httpCookie.comment;
    if(cookie.comment.length == 0) {
        if(httpCookie.commentURL) {
            cookie.comment = httpCookie.commentURL.absoluteString;
        }
    }
    return cookie;
}

+ (instancetype)cookieWithData: (NSDictionary *)data {
    ADHNetworkCookie *cookie = [[ADHNetworkCookie alloc] init];
    cookie.name = adhvf_safestringfy(data[kADHNetworkCookieName]);
    cookie.value = adhvf_safestringfy(data[kADHNetworkCookieValue]);
    if(data[kADHNetworkCookieExpiresDate]) {
        cookie.expiresDate = [NSDate dateWithTimeIntervalSince1970:[data[kADHNetworkCookieExpiresDate] doubleValue]];
    }
    cookie.domain = adhvf_safestringfy(data[kADHNetworkCookieDomain]);
    cookie.path = adhvf_safestringfy(data[kADHNetworkCookiePath]);
    if(data[kADHNetworkCookiePortList]) {
        cookie.portList = data[kADHNetworkCookiePortList];
    }
    cookie.secure = [data[kADHNetworkCookieSecure] boolValue];
    cookie.HTTPOnly = [data[kADHNetworkCookieHTTPOnly] boolValue];
    cookie.comment = adhvf_safestringfy(data[kADHNetworkCookieComment]);
    return cookie;
}

- (NSDictionary *)dicPresentation {
    ADHNetworkCookie *cookie = self;
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    if(cookie.name) {
        data[kADHNetworkCookieName] = cookie.name;
    }
    if(cookie.value) {
        data[kADHNetworkCookieValue] = cookie.value;
    }
    if(cookie.expiresDate) {
        data[kADHNetworkCookieExpiresDate] = [NSNumber numberWithDouble:[cookie.expiresDate timeIntervalSince1970]];
    }
    if(cookie.domain) {
        data[kADHNetworkCookieDomain] = cookie.domain;
    }
    if(cookie.path) {
        data[kADHNetworkCookiePath] = cookie.path;
    }
    if(cookie.portList) {
        data[kADHNetworkCookiePortList] = cookie.portList;
    }
    data[kADHNetworkCookieSecure] = cookie.secure ? @1:@0;
    data[kADHNetworkCookieHTTPOnly] = cookie.HTTPOnly ? @1:@0;
    if(cookie.comment) {
        data[kADHNetworkCookieComment] = cookie.comment;
    }
    return data;
}

@end













