//
//  NetworkItemCell.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/10.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ADHNetworkTransaction;
@interface NetworkTransactionCell : ADHBaseCell

- (void)setTransaction: (ADHNetworkTransaction *)transaction itemKey: (NSString *)key;
+ (CGFloat)rowHeight;

@end
