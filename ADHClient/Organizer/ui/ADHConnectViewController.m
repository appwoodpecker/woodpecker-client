//
//  ADHConnectViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHConnectViewController.h"
#import "ADHOrganizer.h"
#import "ADHRemoteServiceCell.h"
#import "ADHRemoteServiceItem.h"
#import "ADHPreferenceService.h"
#import "ADHAppConnector.h"
#import "ADHOrganizerPrivate.h"

@interface ADHConnectViewController ()<UITableViewDelegate,UITableViewDataSource,ADHRemoteServiceCellDegate>

@property (weak, nonatomic) IBOutlet UIView *layoutView;

@property (weak, nonatomic) IBOutlet UIView *popView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *disappearButton;
@property (weak, nonatomic) IBOutlet UILabel *notAvailableLabel;

@property (nonatomic, weak) ADHAppConnector * connector;
@property (nonatomic, strong) NSArray<ADHRemoteServiceItem *> *serviceList;

@end

@implementation ADHConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    self.connector = [ADHOrganizer sharedOrganizer].connector;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusUpdate) name:kADHConnectorConnectStatusUpdate object:self.connector];
    [self loadServiceList];
    [self searchRemoteService];
}

//关闭darkmode
- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    return UIUserInterfaceStyleLight;
}

- (void)setupAfterXib {
    self.view.backgroundColor = [self colorWithHex:0x202123];
    self.navigationItem.title = @"Woodpecker";
    UINavigationBar * navigationBar = self.navigationController.navigationBar;
    [navigationBar setTitleTextAttributes:@{
                                            NSForegroundColorAttributeName : [self themeColor],
                                            NSFontAttributeName : [UIFont systemFontOfSize:18.0f],
                                            }];
    [navigationBar setBarTintColor:[self colorWithHex:0x16181A]];
    [navigationBar setTintColor:[self themeColor]];
    [navigationBar setTranslucent:NO];
    self.tableView.backgroundColor = [UIColor clearColor];
    UINib * cellNib = [[ADHOrganizer sharedOrganizer] nibWithName:NSStringFromClass([ADHRemoteServiceCell class])];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NSStringFromClass([ADHRemoteServiceCell class])];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentDidAppear) name:kADHOrganizerWindowDidVisible object:nil];
    UIBarButtonItem * closeItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(doClose)];
    self.navigationItem.leftBarButtonItem = closeItem;
    self.layoutView.backgroundColor = [UIColor clearColor];
    UIView *popView = self.popView;
    popView.backgroundColor = [self colorWithHex:0x323232];
    popView.layer.shadowColor = [UIColor blackColor].CGColor;
    popView.layer.shadowOpacity = 0.2;
    popView.layer.shadowOffset = CGSizeMake(1, 1);
    popView.layer.cornerRadius = 3.0f;
    //search button
    self.searchButton.backgroundColor = [self colorWithHex:0x323232];
    self.searchButton.layer.cornerRadius = 4.0f;
    self.searchButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchButton.layer.shadowOpacity = 0.2;
    self.searchButton.layer.shadowOffset = CGSizeMake(1, 1);
    [self.searchButton setTitleColor:[self themeColor] forState:UIControlStateNormal];
    [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
    [self.searchButton setTitle:@"Stop Search" forState:UIControlStateSelected];
    [self.helpButton setTitleColor:[self colorWithHex:0xAAAAAA] forState:UIControlStateNormal];
    [self.disappearButton setTitleColor:[UIColor colorWithRed:0x4A/255.0f green:0x4A/255.0f blue:0x4A/255.0f alpha:0.5] forState:UIControlStateNormal];
}

- (UIColor *)themeColor {
    return [UIColor colorWithRed:0x25/255.0f green:0xA2/255.0 blue:0x61/255.0f alpha:1];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat contentHeight = self.searchButton.frame.origin.y;
    CGFloat labelTop = (contentHeight - self.notAvailableLabel.frame.size.height)/2.0f;
    CGRect labelFrame = self.notAvailableLabel.frame;
    labelFrame.origin.y = labelTop;
    self.notAvailableLabel.frame = labelFrame;
}

- (void)loadServiceList {
    NSArray<ADHRemoteService *>* searchedServices = [self.connector serviceList];
    NSMutableArray * serviceList = [NSMutableArray array];
    for (ADHRemoteService * service in searchedServices) {
        ADHRemoteServiceItem * item = [[ADHRemoteServiceItem alloc] init];
        item.name = service.name;
        item.host = service.host;
        item.port = service.port;
        item.ruleData = service.ruleData;
        item.simulator = service.simulator;
        item.usb = service.usb;
        [serviceList addObject:item];
    }
    self.serviceList = serviceList;
    [self updateServiceConnectStatus];
    [self updateUI];
}

- (void)updateUI {
    [self.tableView reloadData];
    if(self.serviceList.count > 0) {
        self.popView.hidden = NO;
        self.layoutView.hidden = NO;
        self.notAvailableLabel.hidden = YES;
    }else {
        self.popView.hidden = YES;
        self.layoutView.hidden = YES;
        self.notAvailableLabel.hidden = NO;
    }
}

- (void)contentDidAppear {
    [self searchRemoteService];
}

- (void)searchRemoteService {
    __weak typeof(self) wself = self;
    [self.connector startSearchServiceWithUpdateBlock:^(NSArray<ADHRemoteService *> *serviceList, BOOL moreComing) {
        [wself loadServiceList];
        if(!moreComing) {
            [wself updateSearchStatus:NO];
        }
    } error:^(NSError *error) {
        [wself updateSearchStatus:NO];
    }];
    [self resetContent];
    [self updateSearchStatus:YES];
}

- (void)updateSearchStatus: (BOOL)searching {
    self.searchButton.selected = searching;
}

- (void)resetContent {
    [self loadServiceList];
    [self.tableView reloadData];
}

- (IBAction)searchButtonPressed:(id)sender {
    if(!self.searchButton.selected) {
        [self searchRemoteService];
    }else {
        [self.connector stopSearchService];
        [self updateSearchStatus:NO];
    }
}

#pragma mark -----------------   connect   ----------------

- (void)connectToService: (ADHRemoteServiceItem *)serviceItem
{
    [[ADHOrganizer sharedOrganizer] clearAutoConnectTry];
    __weak typeof(self) wself = self;
    [self.connector connectToRemoteHost:serviceItem.host port:serviceItem.port successBlock:^(ADHGCDAsyncSocket *socket) {
        //connected
    } errorBlock:^(NSError *error) {
        //connect failed
        [wself searchRemoteService];
    }];
}

/**
 点击列表disconnect
 */
- (void)disconnectService
{
    [self.connector closeConnection];
    [self updateServiceConnectStatus];
}

- (void)updateServiceConnectStatus
{
    ADHGCDAsyncSocket * socket = [self.connector socket];
    NSString * remoteHost = [socket connectedHost];
    uint16_t remotePort = [socket connectedPort];
    for (ADHRemoteServiceItem * item in self.serviceList) {
        if([item.host isEqualToString:remoteHost] && item.port == remotePort){
            if([self.connector isConnecting]){
                item.connectStatus = ADHRemoteServiceStatusConnecting;
            }else if([self.connector isConnected]){
                item.connectStatus = ADHRemoteServiceStatusConnected;
            }else{
                item.connectStatus = ADHRemoteServiceStatusUnConnect;
            }
        }else{
            item.connectStatus = ADHRemoteServiceStatusUnConnect;
        }
    }
}

- (void)onConnectionStatusUpdate {
    if([[ADHOrganizer sharedOrganizer] isUIShowing]) {
        //showing ui
        if([[ADHOrganizer sharedOrganizer] isWorking]) {
            [self updateServiceConnectStatus];
            [self updateUI];
        }else {
            [self searchRemoteService];
        }
    }
}

#pragma mark -----------------   table view delegate   ----------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    count = self.serviceList.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADHRemoteServiceItem *serviceItem = self.serviceList[indexPath.row];
    return [ADHRemoteServiceCell heightForData:serviceItem];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADHRemoteServiceCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ADHRemoteServiceCell class])];
    ADHRemoteServiceItem *serviceItem = self.serviceList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setData:serviceItem];
    cell.delegate = self;
    return cell;
}

#pragma mark -----------------   cell action   ----------------

- (void)adhRemoteServiceCellActionRequest: (ADHRemoteServiceCell *)cell {
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    ADHRemoteServiceItem * serviceItem = self.serviceList[indexPath.row];
    if(serviceItem.connectStatus == ADHRemoteServiceStatusUnConnect){
        //连接
        [self connectToService:serviceItem];
    }else if(serviceItem.connectStatus == ADHRemoteServiceStatusConnected){
        //断开
        [self disconnectService];
    }
}

- (void)doClose {
    self.view.window.hidden = YES;
}

- (IBAction)disappearButtonPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kADHShowOnConnectionFailed];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *message = @"\nThis page will not show automatically during this installment.\n\n👉 Long press your screen with two fingers will show this page again.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Bye!" message:message preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"I got it" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [wself doClose];
    }];
    [alert addAction:confirm];
    [self presentViewController:alert animated:YES completion:nil];
    alert.view.tintColor = [self themeColor];
}


- (IBAction)helpButtonPressed:(id)sender {
    NSString *url = @"http://www.woodpeck.cn/connection.html";
    NSLocale * locale = [NSLocale currentLocale];
    NSString *code = [locale objectForKey:NSLocaleLanguageCode];
    if([[code lowercaseString] isEqualToString:@"zh"]) {
        url = @"http://www.woodpeck.cn/cnconnection.html";
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark -----------------   util   ----------------

- (UIColor *)colorWithHex: (NSInteger)value {
    return [self colorWithHex:value alpha:1.0f];
}

- (UIColor *)colorWithHex: (NSInteger)value alpha: (float)alpha{
    NSInteger red = (0xFF0000 & value) >> 16;
    NSInteger green = (0x00FF00 & value) >> 8;
    NSInteger blue = 0x0000FF & value;
    UIColor *color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
    return color;
}


@end


