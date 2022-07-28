//
//  DBDao.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/9.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBTable.h"
#import "DBRow.h"

@interface DBDao : NSObject

- (BOOL)openWithPath: (NSString *)path;

- (NSArray *)tables;

/**
 * 查询数目
 */
- (NSInteger)fetchNumberOfRecordsInTable: (DBTable *)table;

- (void)fetchNumberOfRecordsInTable: (DBTable *)table
                        filterField: (DBField *)filterField
                     filterKeywords: (NSString *)filterKeywords
                      oncCompletion: (void (^)(NSInteger count))completionBlock;

/**
 * 查询内容
 */
- (void)fetchDataInTable: (DBTable *)table
                onCompletion: (void (^)(NSArray<DBRow *>* list,NSError *error))completionBlock;

- (void)fetchDataInTable: (DBTable *)table
                pageStep: (NSInteger)step
               pageIndex: (NSInteger)pageIndex
               sortField: (NSString *)field
               ascending: (BOOL)ascending
             filterField: (DBField *)filterField
          filterKeywords: (NSString *)filterKeywords
           oncCompletion: (void (^)(NSArray<DBRow *>* list,NSError *error))completionBlock;



/**
 * 更新字段值
 */
- (void)updateField: (DBField *)field
           newValue: (NSString *)newValue
          keyFields: (NSArray<DBField *> *)keyFields
          keyValues: (NSArray *)keyValues
              table: (DBTable *)table
       onCompletion: (void (^)(BOOL success, NSError * error))completionBlock;


/**
 * 删除row
 */
- (void)deleteRowWithkeyFields: (NSArray<DBField *> *)keyFields
          keyValues: (NSArray *)keyValues
              table: (DBTable *)table
       onCompletion: (void (^)(BOOL success, NSError * error))completionBlock;


/**
 * 清空table
 */
- (void)emptyTable: (DBTable *)table onCompletion: (void (^)(BOOL success, NSError * error))completionBlock;

@end










