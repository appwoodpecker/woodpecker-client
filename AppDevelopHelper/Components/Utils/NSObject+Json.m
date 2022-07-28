//
//  NSObject+Json.m
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NSObject+Json.h"

@implementation NSObject (ADHJson)

- (NSString *)adh_jsonPresentation
{
    NSString * result = nil;
    if([NSJSONSerialization isValidJSONObject:self]){
        NSError * error = nil;
        NSData * data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        if(error){
            NSLog(@"%@",error);
        }
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return result;
}

@end

@implementation NSString (ADHJson)

- (id)adh_jsonObject
{
    NSError * error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if(error){
//        NSLog(@"%@",error);
    }
    return result;
}

@end


