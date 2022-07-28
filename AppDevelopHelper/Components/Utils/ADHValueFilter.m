//
//  ValueFilter.m
//  magapp-x
//
//  Created by 张小刚 on 2016/12/15.
//  Copyright © 2016年 lyeah. All rights reserved.
//

#import "ADHValueFilter.h"

//object -> (integer,bool)
BOOL adhvf_boolValue(id param)
{
    return [param boolValue];
}

NSInteger adhvf_integerValue(id param)
{
    return [param integerValue];
}

float adhvf_floatValue(id param)
{
    return [param floatValue];
}

//(object,integer,bool) -> string
NSString * adhvf_stringfy(id param)
{
    return [NSString stringWithFormat:@"%@",param];
}

NSString * adhvf_string_integer(NSInteger value)
{
    return [NSString stringWithFormat:@"%ld",(long)value];
}

//过滤

NSString * adhvf_safestringfy(id param)
{
    NSString * value = nil;
    if(!param){
        value = adhvf_const_emptystr();
    }else if(![param isKindOfClass:[NSString class]]) {
        value = adhvf_const_emptystr();
    }else {
        value = param;
    }
    return value;
}

NSArray * adhvf_safearray(NSArray * array)
{
    if(!array){
        array = @[];
    }
    return array;
}

//常量
NSString * adhvf_const_emptystr(void)
{
    return @"";
}

NSString * adhvf_const_strtrue(void)
{
    return @"1";
}

NSString * adhvf_const_strfalse(void)
{
    return @"0";
}


@implementation ADHValueFilter

@end
















