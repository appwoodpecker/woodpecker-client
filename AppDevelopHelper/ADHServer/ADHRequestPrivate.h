//
//  ADHRequestPrivate.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/6/9.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADHRequest;

typedef void (^ADHActionResponseBlock)(NSDictionary * body,NSData * payload, ADHRequest * request);

@interface ADHRequest (Private)

///private interface
- (void)setTSession:(ADHSession *)tSession;
- (ADHSession *)tSession;

- (void)setResponseBlock:(ADHActionResponseBlock)responseBlock;
- (ADHActionResponseBlock)responseBlock;

- (void)setServiceObj:(ADHService *)serviceObj;
- (ADHService *)serviceObj;

@end
