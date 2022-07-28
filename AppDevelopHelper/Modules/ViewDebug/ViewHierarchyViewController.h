//
//  ViewDebugViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewAttributeViewController.h"
#import "ViewDebugDomain.h"

NS_ASSUME_NONNULL_BEGIN

//中间3维视图
@interface ViewHierarchyViewController : NSViewController

@property (nonatomic, weak) ViewAttributeViewController *attributeVC;
@property (nonatomic, weak) ViewDebugDomain *domain;

@end

NS_ASSUME_NONNULL_END
