//
//  ADHProtocolConfig.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const kADHPackagePayloadSize;
extern NSString * const kADHNetServiceDomain;
extern NSString * const kADHNetServiceType;
extern NSString * const kADHNetServiceName;

extern NSInteger const kADHProtocolListenTag;

extern NSTimeInterval const kADHProtocolPackageTimeout;

extern NSString * const kADHErrorDomain;
extern NSInteger const kADHErrorCodeTimeOut;


@interface ADHProtocolConfig : NSObject

+ (ADHProtocolConfig *)config;


@end
