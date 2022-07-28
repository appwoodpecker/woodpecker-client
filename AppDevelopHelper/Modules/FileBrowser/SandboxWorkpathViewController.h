//
//  SandboxWorkpathViewController.h
//  Woodpecker
//
//  Created by 张小刚 on 2019/6/1.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileBrowserService.h"

@interface SandboxWorkpathViewController : NSViewController

@property (nonatomic) FileBrowserService *service;
@property (nonatomic, copy) void (^completionBlock)(NSString *path);
@property (nonatomic, copy) void (^updationBlock)(NSString *path);

@end
