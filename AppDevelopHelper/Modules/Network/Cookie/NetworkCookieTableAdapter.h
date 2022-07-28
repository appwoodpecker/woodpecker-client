//
//  NetworkCookieTableAdapter.h
//  ADHClient
//
//  Created by 张小刚 on 2018/5/14.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "SimpleTableAdapter.h"
#import "ADHNetworkCookie.h"

@interface NetworkCookieTableAdapter : SimpleTableAdapter

@property (nonatomic, strong) NSArray<SimpleTableColumn *>* columnList;
- (void)prepareHeader: (CGFloat)tableWidth;
- (void)setData: (NSArray<ADHNetworkCookie *> *)dataList;

@end
