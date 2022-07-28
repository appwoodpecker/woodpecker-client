//
//  UrlUtil.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/4/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlUtil : NSObject

+ (NSString *)filteredUrl: (NSString *)url;

+ (void)openExternalUrl: (NSString *)url;
+ (void)openExternalLocalizedUrl: (NSString *)url;

+ (void)openInFinder: (NSString *)path;

@end
