//
//  ADHLogConsoleService.h
//  ADHClient
//
//  Created by 张小刚 on 2018/6/7.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHService.h"

@interface ADHConsoleActionService : ADHService

- (void)onReceiveNewLog: (NSString *)content;

@end
