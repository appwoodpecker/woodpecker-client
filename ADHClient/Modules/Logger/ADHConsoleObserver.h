//
//  ADHConsoleMocker.h
//  Logger
//
//  Created by zhangxiaogang on 2018/6/7.
//  Copyright © 2018年 zhangxiaogang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHConsoleActionService.h"

@interface ADHConsoleObserver : NSObject

+ (ADHConsoleObserver *)sharedObserver;
- (void)start;
- (void)stop;

- (void)setActionService: (ADHConsoleActionService *)consoleService;

@end
