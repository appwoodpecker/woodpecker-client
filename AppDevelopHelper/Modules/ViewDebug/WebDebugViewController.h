//
//  WebDebugViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/5/4.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHViewNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebDebugViewController : NSViewController

@property (nonatomic, strong) ADHViewNode *webNode;

@end

NS_ASSUME_NONNULL_END
