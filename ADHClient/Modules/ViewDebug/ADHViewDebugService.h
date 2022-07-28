//
//  ADHViewDebugService.h
//  ADHClient
//
//  Created by 张小刚 on 2019/2/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADHViewNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADHViewDebugService : NSObject

+ (ADHViewDebugService *)service;
- (ADHViewNode *)captureViewTree: (UIView *)view;
- (NSData *)snapshotViewList: (NSArray<NSString *> *)viewList;
- (NSData *)snapshotThisView: (UIView *)view;

- (UIView *)getViewWithAddress: (NSString *)insAddr;

@end

@interface ADHWeakView : NSObject

+ (ADHWeakView *)viewWithTarget: (UIView *)view;
- (UIView *)targetView;

@end

NS_ASSUME_NONNULL_END
