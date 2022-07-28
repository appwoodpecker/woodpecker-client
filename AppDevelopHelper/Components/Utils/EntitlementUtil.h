//
//  EntitlementUtil.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/9.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * parse entitlement file
 */
@interface EntitlementUtil : NSObject

+ (NSDictionary *)parseEntitlementData: (NSData *)data;

@end

NS_ASSUME_NONNULL_END
