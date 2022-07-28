//
//  FunctionUtil.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/5/13.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "FunctionUtil.h"

@implementation FunctionUtil

+ (void)performBlock: (void (^)(void))block after: (NSTimeInterval)seconds {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(block) {
            block();
        }
    });
}

+ (NSString *)readbleBytesSize: (uint64_t)size {
    NSString * value = @"";
    if(size < 1024){
        value = [NSString stringWithFormat:@"%llu Bytes",size];
    }else if(size < 1024 * 1024){
        float kbValue = (size / 1024.0f);
        value = [NSString stringWithFormat:@"%.2f KB",kbValue];
    }else {
        float mbValue = (size/(1024*1024.0f));
        value = [NSString stringWithFormat:@"%.2f MB",mbValue];
    }
    return value;
}

+ (void)performBlockInMain:(dispatch_block_t)block {
    if([[NSThread currentThread] isMainThread]) {
        block();
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

@end
