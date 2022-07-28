//
//  ADHNetworkTransaction.m
//  ADHClient
//
//  Created by 张小刚 on 2017/12/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHNetworkTransaction.h"
#import "ADHNetworkRecorder.h"

@interface ADHNetworkTransaction ()

@property (nonatomic, strong) NSData *cachedRequestBody;

@end

@implementation ADHNetworkTransaction

- (NSString *)description
{
    NSString *description = [super description];
    
    description = [description stringByAppendingFormat:@" id = %@;", self.requestID];
    description = [description stringByAppendingFormat:@" url = %@;", self.request.URL];
    description = [description stringByAppendingFormat:@" duration = %f;", self.duration];
    description = [description stringByAppendingFormat:@" receivedDataLength = %lld", self.receivedDataLength];
    
    return description;
}

- (NSData *)requestBody {
    if (!_cachedRequestBody) {
        if (self.request.HTTPBody != nil) {
            _cachedRequestBody = self.request.HTTPBody;
        } else if ([self.request.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
            NSInputStream *bodyStream = [self.request.HTTPBodyStream copy];
            const NSUInteger bufferSize = 1024;
            uint8_t buffer[bufferSize];
            NSMutableData *data = [NSMutableData data];
            [bodyStream open];
            NSInteger readBytes = 0;
            do {
                readBytes = [bodyStream read:buffer maxLength:bufferSize];
                [data appendBytes:buffer length:readBytes];
            } while (readBytes > 0);
            [bodyStream close];
            _cachedRequestBody = data;
        }
    }
    return _cachedRequestBody;
}

- (void)setRequestBody:(NSData *)requestBody
{
    _cachedRequestBody = requestBody;
}

+ (NSString *)readableStringFromTransactionState:(ADHNetworkTransactionState)state
{
    NSString *readableString = nil;
    switch (state) {
        case ADHNetworkTransactionStateUnstarted:
            readableString = @"Unstarted";
            break;
            
        case ADHNetworkTransactionStateStarted:
            readableString = @"Started";
            break;
            
        case ADHNetworkTransactionStateSendingData:
            readableString = @"Sending Body";
            break;
    
        case ADHNetworkTransactionStateResponseReceived:
            readableString = @"Response Received";
            break;
            
        case ADHNetworkTransactionStateReceivingData:
            readableString = @"Receiving Data";
            break;
            
        case ADHNetworkTransactionStateFinished:
            readableString = @"Finished";
            break;
            
        case ADHNetworkTransactionStateFailed:
            readableString = @"Failed";
            break;
    }
    return readableString;
}

- (NSDictionary *)dicPresentation
{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    data[@"requestID"] = adhvf_safestringfy(self.requestID);
    if(self.request){
        NSData * requestData = [ADHNetworkTransaction archivedData:self.request];
        NSString * requestStr = [ADHNetworkTransaction base64Presentation:requestData];
        data[@"request"] = adhvf_safestringfy(requestStr);
    }
    if(self.response){
        NSData * responseData = [ADHNetworkTransaction archivedData:self.response];
        NSString * responseStr = [ADHNetworkTransaction base64Presentation:responseData];
        data[@"response"] = adhvf_safestringfy(responseStr);
    }
    if(self.requestMechanism){
        data[@"requestMechanism"] = adhvf_safestringfy(self.requestMechanism);
    }
    data[@"transactionState"] = [NSString stringWithFormat:@"%ld",(long)self.transactionState];
    if(self.error){
        data[@"error"] = adhvf_safestringfy(self.error.localizedDescription);
    }
    data[@"startTime"] = [NSString stringWithFormat:@"%f",[self.startTime timeIntervalSince1970]];
    data[@"latency"] = [NSString stringWithFormat:@"%f",self.latency];
    data[@"duration"] = [NSString stringWithFormat:@"%f",self.duration];
    data[@"receivedDataLength"] = [NSString stringWithFormat:@"%lld",self.receivedDataLength];
    if(self.cachedRequestBody){
        NSString * bodyStr = [ADHNetworkTransaction base64Presentation:self.requestBody];
        data[@"requestBody"] = adhvf_safestringfy(bodyStr);
    }
    return data;
}

/**
 updation data
 */
- (NSDictionary *)transferRecordData
{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    ADHNetworkTransactionState state = self.transactionState;
    data[@"requestID"] = adhvf_safestringfy(self.requestID);
    data[@"transactionState"] = [NSString stringWithFormat:@"%ld",(long)self.transactionState];
    if(state == ADHNetworkTransactionStateUnstarted){
        
    }else if(state == ADHNetworkTransactionStateStarted){
        if(self.request){
            NSData * requestData = [ADHNetworkTransaction archivedData:self.request];
            NSString * requestStr = [ADHNetworkTransaction base64Presentation:requestData];
            data[@"request"] = adhvf_safestringfy(requestStr);
        }
        data[@"startTime"] = [NSString stringWithFormat:@"%f",[self.startTime timeIntervalSince1970]];
    }else if(state == ADHNetworkTransactionStateSendingData){
        data[@"sentDataLength"] = [NSString stringWithFormat:@"%lld",self.sentDataLength];
    }else if(state == ADHNetworkTransactionStateResponseReceived){
        if([self hasUrlEncodedForm]){
            //only transfer url encode form body，目前好像没用(request.httpbody会被coding传到Mac端)
            if(self.cachedRequestBody){
                NSString * bodyStr = [ADHNetworkTransaction base64Presentation:self.requestBody];
                data[@"requestBody"] = adhvf_safestringfy(bodyStr);
            }
        }
        if(self.response){
            NSData * responseData = [ADHNetworkTransaction archivedData:self.response];
            NSString * responseStr = [ADHNetworkTransaction base64Presentation:responseData];
            data[@"response"] = adhvf_safestringfy(responseStr);
        }
        data[@"latency"] = [NSString stringWithFormat:@"%f",self.latency];
    }else if(state == ADHNetworkTransactionStateReceivingData){
        data[@"receivedDataLength"] = [NSString stringWithFormat:@"%lld",self.receivedDataLength];
    }else if(state == ADHNetworkTransactionStateFinished){
        data[@"duration"] = [NSString stringWithFormat:@"%f",self.duration];
        data[@"receivedDataLength"] = [NSString stringWithFormat:@"%lld",self.receivedDataLength];
    }else if(state == ADHNetworkTransactionStateFailed){
        if(self.error){
            data[@"error"] = adhvf_safestringfy(self.error.localizedDescription);
        }
        data[@"duration"] = [NSString stringWithFormat:@"%f",self.duration];
        data[@"receivedDataLength"] = [NSString stringWithFormat:@"%lld",self.receivedDataLength];
    }
    return data;
}

+ (BOOL)isNecessaryState: (ADHNetworkTransactionState)state
{
    BOOL result = NO;
    switch (state) {
        case ADHNetworkTransactionStateStarted:
        case ADHNetworkTransactionStateResponseReceived:
        case ADHNetworkTransactionStateFinished:
        case ADHNetworkTransactionStateFailed:
            result = YES;
            break;
        default:
            break;
    }
    return result;
}

- (void)updateWithTransferRecord: (ADHNetworkTransferRecord *)record
{
    NSDictionary * data = record.transactionData;
    ADHNetworkTransactionState state = record.transactionState;
    self.transactionState = state;
    ADHNetworkTransaction * transaction = self;
    if(data[@"request"]){
        NSString * requestStr = data[@"request"];
        NSData * requestData = [ADHNetworkTransaction unbase64Data:requestStr];
        transaction.request = [ADHNetworkTransaction unarchivedObject:requestData];
    }
    if(data[@"response"]){
        NSString * responseStr = data[@"response"];
        NSData * responseData = [ADHNetworkTransaction unbase64Data:responseStr];
        NSURLResponse * response = [ADHNetworkTransaction unarchivedObject:responseData];
        if([response isKindOfClass:[NSHTTPURLResponse class]]){
            self.response = (NSHTTPURLResponse *)response;
        }
    }
    if(data[@"requestMechanism"]){
        transaction.requestMechanism = data[@"requestMechanism"];
    }
    
    if(data[@"error"]){
        NSString * errorStr = data[@"error"];
        if(errorStr){
            NSDictionary * userInfo = @{};
            NSErrorDomain domain = @"ADHNetwork";
            NSError * error = [NSError errorWithDomain:domain code:0 userInfo:userInfo];
            transaction.error = error;
        }
    }
    if(data[@"startTime"]){
        NSTimeInterval interval = [data[@"startTime"] doubleValue];
        transaction.startTime = [NSDate dateWithTimeIntervalSince1970:interval];
    }
    if(data[@"latency"]){
        transaction.latency = [data[@"latency"] doubleValue];
    }
    if(data[@"duration"]){
        transaction.duration = [data[@"duration"] doubleValue];
    }
    if(data[@"sentDataLength"]){
        transaction.sentDataLength = [data[@"sentDataLength"] longLongValue];
    }
    if(data[@"receivedDataLength"]){
        transaction.receivedDataLength = [data[@"receivedDataLength"] longLongValue];
    }
    if(data[@"requestBody"]){
        NSString * requestBodyStr = data[@"requestBody"];
        NSData * requestBodyData = [ADHNetworkTransaction unbase64Data:requestBodyStr];
        transaction.requestBody = [ADHNetworkTransaction unarchivedObject:requestBodyData];
    }
}

#pragma mark -----------------   display   ----------------

- (NSString *)readableDuration
{
    NSString * value = nil;
    ADHNetworkTransactionState state = self.transactionState;
    if(state == ADHNetworkTransactionStateFinished || state ==ADHNetworkTransactionStateFailed){
        NSTimeInterval duration = self.duration;
        if(duration < 1.0){
            NSTimeInterval msValue = duration * 1000;
            value = [NSString stringWithFormat:@"%.f ms",msValue];
        }else{
            value = [NSString stringWithFormat:@"%.2f s",duration];
        }
    }else{
        value = @"";
    }
    return value;
}

- (NSString *)readbleTransactionState
{
    NSString * status = [ADHNetworkTransaction readableStringFromTransactionState:self.transactionState];
    if(self.transactionState == ADHNetworkTransactionStateSendingData){
        status = [NSString stringWithFormat:@"%@ (%@)",status, [self readbleSentBodySize]];
    }else if(self.transactionState == ADHNetworkTransactionStateReceivingData){
        status = [NSString stringWithFormat:@"%@ (%@)",status, [self readableReceivedBodySize]];
    }
    return status;
}

- (NSString *)responseCode
{
    NSString * code = adhvf_const_emptystr();
    if(self.response){
        if([self.response respondsToSelector:NSSelectorFromString(@"statusCode")]){
            NSInteger statusCode = self.response.statusCode;
            code= [NSString stringWithFormat:@"%ld",(long)statusCode];
        }
    }
    return code;
}

- (NSString *)requestHost
{
    NSURL * requestURL = self.request.URL;
    NSString * host = requestURL.host;
    if(requestURL.port){
        host = [NSString stringWithFormat:@"%@:%@",host,requestURL.port];
    }
    return host;
}

- (NSString *)requestPath
{
    NSURL * requestURL = self.request.URL;
    NSString * path = requestURL.path;
    if(requestURL.query){
        path = [NSString stringWithFormat:@"%@?%@",path,requestURL.query];
    }
    if(requestURL.fragment){
        path = [NSString stringWithFormat:@"%@?%@",path,requestURL.fragment];
    }
    return path;
}

- (NSString *)readbleSentBodySize
{
    int64_t size = self.sentDataLength;
    return [self readbleBytesSize:size];
}

- (NSString *)readableReceivedBodySize
{
    int64_t size = self.receivedDataLength;
    return [self readbleBytesSize:size];
}

- (NSString *)readbleBytesSize: (uint64_t)size {
    NSString * value = @"";
    if(size < 1024){
        value = [NSString stringWithFormat:@"%llu Bytes",size];
    }else if(size < 1024 * 1024){
        float kbValue = (size / 1024.0f);
        value = [NSString stringWithFormat:@"%.2f KB",kbValue];
    }else {
        float mbValue = (size/(1024*1024.0f));
        value = [NSString stringWithFormat:@"%.2f MB",mbValue];
    }
    return value;
}

#pragma mark -----------------   util   ----------------

+ (NSData *)archivedData:(id<NSCoding>)obj {
    NSData *requestData = nil;
    /*
    if(@available(iOS 11.0, macOS 10.13, *)) {
        requestData = [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:YES error:nil];
    }else {
        requestData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    }*/
    requestData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    return requestData;
}

+ (id)unarchivedObject: (NSData *)data {
    id object = nil;
    /*
    if(@available(iOS 11.0, macOS 10.13, *)) {
        NSArray *classes = @[
                             [NSURLRequest class],
                             [NSURLResponse class],
                             [NSData class],
                             ];
        NSSet *set = [NSSet setWithArray:classes];
        NSError *error = nil;
        object = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:&error];
        if(error) {
            NSLog(@"%@",error);
        }
    }else {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }*/
    object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return object;
}

+ (NSString *)base64Presentation: (NSData *)data
{
    NSString * content = [data base64EncodedStringWithOptions:0];
    return content;
}

+ (NSData *)unbase64Data: (NSString *)base64Str
{
    NSData * data = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
    return data;
}

//是否有query
- (BOOL)hasQuery
{
    BOOL ret = NO;
    return (self.request.URL.query.length > 0);
    return ret;
}

//是否url encoded form body
- (BOOL)hasUrlEncodedForm
{
    BOOL ret = NO;
    NSString * contentType = [self requestContentType];
    if([[contentType lowercaseString] isEqualToString:@"application/x-www-form-urlencoded"]){
        ret = YES;
    }
    return ret;
}

- (BOOL)isJsonResponse
{
    BOOL ret = NO;
    NSString * contentType = [self responseContentType];
    contentType = [contentType lowercaseString];
    /*
     * application/json
     * text/json
     * application/vnd.api+json
    */
    if([contentType containsString:@"/json"] || [contentType containsString:@"+json"]){
        ret = YES;
    }
    return ret;
}

- (NSString *)requestContentType
{
    NSString *contentType = [self.request valueForHTTPHeaderField:@"Content-Type"];
    return contentType;
}

- (NSString *)requestContentEncoding {
    NSString *contentEncoding = [self.request valueForHTTPHeaderField:@"Content-Encoding"];
    return contentEncoding;
}

- (NSString *)responseContentType
{
    NSString * contentType = nil;
    if(self.response){
        contentType = [self.response allHeaderFields][@"Content-Type"];
    }
    return contentType;
}

- (NSString *)requestCookie
{
    NSString * cookieValue = nil;
    if(self.request){
        cookieValue = [self.request valueForHTTPHeaderField:@"Cookie"];
    }
    cookieValue = adhvf_safestringfy(cookieValue);
    return cookieValue;
}

- (NSString *)responseCookie
{
    NSString * cookieValue = nil;
    if(self.response){
        cookieValue = [self.response allHeaderFields][@"Set-Cookie"];
    }
    cookieValue = adhvf_safestringfy(cookieValue);
    return cookieValue;
}

- (BOOL)requestHasCookie
{
    return ([self requestCookie].length > 0);
}

- (BOOL)responseHasCookie
{
    return ([self responseCookie].length > 0);
}

- (BOOL)isResponseBodyReady {
    return (self.transactionState == ADHNetworkTransactionStateFinished) && (self.receivedDataLength > 0);
}

- (BOOL)isCurlAvailable {
    return (self.transactionState >= ADHNetworkTransactionStateResponseReceived);
}

@end


@implementation ADHNetworkTransferRecord

- (NSString *)description
{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    if(self.requestID){
        data[@"requestID"] = self.requestID;
    }
    data[@"transactionState"] = [ADHNetworkTransaction readableStringFromTransactionState:self.transactionState];
    return [NSString stringWithFormat:@"%@",data];
}

- (NSDictionary *)dicPresentation
{
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    if(self.requestID){
        data[@"requestID"] = self.requestID;
    }
    data[@"transactionState"] = [NSString stringWithFormat:@"%ld",(long)self.transactionState];
    data[@"date"] = [NSString stringWithFormat:@"%f",[self.date timeIntervalSince1970]];
    if(self.transactionData){
        data[@"transactionData"] = self.transactionData;
    }
    return data;
}

+ (ADHNetworkTransferRecord *)recordWithData: (NSDictionary *)data
{
    ADHNetworkTransferRecord * record = [[ADHNetworkTransferRecord alloc] init];
    record.requestID = data[@"requestID"];
    record.transactionState = [data[@"transactionState"] integerValue];
    record.date = [NSDate dateWithTimeIntervalSince1970:[data[@"date"] doubleValue]];
    record.transactionData = data[@"transactionData"];
    return record;
}

- (BOOL)isFinished
{
    return (self.transferState == ADHNetworkRecordTransferStateSuccess || self.transferState == ADHNetworkRecordTransferStateFailed);
}

- (BOOL)isSuccess
{
    return (self.transferState == ADHNetworkRecordTransferStateSuccess);
}

- (BOOL)isFailed
{
    return (self.transferState == ADHNetworkRecordTransferStateFailed);
}

- (BOOL)isNecessary
{
    return [ADHNetworkTransaction isNecessaryState:self.transactionState];
}

@end















