//
//  ADHNetworkCookie.h
//  ADHClient
//
//  Created by 张小刚 on 2018/5/14.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kADHNetworkCookieName;
extern NSString *const kADHNetworkCookieValue;
extern NSString *const kADHNetworkCookieExpiresDate;
extern NSString *const kADHNetworkCookieDomain;
extern NSString *const kADHNetworkCookiePath;
extern NSString *const kADHNetworkCookiePortList;
extern NSString *const kADHNetworkCookieSecure;
extern NSString *const kADHNetworkCookieHTTPOnly;
extern NSString *const kADHNetworkCookieComment;

@interface ADHNetworkCookie : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSDate *expiresDate;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSArray<NSNumber *> *portList;
@property (nonatomic, assign, getter=isSecure) BOOL secure;
@property (nonatomic, assign, getter=isHTTPOnly) BOOL HTTPOnly;
//comment text or url
@property (nonatomic, strong) NSString *comment;

+ (instancetype)cookieWithHttpCookie: (NSHTTPCookie *)httpCookie;
+ (instancetype)cookieWithData: (NSDictionary *)data;
- (NSDictionary *)dicPresentation;

@end
