//
//  AppOrganizer.m
//  ADHClient
//
//  Created by 张小刚 on 2017/11/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHOrganizer.h"
#import "ADHGestureRecognizer.h"
#import "ADHAppConnector.h"
#import "ADHConnectViewController.h"
#import "ADHWindow.h"
#import "ADHPreferenceService.h"
//server service
#import "ADHKeepAliveService.h"
#import "ADHMetaService.h"
#import "ADHFileBrowserActionService.h"
#import "ADHAppDefaultActionService.h"
#import "ADHAppInfoActionService.h"
#import "ADHNetworkActionService.h"
#import "ADHWebDebugActionService.h"
#import "ADHUserDefaultsActionService.h"
#import "ADHDeviceActionService.h"
#import "ADHControllerHierarchyActionService.h"
#import "ADHNotificationActionService.h"
#import "ADHNotificationObserver.h"
#import "ADHConsoleActionService.h"
#import "ADHLocalizationActionService.h"
#import "ADHLaunchOptions.h"
#import "ADHUserDefaultUtil.h"
#import "ADHKeyChainActionService.h"
#import "ADHAppBundleActionService.h"
#import "ADHViewDebugActionService.h"
#import "ADHCloudActionService.h"
#import "ADHStateMasterActionService.h"
#import "ADHUtilityActionService.h"
#import "ADHFirebaseActionService.h"
#import "ADHSocketChannel.h"
#import "ADHUsbChannel.h"
#import "ADHUtil.h"

NSString * const kADHOrganizerWindowDidVisible = @"ADHOrganizerWindowDidVisible";
NSString * const kADHOrganizerWorkStatusUpdate = @"ADHOrganizerWorkStatusUpdate";

static NSInteger const ADHOrganizerAutoRecoverConnectionMaxCount = 3;
static NSTimeInterval const ADHOrganizerAutoConnectDelay = 0.1;


@import UIKit;

@interface ADHOrganizer ()

@property (nonatomic, strong) ADHLaunchOptions *launchOptions;
@property (nonatomic, strong) ADHProtocol *mProtocol;
@property (nonatomic, strong) ADHDispatcher *mDispatcher;
@property (nonatomic, strong) ADHAppConnector * mConnector;

@property (nonatomic, strong) UIWindow * mWindow;

@property (nonatomic, strong) NSString * workingHost;
@property (nonatomic, assign) uint16_t workingPort;
@property (nonatomic, assign) BOOL shouldTryRecoverConnection;
@property (nonatomic, assign) NSInteger tryRecoverConnectionCounter;
@property (nonatomic, assign) BOOL bLaunchAutoConnectRoutine;
@property (nonatomic, assign) BOOL bLaunchAutoConnectUIAppeared;



@end

@implementation ADHOrganizer

+ (void)load {
    ADHOrganizer * organizer = [ADHOrganizer sharedOrganizer];
    [organizer setup];
}

+ (ADHOrganizer *)sharedOrganizer {
    static ADHOrganizer * organizer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        organizer = [[ADHOrganizer alloc] init];
    });
    return organizer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadLaunchOptions];
    }
    return self;
}

- (void)loadLaunchOptions {
    ADHLaunchOptions *options = [[ADHLaunchOptions alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:kADHAutoConnectEnabled]) {
        options.autoConnectEnabled = [defaults boolForKey:kADHAutoConnectEnabled];
    }
    if([defaults objectForKey:kADHHostName]) {
        options.hostName = [defaults stringForKey:kADHHostName];
    }
    if([defaults objectForKey:kADHHostAddress]) {
        NSString *addressName = [defaults stringForKey:kADHHostAddress];
        //移除空格
        addressName = [addressName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *components = [addressName componentsSeparatedByString:@":"];
        if(components.count >= 2) {
            options.hostAddress = components[0];
            options.hostPort = (uint16_t)[components[1] intValue];
        }else {
            options.hostAddress = addressName;
            options.hostPort = 0;
        }
    }
    if ([defaults objectForKey:kADHUIGestureEnabled]) {
        options.uiGestureEnabled = [defaults boolForKey:kADHUIGestureEnabled];
    }
    self.launchOptions = options;
}

- (void)addWindowGestureRegcognizer
{
    NSArray * windows = [[UIApplication sharedApplication] windows];
    for (UIWindow * window in windows) {
        if([window isKindOfClass:[ADHWindow class]]){
            continue;
        }
        NSArray * gestureRecognizers = window.gestureRecognizers;
        BOOL isExists = NO;
        for (UIGestureRecognizer * recognizer in gestureRecognizers) {
            if([recognizer isKindOfClass:[ADHGestureRecognizer class]]){
                isExists = YES;
                break;
            }
        }
        if(!isExists){
            ADHGestureRecognizer * recognizer = [[ADHGestureRecognizer alloc] initWithTarget:self action:@selector(showMainView)];
            recognizer.numberOfTouchesRequired = 2;
            [window addGestureRecognizer:recognizer];
        }
    }
}

- (BOOL)isUIShowing {
    return (self.mWindow && !self.mWindow.hidden);
}

- (void)showMainView
{
    if(!self.mWindow){
        UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = UIWindowLevelStatusBar - 1;
        window.backgroundColor = [UIColor whiteColor];
        self.mWindow = window;
        ADHConnectViewController * connectVC = [[ADHConnectViewController alloc] initWithNibName:NSStringFromClass([ADHConnectViewController class]) bundle:[self adhBundle]];
        UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:connectVC];
        self.mWindow.rootViewController = nvc;
    }
    //已经在展示
    if(!self.mWindow.hidden) return;
    [self.mWindow makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] postNotificationName:kADHOrganizerWindowDidVisible object:self];
}

- (void)showUI
{
    [self showMainView];
}

- (ADHProtocol *)protocol {
    return self.mProtocol;
}

- (ADHDispatcher *)dispatcher {
    return self.mDispatcher;
}

- (ADHAppConnector *)connector {
    return self.mConnector;
}

- (void)setup {
    ADHProtocol *protocol = [ADHProtocol protocol];
    self.mProtocol = protocol;
    
    ADHAppConnector * connector = [[ADHAppConnector alloc] init];
    connector.socketIODelegate = self.mProtocol.socketChannel;
    self.mConnector = connector;
    
    ADHDispatcher *dispatcher = [[ADHDispatcher alloc] init];
    self.mDispatcher = dispatcher;
    [self registerServerService:dispatcher];

    ADHApiClient * apiClient = [ADHApiClient sharedApi];
    [apiClient setProtocol:self.mProtocol];
    [apiClient setDispatcher:self.mDispatcher];
    if (self.launchOptions.uiGestureEnabled) {
        [self addWindowGestureRegcognizer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addWindowGestureRegcognizer) name:UIWindowDidBecomeVisibleNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusUpdate:) name:kADHConnectorConnectStatusUpdate object:nil];
    //尝试USB自动连接，无线连接手动连接
    [self performSelector:@selector(tryConnect) withObject:nil afterDelay:ADHOrganizerAutoConnectDelay];
    
    [[ADHKeepAliveService service] start];
}

- (void)registerServerService: (ADHDispatcher *)dispatcher {
    [dispatcher registerService:[ADHMetaService class]];
    [dispatcher registerService:[ADHFileBrowserActionService class]];
    [dispatcher registerService:[ADHAppDefaultActionService class]];
    [dispatcher registerService:[ADHAppInfoActionService class]];
    [dispatcher registerService:[ADHNetworkActionService class]];
    [dispatcher registerService:[ADHWebDebugActionService class]];
    [dispatcher registerService:[ADHUserDefaultsActionService class]];
    [dispatcher registerService:[ADHDeviceActionService class]];
    [dispatcher registerService:[ADHControllerHierarchyActionService class]];
    [dispatcher registerService:[ADHNotificationActionService class]];
    [[ADHNotificationObserver sharedObserver] start];
    [dispatcher registerService:[ADHConsoleActionService class]];
    [dispatcher registerService:[ADHLocalizationActionService class]];
    [dispatcher registerService:[ADHKeyChainActionService class]];
    [dispatcher registerService:[ADHAppBundleActionService class]];
    [dispatcher registerService:[ADHViewDebugActionService class]];
    [dispatcher registerService:[ADHCloudActionService class]];
    [dispatcher registerService:[ADHStateMasterActionService class]];
    [dispatcher registerService:[ADHUtilityActionService class]];
    [dispatcher registerService:[ADHFirebaseActionService class]];
}

/**
 plugin support
 */
- (void)registerService: (Class)serviceClazz {
    [self.mDispatcher registerService:serviceClazz];
}

- (void)onConnectionStatusUpdate:(NSNotification *)noti {
    [self updateProtocolChannel];
    if(![self.mConnector isSocketConnected]){
//        NSLog(@"unconnected -_-");
        //unconnect
        NSDictionary *userInfo = noti.userInfo;
        NSError *err = userInfo[NSUnderlyingErrorKey];
        if(err && err.code == 7) {
            //if another endport closed, do not try to recover.
            [self clearAutoConnectTry];
        }else {
            [self doTryRecoverConnection];
        }
    } else if([self.mConnector isSocketConnected]){
//        NSLog(@"connected ^_^");
        //connected
        self.workingHost = self.mConnector.connectedHost;
        self.workingPort = self.mConnector.connectedPort;
        self.tryRecoverConnectionCounter = 0;
        self.shouldTryRecoverConnection = YES;
    }
    __weak typeof(self) wself = self;
    /**
     * 添加延时
     * 目前如果app和mac同时在连接成功时发送请求会导致某一方失败
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kADHOrganizerWorkStatusUpdate object:wself userInfo:nil];
    });
}

- (void)updateProtocolChannel {
    //usb
    if ([self.mConnector isUsbConnected]) {
        [self.mProtocol setUsb:self.mConnector.usbChannel];
        self.mConnector.usbIODelegate = self.mProtocol.usbChannel;
    } else {
        [self.mProtocol setUsb:nil];
        self.mConnector.usbIODelegate = nil;
    }
    //socket
    if([self.mConnector isSocketConnected]){
        ADHGCDAsyncSocket * clientSocket = [self.mConnector socket];
        [self.mProtocol setSocket:clientSocket];
    }else{
        [self.mProtocol setSocket:nil];
    }
}

- (void)tryConnect {
    if ([ADHUtil isSimulator]) {
        //模拟器使用socket连接
        [self tryAutoConnect];
    } else {
        //真机使用usb连接
        [self.mConnector startUsbConnection];
    }
}

/**
 自动连接
 根据上次连接状态进行操作
 
 如果上次关闭，则不自动链接
 如果自动链接，
    1.如果上次为手动地址，连接手动地址
    2.如果为自动检测，则本次也自动检测，并在检测到时自动连接
 */
- (void)tryAutoConnect {
    adhDebugLog(@"开始尝试自动链接");
    ADHLaunchOptions *launchOptions = self.launchOptions;
    if(!launchOptions.autoConnectEnabled) {
        adhDebugLog(@"用户不允许自动连接");
        return;
    }
    adhDebugLog(@"开始自动连接");
    //标记当前正在自动链接过程
    self.bLaunchAutoConnectRoutine = YES;
    //根据IP直连
    if([launchOptions isHostAddressValid]){
        NSString * host = launchOptions.hostAddress;
        uint16_t port = launchOptions.hostPort;
        adhDebugLog(@"用户设置了address: %@:%d,尝试链接",host,port);
        [self tryConnectToHost:host port:port];
    }else{
        adhDebugLog(@"开始搜索...");
        [self.mConnector startSearchServiceWithUpdateBlock:^(NSArray<ADHRemoteService *> *serviceList, BOOL moreComing) {
            if([self.mConnector isSocketConnected] || [self.mConnector isConnecting]) {
                return;
            }
            if(serviceList.count == 0){
                return;
            }
            //根据本地host name设置直连
            if([launchOptions isHostNameValid]) {
                ADHRemoteService *targetService = nil;
                //查找用户设置的hostName
                NSString *hostName = launchOptions.hostName;
                for (ADHRemoteService *service in serviceList) {
                    if([service.name rangeOfString:hostName options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        targetService = service;
                        break;
                    }
                }
                if(targetService) {
                    adhDebugLog(@"找到指定host: %@，尝试连接",hostName);
                    [self tryConnectToHost:targetService.host port:targetService.port];
                }else {
                    if(!moreComing) {
                        //没有找到符合，让用户处理
                        adhDebugLog(@"没有找到: %@",hostName);
                        [self handleLaunchAutoConnectFailed];
                    }
                }
            }else {
                /**
                * 没有设置偏好host逻辑：
                * 尝试找到允许链接的设备，并进行连接
                * 如果没有找到允许链接的，在所有service出来后(no more coming)，从中选一个不禁止的进行连接
                * 一直搜索直到搜索完毕，根据有多少service进行处理
                */
                //根据匹配规则尝试链接
                ADHRemoteService *matchService = nil;
                for (ADHRemoteService *service in serviceList) {
                    matchService = service;
                    break;
                }
                if(matchService) {
                    adhDebugLog(@"找到match服务: %@，尝试连接",matchService.name);
                    [self tryConnectToHost:matchService.host port:matchService.port];
                }else {
                    if(!moreComing) {
                        //先查找模拟器和usb直连service
                        ADHRemoteService *localService = nil;
                        for (ADHRemoteService *service in serviceList) {
                            if([service isLocalDirect]) {
                                localService = service;
                                break;
                            }
                        }
                        if(localService) {
                            adhDebugLog(@"找到本地直连服务，尝试连接");
                            [self tryConnectToHost:localService.host port:localService.port];
                        }else {
                            //查找一个允许的
                            ADHRemoteService *allowedService = nil;
                            for (ADHRemoteService *service in serviceList) {
                                allowedService = service;
                                break;
                            }
                            if(allowedService) {
                                adhDebugLog(@"找到一个允许的服务，尝试连接");
                                [self tryConnectToHost:allowedService.host port:allowedService.port];
                            }else {
                                //0个或都不允许，让用户手动处理
                                adhDebugLog(@"最终找到%zd个禁止服务",serviceList.count);
                                [self handleLaunchAutoConnectFailed];
                            }
                        }
                    }
                }
            }
        } error:^(NSError *error) {
            adhDebugLog(@"%@",error);
            //目前暂未测试到超时（超时时间不确定）
            [self handleLaunchAutoConnectFailed];
        }];
    }
}

- (void)handleLaunchAutoConnectFailed {
    
}

- (void)tryConnectToHost: (NSString *)host port: (uint16_t)port {
    [self.connector connectToRemoteHost:host port:port successBlock:^(ADHGCDAsyncSocket *socket) {
        
    } errorBlock:^(NSError *error) {
        adhDebugLog(@"连接失败：%@",error.localizedDescription);
        if(self.bLaunchAutoConnectRoutine) {
            [self handleLaunchAutoConnectFailed];
        }
    }];
}

- (void)doTryRecoverConnection {
    if(self.shouldTryRecoverConnection) {
        self.bLaunchAutoConnectRoutine = NO;
        if(self.workingHost.length > 0 && self.workingPort > 0){
            if(![self.connector isSocketConnected] && ![self.connector isConnecting]){
                self.tryRecoverConnectionCounter++;
                if(self.tryRecoverConnectionCounter <= ADHOrganizerAutoRecoverConnectionMaxCount){
                    [self tryConnectToHost:self.workingHost port:self.workingPort];
                    self.shouldTryRecoverConnection = NO;
//                    NSLog(@"try recover connenction %zd",self.tryRecoverConnectionCounter);
                }else{
                    [self clearAutoConnectTry];
//                    NSLog(@"extend max try recover connenction times %zd",ADHOrganizerAutoRecoverConnectionMaxCount);
                }
            }
        }
    }
}

//停止尝试自动连接
- (void)clearAutoConnectTry {
    self.shouldTryRecoverConnection = NO;
    self.workingPort = 0;
    self.workingHost = nil;
}


- (NSBundle *)adhBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"lifebetter.WoodPeckeriOS"];
    if(!bundle) {
        NSString * bundlePath = [[[NSBundle mainBundle] privateFrameworksPath] stringByAppendingPathComponent:@"WoodPeckeriOS.framework"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return bundle;
}

- (UINib *)nibWithName: (NSString *)nibName {
    UINib *nib = [UINib nibWithNibName:nibName bundle:[self adhBundle]];
    return nib;
}

- (BOOL)isWorking {
    return [self.connector isSocketConnected];
}

@end








