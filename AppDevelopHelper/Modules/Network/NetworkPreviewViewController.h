//
//  NetworkPreviewViewController.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/16.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ADHNetworkTransaction;
@interface NetworkPreviewViewController : NSViewController

@property (nonatomic, strong) ADHNetworkTransaction * transaction;
@property (nonatomic, assign) BOOL formatBeautify;


@end
