//
//  IPCCaller.m
//  woodpk
//
//  Created by 张小刚 on 2023/9/10.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import "IPCCaller.h"
#import "NSObject+Json.h"

static NSString *const kMessagePortName = @"lifebetter.woodpecker.wooder";

@implementation IPCCaller

- (NSString *)call {
    NSString *service = [[NSUserDefaults standardUserDefaults] valueForKey:@"service"];
    NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey:@"action"];
    if (service == nil || action == nil) {
        service = @"adh.default";
        action = @"echo";
    }
    NSDictionary *params = @{
        @"service" : service,
        @"action" : action,
    };
    NSString *json = [params adh_jsonPresentation];
    // 生成Remote port
    CFStringRef cfName = (__bridge CFStringRef)(kMessagePortName);
    CFMessagePortRef messagePort = CFMessagePortCreateRemote(kCFAllocatorDefault, cfName);
    if (nil == messagePort) {
        NSLog(@"messagePort create failed");
        return nil;
    }
    // 构建发送数据
    NSString *msg = json;
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    CFDataRef cfData = (__bridge CFDataRef)data;
    // 执行发送操作
    CFDataRef recvData = nil;
    CFMessagePortSendRequest(messagePort, 0, cfData, 0, 10000 , kCFRunLoopDefaultMode, &recvData);
    // 解析返回数据
    NSString *result = nil;
    if (recvData != nil) {
        NSData *data = (__bridge NSData *)recvData;
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        result = json;
    }
    CFMessagePortInvalidate(messagePort);
    CFRelease(messagePort);
    return result;
}

@end
