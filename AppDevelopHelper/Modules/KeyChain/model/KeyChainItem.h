//
//  KeyChainItem.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/9/2.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * unknown
 * available 已获取value
 * not set   value未设置
 */
typedef NS_ENUM(NSUInteger, KeyChainItemValueStatus) {
    KeyChainItemValueStatusUnknown = 0,
    KeyChainItemValueStatusAvailable,
    KeyChainItemValueStatusNotSet,
};

@interface KeyChainItem : NSObject

@property (nonatomic, strong) NSDictionary *attrData;

@property (nonatomic, assign) KeyChainItemValueStatus status;
@property (nonatomic, strong) NSData *valueData;
@property (nonatomic, strong) NSString *valueText;

+ (KeyChainItem *)itemWithData: (NSDictionary *)data;


@end
