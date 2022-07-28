//
//  ADHPRequest.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADHPackage;
@class ADHSession;

@interface ADHPRequest : NSObject

@property (nonatomic, strong) NSDictionary * body;
@property (nonatomic, strong) NSData * payload;

@property (nonatomic, weak) ADHSession * session;

@property (nonatomic, strong) NSArray * packages;

- (ADHPackage *)workPackage;
- (ADHPackage *)nextPackage;
- (void)unpack;

- (float)progress;


@end
