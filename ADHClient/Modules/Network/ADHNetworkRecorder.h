//
//  ADHNetworkRecorder.h
//  ADHClient
//
//  Created by 张小刚 on 2017/12/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ADHNetworkTransaction;

@interface ADHNetworkRecorder : NSObject

/// In general, it only makes sense to have one recorder for the entire application.
+ (instancetype)defaultRecorder;

// Accessing recorded network activity

/// Array of FLEXNetworkTransaction objects ordered by start time with the newest first.
- (NSArray *)networkTransactions;

//读取cache response body
- (NSData *)cachedResponseBodyForTransaction:(NSString *)transRequestId;


/// clear all network transactions and cached response bodies.
- (void)clearRecordedActivity;
- (void)clearTransactionWithId: (NSString *)requestId;
- (void)clearContext;

// Recording network activity

/// Call when app is about to send HTTP request.
- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID request:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;

/// Call when HTTP response is available.
- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response;

///Call when chunk data is sent
- (void)recordDataSentWithRequestID: (NSString *)requestID bytesSent: (int64_t)bytesSent totalBytesSent: (int64_t)totalBytesSent;

/// Call when data chunk is received over the network.
- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength;

/// Call when HTTP request has finished loading.
- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody;

/// Call when HTTP request has failed to load.
- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error;

/// Call to set the request mechanism anytime after recordRequestWillBeSent... has been called.
/// This string can be set to anything useful about the API used to make the request.
- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID;

@end

