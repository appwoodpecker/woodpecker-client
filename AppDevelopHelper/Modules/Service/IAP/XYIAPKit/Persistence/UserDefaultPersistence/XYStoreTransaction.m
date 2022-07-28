//
//  XYStoreTransaction.m
//  Pods
//
//  Created by qichao.ma on 2018/4/19.
//

#import "XYStoreTransaction.h"

NSString* const XYStoreCoderConsumedKey = @"consumed";
NSString* const XYStoreCoderProductIdentifierKey = @"productIdentifier";
NSString* const XYStoreCoderTransactionDateKey = @"transactionDate";
NSString* const XYStoreCoderTransactionIdentifierKey = @"transactionIdentifier";


@implementation XYStoreTransaction

- (instancetype)initWithPaymentTransaction:(SKPaymentTransaction*)paymentTransaction
{
    if (self = [super init])
    {
        _productIdentifier = paymentTransaction.payment.productIdentifier;
        _transactionDate = paymentTransaction.transactionDate;
        _transactionIdentifier = paymentTransaction.transactionIdentifier;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        _consumed = [decoder decodeBoolForKey:XYStoreCoderConsumedKey];
        _productIdentifier = [decoder decodeObjectForKey:XYStoreCoderProductIdentifierKey];
        _transactionDate = [decoder decodeObjectForKey:XYStoreCoderTransactionDateKey];
        _transactionIdentifier = [decoder decodeObjectForKey:XYStoreCoderTransactionIdentifierKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.consumed forKey:XYStoreCoderConsumedKey];
    [coder encodeObject:self.productIdentifier forKey:XYStoreCoderProductIdentifierKey];
    [coder encodeObject:self.transactionDate forKey:XYStoreCoderTransactionDateKey];
    if (self.transactionIdentifier != nil) { [coder encodeObject:self.transactionIdentifier forKey:XYStoreCoderTransactionIdentifierKey]; }
}

@end
