//
//  StoreService.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/10.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "StoreService.h"
@import StoreKit;

NSString *const kStoreServiceAuthStateUpdate = @"kStoreServiceAuthStateUpdate";

@interface XMLUtil ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, weak) NSView *contentView;

@end

@implementation XMLUtil

+ (XMLUtil *)service {
    static dispatch_once_t onceToken;
    static XMLUtil * sharedService = nil;
    dispatch_once(&onceToken, ^{
        sharedService = [[XMLUtil alloc] init];
    });
    return sharedService;
}

- (void)doPurchaseRoutine {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = kLocalized(@"pro_title");
    alert.informativeText = kLocalized(@"pro_info");
    [alert addButtonWithTitle:kLocalized(@"pro_upgrade")];
    [alert addButtonWithTitle:kLocalized(@"restore_purchase")];
    [alert addButtonWithTitle:kAppLocalized(@"Cancel")];
    NSModalResponse response = [alert runModal];
    if(response == NSAlertFirstButtonReturn) {
        [self purchase];
    }else if(response == NSAlertSecondButtonReturn) {
        [self restore];
    }else if(response == NSAlertThirdButtonReturn) {
        //cancel
    }
}

- (void)purchase {
    [self prepareContext];
    [self doRequestProduct];
}

- (void)restore {
    [self prepareContext];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [self showHud];
}

- (void)doRequestProduct {
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"lifebetter.woodpecker.pro"]];
    request.delegate = self;
    self.request = request;
    [self.request start];
    [self showHud];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [self hideHud];
    SKProduct *product = nil;
    if(response.products.count > 0) {
        product = response.products[0];
    }
    if(!product) {
        return;
    }
    [self startPayWithProduct:product];
}

//start pay
- (void)startPayWithProduct: (SKProduct *)product {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    __weak typeof(self) wself = self;
    [self performBlockInMain:^{
        for (SKPaymentTransaction *trans in transactions) {
            SKPaymentTransactionState state = trans.transactionState;
            if(state == SKPaymentTransactionStatePurchasing) {
                [wself showHud];
                //begin
            }else if(state == SKPaymentTransactionStateDeferred){
                //not finished
                
            }else if(state == SKPaymentTransactionStatePurchased || state == SKPaymentTransactionStateRestored) {
                //success
                [wself hideHud];
                [[SKPaymentQueue defaultQueue] finishTransaction:trans];
                [wself doPurchaseSuccess];
            }else if(state == SKPaymentTransactionStateFailed) {
                //failed
                [wself hideHud];
                [[SKPaymentQueue defaultQueue] finishTransaction:trans];
                [wself doPurchaseFailed];
            }
        }
    }];
}

- (void)showHud {
    __weak typeof(self) wself = self;
    [self performBlockInMain:^{
        [wself.contentView showHud];
    }];
}

- (void)hideHud {
    __weak typeof(self) wself = self;
    [self performBlockInMain:^{
        [wself.contentView hideHud];
    }];
}

- (void)doPurchaseSuccess {
    markPro();
    [[NSNotificationCenter defaultCenter] postNotificationName:kStoreServiceAuthStateUpdate object:nil];
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = kLocalized(@"pro_success_title");
    alert.informativeText = kLocalized(@"pro_success_info");
    [alert addButtonWithTitle:kLocalized(@"pro_success_start")];
    [alert runModal];
}

- (void)doPurchaseFailed {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = kLocalized(@"pro_failed_title");
    alert.informativeText = kLocalized(@"pro_failed_info");
    [alert addButtonWithTitle:kAppLocalized(@"Confirm")];
    [alert runModal];
}

- (void)prepareContext {
    self.contentView = NSApp.keyWindow.contentViewController.view;
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

@end
