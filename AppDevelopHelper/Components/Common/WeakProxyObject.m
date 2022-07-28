//
//  WeakProxyObject.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/24.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "WeakProxyObject.h"

@interface WeakProxyObject ()

@property (nonatomic, weak) id mObject;

@end

@implementation WeakProxyObject

- (instancetype) initWithObject:(id)object {
    self = [super init];
    if (self) {
        _mObject = object;
    }
    return self;
}

- (id)object {
    return self.mObject;
}

@end
