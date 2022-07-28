//
//  FileActivityViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/7/11.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SandboxViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileActivityViewController : NSViewController

@property (nonatomic, weak) SandboxViewController *container;

@end

NS_ASSUME_NONNULL_END
