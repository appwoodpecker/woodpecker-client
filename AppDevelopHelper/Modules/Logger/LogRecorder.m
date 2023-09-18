//
//  LogRecorder.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "LogRecorder.h"
#import "EnvtService.h"

NSString * const kLogRecorderUpdateNotification                     = @"kLogRecorderUpdateNotification";
NSString * const kLogRecorderUpdateNotificationNewItemKey           = @"newItem";

NSString * const kLogRecorderConsoleUpdateNotification              = @"kLogRecorderConsoleUpdateNotification";
NSString * const kLogRecorderUpdateNotificationNewConsoleItemsKey   = @"list";

@interface LogRecorder ()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableArray * mItemList;

@end

@implementation LogRecorder

static NSMutableArray *gRecorderList;

+ (LogRecorder *)recorderWithContext: (AppContext *)context {
    if(!gRecorderList) {
        gRecorderList = [NSMutableArray array];
    }
    LogRecorder *targetRecorder = nil;
    for (LogRecorder *recorder in gRecorderList) {
        if(recorder.context == context) {
            targetRecorder = recorder;
            break;
        }
    }
    if(!targetRecorder) {
        LogRecorder *recorder = [[LogRecorder alloc] init];
        recorder.context = context;
        [gRecorderList addObject:recorder];
        targetRecorder = recorder;
    }
    return targetRecorder;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = [self getLoggerQueue];
        self.mItemList = [NSMutableArray array];
    }
    return self;
}

- (dispatch_queue_t)getLoggerQueue {
    static dispatch_queue_t sharedQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = dispatch_queue_create("studio.lifebetter.service.logrecorder", DISPATCH_QUEUE_SERIAL);
    });
    return sharedQueue;
}

- (NSArray<LogItem *> *)itemList {
    return [NSArray arrayWithArray:self.mItemList];
}

- (void)insertItem: (LogItem *)item {
    [self.mItemList addObject:item];
}

- (void)logWithBody: (NSDictionary *)data payload: (NSData *)payload {
    dispatch_async(self.queue, ^{
        [self _logWithBody:data payload:payload];
    });
}

- (void)clearRecords {
    dispatch_async(self.queue, ^{
       [self.mItemList removeAllObjects];
    });
}
    
#pragma mark -----------------   record   ----------------

- (void)_logWithBody: (NSDictionary *)data payload: (NSData *)payload {
    NSString * type = data[@"type"];
    LogItem * item = [[LogItem alloc] init];
    item.type = type;
    NSString * text = data[@"text"];
    if([text isKindOfClass:[NSString class]]){
        item.text = text;
        if(data[@"color"]){
            NSString * colorValue = data[@"color"];
            NSArray * components = [colorValue componentsSeparatedByString:@"|"];
            if(components.count == 4){
                CGFloat red = [components[0] floatValue];
                CGFloat green = [components[1] floatValue];
                CGFloat blue = [components[2] floatValue];
                CGFloat alpha = [components[3] floatValue];
                NSColor * color = [NSColor colorWithRed:red green:green blue:blue alpha:alpha];
                item.textColor = color;
            }
        }
    }
    if([type isEqualToString:@"file"]){
        NSString * fileName = data[@"filename"];
        if(payload){
            NSString * filePath = [self saveFileWithData:payload fileName:fileName];
            if(filePath){
                item.filePath = filePath;
                item.fileName = fileName;
            }
        }
    }
    item.date = [NSDate date];
    [self.mItemList addObject:item];
    [self notifyUpdate];
}

- (NSString *)saveFileWithData: (NSData *)fileData fileName: (NSString *)fileName {
    NSString * resultFilePath = nil;
    if(fileName.length == 0){
        fileName = [ADHDateUtil formatStringWithDate:[NSDate date] dateFormat:@"yyyyMMddHHmmss"];
    }
    NSString * filePath = [self getFilePath:fileName];
    BOOL ret = [ADHFileUtil saveData:fileData atPath:filePath];
    if(ret){
        resultFilePath = filePath;
    }
    return resultFilePath;
}

- (NSString *)workPath {
    NSString * workPath = [[EnvtService sharedService] loggerWorkPath];
    return workPath;
}

- (NSString *)getFilePath: (NSString *)fileName {
    NSString * workPath = [self workPath];
    return [workPath stringByAppendingPathComponent:fileName];
}

#pragma mark -----------------   console log   ----------------

///console log
- (void)onReceiveNewLog: (NSArray<NSString *> *)messages {
    NSMutableString *content = [[NSMutableString alloc] init];
    for (NSString *message in messages) {
        [content appendString:message];
    }
    if(content.length > 0) {
        if([content hasSuffix:@"\n"]) {
            NSRange lastRange = NSMakeRange(content.length-1, 1);
            [content deleteCharactersInRange:lastRange];
        }
        [self.mItemList addObject:content];
        [self notifyUpdate];
    }
}

- (void)notifyUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogRecorderUpdateNotification object:self userInfo:nil];
}



@end
