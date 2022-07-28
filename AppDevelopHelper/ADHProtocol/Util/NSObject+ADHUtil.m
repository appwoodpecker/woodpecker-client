//
//  NSObject+ADHUtil.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/28.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NSObject+ADHUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSObject (ADHUtil)

/**
 json object to json data
 */
- (NSData *)adh_jsonData
{
    NSError * error = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    return data;
}


@end

@implementation NSData(ADHUtil)

/**
 json data to json object
 */
- (id)adh_jsonObject
{
    NSError * error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:self options:0 error:&error];
    return object;
}

- (BOOL)adh_hasPrefix: (NSData *)data
{
    BOOL ret = NO;
    NSRange range = [self rangeOfData:data options:0 range:NSMakeRange(0, self.length)];
    if(range.location != NSNotFound){
        ret = YES;
    }
    return ret;
}

- (BOOL)adh_hasSuffix: (NSData *)data
{
    BOOL ret = NO;
    NSRange range = [self rangeOfData:data options:NSDataSearchBackwards range:NSMakeRange(0, self.length)];
    if(range.location != NSNotFound){
        ret = YES;
    }
    return ret;
}

- (NSData *)adh_subDataFromLength: (NSUInteger)length
{
    NSData * subData = nil;
    if(self.length > length){
        NSRange range = NSMakeRange(length, self.length-length);
        subData = [self subdataWithRange:range];
    }
    return subData;
}

- (NSData *)adh_subDataToData: (NSData *)data
{
    NSData * resultData = nil;
    NSRange range = [self rangeOfData:data options:0 range:NSMakeRange(0, self.length)];
    if(range.location > 0){
        NSRange resultRange = NSMakeRange(0, range.location);
        resultData = [self subdataWithRange:resultRange];
    }
    return resultData;
}

/**
 start: 01-------
 data : 012345678
 end:   -------78
 
 result 23456
 */
- (NSData *)adh_dataBetween: (NSData *)startData endData: (NSData *)endData;
{
    NSData * data = nil;
    NSRange searchRange = NSMakeRange(0, self.length);
    NSRange startRange = [self rangeOfData:startData options:0 range:searchRange];
    NSRange endRange = [self rangeOfData:endData options:0 range:searchRange];
    if(startRange.location != NSNotFound && endRange.location != NSNotFound) {
        NSInteger location = NSMaxRange(startRange);
        NSInteger length = endRange.location - location;
        NSRange dataRange = NSMakeRange(location, length);
        data = [self subdataWithRange:dataRange];
    }
    return data;
}


@end

@implementation NSString (md5)

- (NSString *)md5Digest {
    NSString *string = self;
    NSParameterAssert(string != nil && [string length] > 0);
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);

    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }

    return outputString;
}

@end

















