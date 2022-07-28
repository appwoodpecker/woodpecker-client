//
//  ADHKeepAliveService.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/10/13.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHKeepAliveService : NSObject

+ (ADHKeepAliveService *)service;
- (void)start;

@end
