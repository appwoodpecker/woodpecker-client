//
//  XYInAppReceipt.m
//  Pods
//
//  Created by qichao.ma on 2018/5/3.
//

#import "XYInAppReceipt.h"
#import "NSDate+XYStoreExtension.h"

@implementation XYInAppReceipt

// YYModel解析
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    long long expires_date = [dic[@"expires_date_ms"] longLongValue] / 1000;
    _expires_date = [NSDate dateWithTimeIntervalSince1970:expires_date];
    
    return YES;
}

// YYModel解析
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    
    dic[@"purchase_date"] = [NSDate GMTdateString:_purchase_date];
    
    dic[@"original_purchase_date"] = [NSDate GMTdateString:_original_purchase_date];
    
    dic[@"expires_date"] = [NSDate GMTdateString:_expires_date];
    
    dic[@"cancellation_date"] = [NSDate GMTdateString:_cancellation_date];
    
    return YES;
}

@end
