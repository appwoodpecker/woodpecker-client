//
//  KeyChainItem.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/9/2.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "KeyChainItem.h"

@implementation KeyChainItem

+ (KeyChainItem *)itemWithData: (NSDictionary *)data {
    KeyChainItem *item = [[KeyChainItem alloc] init];
    item.attrData = data;
    return item;
}

@end
