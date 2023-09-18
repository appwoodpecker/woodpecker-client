//
//  IndexTestViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/7/11.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "IndexTestViewController.h"
#import "EntitlementUtil.h"
#import "SceneTestViewController.h"
#import "RateViewController.h"
#import "PayViewController.h"

@import StoreKit;

@interface IndexTestViewController ()<NSTableViewDelegate,NSTableViewDataSource,ADHBaseCellDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSArray *list;

@property (nonatomic, strong) SKProductsRequest *request;

@end

@implementation IndexTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 40.0f;
    [self loadContent];
    [self.tableView reloadData];
}

- (void)loadContent {
    self.list = @[
                  @{
                      @"title" : @"支付",
                      @"action" : NSStringFromSelector(@selector(doPayUI)),
                  },
                  @{
                      @"title" : @"Mark Pro(Legacy)",
                      @"action" : NSStringFromSelector(@selector(doLegacyMarkPro)),
                  },
                  @{
                      @"title" : @"Toast适配",
                      @"action" : NSStringFromSelector(@selector(doToastTest)),
                  },
                  @{
                      @"title" : @"版本更新标识",
                      @"action" : NSStringFromSelector(@selector(doVersionTest)),
                      },
                  @{
                      @"title" : @"首次启动标识",
                      @"action" : NSStringFromSelector(@selector(doWelcomeTest)),
                      },
                  @{
                      @"title" : @"Rate",
                      @"action" : NSStringFromSelector(@selector(doRateTest)),
                      },
                  @{
                      @"title" : @"取消Rate标记",
                      @"action" : NSStringFromSelector(@selector(doUnmarkRate)),
                      },
                  @{
                      @"title" : @"scene test",
                      @"action" : NSStringFromSelector(@selector(showScene)),
                      },
                  @{
                      @"title" : @"show success hud",
                      @"action" : NSStringFromSelector(@selector(showSuccessHud)),
                      },
                  @{
                      @"title" : @"show success without text",
                      @"action" : NSStringFromSelector(@selector(showSuccessWithoutText)),
                      },
                  @{
                      @"title" : @"Purchase",
                      @"action" : NSStringFromSelector(@selector(encode1)),
                      },
                  @{
                      @"title" : @"Restore purchase",
                      @"action" : NSStringFromSelector(@selector(encode2)),
                      },
                  @{
                      @"title" : @"Mark Pro",
                      @"action" : NSStringFromSelector(@selector(markPro)),
                      },
                  @{
                      @"title" : @"Unmark Pro",
                      @"action" : NSStringFromSelector(@selector(unmarkPro)),
                      },
                  @{
                      @"title" : @"Pro Check",
                      @"action" : NSStringFromSelector(@selector(proCheck)),
                      },
                  @{
                      @"title" : @"Pro Routine",
                      @"action" : NSStringFromSelector(@selector(proRoutine)),
                      },
                  @{
                      @"title" : @"Tell app disconnect",
                      @"action" : NSStringFromSelector(@selector(disConnectTest)),
                      },
                  @{
                      @"title" : @"File Test",
                      @"action" : NSStringFromSelector(@selector(doFileTest)),
                      },
                  @{
                      @"title" : @"Which Screen",
                      @"action" : NSStringFromSelector(@selector(doScreenTest)),
                      },
                  @{
                      @"title" : @"Entitlement Parse",
                      @"action" : NSStringFromSelector(@selector(doEntitlementTest)),
                      },
                  ];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.list.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *data = self.list[row];
    ADHBaseCell * cell = [tableView makeViewWithIdentifier:@"cellId" owner:nil];
    NSString *title = data[@"title"];
    cell.textField.stringValue = title;
    cell.delegate = self;
    return cell;
}

- (void)cellClicked: (ADHBaseCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    NSDictionary *data = self.list[row];
    SEL selector = NSSelectorFromString(data[@"action"]);
    [self performSelector:selector withObject:nil];
}

- (void)showSuccessHud {
    [self showSuccessWithText:@"Success"];
}

- (void)showSuccessWithoutText {
    [self showSuccess];
}

- (void)purchase {
    [self doRequestProduct];
}

- (void)restore {
    [self.view showHud];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)doRequestProduct {
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"lifebetter.woodpecker.pro"]];
    request.delegate = self;
    self.request = request;
    [self.request start];
    [self.view showHud];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [self.view hideHud];
    SKProduct *product = nil;
    if(response.products.count > 0) {
        product = response.products[0];
    }
    if(!product) {
        return;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    NSString *tip = [NSString stringWithFormat:@"%@ %@",product.localizedTitle,formattedPrice];
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [ADHAlert alertWithMessage:@"内购提醒" infoText:tip comfirmBlock:^{
            [wself startPayWithProduct:product];
        } cancelBlock:nil];
    });
}

- (void)startPayWithProduct: (SKProduct *)product {
    //start pay
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *trans in transactions) {
        SKPaymentTransactionState state = trans.transactionState;
        if(state == SKPaymentTransactionStatePurchasing) {
            [self.view showHud];

            //begin
        }else if(state == SKPaymentTransactionStateDeferred){
            //not finished
            
        }else if(state == SKPaymentTransactionStatePurchased || state == SKPaymentTransactionStateRestored) {
            //success
            
            //mark finish
            [[SKPaymentQueue defaultQueue] finishTransaction:trans];
            [self.view hideHud];
        }else if(state == SKPaymentTransactionStateFailed) {
            //failed
            
            //mark finish
            [[SKPaymentQueue defaultQueue] finishTransaction:trans];
            [self.view hideHud];
        }
    }
}

- (void)doLegacyMarkPro {
    [PayService.shared testMarkProLegacy];
}

- (void)markPro {
    [[PayService shared] setPro:YES];
}

- (void)unmarkPro {
    [[PayService shared] testClearPro];
}

- (void)proCheck {
    if(isPro) {
        [self showSuccessWithText:@"Pro User"];
    }else {
        [self showErrorWithText:@"Not Pro User"];
    }
}

- (void)proRoutine {
    if(!doProCheckRoutine()) {
        return;
    }else {
        [self showSuccessWithText:@"Pro User"];
    }
}

- (void)disConnectTest {
    //tell app that it will closed, and do not auto-connect.
    [self.apiClient requestWithService:@"adh.appinfo" action:@"closeapp" onSuccess:^(NSDictionary *body, NSData *payload) {
        NSLog(@"request disconnect success");
    } onFailed:^(NSError *error) {
        NSLog(@"request disconnect failed");
    }];
}

- (void)doFileTest {
    NSString *testPath = [[EnvtService sharedService] appFileWorkPath];
    NSString * filePath = [testPath stringByAppendingPathComponent:@"test.txt"];
    NSData *data = [@"lllll" dataUsingEncoding:NSUTF8StringEncoding];
    NSTimeInterval day = 24 * 60 * 60;
    NSDictionary *attributes = @{
                                 NSFileCreationDate : [NSDate dateWithTimeIntervalSinceNow:-2 * day],
                                 NSFileModificationDate : [NSDate dateWithTimeIntervalSinceNow:-1*day],
                                 };
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:attributes];
}

- (void)doScreenTest {
    NSScreen *screen = self.view.window.screen;
    NSLog(@"screen: (%.f,%.f %.f,%.f)",screen.frame.origin.x,screen.frame.origin.y,screen.frame.size.width,screen.frame.size.height);
}

- (void)doEntitlementTest {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testembedded" ofType:@"mobileprovision"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary * info = [EntitlementUtil parseEntitlementData:data];
}

- (void)showScene {
    SceneTestViewController *vc = [[SceneTestViewController alloc] init];
    [self presentViewControllerAsModalWindow:vc];
}

- (void)doRateTest {
    RateViewController *rateVC = [[RateViewController alloc] init];
    [self presentViewControllerAsModalWindow:rateVC];
}

- (void)doUnmarkRate {
    [Preference resetLaunchTimes];
    [Preference markRated:NO];
}

- (void)doWelcomeTest {
    [Preference setWelcomePageShowd:NO];
}

- (void)doVersionTest {
    [Preference setLatestVersion:@""];
}

- (void)doToastTest {
    [self.view showToastWithIcon:@"icon_status_error" statusText:@"担惊受恐非即时俩房间阿双方均奥斯卡理发 担惊受恐非即时俩"];
}

- (void)doPayUI {
    PayViewController *rateVC = [[PayViewController alloc] init];
    [self presentViewControllerAsModalWindow:rateVC];
}

@end
