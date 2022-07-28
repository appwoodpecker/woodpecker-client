//
//  ADHNetworkUtility.m
//  ADHClient
//
//  Created by 张小刚 on 2017/12/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHNetworkUtility.h"

@implementation ADHNetworkUtility

+ (SEL)swizzledSelectorForSelector:(SEL)selector
{
    return NSSelectorFromString([NSString stringWithFormat:@"_adh_swizzle_%x_%@", arc4random(), NSStringFromSelector(selector)]);
}

+ (BOOL)instanceRespondsButDoesNotImplementSelector:(SEL)selector class:(Class)cls
{
    if ([cls instancesRespondToSelector:selector]) {
        unsigned int numMethods = 0;
        Method *methods = class_copyMethodList(cls, &numMethods);
        
        BOOL implementsSelector = NO;
        for (int index = 0; index < numMethods; index++) {
            SEL methodSelector = method_getName(methods[index]);
            if (selector == methodSelector) {
                implementsSelector = YES;
                break;
            }
        }
        
        free(methods);
        
        if (!implementsSelector) {
            return YES;
        }
    }
    
    return NO;
}

+ (void)replaceImplementationOfKnownSelector:(SEL)originalSelector onClass:(Class)class withBlock:(id)block swizzledSelector:(SEL)swizzledSelector
{
    // This method is only intended for swizzling methods that are know to exist on the class.
    // Bail if that isn't the case.
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    if (!originalMethod) {
        return;
    }
    
    IMP implementation = imp_implementationWithBlock(block);
    class_addMethod(class, swizzledSelector, implementation, method_getTypeEncoding(originalMethod));
    Method newMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, newMethod);
}

+ (void)replaceImplementationOfSelector:(SEL)selector withSelector:(SEL)swizzledSelector forClass:(Class)cls withMethodDescription:(struct objc_method_description)methodDescription implementationBlock:(id)implementationBlock undefinedBlock:(id)undefinedBlock
{
    if ([self instanceRespondsButDoesNotImplementSelector:selector class:cls]) {
        return;
    }
    //block -> sel function
    IMP implementation = imp_implementationWithBlock((id)([cls instancesRespondToSelector:selector] ? implementationBlock : undefinedBlock));
    /**
     如果old selector存在则添加新实现，并用新selector替换旧selector
     否则仅添加原selector为新实现
     */
    Method oldMethod = class_getInstanceMethod(cls, selector);
    if (oldMethod) {
        class_addMethod(cls, swizzledSelector, implementation, methodDescription.types);
        
        Method newMethod = class_getInstanceMethod(cls, swizzledSelector);
        
        method_exchangeImplementations(oldMethod, newMethod);
    } else {
        class_addMethod(cls, selector, implementation, methodDescription.types);
    }
}

#pragma mark Delegate Injection Convenience Methods


/// All swizzled delegate methods should make use of this guard.
/// This will prevent duplicated sniffing when the original implementation calls up to a superclass implementation which we've also swizzled.
/// The superclass implementation (and implementations in classes above that) will be executed without inteference if called from the original implementation.
+ (void)sniffWithoutDuplicationForObject:(NSObject *)object selector:(SEL)selector sniffingBlock:(void (^)(void))sniffingBlock originalImplementationBlock:(void (^)(void))originalImplementationBlock
{
    // If we don't have an object to detect nested calls on, just run the original implmentation and bail.
    // This case can happen if someone besides the URL loading system calls the delegate methods directly.
    // See https://github.com/Flipboard/FLEX/issues/61 for an example.
    if (!object) {
        originalImplementationBlock();
        return;
    }
    
    const void *key = selector;
    
    // Don't run the sniffing block if we're inside a nested call
    if (!objc_getAssociatedObject(object, key)) {
        sniffingBlock();
    }
    
    // Mark that we're calling through to the original so we can detect nested calls
    objc_setAssociatedObject(object, key, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    originalImplementationBlock();
    objc_setAssociatedObject(object, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
