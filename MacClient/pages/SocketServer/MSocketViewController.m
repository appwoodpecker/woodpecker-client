//
//  MSocketViewController.m
//  MacClient
//
//  Created by 张小刚 on 2019/6/15.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "MSocketViewController.h"
#import "ADHGCDAsyncSocket.h"
@import SystemConfiguration;
@import Darwin;

@interface MSocketViewController ()<ADHGCDAsyncSocketDelegate>

@property (nonatomic, strong) ADHGCDAsyncSocket *socket;
@property (nonatomic, strong) ADHGCDAsyncSocket *clientSocket;
@property (weak) IBOutlet NSTextField *stateLabel;
@property (weak) IBOutlet NSTextField *clientLabel;
@property (weak) IBOutlet NSTextField *writeLabel;
@property (unsafe_unretained) IBOutlet NSTextView *contentTextView;

@property (nonatomic, assign) long tag;

@end

@implementation MSocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stateLabel.stringValue = @"";
    self.clientLabel.stringValue = @"";
    self.writeLabel.stringValue = @"";
    
}

- (IBAction)listenButtonPressed:(id)sender {
    [self startListening];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self.socket disconnect];
    self.socket = nil;
}


- (IBAction)closeClientButtonPressed:(id)sender {
    if(self.clientSocket.isConnected) {
        [self.clientSocket disconnect];
    }
    self.clientSocket = nil;
}

- (IBAction)writeButtonPressed:(id)sender {
    [self writeDate];
}

- (void)writeDate {
    if(!self.clientSocket.isConnected) {
        return;
    }
    NSDate *date = [NSDate date];
    NSString *text = [NSString stringWithFormat:@"%@",date];
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    self.tag++;
    [self.clientSocket writeData:data withTimeout:60 tag:self.tag];
}

- (IBAction)writeDataButtonPressed:(id)sender {
    if(!self.clientSocket.isConnected) {
        return;
    }
    NSString *text = self.contentTextView.string;
    if(text.length == 0) {
        return;
    }
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    self.tag++;
    [self.clientSocket writeData:data withTimeout:60 tag:self.tag];
}


- (void)startListening {
    //setup socket
    ADHGCDAsyncSocket * socket = [[ADHGCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError * error = nil;
    uint16_t port = 60000;
    BOOL ret = [socket acceptOnPort:port error:&error];
    if(ret) {
        self.socket = socket;
        NSArray * addresses = [self getIPAddresses];
        NSString * localHost = nil;
        for (NSString *anAddress in addresses) {
            if (![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count] == 4) {
                localHost = anAddress;
                break;
            }
        }
        self.stateLabel.stringValue = [NSString stringWithFormat:@"%@ : %d",localHost,port];
    }else {
        NSLog(@"%@",error);
        self.stateLabel.stringValue = @"";
    }
}


- (NSArray *)getIPAddresses {
    NSMutableArray * addresses = [NSMutableArray array];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0){
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL){
            if(temp_addr->ifa_addr->sa_family == AF_INET){
                // Get NSString from C String
                NSString * address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                if(address.length > 0){
                    [addresses addObject:address];
                }
            }else if(temp_addr->ifa_addr->sa_family == AF_INET6){
                //IPv6
                /*
                 char tmp[50];
                 struct sockaddr_in6 * in6 = (struct sockaddr_in6*) temp_addr->ifa_addr;
                 inet_ntop(AF_INET6, &in6->sin6_addr, tmp, sizeof(tmp));
                 NSString * address = [NSString stringWithUTF8String:tmp];
                 if(address.length > 0){
                 [addresses addObject:address];
                 }
                 */
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return addresses;
}

/**
 * 新的client连接
 */
- (void)socket:(ADHGCDAsyncSocket *)sock didAcceptNewSocket:(ADHGCDAsyncSocket *)newSocket {
    if(self.clientSocket) {
        [self.clientSocket disconnect];
        self.clientSocket = nil;
    }
    self.clientSocket = newSocket;
    self.clientLabel.stringValue = [NSString stringWithFormat:@"%@: %d",newSocket.connectedHost,newSocket.connectedPort];
}

/**
 * Server/Client
 * socket断开链接
 **/
- (void)socketDidDisconnect:(ADHGCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"client disconnect: %@",err);
    if(sock == self.clientSocket) {
        self.clientLabel.stringValue = @"";
    }
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(ADHGCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    self.writeLabel.stringValue = [NSString stringWithFormat:@"did write data: [%ld]",tag];
    NSLog(@"did write data: [%ld]",tag);
}

@end
