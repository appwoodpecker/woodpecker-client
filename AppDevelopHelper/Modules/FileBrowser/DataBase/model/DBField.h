//
//  DBColumn.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/9.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBTypeKit.h"


@interface DBField : NSObject

@property(nonatomic,strong) NSString  *name;//字段名称
@property(nonatomic,strong) NSString  *type;//字段数据库类型
@property(nonatomic,strong) NSString  *defaultVal;//缺省值
@property(nonatomic,assign) BOOL      isNotNULL;//是否为空
@property(nonatomic,assign) BOOL      isPrimaryKey;//是否为主键
@property (nonatomic, assign) DBDataType fieldType;//字段类型

- (BOOL)isBLOB;
- (BOOL)isEditable;
- (BOOL)isSearchable;


@end
