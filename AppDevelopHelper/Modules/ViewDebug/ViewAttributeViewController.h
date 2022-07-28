//
//  ViewAttributeViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewDebugNode.h"
#import "ViewDebugDomain.h"

NS_ASSUME_NONNULL_BEGIN

//右侧属性
@interface ViewAttributeViewController : NSViewController

@property (nonatomic, weak) ViewDebugDomain *domain;

@end

NS_ASSUME_NONNULL_END
