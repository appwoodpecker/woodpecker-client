//
//  ADHDispatcher+Default.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2023/9/2.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import "ADHDispatcher+Default.h"
#import "MacDefaultActionService.h"
#import "NetworkActionService.h"
#import "LogActionService.h"
#import "NotificationActionService.h"
#import "WebActionService.h"
#import "FileBrowserActionService.h"

@implementation ADHDispatcher (Default)

+ (ADHDispatcher *)macClientDispatcher {
    ADHDispatcher *dispatcher = [[ADHDispatcher alloc] init];
    [dispatcher registerService:[MacDefaultActionService class]];
    [dispatcher registerService:[NetworkActionService class]];
    [dispatcher registerService:[LogActionService class]];
    [dispatcher registerService:[NotificationActionService class]];
    [dispatcher registerService:[WebActionService class]];
    [dispatcher registerService:[FileBrowserActionService class]];
    return dispatcher;
}

@end
