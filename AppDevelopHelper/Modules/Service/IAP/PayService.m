//
//  PayService.m
//  ZJActionProject
//
//  Created by zhangxiaogang on 2019/11/4.
//  Copyright © 2019 ZJSoft. All rights reserved.
//

#import "PayService.h"
#import "XYStoreiTunesReceiptVerifier.h"
#import "ADHUserDefaultUtil.h"
#import "ADHEncryptUtil.h"
#import "PayViewController.h"
#import "AppDelegate.h"

NSString *const kStoreServiceAuthStateUpdate = @"kStoreServiceAuthStateUpdate";

@interface PayService ()

@property (nonatomic, strong) NSArray *subscribeProductIds;
@property (nonatomic, strong) NSArray *persistProductIds;

@end

@implementation PayService

+ (PayService *)shared {
    static PayService *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[PayService alloc] init];
    });
    return sharedService;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiptVerfied:) name:kZJReceiptVerifiedNotification object:nil];
}

/**
 * 保存购买票据
 */
- (void)onReceiptVerfied: (NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString * productId = userInfo[@"productId"];
    NSDictionary * receipt = userInfo[@"receipt"];
    if(!productId || !receipt) {
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = paths[0];
    NSString *recordDirectory = [docPath stringByAppendingPathComponent:@"Receipt"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = [fm fileExistsAtPath:recordDirectory isDirectory:&isDir];
    if(!isExists || !isDir) {
        [fm createDirectoryAtPath:recordDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [NSString stringWithFormat:@"%@.plist",productId];
    NSString *path = [recordDirectory stringByAppendingPathComponent:fileName];
    [receipt writeToFile:path atomically:YES];
    [self checkIapExpireStatus];
}

/**
 * 检查订阅产品状态
 */
- (void)checkIapExpireStatus {
    
}

- (void)setupWithKey:(NSString *)secretKey
   subscribeProducts: (NSArray *)subscribeProductIds
     persistProducts: (NSArray *)persistProductIds {
    [[XYStore defaultStore] registerReceiptVerifier:[XYStoreiTunesReceiptVerifier shareInstance]];
    [XYStoreiTunesReceiptVerifier shareInstance].sharedSecretKey = secretKey;
    self.subscribeProductIds = subscribeProductIds;
    self.persistProductIds = persistProductIds;
    //检查过期状态
    [self checkIapExpireStatus];
}

- (void)setPro:(BOOL)pro {
    
}

//is pro
- (BOOL)isProUser {
    return YES;
}

#pragma mark legacy pro
- (BOOL)isLegacyProUser {
    return NO;
}

- (void)clearLegacyProUser {
    
}

/**
 * 设置去除广告状态
 */
- (void)setAdRemoved: (BOOL)removed {
    [[NSUserDefaults standardUserDefaults] setBool:removed forKey:@"isProvideContent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * 去除广告付费
 */
- (BOOL)isAdRemoved {
    return YES;
}

/**
 * 请求产品价格
 */
- (void)fetchProduct:(NSString *)productId success:(void (^)(SKProduct *product, NSString *price))success {
    __weak typeof(self) wself = self;
    [[XYStore defaultStore] fetchProduct:productId success:^(SKProduct *product) {
        NSString *priceStr = [XYStore localizedPriceOfProduct:product];
        [wself saveProductPrice:priceStr product:product.productIdentifier];
        if(success) {
            success(product, priceStr);
        }
     } failure:^(NSError *error) {
        
     }];
}

/**
 * 获取本地缓存的产品价格
 */
- (NSString *)getProductPrice: (NSString *)productId {
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:productId];
    return value;
}

- (void)saveProductPrice: (NSString *)price product: (NSString *)productId {
    [[NSUserDefaults standardUserDefaults] setObject:price forKey:productId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * 获取产品部分价格
 * factor: 比如product为年，需要获取每月的价格时factor=1/12.0
 */
- (NSString *)getProductPrice: (NSString *)productId factor: (float)factor {
    SKProduct *product = [[XYStore defaultStore] productForIdentifier:productId];
    if(!product) {
        return @"";
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    numberFormatter.locale = product.priceLocale;
    numberFormatter.roundingMode = NSNumberFormatterRoundDown;
    NSDecimalNumber *price = product.price;
    NSString *multiplier = [NSString stringWithFormat:@"%f",factor];
    NSDecimalNumber *multiplierNumber = [NSDecimalNumber decimalNumberWithString:multiplier];
    NSDecimalNumber *resultPrice = [price decimalNumberByMultiplyingBy:multiplierNumber];
    NSString *priceText = [numberFormatter stringFromNumber:resultPrice];
    return priceText;
}

- (void)addPayment:(NSString*)productIdentifier
           success:(void (^)(NSString *productId))successBlock
           failure:(void (^)(NSString *productId, NSError *error))failureBlock
{
    __weak typeof(self) wself = self;
    [[XYStore defaultStore] addPayment:productIdentifier success:^(SKPaymentTransaction *transaction) {
        [wself performBlockInMain:^{
            [wself setPro:YES];
            if(successBlock) {
                successBlock(transaction.transactionIdentifier);
            }
        }];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [wself performBlockInMain:^{
            if(failureBlock) {
                failureBlock(transaction.transactionIdentifier,error);
            }
        }];
    }];
}

/**
 * restore
 */
- (void)restoreTransactionsOnSuccess:(void (^)(BOOL pro, BOOL removeAd))successBlock
                             failure:(void (^)(NSError *error))failureBlock {
    __weak typeof(self) wself = self;
    [[XYStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
        BOOL pro = NO;
        BOOL removeAd = NO;
        //永久型
        for (NSString *productId in self.persistProductIds) {
            if ([[XYStoreiTunesReceiptVerifier shareInstance] isValidWithPersistentProductId:productId]) {
                pro = YES;
                break;
            }
        }
        //订阅型
        if (!pro) {
            for (NSString *productId in self.subscribeProductIds) {
                if ([[XYStoreiTunesReceiptVerifier shareInstance] isSubscribedWithAutoRenewProduct:productId]) {
                    pro = YES;
                    break;
                }
            }
        }
        /*
        if(!pro) {
            for (SKPaymentTransaction *transaction in transactions) {
                if ([transaction.payment.productIdentifier isEqualToString:kProductRemoveAd]) {
                    removeAd = YES;
                    break;
                }
            }
        }*/
        [wself performBlockInMain:^{
            if (pro) {
                [wself setPro:YES];
            }
            if(successBlock) {
                successBlock(pro,removeAd);
            }
        }];
    } failure:^(NSError *error) {
        [wself performBlockInMain:^{
            if(failureBlock) {
                failureBlock(error);
            }
        }];
    }];
}

- (void)performBlockInMain:(dispatch_block_t)block {
    if([[NSThread currentThread] isMainThread]) {
        block();
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

#pragma mark interface

- (BOOL)fastCheckPro {
    return YES;
}

//pro check routine
- (BOOL)doProCheckRoutine {
    if ([self fastCheckPro]) {
        return YES;
    }
    //唤起支付
    static dispatch_source_t timer = nil;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC, 0);
    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(timer, ^{
        timer = nil;
        [wself showPayUI];
    });
    dispatch_resume(timer);
    return NO;
}

- (void)showPayUI {
    PayViewController *vc = [[PayViewController alloc] init];
    AppDelegate *delegate = (AppDelegate *)NSApp.delegate;
    MainWindowController *mainWC = delegate.mainWC;
    NSTabViewController *tabVC = mainWC.tabVC;
    [tabVC presentViewControllerAsModalWindow:vc];
}

#pragma mark Test

- (void)testClearPro {
    [self clearLegacyProUser];
    [self setPro:NO];
}

- (void)testMarkProLegacy {
    
}

@end
