//
//  TestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2017/12/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "TestViewController.h"
#import "ADHOrganizer.h"
#import "ADHFileBrowserActionService.h"
#import "ADHAppDefaultActionService.h"
#import "ADHAppInfoActionService.h"
#import "ADHNetworkActionService.h"
#import "ADHWebDebugActionService.h"

#import "AppFileViewController.h"
#import "NetworkTestViewController.h"
#import "WebDebuggerTestViewController.h"
#import "LogTestViewController.h"
#import "NotificationTestViewController.h"
#import "UserDefaultsTestViewController.h"
#import "DeviceTestViewController.h"
#import "ControllerHierarchyTestViewController.h"
#import "ConsoleTestViewController.h"
#import "KeyChainTestViewController.h"
#import "BundleTestViewController.h"
#import "ViewDebugTestViewController.h"
#import "WebTestViewController.h"
#import "CloudTestViewController.h"
#import "UtilityTestViewController.h"

@interface TestViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * list;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Woodpecker";
    [self loadContent];
    [self registerService];
}

- (void)registerService
{
}

- (void)loadContent
{
    self.list = @[
                @{
                    @"title" : @"Utility",
                    @"action" : NSStringFromSelector(@selector(utility)),
                    },
                  @{
                      @"title" : @"iCloud",
                      @"action" : NSStringFromSelector(@selector(icloud)),
                      },
                  @{
                      @"title" : @"View Debug",
                      @"action" : NSStringFromSelector(@selector(viewDebug)),
                      },
                  @{
                      @"title" : @"Bundle",
                      @"action" : NSStringFromSelector(@selector(bundle)),
                      },
                  @{
                      @"title" : @"KeyChain",
                      @"action" : NSStringFromSelector(@selector(keychain)),
                      },
                  @{
                      @"title" : @"Console",
                      @"action" : NSStringFromSelector(@selector(console)),
                      },
                  @{
                      @"title" : @"Controller Hierarchy",
                      @"action" : NSStringFromSelector(@selector(controllerHierarchy)),
                      },
                  @{
                      @"title" : @"Device",
                      @"action" : NSStringFromSelector(@selector(device)),
                      },
                  @{
                      @"title" : @"UserDefaults",
                      @"action" : NSStringFromSelector(@selector(userDefaults)),
                      },
                  @{
                      @"title" : @"AppFile",
                      @"action" : NSStringFromSelector(@selector(appFile)),
                      },
                  @{
                      @"title" : @"Network",
                      @"action" : NSStringFromSelector(@selector(network)),
                      },
                  @{
                      @"title" : @"WebDebugger(WKWebview)",
                      @"action" : NSStringFromSelector(@selector(webDebugger)),
                      },
                  @{
                      @"title" : @"Logger",
                      @"action" : NSStringFromSelector(@selector(logger)),
                      },
                  @{
                      @"title" : @"showUI",
                      @"action" : NSStringFromSelector(@selector(showUI)),
                      },
                  @{
                      @"title" : @"Notification",
                      @"action" : NSStringFromSelector(@selector(notification)),
                      },                  
                  ];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * kReuseIdentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseIdentifier];
    }
    NSDictionary * data = self.list[indexPath.row];
    NSString * title = data[@"title"];
    cell.textLabel.text = title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * data = self.list[indexPath.row];
    NSString * action = data[@"action"];
    SEL selector = NSSelectorFromString(action);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector];
#pragma clang diagnostic pop
}

- (void)appFile
{
    AppFileViewController * vc = [[AppFileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)network
{
    NetworkTestViewController * vc = [[NetworkTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)webDebugger
{
    WebDebuggerTestViewController * vc = [[WebDebuggerTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)webDebugger_uiwebview
{
    WebDebuggerTestViewController * vc = [[WebDebuggerTestViewController alloc] init];
    vc.uiwebView = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)logger
{
    LogTestViewController * vc = [[LogTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showUI
{
    [[ADHOrganizer sharedOrganizer] showUI];
}

- (void)notification
{
    NotificationTestViewController * vc = [[NotificationTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userDefaults
{
    UserDefaultsTestViewController * vc = [[UserDefaultsTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)device
{
    DeviceTestViewController * vc = [[DeviceTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) controllerHierarchy {
    ControllerHierarchyTestViewController *vc = [[ControllerHierarchyTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)console {
    ConsoleTestViewController *vc = [[ConsoleTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)keychain {
    KeyChainTestViewController *vc = [[KeyChainTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)bundle {
    BundleTestViewController *vc = [[BundleTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDebug {
    ViewDebugTestViewController *vc = [[ViewDebugTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)webtest {
    WebTestViewController *vc = [[WebTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)icloud {
    CloudTestViewController *vc = [[CloudTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)utility {
    UtilityTestViewController *vc = [[UtilityTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end













