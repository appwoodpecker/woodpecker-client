//
//  DBItem.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/13.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBTypeKit.h"

@interface DBItem : NSObject

@property (nonatomic,assign) DBDataType dataType;
@property (nonatomic, strong) NSString * stringValue;
//BLOB类型
@property (nonatomic, strong) NSData * dataValue;
- (BOOL)isBLOB;

@end
