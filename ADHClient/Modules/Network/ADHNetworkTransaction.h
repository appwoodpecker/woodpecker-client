//
//  ADHNetworkTransaction.h
//  ADHClient
//
//  Created by 张小刚 on 2017/12/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ADHNetworkTransactionState) {
    ADHNetworkTransactionStateUnstarted = 0,
    ADHNetworkTransactionStateStarted = 1,
    ADHNetworkTransactionStateSendingData = 2,
    ADHNetworkTransactionStateResponseReceived = 3,
    ADHNetworkTransactionStateReceivingData = 4,
    ADHNetworkTransactionStateFinished = 5,
    ADHNetworkTransactionStateFailed = 6,
};

/**
 update transfer state
 */
typedef NS_ENUM(NSUInteger, ADHNetworkRecordTransferState) {
    ADHNetworkRecordTransferStateUnstart = 0,
    ADHNetworkRecordTransferStateTransfering,
    ADHNetworkRecordTransferStateSuccess,
    ADHNetworkRecordTransferStateFailed,
};

@class ADHNetworkTransferRecord;
@interface ADHNetworkTransaction : NSObject

@property (nonatomic, copy) NSString *requestID;

@property (nonatomic, strong) NSURLRequest *request;
//@property (nonatomic, strong) NSString * requestUserAgent;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, copy) NSString *requestMechanism;
@property (nonatomic, assign) ADHNetworkTransactionState transactionState;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) NSTimeInterval latency;
@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, assign) int64_t sentDataLength;
@property (nonatomic, assign) int64_t receivedDataLength;

/// Populated lazily. Handles both normal HTTPBody data and HTTPBodyStreams.
@property (nonatomic, strong, readonly) NSData *requestBody;

@property (nonatomic, strong) NSDate * updateTime;

- (NSDictionary *)transferRecordData;
- (void)updateWithTransferRecord: (ADHNetworkTransferRecord *)record;


+ (NSString *)readableStringFromTransactionState:(ADHNetworkTransactionState)state;

//时长
- (NSString *)responseCode;
- (NSString *)readableDuration;
- (NSString *)readbleTransactionState;
- (NSString *)requestHost;
- (NSString *)requestPath;
- (NSString *)readbleSentBodySize;
- (NSString *)readableReceivedBodySize;
- (NSString *)requestContentType;
- (NSString *)responseContentType;
- (NSString *)requestCookie;
- (NSString *)responseCookie;
- (NSString *)requestContentEncoding;

- (BOOL)hasQuery;
- (BOOL)hasUrlEncodedForm;
- (BOOL)requestHasCookie;
- (BOOL)responseHasCookie;
- (BOOL)isJsonResponse;

- (BOOL)isResponseBodyReady;
- (BOOL)isCurlAvailable;

@end


@interface ADHNetworkTransferRecord : NSObject

@property (nonatomic, copy) NSString *requestID;
@property (nonatomic, assign) ADHNetworkTransactionState transactionState;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSDictionary * transactionData;
//upload state
@property (nonatomic, assign) ADHNetworkRecordTransferState transferState;

- (NSDictionary *)dicPresentation;
+ (ADHNetworkTransferRecord *)recordWithData: (NSDictionary *)data;

- (BOOL)isFinished;
- (BOOL)isSuccess;
- (BOOL)isFailed;

//是否是必要状态
- (BOOL)isNecessary;

@end









