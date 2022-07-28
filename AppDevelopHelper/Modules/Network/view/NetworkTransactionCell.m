//
//  NetworkItemCell.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/10.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NetworkTransactionCell.h"
#import "ADHNetworkTransaction.h"

@interface NetworkTransactionCell ()

@property (weak) IBOutlet NSTextField *titleTextfield;

@end

@implementation NetworkTransactionCell

- (void)setTransaction: (ADHNetworkTransaction *)transaction itemKey: (NSString *)key
{
    NSString * value = nil;
    NSURLRequest * request = transaction.request;
    NSURL * requestURL = request.URL;    
    if([key isEqualToString:@"Response Code"]){
        value = [transaction responseCode];
    }else if([key isEqualToString:@"Protocol"]){
        value = requestURL.scheme;
    }else if([key isEqualToString:@"Host"]){
        value = [transaction requestHost];
    }else if([key isEqualToString:@"Path"]){
        value = [transaction requestPath];
    }else if([key isEqualToString:@"Method"]){
        value = request.HTTPMethod;
    }else if([key isEqualToString:@"Start"]){
        value = [ADHDateUtil formatStringWithDate:transaction.startTime dateFormat:@"HH:mm:ss"];
    }else if([key isEqualToString:@"Duration"]){
        value = [transaction readableDuration];
    }else if([key isEqualToString:@"Size"]){
        value = [transaction readableReceivedBodySize];
    }else if([key isEqualToString:@"Status"]){
        value = [transaction readbleTransactionState];
    }
    value = adhvf_safestringfy(value);
    self.titleTextfield.stringValue = value;
}

+ (CGFloat)rowHeight
{
    return 20.0f;
}

@end





