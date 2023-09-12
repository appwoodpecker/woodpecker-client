//
//  ADHProtocol.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2023/9/2.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import "ADHProtocol.h"
#import "ADHUsbChannel.h"
#import "ADHSocketChannel.h"

@interface ADHProtocol ()

@property (nonatomic, strong) ADHSocketChannel *mSocketChannel;
@property (nonatomic, strong) ADHUsbChannel *mUsbChannel;
@property (nonatomic, weak) id <ADHChannelDelegate> mDelegate;

@end

@implementation ADHProtocol

+ (ADHProtocol *)protocol {
    return [ADHProtocol new];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mSocketChannel = [ADHSocketChannel channel];
    }
    return self;
}

- (id<ADHChannel>)workChannel {
    if (self.mUsbChannel != nil && self.mUsbChannel.isConnected) {
        return self.mUsbChannel;
    } else {
        return self.mSocketChannel;
    }
    return self.mSocketChannel;
}

- (void)setSocket:(ADHGCDAsyncSocket *)socket {
    [self.mSocketChannel setSocket:socket];
    if (self.mDelegate != nil) {
        [self.mSocketChannel setDelegate:self.mDelegate];
    }
}

- (void)setUsb:(ADHPTChannel *)usbChannel {
    if (self.mUsbChannel == nil) {
        self.mUsbChannel = [ADHUsbChannel channel];
    }
    [self.mUsbChannel setUsb:usbChannel];
    if (self.mDelegate != nil) {
        [self.mUsbChannel setDelegate:self.mDelegate];
    }
}

- (void)setDelegete:(id<ADHChannelDelegate>)delegate {
    self.mDelegate = delegate;
    [self.mSocketChannel setDelegate:delegate];
    [self.mUsbChannel setDelegate:delegate];
}

- (ADHSocketChannel *)socketChannel {
    return self.mSocketChannel;
}

- (ADHUsbChannel *)usbChannel {
    return self.mUsbChannel;
}

- (BOOL)matchWithSocket:(ADHGCDAsyncSocket *)socket {
    return self.mSocketChannel.socket == socket;
}

- (BOOL)matchWithUsb:(ADHPTChannel *)channel {
    return self.mUsbChannel.usb == channel;
}

- (BOOL)isConnected {
    if (self.mSocketChannel != nil) {
        return self.mSocketChannel.socket.isConnected;
    }
    if (self.mUsbChannel != nil) {
        return self.mUsbChannel.isConnected;
    }
    return NO;
}

- (void)disConnect {
    [self.mSocketChannel.socket disconnect];
    self.mSocketChannel.delegate = nil;
    self.mSocketChannel = nil;
    [self.mUsbChannel disConnect];
    self.mUsbChannel.delegate = nil;
    self.mUsbChannel = nil;
}

@end
