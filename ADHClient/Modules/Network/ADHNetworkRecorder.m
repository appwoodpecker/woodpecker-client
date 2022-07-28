//
//  ADHNetworkRecorder.m
//  ADHClient
//
//  Created by 张小刚 on 2017/12/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHNetworkRecorder.h"
#import "ADHNetworkTransaction.h"

static NSInteger const kADHNetworkTransferRecordLimit = 20;

@interface ADHNetworkRecorder ()

@property (nonatomic, strong) NSMutableArray *orderedTransactions;
@property (nonatomic, strong) NSMutableDictionary *networkTransactionsForRequestIdentifiers;
@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) dispatch_queue_t sendQueue;
@property (nonatomic, strong) NSMutableArray * orderedTransferRecords;

@end

@implementation ADHNetworkRecorder

/// In general, it only makes sense to have one recorder for the entire application.
+ (instancetype)defaultRecorder
{
    static ADHNetworkRecorder * defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [[ADHNetworkRecorder alloc] init];
    });
    return defaultRecorder;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //receive in
        self.orderedTransactions = [NSMutableArray array];
        self.networkTransactionsForRequestIdentifiers = [NSMutableDictionary dictionary];
        self.queue = dispatch_queue_create("studio.lifebetter.service.networkrecorder", DISPATCH_QUEUE_SERIAL);
        //send out
        self.sendQueue = dispatch_queue_create("studio.lifebetter.service.networkpush", DISPATCH_QUEUE_SERIAL);
        self.orderedTransferRecords = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)networkTransactions
{
    __block NSArray *transactions = nil;
    dispatch_sync(self.queue, ^{
        transactions = [self.orderedTransactions copy];
    });
    return transactions;
}

- (void)clearRecordedActivity
{
    dispatch_async(self.queue, ^{
        [self.orderedTransactions removeAllObjects];
        [self.networkTransactionsForRequestIdentifiers removeAllObjects];
        [self.orderedTransferRecords removeAllObjects];
    });
}

- (ADHNetworkTransaction *)transactionWithId: (NSString *)requestId
{
    return self.networkTransactionsForRequestIdentifiers[requestId];
}

- (void)clearTransactionWithId: (NSString *)requestId
{
    if(!requestId) return;
    dispatch_async(self.queue, ^{
        ADHNetworkTransaction * transaction = [self transactionWithId:requestId];
        if(transaction){
            [self.orderedTransactions removeObject:transaction];
            [self.networkTransactionsForRequestIdentifiers removeObjectForKey:requestId];
        }
    });
}

#pragma mark -----------------   response body   ----------------

- (NSString *)workPath
{
    NSString * tmpPath = [ADHFileUtil tmpPath];
    NSString * workPath = [tmpPath stringByAppendingPathComponent:@"adhNetwork"];
    return workPath;
}

- (NSString *)transactionResponseBodyPath: (NSString *)transRequestId
{
    return [[self workPath] stringByAppendingPathComponent:transRequestId];
}

//save response body to tmp disk
- (void)cacheResponseBody: (NSData *)responseBody forTransaction: (ADHNetworkTransaction *)transaction
{
    if(![ADHFileUtil dirExistsAtPath:[self workPath]]){
        [ADHFileUtil createDirAtPath:[self workPath]];
    }
    NSString * filePath = [self transactionResponseBodyPath:transaction.requestID];
    [ADHFileUtil saveData:responseBody atPath:filePath];
}

//read response body from disk
- (NSData *)cachedResponseBodyForTransaction:(NSString *)transRequestId
{
    NSString * filePath = [self transactionResponseBodyPath:transRequestId];
    NSData * responseBody = [[NSData alloc] initWithContentsOfFile:filePath];
    return responseBody;
}

- (void)clearContext
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * path = [self workPath];
        [ADHFileUtil emptyDir:path];
    });
}

#pragma mark -----------------   Recording network activity   ----------------

/// Call when app is about to send HTTP request.
- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID request:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if(![request respondsToSelector:@selector(HTTPMethod)]){
        //仅支持http request
        return;
    }
    NSDate *startDate = [NSDate date];
    if (redirectResponse) {
        [self recordResponseReceivedWithRequestID:requestID response:redirectResponse];
        [self recordLoadingFinishedWithRequestID:requestID responseBody:nil];
    }
    
    dispatch_async(self.queue, ^{
        ADHNetworkTransaction *transaction = [[ADHNetworkTransaction alloc] init];
        transaction.requestID = requestID;
        NSMutableURLRequest * mutableRequest = [request mutableCopy];
        if(request.URL){
            NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
            if(cookies.count > 0){
                NSDictionary * cookieData = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                [cookieData enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString * value, BOOL * _Nonnull stop) {
                    [mutableRequest setValue:value forHTTPHeaderField:key];
                }];
            }
        }
        transaction.request = mutableRequest;
        transaction.startTime = startDate;
        [self.orderedTransactions insertObject:transaction atIndex:0];
        [self.networkTransactionsForRequestIdentifiers setObject:transaction forKey:requestID];
        transaction.transactionState = ADHNetworkTransactionStateStarted;
        
        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

/// Call to set the request mechanism anytime after recordRequestWillBeSent... has been called.
/// This string can be set to anything useful about the API used to make the request.
- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID
{
    dispatch_async(self.queue, ^{
        ADHNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.requestMechanism = mechanism;
//        [self postUpdateNotificationForTransaction:transaction];
    });
}

/// Call when HTTP response is available.
- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response
{
    NSDate *responseDate = [NSDate date];
    dispatch_async(self.queue, ^{
        ADHNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.response = (NSHTTPURLResponse *)response;
        transaction.transactionState = ADHNetworkTransactionStateResponseReceived;
        transaction.latency = -[transaction.startTime timeIntervalSinceDate:responseDate];
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

///Call when chunk data is sent
- (void)recordDataSentWithRequestID: (NSString *)requestID bytesSent: (int64_t)bytesSent totalBytesSent: (int64_t)totalBytesSent
{
    dispatch_async(self.queue, ^{
        ADHNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = ADHNetworkTransactionStateSendingData;
        transaction.sentDataLength = totalBytesSent;
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

/// Call when data chunk is received over the network.
- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength
{
    dispatch_async(self.queue, ^{
        ADHNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = ADHNetworkTransactionStateReceivingData;
        transaction.receivedDataLength += dataLength;
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

/// Call when HTTP request has finished loading.
- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody
{
    NSDate *finishedDate = [NSDate date];
    
    dispatch_async(self.queue, ^{
        ADHNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = ADHNetworkTransactionStateFinished;
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];
        BOOL shouldCache = [responseBody length] > 0;
        if (shouldCache) {
            [self cacheResponseBody:responseBody forTransaction:transaction];
        }
        [self postUpdateNotificationForTransaction:transaction];
    });
}

/// Call when HTTP request has failed to load.
- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error
{
    dispatch_async(self.queue, ^{
        ADHNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = ADHNetworkTransactionStateFailed;
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.error = error;
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}


#pragma mark Notification Posting

- (void)postNewTransactionNotificationWithTransaction:(ADHNetworkTransaction *)transaction
{
    ADHNetworkTransferRecord * record = [[ADHNetworkTransferRecord alloc] init];
    record.date = [NSDate date];
    record.requestID = transaction.requestID;
    record.transactionState = transaction.transactionState;
    record.transferState = ADHNetworkRecordTransferStateUnstart;
    record.transactionData = [transaction transferRecordData];
    [self onNetworkNewTransaction:transaction record:record];
}

- (void)postUpdateNotificationForTransaction:(ADHNetworkTransaction *)transaction
{
    ADHNetworkTransferRecord * record = [[ADHNetworkTransferRecord alloc] init];
    record.date = [NSDate date];
    record.requestID = transaction.requestID;
    record.transactionState = transaction.transactionState;
    record.transferState = ADHNetworkRecordTransferStateUnstart;
    record.transactionData = [transaction transferRecordData];
    [self onNetworkTransactionUpdate:transaction record:record];
}

#pragma mark -----------------  send out transaction   ----------------

//new transaction
- (void)onNetworkNewTransaction: (ADHNetworkTransaction *)transaction record: (ADHNetworkTransferRecord *)record
{
    [self addRecordToQueue:record];
}

//transaction update
- (void)onNetworkTransactionUpdate: (ADHNetworkTransaction *)transaction record: (ADHNetworkTransferRecord *)record
{
    [self addRecordToQueue:record];
}

- (void)addRecordToQueue: (ADHNetworkTransferRecord *)record
{
    //插入队列后面
    dispatch_async(self.sendQueue, ^{
        [self.orderedTransferRecords addObject:record];
    });
    [self dispatchTransferRecords];
}

/**
 获取需要发送的records，
 条数限制为limit
 */
- (NSArray *)fetchNextSendingRecords
{
    NSMutableArray * sendingRecords = [NSMutableArray array];
    NSInteger count = 0;
    for (ADHNetworkTransferRecord * record in self.orderedTransferRecords) {
        if(record.transferState == ADHNetworkRecordTransferStateUnstart){
            [sendingRecords addObject:record];
            count ++;
        }
        if(count == kADHNetworkTransferRecordLimit){
            break;
        }
    }
    return sendingRecords;
}

- (void)dispatchTransferRecords
{
    dispatch_async(self.sendQueue, ^{
        [self clearRecordQueue];
        NSArray * sendingRecords = [self fetchNextSendingRecords];
        if(sendingRecords.count == 0) return;
        NSMutableArray * datalist = [NSMutableArray arrayWithCapacity:sendingRecords.count];
        for (ADHNetworkTransferRecord * record in sendingRecords) {
            NSDictionary * data = [record dicPresentation];
            [datalist addObject:data];
            record.transferState = ADHNetworkRecordTransferStateTransfering;
        }
        if(datalist.count == 0) return;
        NSDictionary * data = @{
                                @"list" : datalist,
                                };
        [[ADHApiClient sharedApi] requestWithService:@"adh.network"
                                              action:@"transactionUpdate"
                                                body: data
                                           onSuccess:^(NSDictionary *body, NSData *payload) {
                                               [self updateRecords:sendingRecords transferState:ADHNetworkRecordTransferStateSuccess];
                                               [self dispatchTransferRecords];
                                           } onFailed:^(NSError *error) {
                                               [self updateRecords:sendingRecords transferState:ADHNetworkRecordTransferStateFailed];
                                               [self dispatchTransferRecords];
                                           }];
    });
}

- (void)updateRecords: (NSArray *)records transferState: (ADHNetworkRecordTransferState)state
{
    for (ADHNetworkTransferRecord * record in records) {
        if(![record isFinished]){
            record.transferState = state;
        }
    }
}

- (void)clearRecordQueue
{
    //clear sended records
    NSMutableArray * recordsToRemove = [NSMutableArray array];
    for (ADHNetworkTransferRecord * record in self.orderedTransferRecords) {
        if([record isSuccess]){
            [recordsToRemove addObject:record];
        }else{
            if([record isFailed]){
                if([record isNecessary]){
                    record.transferState = ADHNetworkRecordTransferStateUnstart;
                }else{
                    [recordsToRemove addObject:record];
                }
            }
        }
    }
    //clear finished transactions
    for (ADHNetworkTransferRecord * record in recordsToRemove) {
        ADHNetworkTransactionState state = record.transactionState;
        if(state == ADHNetworkTransactionStateFinished || state == ADHNetworkTransactionStateFailed){
            [self clearTransactionWithId:record.requestID];
        }
    }
    [self.orderedTransferRecords removeObjectsInArray:recordsToRemove];
}





@end












