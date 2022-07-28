//
//  ADHAction.m
//  ADHClient
//
//  Created by 张小刚 on 2017/11/4.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHRequest.h"
#import "ADHRequestPrivate.h"

@interface ADHRequest ()

//private use by dispatcher
@property (nonatomic, weak) ADHSession * tSession;
//set by dispatcher call finish method not this block
@property (nonatomic, strong) ADHActionResponseBlock responseBlock;

/**
 the service object which handle current request
 
 * use strong to prevent service release before request finish (do not modify)
 */
@property (nonatomic, strong) ADHService * serviceObj;

@end

@implementation ADHRequest

- (void)finish
{
    [self finishWithBody:nil payload:nil];
}

- (void)finishWithBody: (NSDictionary *)body
{
    [self finishWithBody:body payload:nil];
}

- (void)finishWithBody: (NSDictionary *)body payload: (NSData *)payload
{
    self.responseBlock(body, payload, self);
}

@end
