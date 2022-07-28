//
//  TypeKit.h
//  MDatabase
//
//  Created by MacDev on 16/6/9.
//  Copyright © 2016年 http://www.macdev.io All rights reserved.
//



typedef NS_ENUM(NSUInteger, DBDataType) {
    DBDataTypeUNKNOWN,
    DBDataTypeINTEGER,
    DBDataTypeTEXT,
    DBDataTypeBLOB,
    DBDataTypeREAL,
    DBDataTypeNUMERIC,
};


@interface DBTypeKit : NSObject

+ (DBDataType)dataType:(NSString *)sqltype;
+ (BOOL)isBLOB: (DBDataType)type;
@end

