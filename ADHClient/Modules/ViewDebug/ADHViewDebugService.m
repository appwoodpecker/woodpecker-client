//
//  ADHViewDebugService.m
//  ADHClient
//
//  Created by 张小刚 on 2019/2/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHViewDebugService.h"
#import <objc/runtime.h>
#import "ADHAttributeUtil.h"

@interface ADHViewDebugService ()

@property (nonatomic, strong) NSArray *mWeakViews;

@end

@implementation ADHViewDebugService

+ (ADHViewDebugService *)service {
    static ADHViewDebugService * service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[ADHViewDebugService alloc] init];
    });
    return service;
}

- (void)releaseWeakViews {
    if(self.mWeakViews) {
        self.mWeakViews = nil;
    }
}

- (ADHViewNode *)captureViewTree: (UIView *)view {
    NSMutableArray *weakViews = [NSMutableArray array];
    ADHViewNode *node = [self traverseView:view parentNode:nil weakViews:weakViews];
    [self releaseWeakViews];
    self.mWeakViews = weakViews;
    return node;
}

/// view -> view属性node
- (ADHViewNode *)nodeWithView: (UIView *)view {
    ADHViewNode *node = [ADHViewNode node];
    ADHWeakView *weakView = [ADHWeakView viewWithTarget:view];
    node.weakView = weakView;
    node.instanceAddr = [self getInstanceAddr:view];
    node.weakViewAddr = [self getInstanceAddr:weakView];
    node.className = NSStringFromClass([view class]);
    //attributes
    NSArray<Class> *clazzList = [self getInstanceClassHierarchy:view];
    NSMutableArray *attributes = [NSMutableArray array];
    NSMutableArray *classList = [NSMutableArray array];
    for (Class clazz in clazzList) {
        NSString *className = NSStringFromClass(clazz);
        if(className) {
            [classList addObject:className];
        }
        ADHAttribute *attr = [ADHAttributeUtil attributeWithClass:clazz];
        if(!attr) {
            continue;
        }
        [attr setPropertyWithView:view];
        [attributes addObject:attr];
    }
    node.classList = classList;
    node.attributes = attributes;
    return node;
}

- (ADHViewNode *)traverseView: (UIView *)view parentNode: (ADHViewNode *)parent weakViews: (NSMutableArray *)weakViews {
    ADHViewNode *node = [self nodeWithView:view];
    if(node.weakView) {
        [weakViews addObject:node.weakView];
    }
    if(!parent) {
        //root
        node.parent = nil;
        node.level = 0;
    }else {
        node.parent = parent;
        [parent addChild:node];
        node.level = parent.level + 1;
    }
    NSArray *subViews = view.subviews;
    if(subViews.count > 0) {
        for (NSInteger i=0; i<subViews.count; i++) {
            UIView *subView = subViews[i];
            if(![self isViewValid:subView]) {
                continue;
            }
            [self traverseView:subView parentNode:node weakViews:weakViews];
        }
    }
    return node;
}

- (BOOL)isViewValid: (UIView *)view {
    BOOL valid = YES;
    if(view.hidden) {
        valid = NO;
    }
    return valid;
}

/*
- (NSData *)snapshotNodeTree: (ADHViewNode *)node {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [self traverseSnapshotNode:node intoData:data];
    NSData *snapshot = [NSKeyedArchiver archivedDataWithRootObject:data];
    return snapshot;
}

- (void)traverseSnapshotNode: (ADHViewNode *)node intoData: (NSMutableDictionary *)data {
    UIView *view = node.view;
    NSData *snapshot = [self snapshotThisView:view];
    if(snapshot) {
        data[node.instanceAddr] = snapshot;
    }
    if(node.childNodes.count > 0) {
        for (NSInteger i=0; i<node.childNodes.count; i++) {
            ADHViewNode *childNode = node.childNodes[i];
            [self traverseSnapshotNode:childNode intoData:data];
        }
    }
}
*/

- (NSData *)snapshotViewList: (NSArray<NSString *> *)viewList {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    for (NSString *insAddr in viewList) {
        UIView *view = [self getViewWithAddress:insAddr];
        if(view) {
            NSData *snapshot = [self snapshotThisView:view];
            if(snapshot) {
                data[insAddr] = snapshot;
            }
        }
    }
    NSData *snapshotData = nil;
    if(data.count > 0) {
        snapshotData = [NSKeyedArchiver archivedDataWithRootObject:data];
    }
    return snapshotData;
}

#pragma mark -----------------   util   ----------------

- (NSArray<Class> *)getInstanceClassHierarchy: (id)instance {
    NSMutableArray *clazzList = [NSMutableArray array];
    Class clazz = [instance class];
    while (clazz) {
        [clazzList addObject:clazz];
        clazz = class_getSuperclass(clazz);
    }
    return clazzList;
}

- (NSString *)getInstanceAddr: (id)instance {
    return [NSString stringWithFormat:@"%p",instance];
}

- (NSData *)snapshotThisView: (UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    NSArray *subViews = view.subviews;
    NSMutableArray *hiddenValues = [NSMutableArray arrayWithCapacity:subViews.count];
    for (UIView *subView in subViews) {
        [hiddenValues addObject:subView.hidden ? @(1):@(0)];
        subView.hidden = YES;
    }
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    for (NSInteger i=0; i<subViews.count; i++) {
        UIView *subView = subViews[i];
        BOOL hidden = [hiddenValues[i] boolValue];
        subView.hidden = hidden;
    }
    NSData *snapshot = UIImagePNGRepresentation(image);
    return snapshot;
}

- (UIView *)getViewWithAddress: (NSString *)insAddr {
    NSScanner *scanner = [NSScanner scannerWithString:insAddr];
    unsigned long long addr;
    [scanner scanHexLongLong:&addr];
    id instance = (__bridge id)((const void*)addr);
    UIView *view = nil;
    if([instance isKindOfClass:[ADHWeakView class]]) {
        ADHWeakView *weakView = (ADHWeakView *)instance;
        view = weakView.targetView;
    }
    return view;
}

@end

@interface ADHWeakView ()

@property (nonatomic, weak) UIView *mTargetView;

@end

@implementation ADHWeakView

+ (ADHWeakView *)viewWithTarget: (UIView *)view {
    ADHWeakView *weakView = [[ADHWeakView alloc] init];
    weakView.mTargetView = view;
    return weakView;
}

- (UIView *)targetView {
    return self.mTargetView;
}

@end
