//
//  DBColumn.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/9.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DBField.h"
#import "DBTypeKit.h"

@implementation DBField

- (BOOL)isBLOB
{
    return (self.fieldType == DBDataTypeBLOB);
}

//meta column
- (BOOL)isMetaColumn
{
    BOOL ret = NO;
    NSString * fldName = self.name;
    NSArray * metaNames = @[@"Z_ENT",@"Z_OPT"];
    for (NSString * metaName in metaNames) {
        if([metaName isEqualToString:fldName]){
            ret = YES;
            break;
        }
    }
    return ret;
}

//pk,blob
- (BOOL)isEditable
{
    return (!self.isPrimaryKey && !self.isBLOB && !self.isMetaColumn);
}

- (BOOL)isSearchable {
    return (!self.isBLOB && !self.isMetaColumn);
}

@end











