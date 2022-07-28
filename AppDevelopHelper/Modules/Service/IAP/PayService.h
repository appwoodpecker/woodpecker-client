//
//  PayService.h
//  ZJActionProject
//
//  Created by zhangxiaogang on 2019/11/4.
//  Copyright © 2019 ZJSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;

#define isPro [PayService.shared fastCheckPro]
#define doProCheckRoutine() [PayService.shared doProCheckRoutine]

extern NSString *const kStoreServiceAuthStateUpdate;


//iap相关
@interface PayService : NSObject

+ (PayService *)shared;

/**
 * 初始设置
 * secretKey: enLocalized(@"yek")
 * subscribeProductIds: 订阅类型产品id
 * persistProductIds: 一次性订阅类型产品id
 */
- (void)setupWithKey:(NSString *)secretKey
   subscribeProducts: (NSArray *)subscribeProductIds
     persistProducts: (NSArray *)persistProductIds;

/**
 * 设置proUser状态
 */
- (void)setPro: (BOOL)pro;

/**
 * 是否为ProUser状态
 */
- (BOOL)isProUser;

/**
 * 设置去除广告状态
 */
- (void)setAdRemoved: (BOOL)removed;

/**
 * 去除广告付费
 */
- (BOOL)isAdRemoved;

/**
 * 请求产品价格
 */
- (void)fetchProduct:(NSString *)productId success:(void (^)(SKProduct *product, NSString *price))success;

/**
 * 获取本地缓存的产品价格
 */
- (NSString *)getProductPrice: (NSString *)productId;

/**
 * 获取产品部分价格
 * factor: 比如product为年，需要获取每月的价格时factor=1/12.0
 */
- (NSString *)getProductPrice: (NSString *)productId factor: (float)factor;

/**
 * pay
 */
- (void)addPayment:(NSString*)productIdentifier
           success:(void (^)(NSString *productId))successBlock
           failure:(void (^)(NSString *productId, NSError *error))failureBlock;

/**
 * restore
 */
- (void)restoreTransactionsOnSuccess:(void (^)(BOOL pro, BOOL adRemove))successBlock
                             failure:(void (^)(NSError *error))failureBlock;


#pragma mark

- (BOOL)fastCheckPro;
- (BOOL)doProCheckRoutine;
//清除pro和legacy pro
- (void)testClearPro;
- (void)testMarkProLegacy;

@end
