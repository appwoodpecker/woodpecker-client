//
//  ADHRemoteService.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHRemoteService : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * host;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, strong) NSDictionary *ruleData;
@property (nonatomic, assign) BOOL simulator;
@property (nonatomic, assign) BOOL usb;

//local
- (BOOL)isLocalDirect;


@end
