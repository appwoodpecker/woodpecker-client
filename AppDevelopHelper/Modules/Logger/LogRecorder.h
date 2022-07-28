//
//  LogRecorder.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogItem.h"

//i/o
extern NSString * const kLogRecorderUpdateNotification;
extern NSString * const kLogRecorderUpdateNotificationNewItemKey;
//console
extern NSString * const kLogRecorderConsoleUpdateNotification;
extern NSString * const kLogRecorderUpdateNotificationNewConsoleItemsKey;


@interface LogRecorder : NSObject

//shared
+ (LogRecorder *)recorderWithContext: (AppContext *)context;

- (void)logWithBody: (NSDictionary *)body payload: (NSData *)payload;

- (NSArray<LogItem *> *)itemList;
- (void)clearRecords;

- (void)insertItem: (LogItem *)item;
- (NSString *)saveFileWithData: (NSData *)fileData fileName: (NSString *)fileName;

///console log

- (void)onReceiveNewLog: (NSArray<NSString *> *)messages;

@end


