//
//  DBTable.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/9.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBField.h"

@interface DBTable : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSArray<DBField *> * fields;
@property (nonatomic, strong) NSArray<DBField *> * keyFields;

- (NSIndexSet *)keyFieldsIndexSet;
- (NSString *)fieldNames;
- (DBField *)fieldWithName: (NSString *)name;

/**
 元数据table，不支持编辑，目前主要标记coredata
 */
- (BOOL)isEditable;

@end
