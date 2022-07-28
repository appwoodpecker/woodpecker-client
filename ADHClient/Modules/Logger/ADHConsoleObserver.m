//
//  ADHLogObserver.m
//  Logger
//
//  Created by zhangxiaogang on 2018/6/7.
//  Copyright © 2018年 zhangxiaogang. All rights reserved.
//

#import "ADHConsoleObserver.h"
#import <stdio.h>
#import "ADHConsoleActionService.h"

@interface ADHConsoleMocker: NSObject

@property (nonatomic, assign) int oldFd;
@property (nonatomic, assign) int backupFd;
@property (nonatomic, strong) NSThread *readThread;
@property (nonatomic, strong) NSFileHandle *readFileHandle;

@end

@implementation ADHConsoleMocker

@end

@interface ADHConsoleObserver ()


@property (nonatomic, strong) NSMutableArray *logMockers;
@property (nonatomic, assign) BOOL bMocking;

@property (nonatomic, weak) ADHConsoleActionService *mConsoleService;

@end

@implementation ADHConsoleObserver

+ (ADHConsoleObserver *)sharedObserver {
    static ADHConsoleObserver *sharedObserver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObserver = [[ADHConsoleObserver alloc] init];
    });
    return sharedObserver;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.logMockers = [NSMutableArray array];
    }
    return self;
}

- (void)setActionService: (ADHConsoleActionService *)consoleService {
    self.mConsoleService = consoleService;
}

- (void)start {
    if(self.bMocking) return;
    [self mockFileDescriptor:STDERR_FILENO];
    [self mockFileDescriptor:STDOUT_FILENO];
    self.bMocking = YES;
}

- (void)stop {
    for (ADHConsoleMocker *mocker in self.logMockers) {
        int backupFd = mocker.backupFd;
        int oldFd = mocker.oldFd;
        dup2(backupFd, oldFd);
        mocker.readFileHandle = nil;
        mocker.readThread = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.logMockers removeAllObjects];
    self.bMocking = NO;
}

- (void)mockFileDescriptor: (int)oldFd {
    int backupFd = dup(oldFd);
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *writeHandle = [pipe fileHandleForWriting];
    dup2(writeHandle.fileDescriptor, oldFd);
    
    NSThread *readThread = [[NSThread alloc] initWithTarget:self selector:@selector(readFdThreadEntry:) object:[NSNumber numberWithInt:oldFd]];
    [readThread start];
    NSFileHandle *readHandle = [pipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redirectReadCompletionNotification:) name:NSFileHandleReadCompletionNotification object:readHandle];
    [readHandle performSelector:@selector(readInBackgroundAndNotify) onThread:readThread withObject:nil waitUntilDone:YES];
    
    ADHConsoleMocker *mocker = [[ADHConsoleMocker alloc] init];
    mocker.oldFd = oldFd;
    mocker.backupFd = backupFd;
    mocker.readThread = readThread;
    mocker.readFileHandle = readHandle;
    [self.logMockers addObject:mocker];
    
}

- (void)readFdThreadEntry:(NSNumber *)fd {
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
    [runLoop run];
}

- (void)redirectReadCompletionNotification: (NSNotification *)notification {
    // parse data
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if(data) {
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(content) {
            [self.mConsoleService onReceiveNewLog:content];
        }
    }
    //continue
    NSFileHandle *readHandle = notification.object;
    ADHConsoleMocker *mocker = [self mockerWithFileHandle:readHandle];
    if(mocker) {
        if(data) {
            const void * bytes = [data bytes];
            size_t length = data.length;
            write(mocker.backupFd, bytes, length);
        }
        //continue read
        NSThread *readThread = mocker.readThread;
        [readHandle performSelector:@selector(readInBackgroundAndNotify) onThread:readThread withObject:nil waitUntilDone:YES];
    }
}

- (ADHConsoleMocker *)mockerWithFileHandle: (NSFileHandle *)fileHandle {
    ADHConsoleMocker *targetMocker = nil;
    for (ADHConsoleMocker *mocker in self.logMockers) {
        if(mocker.readFileHandle == fileHandle) {
            targetMocker = mocker;
            break;
        }
    }
    return targetMocker;
}


@end




