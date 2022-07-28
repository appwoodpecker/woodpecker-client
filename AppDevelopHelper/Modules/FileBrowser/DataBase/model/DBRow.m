//
//  DBRow.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/13.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DBRow.h"

@implementation DBRow

- (DBItem *)itemAtIndex: (NSInteger)index
{
    return [self.itemList objectAtIndex:index];
}

@end
