//
//  ADHPRequest.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHPRequest.h"
#import "ADHPackage.h"
#import "ADHProtocolConfig.h"

@implementation ADHPRequest

- (ADHPackage *)workPackage
{
    return [self nextPackage];
}

- (ADHPackage *)nextPackage
{
    ADHPackage * nextPackage = nil;
    for (NSInteger tag=0; tag<self.packages.count; tag++) {
        ADHPackage * package = self.packages[tag];
        if(!package.sended){
            nextPackage = package;
            break;
        }
    }
    return nextPackage;
}

- (void)unpack
{
    NSData * payload = self.payload;
    NSMutableArray * packages = [NSMutableArray array];
    NSUInteger payloadPtr = NSNotFound;
    NSUInteger leftPayloadLength = payload.length;
    do {
        ADHPackage * package = [ADHPackage package];
        if(payloadPtr == NSNotFound){
            package.isBody = YES;
        }
        if(leftPayloadLength > 0){
            NSUInteger location = payloadPtr;
            if(location == NSNotFound){
                location = 0;
            }
            NSUInteger length = MIN(kADHPackagePayloadSize, leftPayloadLength);
            NSRange range = NSMakeRange(location, length);
            package.payloadRange = range;
            leftPayloadLength -= length;
            if(payloadPtr == NSNotFound){
                payloadPtr = 0;
            }
            payloadPtr += length;
        }else{
            package.payloadRange = NSMakeRange(NSNotFound, 0);
        }
        package.request = self;
        [packages addObject:package];
        
    } while (leftPayloadLength > 0);
    self.packages = packages;
}

- (float)progress
{
    float progress = 0.0f;
    NSInteger totalCount = self.packages.count;
    if(totalCount > 0){
        NSInteger sendCount = 0;
        for (ADHPackage * package in self.packages) {
            if(package.sended){
                sendCount ++;
            }else{
                break;
            }
        }
        progress = (sendCount*1.0) / totalCount;
    }
    if(progress < 0) progress = 0;
    if(progress > 1) progress = 1.0;
    return progress;
}

@end















