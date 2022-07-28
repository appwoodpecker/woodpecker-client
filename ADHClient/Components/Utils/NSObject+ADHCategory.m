//
//  NSObject+ADHCategory.m
//  ADHClient
//
//  Created by 张小刚 on 2020/8/1.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "NSObject+ADHCategory.h"

@implementation NSObject (ADHCategory)

- (nonnull id)adhCallMethod:(NSString *)selName {
    return [self adhCallMethod:selName args:nil];
}

/**
 * 目前支持NSInteger,object
 */
- (nonnull id)adhCallMethod:(NSString *)selName args: (nullable NSArray *)arglist {
    if(!selName) {
        return nil;
    }
    SEL selector = NSSelectorFromString(selName);
    NSMethodSignature *sig = [self methodSignatureForSelector:selector];
    if(!sig) {
        return nil;
    }
    NSInvocation *call = [NSInvocation invocationWithMethodSignature:sig];
    call.target = self;
    call.selector = selector;
    if(arglist.count > 0) {
        for (NSInteger i=0; i<arglist.count; i++) {
            id value = arglist[i];
            NSInteger argIndex = 2+i;
            const char * ctype = [sig getArgumentTypeAtIndex:argIndex];
            if(strcmp(ctype, @encode(NSInteger)) == 0) {
                NSInteger intValue = [value integerValue];
                [call setArgument:&intValue atIndex:argIndex];
            }else if(strcmp(ctype, @encode(double)) == 0) {
                double doubleValue = [value doubleValue];
                [call setArgument:&doubleValue atIndex:argIndex];
            }else if(strcmp(ctype, @encode(id)) == 0) {
                [call setArgument:&value atIndex:argIndex];
            }else if(strcmp(ctype, "@?") == 0) {
                [call setArgument:&value atIndex:argIndex];
            }
        }
    }
    [call invoke];
    id resultValue = nil;
    const char * ctype = [sig methodReturnType];
    if(strcmp(ctype, @encode(id)) == 0) {
        __unsafe_unretained id value;
        [call getReturnValue:&value];
        resultValue = value;
    }else if(strcmp(ctype, @encode(double)) == 0) {
        double value;
        [call getReturnValue:&value];
        resultValue = @(value);
    }else if(strcmp(ctype, @encode(NSInteger)) == 0) {
        NSInteger value;
        [call getReturnValue:&value];
        resultValue = @(value);
    }
    return resultValue;
}


@end
