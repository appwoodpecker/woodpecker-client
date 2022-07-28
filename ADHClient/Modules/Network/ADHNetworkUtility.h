//
//  ADHNetworkUtility.h
//  ADHClient
//
//  Created by 张小刚 on 2017/12/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface ADHNetworkUtility : NSObject

// Swizzling utilities

+ (SEL)swizzledSelectorForSelector:(SEL)selector;
+ (BOOL)instanceRespondsButDoesNotImplementSelector:(SEL)selector class:(Class)cls;
+ (void)replaceImplementationOfKnownSelector:(SEL)originalSelector onClass:(Class)class withBlock:(id)block swizzledSelector:(SEL)swizzledSelector;
+ (void)replaceImplementationOfSelector:(SEL)selector withSelector:(SEL)swizzledSelector forClass:(Class)cls withMethodDescription:(struct objc_method_description)methodDescription implementationBlock:(id)implementationBlock undefinedBlock:(id)undefinedBlock;
+ (void)sniffWithoutDuplicationForObject:(NSObject *)object selector:(SEL)selector sniffingBlock:(void (^)(void))sniffingBlock originalImplementationBlock:(void (^)(void))originalImplementationBlock;

@end
