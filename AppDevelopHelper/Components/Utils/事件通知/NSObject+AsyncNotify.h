//
//  DHObject.h
//  Flux
//
//  Created by 张小刚 on 16/4/3.
//  Copyright © 2016年 lyeah company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ADHAsyncNotify)

- (void)setNotificationInfoForName:(NSString *)aName selectorName:(NSString *) selectorName async:(BOOL) async;
- (void)checkNotificationFired:(NSString *)aName;

@end
