//
//  DBDao.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/9.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DBDao.h"
#import "EGODatabase.h"


@interface DBDao ()

@property (nonatomic, strong) EGODatabase * database;

@end

@implementation DBDao

- (BOOL)openWithPath: (NSString *)path
{
    EGODatabase * db = [[EGODatabase alloc] initWithPath:path];
    BOOL ret = [db open];
    if(ret){
        self.database = db;
    }
    return ret;
}

- (NSArray *)tables
{
    NSString * sql = @"SELECT name FROM sqlite_master WHERE type = 'table'";
    EGODatabaseResult * dbResult = [self.database executeQuery:sql];
    NSMutableArray * tables = [NSMutableArray array];
    for (EGODatabaseRow * row in dbResult.rows) {
        DBTable * table = [[DBTable alloc] init];
        NSString * tblName = [row stringForColumn:@"name"];
        //fields
        NSString * sql = [[NSString alloc] initWithFormat:@" PRAGMA table_info ( %@ ) ", tblName];
        EGODatabaseResult * dbResult = [self.database executeQuery:sql];
        NSMutableArray * fields = [NSMutableArray array];
        for (EGODatabaseRow * row in dbResult.rows) {
            DBField * field = [[DBField alloc]init];
            NSString * name = [row stringForColumn:@"name"];
            NSString * type = [row stringForColumn:@"type"];
            NSString * defaultV = [row stringForColumn:@"dflt_value"];
            BOOL isPrimaryKey = [row boolForColumn:@"pk"];
            BOOL isNotNULL = ![row boolForColumn:@"notnull"];
            field.name = name;
            field.type = type;
            field.defaultVal = defaultV;
            field.isPrimaryKey = isPrimaryKey;
            field.isNotNULL = isNotNULL;
            field.fieldType = [DBTypeKit dataType:field.type];
            [fields addObject:field];
        }
        //显示排序
        table.fields = [self sortedFields:fields];
        NSMutableArray * keyFields = [NSMutableArray array];
        for (DBField *field in table.fields) {
            if(field.isPrimaryKey){
                [keyFields addObject:field];
            }
        }
        table.keyFields = keyFields;
        table.name = tblName;
        [tables addObject:table];
    }
    return tables;
}

/**
 排序，优化显示，将CoreData字段往后排列
 */
- (NSArray<DBField *> *)sortedFields: (NSArray<DBField *> *)fields
{
    NSArray * excludedNames = @[@"Z_ENT",@"Z_OPT"];
    NSMutableArray * excludedFields = [NSMutableArray array];
    NSMutableArray * sortFields = [NSMutableArray array];
    for (DBField * field in fields) {
        BOOL shouldExclude = NO;
        NSString * name = field.name;
        for (NSString * excludeName in excludedNames) {
            if([excludeName isEqualToString:name]){
                shouldExclude = YES;
                break;
            }
        }
        if(shouldExclude){
            [excludedFields addObject:field];
        }else{
            [sortFields addObject:field];
        }
    }
    
    [sortFields sortUsingComparator:^NSComparisonResult(DBField * field1, DBField * field2) {
        NSString * name1 = field1.name;
        NSString * name2 = field2.name;
        return [name1 compare:name2 options:NSCaseInsensitiveSearch];
    }];
    [sortFields addObjectsFromArray:excludedFields];
    return sortFields;
}


- (NSInteger)fetchNumberOfRecordsInTable: (DBTable *)table
{
    NSInteger count = 0;
    NSString * sql = [NSString stringWithFormat:@"SELECT COUNT(*) from %@",table.name];
    EGODatabaseResult * dbResult = [self.database executeQuery:sql];
    if(dbResult.rows.count > 0){
        EGODatabaseRow * row = [dbResult firstRow];
        count = [row intForColumnAtIndex:0];
    }
    return count;
}

/**
 * 查询行数
 * SELECT COUNT(*) FROM tblName WHERE fieldName='keywords'
 */
- (void)fetchNumberOfRecordsInTable: (DBTable *)table
                             filterField: (DBField *)filterField
                          filterKeywords: (NSString *)filterKeywords
                           oncCompletion: (void (^)(NSInteger count))completionBlock {
    NSMutableString * sql = [NSMutableString stringWithFormat:@"SELECT COUNT(*) from %@",table.name];
    if(filterField && filterKeywords.length > 0) {
        NSString *fieldName = filterField.name;
        NSMutableString * whereExp = [NSMutableString stringWithFormat:@"WHERE %@ LIKE '%%%@%%'",fieldName,filterKeywords];
        [sql appendFormat:@" %@",whereExp];
    }
//    NSLog(@"%@",sql);
    EGODatabaseRequest * request = [self.database requestWithQuery:sql];
    [request setCompletion:^(EGODatabaseRequest *request, EGODatabaseResult *dbResult, NSError *error) {
        NSInteger count = 0;
        if(dbResult.rows.count > 0){
            EGODatabaseRow * row = [dbResult firstRow];
            count = [row intForColumnAtIndex:0];
        }
        if(completionBlock) {
            completionBlock(count);
        }
    }];
    [request start];
}

- (NSString *)joinedFieldsName: (NSArray *)fields
{
    NSMutableString * fieldNames = [NSMutableString string];
    for (NSInteger i=0; i<fields.count; i++) {
        DBField * field = fields[i];
        [fieldNames appendString:field.name];
        if(i < fields.count-1){
            [fieldNames appendString:@","];
        }
    }
    return fieldNames;
}

- (void)fetchDataInTable: (DBTable *)table
                onCompletion: (void (^)(NSArray<DBRow *>* list,NSError *error))completionBlock
{
    NSString * sql = [NSString stringWithFormat:@"SELECT %@ FROM %@",table.fieldNames,table.name];
    [self _fetchDataWithSql:sql table:table onCompletion:completionBlock];
}

/**
 * 查询数据
 * WHERE City LIKE '%keywords%'
 */
- (void)fetchDataInTable: (DBTable *)table
                pageStep: (NSInteger)step
               pageIndex: (NSInteger)pageIndex
               sortField: (NSString *)sortKey
               ascending: (BOOL)ascending
             filterField: (DBField *)filterField
          filterKeywords: (NSString *)filterKeywords
           oncCompletion: (void (^)(NSArray<DBRow *>* list,NSError *error))completionBlock {
    NSInteger startIndex = pageIndex * step;
    NSMutableString * sql = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@",table.fieldNames,table.name];
    //where
    if(filterField && filterKeywords.length > 0) {
        NSString *whereExp = nil;
        NSString *fieldName = filterField.name;
        if(filterField.fieldType == DBDataTypeINTEGER) {
            whereExp = [NSString stringWithFormat:@"WHERE %@=%@",fieldName,filterKeywords];
        }else {
            whereExp = [NSString stringWithFormat:@"WHERE %@ LIKE '%%%@%%'",fieldName,filterKeywords];
        }
        [sql appendFormat:@" %@",whereExp];
    }
    //sort
    NSMutableString * sortExp = [NSMutableString string];
    if(sortKey.length > 0){
        NSString * order = ascending ? @"ASC" : @"DESC";
        [sortExp appendFormat:@"ORDER BY %@ %@",sortKey,order];
        [sql appendFormat:@" %@",sortExp];
    }
    NSString * pageExp = [NSString stringWithFormat:@"LIMIT %zd,%zd",startIndex,step];
    [sql appendFormat:@" %@",pageExp];
    [self _fetchDataWithSql:sql table:table onCompletion:completionBlock];
}

- (void)_fetchDataWithSql: (NSString *)sql
                    table: (DBTable *)table
            onCompletion: (void (^)(NSArray<DBRow *>* list,NSError *error))completionBlock
{
//    NSLog(@"%@",sql);
    EGODatabaseRequest * request = [self.database requestWithQuery:sql];
    [request setCompletion:^(EGODatabaseRequest *request, EGODatabaseResult *dbResult, NSError *error) {
        NSMutableArray * rowList = [NSMutableArray array];
        for (EGODatabaseRow * row in dbResult.rows) {
            NSArray * rowData = row.data;
            DBRow * row = [[DBRow alloc] init];
            NSMutableArray * itemList = [NSMutableArray array];
            for (NSInteger fieldIndex=0;fieldIndex<table.fields.count;fieldIndex++){
                DBField * field = table.fields[fieldIndex];
                DBItem * item = [[DBItem alloc] init];
                if(!field.isBLOB){
                    item.stringValue = rowData[fieldIndex];
                }else{
                    item.dataValue = rowData[fieldIndex];
                }
                item.dataType = [field fieldType];
                [itemList addObject:item];
            }
            row.itemList = itemList;
            [rowList addObject:row];
        }
        if(completionBlock){
            completionBlock(rowList,error);
        }
    }];
    [request start];
}

- (void)updateField: (DBField *)field
           newValue: (NSString *)newValue
          keyFields: (NSArray<DBField *> *)keyFields
          keyValues: (NSArray *)keyValues
              table: (DBTable *)table
       onCompletion: (void (^)(BOOL success, NSError * error))completionBlock
{
    NSMutableString * sql = [NSMutableString string];
    [sql appendFormat:@"UPDATE %@ SET %@='%@'",table.name,field.name,newValue];
    NSMutableString * whereExp = [NSMutableString stringWithFormat:@"WHERE "];
    for (NSInteger i=0;i<keyFields.count;i++) {
        DBField * field = keyFields[i];
        id fieldValue = keyValues[i];
        [whereExp appendFormat:@"%@='%@'",field.name,fieldValue];
        if(i<keyFields.count-1){
            [whereExp appendFormat:@" AND "];
        }
    }
    [sql appendFormat:@" %@",whereExp];
    [self _updateDataWithSql:sql onCompletion:completionBlock];
}

- (void)_updateDataWithSql: (NSString *)sql
              onCompletion: (void (^)(BOOL success, NSError * error))completionBlock
{
    NSLog(@"%@",sql);
    EGODatabaseRequest * request = [self.database requestWithUpdate:sql];
    [request setCompletion:^(EGODatabaseRequest *request, EGODatabaseResult *result, NSError *error) {
        if(completionBlock){
            BOOL success = (error == nil);
            completionBlock(success,error);
        }
        [self.database close];
        [self.database open];
    }];
    [request start];
}

/**
 * 删除row
 * DELETE FROM 表名称 WHERE 列名称 = 值
 */
- (void)deleteRowWithkeyFields: (NSArray<DBField *> *)keyFields
                     keyValues: (NSArray *)keyValues
                         table: (DBTable *)table
                  onCompletion: (void (^)(BOOL success, NSError * error))completionBlock {
    NSMutableString * sql = [NSMutableString string];
    [sql appendFormat:@"DELETE FROM %@",table.name];
    NSMutableString * whereExp = [NSMutableString stringWithFormat:@"WHERE "];
    for (NSInteger i=0;i<keyFields.count;i++) {
        DBField * field = keyFields[i];
        id fieldValue = keyValues[i];
        [whereExp appendFormat:@"%@='%@'",field.name,fieldValue];
        if(i<keyFields.count-1){
            [whereExp appendFormat:@" AND "];
        }
    }
    [sql appendFormat:@" %@",whereExp];
    [self _updateDataWithSql:sql onCompletion:completionBlock];
}

/**
 * 清空table
 * DELETE * FROM table_name
 */
- (void)emptyTable: (DBTable *)table onCompletion: (void (^)(BOOL success, NSError * error))completionBlock {
    NSMutableString * sql = [NSMutableString string];
    [sql appendFormat:@"DELETE FROM %@",table.name];
    [self _updateDataWithSql:sql onCompletion:completionBlock];
}

@end








