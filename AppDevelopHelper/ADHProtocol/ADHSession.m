//
//  ADHSession.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHSession.h"
#import "ADHSocketChannel.h"

@implementation ADHSession

+ (ADHSession *)session
{
    return [[ADHSession alloc] init];
}

/**
 * gcdsocket的tag使用了session.tag，gcd只支持long型(在arm32平台为32位)
 * 这边tag设置为31位，确保正常
 */
- (void)setTag
{
    uint32_t tag = 0;
    uint32_t interval = (uint32_t)([[NSDate date] timeIntervalSince1970]);
    uint32_t random = arc4random();
    uint32_t tmp = interval + random;
    //31位
    tmp = (tmp >> 1);
    tag = tmp;
    self.tag = tag;
}

- (float)progress
{
    float progress = 0.0f;
    SessionStatus status = self.status;
    if(self.isLocalToRemote){
        float reqPercent = [self requestProgressPercent];
        if(status == SessionStatusDefault){
            progress = 0.0f;
        }else if(status == SessionStatusSendRequest){
            float requestProgress = [self.request progress];
            progress = requestProgress * reqPercent;
        }else if(status == SessionStatusSendRequestFinish){
            progress = 1.0 *reqPercent;
        }else if(status == SessionStatusReceiveResponse){
            float responseProgress = [self.response progress];
            progress = reqPercent + (1-reqPercent)*responseProgress;
        }else if(status == SessionStatusReceiveResponseFinish){
            progress = 1.0f;
        }
    }else{
        if(status == SessionStatusDefault){
            progress = 0.0f;
        }else if(status == SessionStatusSendRequest){
            float requestProgress = [self.request progress];
            progress = requestProgress;
        }else if(status == SessionStatusSendRequestFinish){
            progress = 1.0f;
        }
    }
    return progress;
}

- (float)requestProgressPercent
{
    float percent = 0.0f;
    if(self.request.payload){
        percent = 0.5;
    }else{
        percent = 0.1;
    }
    return percent;
}

@end

















