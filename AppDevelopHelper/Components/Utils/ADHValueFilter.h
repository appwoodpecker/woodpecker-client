//
//  ValueFilter.h
//  magapp-x
//
//  Created by 张小刚 on 2016/12/15.
//  Copyright © 2016年 lyeah. All rights reserved.
//

#import <Foundation/Foundation.h>


//object -> (integer,bool)
extern BOOL adhvf_boolValue(id param);
extern NSInteger adhvf_integerValue(id param);
extern float adhvf_floatValue(id param);

//(object,integer,bool) -> string
extern NSString * adhvf_stringfy(id param);
extern NSString * adhvf_string_integer(NSInteger value);

//过滤
extern NSString * adhvf_safestringfy(id param);
extern NSArray * adhvf_safearray(NSArray * array);

//常量
extern NSString * adhvf_const_emptystr(void);
extern NSString * adhvf_const_strtrue(void);
extern NSString * adhvf_const_strfalse(void);

@interface ADHValueFilter : NSObject


@end
