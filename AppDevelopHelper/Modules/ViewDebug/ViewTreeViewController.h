//
//  ViewTreeViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewDebugDomain.h"

NS_ASSUME_NONNULL_BEGIN

//左侧导航
@interface ViewTreeViewController : NSViewController

@property (nonatomic, weak) ViewDebugDomain *domain;

@end

NS_ASSUME_NONNULL_END
