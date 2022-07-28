//
//  LogActionRequest.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/1/8.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiActionRequest : NSObject

@property (nonatomic, strong) NSString * service;
@property (nonatomic, strong) NSString * action;
@property (nonatomic, strong) NSDictionary * body;
@property (nonatomic, strong) NSString * filePath;

@end
