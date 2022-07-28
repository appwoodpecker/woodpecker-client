//
//  ADHNetworkObserver.h
//  ADHClient
//
//  Created by 张小刚 on 2017/12/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHNetworkObserver : NSObject

+ (ADHNetworkObserver *)sharedObserver;
- (void)start;
- (void)stop;

@end
