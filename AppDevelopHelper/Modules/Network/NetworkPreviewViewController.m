//
//  NetworkPreviewViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/16.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NetworkPreviewViewController.h"
#import "ADHFilePreviewController.h"
#import "ADHNetworkTransaction.h"
#import "NetworkService.h"

@interface NetworkPreviewViewController ()

@property (nonatomic, strong) ADHFilePreviewController * previewVC;

@end

@implementation NetworkPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self loadContent];
}

- (void)setupAfterXib {
    ADHFilePreviewController * previewVC = [[ADHFilePreviewController alloc] init];
    previewVC.formatBeautify = self.formatBeautify;
    NSView * contentView = previewVC.view;
    contentView.frame = self.view.bounds;
    contentView.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    [self.view addSubview:contentView];
    self.previewVC = previewVC;
}

- (void)loadContent {
    //检查本地是否存在，如果不存在加载
    BOOL shouldLoad = NO;
    if(self.transaction.receivedDataLength > 0 && ![[NetworkService serviceWithContext:self.context] responseBodyExistsForTransaction:self.transaction]){
        shouldLoad = YES;
    }
    if(shouldLoad){
        [self dataRequest];
    }else{
        [self doPreviewResponseBody];
    }
}

- (void)doPreviewResponseBody {
    NSString * path = [[NetworkService serviceWithContext:self.context] getTransactionResponseBodyPath:self.transaction];
    self.previewVC.filePath = path;
    NSString * mimeType = [self.transaction.response MIMEType];
    self.previewVC.mimeType = mimeType;
    [self.previewVC reload];
}

- (void)dataRequest {
    [self.view showHud];
    __weak typeof(self) wself = self;
    [[NetworkService serviceWithContext:self.context] downloadResponseBody:self.transaction onCompletion:^(NSString *path) {
        [wself.view hideHud];
        [wself doPreviewResponseBody];
    } onError:^(NSError * error) {
        [wself.view hideHud];
    }];
}


@end











