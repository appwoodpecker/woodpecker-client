//
//  WeakProxyObject.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/24.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeakProxyObject : NSObject

- (instancetype) initWithObject:(id)object;
- (id)object;

@end

NS_ASSUME_NONNULL_END
