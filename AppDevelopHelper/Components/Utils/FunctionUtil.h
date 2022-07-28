//
//  FunctionUtil.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/5/13.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FunctionUtil : NSObject

+ (void)performBlock: (void (^)(void))block after: (NSTimeInterval)seconds;

+ (NSString *)readbleBytesSize: (uint64_t)size;

+ (void)performBlockInMain:(dispatch_block_t)block;

@end
