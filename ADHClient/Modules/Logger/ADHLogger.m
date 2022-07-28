//
//  ADHLogger.m
//  ADHClient
//
//  Created by 张小刚 on 2017/12/30.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHLogger.h"

@implementation ADHLogger

+ (ADHLogger *)sharedLogger
{
    static ADHLogger * sharedLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [[ADHLogger alloc] init];
    });
    return sharedLogger;
}

- (void)logText: (NSString *)text
{
    NSDictionary * body = @{
                            @"type" : @"text",
                            @"text" : adhvf_safestringfy(text),
                            };
    [[ADHApiClient sharedApi] requestWithService:@"adh.logger" action:@"log" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        
    } onFailed:^(NSError *error) {
        
    }];
}

#if TARGET_OS_IPHONE
- (void)logText: (NSString *)text color: (UIColor *)color {
    NSString * colorValue = nil;
    if(color){
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        colorValue = [NSString stringWithFormat:@"%f|%f|%f|%f",red,green,blue,alpha];
    }
    NSDictionary * body = @{
                            @"type" : @"text",
                            @"text" : adhvf_safestringfy(text),
                            @"color" : adhvf_safestringfy(colorValue),
                            };
    [[ADHApiClient sharedApi] requestWithService:@"adh.logger" action:@"log" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        
    } onFailed:^(NSError *error) {
        
    }];
}

#endif

    
- (void)logFileWithData:(NSData *)fileData fileName:(NSString *)fileName text: (NSString *)text
    {
    NSDictionary * body = @{
                            @"type" : @"file",
                            @"filename" : adhvf_safestringfy(fileName),
                            @"text" : adhvf_safestringfy(text),
                            };
    [[ADHApiClient sharedApi] requestWithService:@"adh.logger" action:@"log" body:body payload:fileData progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        
    } onFailed:^(NSError *error) {
        
    }];
}
    
- (NSDictionary *)uniformLogBody: (NSDictionary *)body
{
    NSMutableDictionary * data = [body mutableCopy];
    data[@"date"] = [NSNumber numberWithDouble:[ADHDateUtil currentTimeInterval]];
    return data;
}
    
@end
