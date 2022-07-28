//
//  ConsoleService.h
//  ADHClient
//
//  Created by 张小刚 on 2018/5/26.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHWebDebugService : NSObject

+ (ADHWebDebugService *)service;

- (void)setupWebView: (id)webView;
- (void)teardownWebView: (id)webView;

@end
