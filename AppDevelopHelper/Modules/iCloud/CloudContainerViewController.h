//
//  CloudContainerViewController.h
//  Woodpecker
//
//  Created by 张小刚 on 2019/10/13.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CloudContainerViewController : NSViewController

@property (nonatomic, strong) NSString *currentContainerId;
@property (nonatomic, copy) void (^completionBlock)(NSString *containerId);

@end
