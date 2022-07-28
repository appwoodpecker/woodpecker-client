//
//  ADHStateMasterService.m
//  ADHClient
//
//  Created by 张小刚 on 2020/5/31.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHStateMasterService.h"

@implementation ADHStateMasterService

+ (ADHStateMasterService *)service {
    static ADHStateMasterService * service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[ADHStateMasterService alloc] init];
    });
    return service;
}



@end
