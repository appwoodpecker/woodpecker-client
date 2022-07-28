//
//  TypeKit.m
//  MDatabase
//
//  Created by MacDev on 16/6/9.
//  Copyright © 2016年 http://www.macdev.io All rights reserved.
//

#import "DBTypeKit.h"

/**
 sqlite Affinity Type 数据类型
 https://sqlite.org/datatype3.html
 
 //sqlite类型归属
 INT                    INTEGER
 CHAR,CLOB,TEXT         TEXT
 BLOB                   BLOB
 REAL,FLOA,DOUB         REAL
 Others                 NUMERIC
 
 
 //sqlite data type 与 OC转换
 INTEGER                NSInteger
 REAL                   Double
 NUMERIC                NSNumber
 TEXT                   NSString
 BLOB                   NSData
 
 
 每个字段属性keys
 cid,
 name,
 type,
 notnull,
 dflt_value,
 pk
 
 */


static NSDictionary * sqliteAffinityNameValues()
{
    return @{
             @"INTEGER" : [NSNumber numberWithInteger:DBDataTypeINTEGER],
             @"REAL" : [NSNumber numberWithInteger:DBDataTypeREAL],
             @"NUMERIC" : [NSNumber numberWithInteger:DBDataTypeNUMERIC],
             @"TEXT" : [NSNumber numberWithInteger:DBDataTypeTEXT],
             @"BLOB" : [NSNumber numberWithInteger:DBDataTypeBLOB],
             };
}

static NSDictionary * sqliteAffinityTypeMapping()
{
    NSDictionary * sqliteAffinityTypes = @{
                                           @"INTEGER" : @[@"INT"],
                                           @"TEXT" : @[@"CHAR",@"CLOB",@"TEXT"],
                                           @"REAL" : @[@"REAL",@"FLOA",@"DOUB"],
                                           @"BLOB" : @[@"BLOB"],
                                           //@"NUMERIC" : @[],        其他类型
                                           };
    return sqliteAffinityTypes;
}

static NSDictionary * objcSqliteTypeMapping()
{
    return  @{
              @"INTEGER"    : @"NSInteger",
              @"REAL"       : @"Double",
              @"NUMERIC"    : @"Number",
              @"TEXT"       : @"NSString",
              @"BLOB"       : @"NSData",
              };
}

static NSString * sqliteAffinityType(NSString *sqliteType)
{
    NSDictionary * sqliteAffinityTypes = sqliteAffinityTypeMapping();
    __block NSString * resultAffinityType = nil;
    if(!sqliteType){
        //为空为BLOB
        sqliteType = @"BLOB";
    }
    [sqliteAffinityTypes enumerateKeysAndObjectsUsingBlock:^(NSString * affinityType, NSArray * typeNames, BOOL * _Nonnull stop) {
        BOOL find = NO;
        for (NSString * keyword in typeNames) {
            if([sqliteType rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound){
                find = YES;
                break;
            }
        }
        if(find){
            resultAffinityType = affinityType;
            *stop = YES;
        }
    }];
    if(!resultAffinityType){
        //其他类型为NUMERIC
        resultAffinityType = @"NUMERIC";
    }
    return resultAffinityType;
}

static NSString *objcType(NSString *sqliteType)
{
    NSString * objcType = nil;
    NSString * affinityType = sqliteAffinityType(sqliteType);
    if(affinityType){
        NSDictionary * objcSqliteTypes = objcSqliteTypeMapping();
        objcType = objcSqliteTypes[affinityType];
    }
    return objcType;
}

 static DBDataType dataType(NSString *sqliteType)
{
    DBDataType dataType = DBDataTypeUNKNOWN;
    NSString * affinityType = sqliteAffinityType(sqliteType);
    if(affinityType){
        NSDictionary * dataTypeNameValues = sqliteAffinityNameValues();
        NSNumber * numberValue = dataTypeNameValues[affinityType];
        dataType = [numberValue integerValue];
    }
    return dataType;
}

@implementation DBTypeKit

+ (NSString*)objcType:(NSString *)type
{
    return objcType(type);
}

+ (DBDataType)dataType:(NSString *)type
{
    return dataType(type);
    
}

+ (BOOL)isBLOB: (DBDataType)type
{
    return (type == DBDataTypeBLOB);
}

@end











