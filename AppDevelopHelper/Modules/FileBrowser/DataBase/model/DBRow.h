//
//  DBRow.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/13.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBItem.h"

@interface DBRow : NSObject

@property (nonatomic, strong) NSArray<DBItem *> * itemList;

- (DBItem *)itemAtIndex: (NSInteger)index;

@end
