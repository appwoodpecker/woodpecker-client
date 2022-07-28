//
//  ADHPResponse.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADHPackage;
@class ADHSession;

@interface ADHPResponse : NSObject

@property (nonatomic, weak) ADHSession * session;

@property (nonatomic, strong) NSDictionary * body;
@property (nonatomic, assign) NSInteger payloadSize;
@property (nonatomic, strong) NSData * payload;
@property (nonatomic, strong) NSMutableArray * packages;

- (BOOL)isEndPackage: (ADHPackage *)package;
- (void)pack;

- (float)progress;


@end
