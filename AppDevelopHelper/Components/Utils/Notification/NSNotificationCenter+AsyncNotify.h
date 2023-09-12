//
//  DHNotificationCenter.h
//  Flux
//
//  Created by 张小刚 on 16/4/3.
//  Copyright © 2016年 lyeah company. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "NSObject+AsyncNotify.h"


@interface NSNotificationCenter (ADHAsyncNotify)

- (void)addObserver:(_Nonnull id)observer selector:(_Nullable SEL)aSelector name:(nullable NSString *)aName object:(nullable id)anObject async: (BOOL)async;

@end
