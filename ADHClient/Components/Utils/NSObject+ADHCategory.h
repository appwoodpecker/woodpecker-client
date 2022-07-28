//
//  NSObject+ADHCategory.h
//  ADHClient
//
//  Created by 张小刚 on 2020/8/1.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ADHCategory)

/**
 * 目前参数支持NSInteger,Douelb,object,Block
 */
- (nonnull id)adhCallMethod:(NSString *)selName args: (nullable NSArray *)arglist;
- (nonnull id)adhCallMethod:(NSString *)selName;

@end

NS_ASSUME_NONNULL_END
