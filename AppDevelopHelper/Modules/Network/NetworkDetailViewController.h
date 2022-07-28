//
//  NetworkDetailViewController.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/14.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHNetworkTransaction.h"

@interface NetworkDetailViewController : NSViewController

- (void)clearContent;
- (void)setTransaction: (ADHNetworkTransaction *)transaction;

@end
