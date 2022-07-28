//
//  DBItem.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/13.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DBItem.h"

@implementation DBItem

- (BOOL)isBLOB
{
    return (self.dataType == DBDataTypeBLOB);
}

@end
