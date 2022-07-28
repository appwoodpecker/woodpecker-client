//
//  ADHPResponse.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHPResponse.h"
#import "ADHPackage.h"
#import "ADHProtocolConfig.h"

@implementation ADHPResponse

- (BOOL)isEndPackage: (ADHPackage *)package
{
    BOOL isEnd = NO;
    ADHPackage * bodyPackage = [self bodyPackage];
    if(self.payloadSize == 0){
        isEnd = (package == bodyPackage);
    }else{
        NSUInteger pos = NSMaxRange(package.payloadRange);
        if(pos == self.payloadSize){
            isEnd = YES;
        }
    }
    return isEnd;
}

- (ADHPackage *)bodyPackage
{
    ADHPackage * bodyPackage = nil;
    for (ADHPackage * package in self.packages) {
        if(package.isBody){
            bodyPackage = package;
            break;
        }
    }
    return bodyPackage;
}

- (void)pack
{
    NSMutableData * data = [NSMutableData data];
    for (ADHPackage * package in self.packages) {
        if(package.responsePayloadData){
            [data appendData:package.responsePayloadData];
        }
    }
    if(data.length > 0){
        self.payload = data;
    }
}

- (float)progress
{
    float progress = 0;
    if(self.payloadSize > 0){
        NSInteger receivedCount = self.packages.count;
        NSInteger receivedBytes = (receivedCount * kADHPackagePayloadSize);
        progress = (receivedBytes * 1.0)/self.payloadSize;
    }
    if(progress < 0) progress = 0;
    if(progress > 1) progress = 1.0;
    return progress;
}

@end










