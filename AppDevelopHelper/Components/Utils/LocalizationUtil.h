//
//  LocalizationUtil.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/8/4.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalizationUtil : NSObject

+ (NSString *)appLanguage;
+ (BOOL)isChinese;

@end

extern NSString* kLocalized(NSString* key);
extern NSString* kAppLocalized(NSString* key);
