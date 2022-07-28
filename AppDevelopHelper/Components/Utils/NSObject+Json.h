//
//  NSObject+Json.h
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ADHJson)

- (NSString *)adh_jsonPresentation;

@end


@interface NSString (ADHJson)

- (id)adh_jsonObject;

@end
