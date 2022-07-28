//
//  SandboxContainerViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/10.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SandboxContainerViewController : NSViewController

@property (nonatomic, strong) NSString *currentContainerName;
@property (nonatomic, copy) void (^completionBlock)(NSString *containerName);

@end

NS_ASSUME_NONNULL_END
