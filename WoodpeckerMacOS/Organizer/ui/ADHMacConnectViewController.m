//
//  ADHMacConnectViewController.m
//  WoodpeckerMacOS
//
//  Created by 张小刚 on 2019/5/25.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHMacConnectViewController.h"
#import "ADHRemoteService.h"
#import "ADHRemoteServiceItem.h"
#import "ADHMacRemoteServiceCell.h"
#import "ADHAppConnector.h"

@interface ADHMacConnectViewController ()<ADHMacRemoteServiceCellDegate>

@property (weak) IBOutlet NSScrollView *tableConainerView;

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *notAvailableLabel;

@property (nonatomic, weak) ADHAppConnector * connector;
@property (nonatomic, strong) NSArray<ADHRemoteServiceItem *> *serviceList;
@property (nonatomic, assign) BOOL bSearching;

@end

@implementation ADHMacConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    self.connector = [ADHMacClientOrganizer sharedOrganizer].connector;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusUpdate) name:kADHConnectorConnectStatusUpdate object:self.connector];
    [self initValue];
}

- (void)setupAfterXib {
    NSBundle *bundle = [[ADHMacClientOrganizer sharedOrganizer] adhBundle];
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"ADHMacRemoteServiceCell" bundle:bundle];
    [self.tableView registerNib:nib forIdentifier:@"ADHMacRemoteServiceCell"];
}

- (void)initValue {
    [self loadServiceList];
}

- (void)viewDidLayout {
    [super viewDidLayout];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self searchRemoteService];
}

- (IBAction)searchButtonClicked:(id)sender {
    if(!self.bSearching) {
        [self searchRemoteService];
    }else {
        [self searchRemoteService];
    }
}

- (IBAction)helpButtonClicked:(id)sender {
    NSString *url = @"http://www.woodpeck.cn/connection.html";
    NSLocale * locale = [NSLocale currentLocale];
    NSString *code = [locale objectForKey:NSLocaleLanguageCode];
    if([[code lowercaseString] isEqualToString:@"zh"]) {
        url = @"http://www.woodpeck.cn/cnconnection.html";
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (void)loadServiceList {
    NSArray<ADHRemoteService *>* searchedServices = [self.connector serviceList];
    NSMutableArray * serviceList = [NSMutableArray array];
    for (ADHRemoteService * service in searchedServices) {
        ADHRemoteServiceItem * item = [[ADHRemoteServiceItem alloc] init];
        item.name = service.name;
        item.host = service.host;
        item.port = service.port;
        [serviceList addObject:item];
    }
    self.serviceList = serviceList;
    [self updateServiceConnectStatus];
    [self updateUI];
}

- (void)updateUI {
    [self.tableView reloadData];
    if(self.serviceList.count > 0) {
        self.tableConainerView.hidden = NO;
        self.notAvailableLabel.hidden = YES;
    }else {
        self.tableConainerView.hidden = YES;
        self.notAvailableLabel.hidden = NO;
    }
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
    if(searching) {
        self.view.window.title = @"Searching...";
    }else {
        self.view.window.title = @"Woodpecker";
    }
    self.bSearching = searching;
}

- (void)resetContent {
    [self loadServiceList];
    [self.tableView reloadData];
}

#pragma mark -----------------   connect   ----------------

- (void)connectToService: (ADHRemoteServiceItem *)serviceItem {
    [[ADHMacClientOrganizer sharedOrganizer] clearAutoConnectTry];
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
- (void)disconnectService {
    [self.connector closeConnection];
    [self updateServiceConnectStatus];
    [self.tableView reloadData];
}

- (void)updateServiceConnectStatus {
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
    if([[ADHMacClientOrganizer sharedOrganizer] isUIShowing]) {
        //showing ui
        if([[ADHMacClientOrganizer sharedOrganizer] isWorking]) {
            [self updateServiceConnectStatus];
            [self updateUI];
        }else {
            [self searchRemoteService];
        }
    }
}

#pragma mark -----------------   table view delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = 0;
    count = self.serviceList.count;
    return count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat height = 60.0f;
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    ADHMacRemoteServiceCell *cell = [tableView makeViewWithIdentifier:@"ADHMacRemoteServiceCell" owner:nil];
    ADHRemoteServiceItem *item = self.serviceList[row];
    [cell setData:item];
    cell.delegate = self;
    return cell;
}

#pragma mark -----------------   cell delegate   ----------------

- (void)adhMacRemoteServiceCellActionRequest: (ADHMacRemoteServiceCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    if(row < 0 || row >= self.serviceList.count) {
        return;
    }
    ADHRemoteServiceItem * serviceItem = self.serviceList[row];
    if(serviceItem.connectStatus == ADHRemoteServiceStatusUnConnect){
        //连接
        [self connectToService:serviceItem];
    }else if(serviceItem.connectStatus == ADHRemoteServiceStatusConnected){
        //断开
        [self disconnectService];
    }
}

@end
