//
//  ADHPackage.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADHPRequest;
@class ADHPResponse;

@interface ADHPackage : NSObject

//request
@property (nonatomic, weak) ADHPRequest * request;
//是否是body package
@property (nonatomic, assign) BOOL isBody;
//payload
@property (nonatomic, assign) NSRange payloadRange;
//packageData
- (NSData *)packageData;
+ (ADHPackage *)packageWithData: (NSData *)data;

@property (nonatomic, assign) BOOL sended;

//response
@property (nonatomic, weak) ADHPResponse * response;
@property (nonatomic, assign) uint32_t responseTag;
@property (nonatomic, strong) NSDictionary * body;
@property (nonatomic, assign) NSUInteger responsePayloadSize;
@property (nonatomic, strong) NSData * responsePayloadData;


+ (ADHPackage *)package;

+ (NSData *)kPackageStartData;
+ (NSData *)kPackageEndData;

+ (NSData *)kMetaDataStartData;
+ (NSData *)kMetaDataEndData;

+ (NSData *)kBodyStartData;
+ (NSData *)kBodyEndData;

+ (NSData *)kPayloadStartData;
+ (NSData *)kPayloadEndData;

@end
