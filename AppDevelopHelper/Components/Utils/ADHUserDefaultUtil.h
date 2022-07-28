//
//  UserDefaultUtil.h
//  
//
//  Created by 张 小刚 on 13-9-23.
//  Copyright (c) 2013年 duohuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHUserDefaultUtil : NSObject

+ (void)setDefaultValue: (id)value forKey: (NSString *)key;
+ (id)defaultValueForKey: (NSString *)key;
+ (void)empty;

//set domain
//if (domain == nil)  domain = default doamin
+ (void)setDefaultValue: (id)value forKey: (NSString *)key inDomain: (NSString *)domain;
+ (id)defaultValueForKey: (NSString *)key inDomain: (NSString *)domain;
+ (void)emptyDomain: (NSString *)domain;

+ (void)setVersionDefaultValue: (id)value forKey: (NSString *)key;
+ (id)versionDefaultValueForKey: (NSString *)key;
+ (void)emptyVersion;


@end

#pragma mark ---------------- Content ---------------

/*
 ///standard UserDefaults
 @{
    @"defaultDomain" : @{
        @"city" : @"nanjing",
    },
 
    @"customDomain" : @{
        @"weather" : @"qing",
    }
 }
 
*/
