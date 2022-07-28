//
//  NSObject+ADHUtil.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/28.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ADHUtil)

/**
 json object to json data
 */
- (NSData *)adh_jsonData;

@end

@interface NSData (ADHUtil)

/**
 json data to json object
 */
- (id)adh_jsonObject;
- (BOOL)adh_hasPrefix: (NSData *)data;
- (BOOL)adh_hasSuffix: (NSData *)data;
- (NSData *)adh_subDataFromLength: (NSUInteger)length;
- (NSData *)adh_subDataToData: (NSData *)data;
- (NSData *)adh_dataBetween: (NSData *)startData endData: (NSData *)endData;

@end

@interface NSString (md5)

- (NSString *)md5Digest;

@end
























