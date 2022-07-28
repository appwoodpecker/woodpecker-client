//
//  DBTable.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/9.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DBTable.h"

@implementation DBTable

- (NSString *)description
{
    NSMutableString * content = [NSMutableString string];
    [content appendFormat:@"%@",self.name];
    if(self.fields){
        [content appendFormat:@"%@",self.fields];
    }
    return content;
}

- (NSIndexSet *)keyFieldsIndexSet
{
    NSArray * keyFields = self.keyFields;
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    for (DBField * keyField in keyFields) {
        NSUInteger keyIndex = [self.fields indexOfObject:keyField];
        [indexSet addIndex:keyIndex];
    }
    return indexSet;
}

- (NSString *)fieldNames
{
    NSMutableString * content = [NSMutableString string];
    for (NSInteger i=0;i<self.fields.count;i++) {
        DBField * field = self.fields[i];
        [content appendFormat:@"%@",field.name];
        if(i<self.fields.count-1){
            [content appendString:@","];
        }
    }
    return content;
}

- (DBField *)fieldWithName: (NSString *)name {
    DBField *targetField = nil;
    for (DBField *field in self.fields) {
        if([field.name isEqualToString:name]) {
            targetField = field;
            break;
        }
    }
    return targetField;
}

- (BOOL)isEditable
{
    NSString * tblName = self.name;
    BOOL ret = YES;
    NSArray * excludeTableNames = @[@"Z_PRIMARYKEY",@"Z_METADATA",@"Z_MODELCACHE"];
    for (NSString * excludeName in excludeTableNames) {
        if([excludeName isEqualToString:tblName]){
            ret = NO;
            break;
        }
    }
    return ret;
}


@end







