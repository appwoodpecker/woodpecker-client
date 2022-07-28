//
//  ADHPackage.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHPackage.h"
#import "ADHPRequest.h"
#import "ADHSession.h"
#import "NSObject+ADHUtil.h"

@implementation ADHPackage

/**
 package to data
 [PACKAGE_START]-
        [METADATA_START]-[METADTA]-[METADATA_END]-
        [BODY_START]-[BODY]-[BODY_END]-
        [PAYLOAD_START]-[PAYLOAD]-[PAYLOAD_END]-
 [PACKAGE_END]
 */
- (NSData *)packageData
{
    NSMutableData * resultData = [NSMutableData data];
    //PACKAGE_START
    [resultData appendData:[ADHPackage kPackageStartData]];
    //METADATA_START
    [resultData appendData:[ADHPackage kMetaDataStartData]];
    //[METADTA]
    NSData * metaData = [self metaData];
    [resultData appendData:metaData];
    //METADATA_END
    [resultData appendData:[ADHPackage kMetaDataEndData]];
    if(self.isBody){
        //BODY_START
        [resultData appendData:[ADHPackage kBodyStartData]];
        //[BODY]
        NSData * bodyData = [self bodyData];
        [resultData appendData:bodyData];
        //BODY_END
        [resultData appendData:[ADHPackage kBodyEndData]];
    }
    if(self.payloadRange.location != NSNotFound){
        //PAYLOAD_START
        [resultData appendData:[ADHPackage kPayloadStartData]];
        //[PAYLOAD]
        NSData * payloadData = [self payloadData];
        [resultData appendData:payloadData];
        //PAYLOAD_END
        [resultData appendData:[ADHPackage kPayloadEndData]];
    }
    [resultData appendData:[ADHPackage kPackageEndData]];
    return [NSData dataWithData:resultData];
}

- (NSData *)metaData
{
    NSMutableDictionary * metadata = [NSMutableDictionary dictionary];
    //tag
    metadata[@"tag"] =  [NSString stringWithFormat:@"%lld",self.request.session.tag];
    //body package
    metadata[@"isbody"] = self.isBody ? @"1":@"0";
    if(self.isBody){
        //payload size
        metadata[@"size"] = [NSString stringWithFormat:@"%lu",(unsigned long)self.request.payload.length];
    }
    //payload range
    if(self.payloadRange.location != NSNotFound){
        metadata[@"range"] = [NSString stringWithFormat:@"%lu-%lu",(unsigned long)self.payloadRange.location,(unsigned long)self.payloadRange.length];
    }
    NSData * data = [metadata adh_jsonData];
    return data;
}

- (NSData *)bodyData
{
    NSDictionary * body = self.request.body;
    NSData * data = [body adh_jsonData];
    return data;
}

- (NSData *)payloadData
{
    NSData * data = [self.request.payload subdataWithRange:self.payloadRange];
    return data;
}

/**
 parse data to package
 */
+ (ADHPackage *)packageWithData: (NSData *)data
{
    ADHPackage * resultPackage = nil;
    //PACKAGE_START
    if(([data adh_hasPrefix:[ADHPackage kPackageStartData]] && [data adh_hasSuffix:[ADHPackage kPackageEndData]])){
        ADHPackage * package = [ADHPackage package];
        data = [data adh_subDataFromLength:[ADHPackage kPackageStartData].length];
        //METADATA
        NSData * metaData = [data adh_dataBetween:[ADHPackage kMetaDataStartData] endData:[ADHPackage kMetaDataEndData]];
        NSDictionary * metaInfo = [metaData adh_jsonObject];
        if([metaInfo isKindOfClass:[NSDictionary class]]){
            BOOL isBody = [metaInfo[@"isbody"] isEqualToString:@"1"];
            if(isBody){
                NSUInteger payloadSize = [metaInfo[@"size"] integerValue];
                package.responsePayloadSize = payloadSize;
            }
            NSInteger tag =[metaInfo[@"tag"] integerValue];
            NSString * rangeStr = metaInfo[@"range"];
            NSRange payloadRange = NSMakeRange(NSNotFound, 0);
            if(rangeStr.length > 0){
                NSArray * values = [rangeStr componentsSeparatedByString:@"-"];
                if([values isKindOfClass:[NSArray class]] && values.count == 2){
                    NSUInteger location = [values[0] integerValue];
                    NSUInteger length = [values[1] integerValue];
                    payloadRange = NSMakeRange(location, length);
                }
            }
            package.payloadRange = payloadRange;
            package.isBody = isBody;
            package.responseTag = tag;
            data = [data adh_subDataFromLength:([ADHPackage kMetaDataStartData].length + metaData.length + [ADHPackage kMetaDataEndData].length)];
            //BODY
            if(isBody){
                NSData * bodyData = [data adh_dataBetween:[ADHPackage kBodyStartData] endData:[ADHPackage kBodyEndData]];
                NSDictionary * body = [bodyData adh_jsonObject];
                if(body){
                    package.body = body;
                    data = [data adh_subDataFromLength:([ADHPackage kBodyStartData].length + bodyData.length + [ADHPackage kBodyEndData].length)];
                }else{
                    goto error;
                }
            }
            //PAYLOAD
            if(payloadRange.length > 0){
                NSData * payloadData = [data adh_dataBetween:[ADHPackage kPayloadStartData] endData:[ADHPackage kPayloadEndData]];
                if(payloadData.length == payloadRange.length){
                    package.responsePayloadData = payloadData;
                    resultPackage = package;
                }
            }else{
                resultPackage = package;
            }
        }
    }
error:
    return resultPackage;
}



+ (ADHPackage *)package
{
    return [[ADHPackage alloc] init];
}

+ (NSData *)kPackageStartData
{
    return [ADHPackage dataWithCode:@"ADH_PACKAGE_START"];
}

+ (NSData *)kPackageEndData
{
    return [ADHPackage dataWithCode:@"ADH_PACKAGE_END"];
}

+ (NSData *)kMetaDataStartData
{
    return [ADHPackage dataWithCode:@"ADH_METADATA_START"];
}

+ (NSData *)kMetaDataEndData
{
    return [ADHPackage dataWithCode:@"ADH_METADATA_END"];
}

+ (NSData *)kBodyStartData
{
    return [ADHPackage dataWithCode:@"ADH_BODY_START"];
}

+ (NSData *)kBodyEndData
{
    return [ADHPackage dataWithCode:@"ADH_BODY_END"];
}

+ (NSData *)kPayloadStartData
{
    return [ADHPackage dataWithCode:@"ADH_PAYLOAD_START"];
}

+ (NSData *)kPayloadEndData
{
    return [ADHPackage dataWithCode:@"ADH_PAYLOAD_END"];
}

+ (NSData *)dataWithCode: (NSString *)code
{
    return [code dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -----------------   json   ----------------




@end









