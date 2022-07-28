//
//  NetworkViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/3.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NetworkViewController.h"
#import "NetworkActionService.h"
#import "ADHNetworkTransaction.h"
#import "NetworkTransactionCell.h"
#import "NetworkDetailViewController.h"
#import "NetworkService.h"
#import "MacOrganizer.h"
#import "NetworkCookieViewController.h"
#import "DeviceUtil.h"

static CGFloat const kColumnFlexibleMinUnitWidth = 200.0f;
static NSInteger const kAlertTransactionCount = 500;

@interface NetworkViewController ()<ADHBaseCellDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSSearchField *filterTextfield;

@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *pauseButton;
@property (weak) IBOutlet NSButton *trashButton;
@property (weak) IBOutlet NSButton *cookieButton;

@property (weak) IBOutlet NSTextField *alertLabel;

@property (weak) IBOutlet NSView *detailView;
@property (nonatomic, strong) NetworkDetailViewController * detailVC;

@property (nonatomic, strong) NSArray * columnList;

//origin
@property (nonatomic, strong) NSMutableDictionary * transactionsForRequestIdentifiers;
@property (nonatomic, strong) NSMutableArray * transactionList;
//sorted
@property (nonatomic, strong) NSArray * sortedTransactionList;
//filtered
@property (nonatomic, strong) NSArray * filteredTransactionList;
//display
@property (nonatomic, strong) NSArray * displayTransactionList;

@property (nonatomic, strong) NSSortDescriptor * sortDescriptor;
@property (nonatomic, strong) NSString * keywords;

@property (nonatomic, assign) BOOL stateOn;
@property (nonatomic, assign) BOOL shouldTryStart;

@property (nonatomic, strong) ADHNetworkTransaction * focusedTransaction;

@property (nonatomic, strong) dispatch_queue_t queue;


@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
    [self setupAfterXib];
    [self initialUI];
    [self resetContext];
    [self addNotification];
}

- (void)initValues
{
    self.stateOn = NO;
    self.transactionList = [NSMutableArray array];
    self.transactionsForRequestIdentifiers = [NSMutableDictionary dictionary];
    self.columnList = @[
                        @{
                            @"name" : @"Response Code",
                            @"width" : @110,
                            },
                        @{
                            @"name" : @"Method",
                            @"width" : @80,
                            },
                        @{
                            @"name" : @"Protocol",
                            @"width" : @80,
                            },
                        @{
                            @"name" : @"Host",
                            @"flexible-width" : @1,
                            @"sort" : @1,
                            },
                        @{
                            @"name" : @"Path",
                            @"flexible-width" : @1.8,
                            @"sort" : @1,
                            },
                        @{
                            @"name" : @"Start",
                            @"width" : @100,
                            @"sort" : @1,
                            },
                        @{
                            @"name" : @"Duration",
                            @"width" : @100,
                            @"sort" : @1,
                            },
                        @{
                            @"name" : @"Size",
                            @"width" : @100,
                            @"sort" : @1,
                            },
                        @{
                            @"name" : @"Status",
                            @"width" : @160,
                            },
                        ];
    self.queue = dispatch_queue_create("studio.lifebetter.network", DISPATCH_QUEUE_SERIAL);
    self.shouldTryStart = YES;
}

- (void)setupAfterXib
{
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([NetworkTransactionCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([NetworkTransactionCell class])];
    self.tableView.rowHeight = [NetworkTransactionCell rowHeight];
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask;
    self.tableView.intercellSpacing = NSZeroSize;
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.columnAutoresizingStyle = NSTableViewNoColumnAutoresizing;
    [self setupSearchTextField];
    self.cookieButton.toolTip = @"Cookie";
    
    NetworkDetailViewController * detailVC = [[NetworkDetailViewController alloc] init];
    detailVC.context = self.context;
    NSView * contentView = detailVC.view;
    contentView.frame = self.detailView.bounds;
    contentView.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    [self.detailView addSubview:contentView];
    self.detailVC = detailVC;
    [self.detailVC clearContent];
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTransactionUpdate:) name:kNetworkTransactionUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTransactionSelectionChanged:) name:NSTableViewSelectionDidChangeNotification object:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doOnWorkAppStateUpdate) name:kAppContextAppStatusUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.startButton setTintColor:[Appearance actionImageColor]];
    [self.trashButton setTintColor:[Appearance actionImageColor]];
    [self.cookieButton setTintColor:[Appearance actionImageColor]];
    
    if([Appearance isDark]) {
        
    }else {
        
    }
}

- (void)setupSearchTextField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.filterTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.filterTextfield];
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    [self updateColumnSize];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    if(self.shouldTryStart) {
        [self doStartRecord];
    }
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    if(self.stateOn) {
        [self doStopRecord];
    }
}

- (void)initialUI
{
    [self setupColumns];
    [self updateStateUI];
}

- (void)updateStateUI
{
    self.startButton.hidden = self.stateOn;
    self.pauseButton.hidden = !self.startButton.hidden;
}

- (void)setupColumns
{
    NSArray *columns = [self.tableView.tableColumns mutableCopy];
    for (NSTableColumn * column in columns) {
        [self.tableView removeTableColumn:column];
    }
    for (NSDictionary * data in self.columnList) {
        
        NSString * name = data[@"name"];
        NSTableColumn * column = [[NSTableColumn alloc] init];
        column.identifier = name;
        NSString * title = name;
        column.title = title;
        column.minWidth = 60.0f;
        BOOL sorted = [data[@"sort"] boolValue];
        if(sorted){
            column.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:name ascending:YES];
        }
        [self.tableView addTableColumn:column];
    }
    [self updateColumnSize];
}

- (void)updateColumnSize
{
    CGFloat contentWidth = self.tableView.frame.size.width;
    CGFloat totalFixWidth = 0;
    float flexibleUnits = 0;
    for (NSDictionary * columnData in self.columnList) {
        if(columnData[@"width"]){
            CGFloat fixWidth = [columnData[@"width"] floatValue];
            totalFixWidth += fixWidth;
        }else if(columnData[@"flexible-width"]){
            float flexibleUnit = [columnData[@"flexible-width"] floatValue];
            flexibleUnits += flexibleUnit;
        }
    }
    CGFloat flexibleWidth = contentWidth - totalFixWidth;
    CGFloat unitWidth = (flexibleWidth /flexibleUnits);
    unitWidth = MAX(unitWidth, kColumnFlexibleMinUnitWidth);
    
    NSArray *columns = [self.tableView.tableColumns mutableCopy];
    for (NSInteger index=0;index<columns.count;index++) {
        NSTableColumn * column = columns[index];
        NSDictionary * columnData = self.columnList[index];
        if(columnData[@"width"]){
            column.width = [columnData[@"width"] floatValue];
        }else if(columnData[@"flexible-width"]){
            float units = [columnData[@"flexible-width"] floatValue];
            column.width = units * unitWidth;
        }
    }
}

- (void)resetContext
{
    [NetworkService clear];
}

#pragma mark -----------------   tableview datasource & delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.displayTransactionList.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NetworkTransactionCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([NetworkTransactionCell class]) owner:nil];
    ADHNetworkTransaction * transaction = self.displayTransactionList[row];
    NSInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];
    NSDictionary * columnData = self.columnList[columnIndex];
    NSString * key = columnData[@"name"];
    [cell setTransaction:transaction itemKey:key];
    cell.delegate = self;
    return cell;
}

#pragma mark -----------------   cell delegate   ----------------
/**
 section changed
 */
- (void)onTransactionSelectionChanged: (NSNotification *)noti
{
    NSInteger row = [self.tableView selectedRow];
    if(row <0) {
        [self.detailVC clearContent];
        self.focusedTransaction = nil;
    }
}

- (void)cellClicked:(ADHBaseCell *)cell
{
    NSInteger row = [self.tableView rowForView:cell];
    if(row <0) {
        [self.detailVC clearContent];
        self.focusedTransaction = nil;
    }else{
        ADHNetworkTransaction * transaction = self.displayTransactionList[row];
        if(self.focusedTransaction == transaction) return;
        [self.detailVC setTransaction:transaction];
        self.focusedTransaction = transaction;
    }
}

#pragma mark -----------------   Menu   ----------------
- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point
{
    NSInteger row = [self.tableView rowForView:cell];
    if(row < 0) return;
    ADHNetworkTransaction * trans = self.displayTransactionList[row];
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //copy url
    NSMenuItem * copyUrlMenu = [[NSMenuItem alloc] initWithTitle:@"Copy URL" action:@selector(copyUrlMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    copyUrlMenu.target = self;
    copyUrlMenu.representedObject = trans;
    [menu addItem:copyUrlMenu];
    //curl
    if([trans isCurlAvailable]) {
        NSMenuItem * curlMenu = [[NSMenuItem alloc] initWithTitle:@"Copy as Curl" action:@selector(curlMenuMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
        curlMenu.target = self;
        curlMenu.representedObject = trans;
        [menu addItem:curlMenu];
    }
    //clear
    NSMenuItem * clearMenu = [[NSMenuItem alloc] initWithTitle:@"Clear" action:@selector(clearMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    clearMenu.target = self;
    clearMenu.representedObject = trans;
    [menu addItem:clearMenu];
    //clear others
    NSMenuItem * clearOtherMenu = [[NSMenuItem alloc] initWithTitle:@"Clear Others" action:@selector(clearOthersMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    clearOtherMenu.target = self;
    clearOtherMenu.representedObject = trans;
    [menu addItem:clearOtherMenu];
    //show response body
    if([trans isResponseBodyReady]) {
        NSMenuItem * openMenu = [[NSMenuItem alloc] initWithTitle:@"Show Response in Finder" action:@selector(showResponseBodyInFinder:) keyEquivalent:adhvf_const_emptystr()];
        openMenu.target = self;
        openMenu.representedObject = trans;
        [menu addItem:openMenu];
    }
    [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
}

- (void)clearMenuSelected: (NSMenuItem *)menu {
    ADHNetworkTransaction * trans = menu.representedObject;
    dispatch_async(self.queue, ^{
        [self.transactionList removeObject:trans];
        [self cookList];
        [self updateDisplayList];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self updateTransactionCountUI];
        });
    });
}

- (void)clearOthersMenuSelected: (NSMenuItem *)menu {
    ADHNetworkTransaction * trans = menu.representedObject;
    dispatch_async(self.queue, ^{
        [self.transactionList removeAllObjects];
        [self.transactionList addObject:trans];
        [self cookList];
        [self updateDisplayList];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self updateTransactionCountUI];
        });
    });
}

- (void)copyUrlMenuSelected: (NSMenuItem *)menu {
    ADHNetworkTransaction * trans = menu.representedObject;
    NSString * url = trans.request.URL.absoluteString;
    if(url.length > 0){
        [DeviceUtil pasteText:url];
        [self showSuccessWithText:@"URL Copied"];
    }else {
        [self showErrorWithText:@"URL is empty"];
    }
}

- (void)showResponseBodyInFinder: (NSMenuItem *)menu {
    ADHNetworkTransaction * trans = menu.representedObject;
    BOOL responseBodyExists = [[NetworkService serviceWithContext:self.context] responseBodyExistsForTransaction:trans];
    if(!responseBodyExists) {
        [self.view showHud];
        [[NetworkService serviceWithContext:self.context] downloadResponseBody:trans onCompletion:^(NSString *path) {
            [UrlUtil openInFinder:path];
            [self.view hideHud];
        } onError:^(NSError * error) {
            [self.view hideHud];
        }];
    }else {
        NSString * path = [[NetworkService serviceWithContext:self.context] getTransactionResponseBodyPath:trans];
        [UrlUtil openInFinder:path];
    }
}

- (void)curlMenuMenuSelected: (NSMenuItem *)menu {
    ADHNetworkTransaction * trans = menu.representedObject;
    NSURLRequest *request = trans.request;
    //url
    __block NSMutableString *curlCommandString = [NSMutableString stringWithFormat:@"curl -v -X %@ ", request.HTTPMethod];
    [curlCommandString appendFormat:@"\'%@\' ", request.URL.absoluteString];
    //header(include cookie)
    [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *val, BOOL *stop) {
        [curlCommandString appendFormat:@"-H \'%@: %@\' ", key, val];
    }];
    //body
    if (request.HTTPBody) {
        [curlCommandString appendFormat:@"-d \'%@\'", [NSString stringWithCString:request.HTTPBody.bytes encoding:NSUTF8StringEncoding]];
    }
    if(curlCommandString.length > 0) {
        [DeviceUtil pasteText:curlCommandString];
        [self showSuccessWithText:@"Curl Copied"];
    }else {
        [self showErrorWithText:@"Curl is empty"];
    }
}

//排序
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    NSSortDescriptor * sortDescriptor = nil;
    if([aTableView sortDescriptors].count > 0){
        sortDescriptor = [[aTableView sortDescriptors] objectAtIndex:0];
    }
    self.sortDescriptor = sortDescriptor;
    dispatch_async(self.queue, ^{
        [self cookList];
        [self updateDisplayList];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark -----------------   transaction   ----------------

- (ADHNetworkTransaction *)transactionWithRequestId: (NSString *)requestId
{
    if(!requestId) return nil;
    ADHNetworkTransaction * transaction = self.transactionsForRequestIdentifiers[requestId];
    if(!transaction){
        transaction = [[ADHNetworkTransaction alloc] init];
        transaction.requestID = requestId;
        [self.transactionList addObject:transaction];
        self.transactionsForRequestIdentifiers[requestId] = transaction;
    }
    return transaction;
}

- (void)onTransactionUpdate: (NSNotification *)noti
{
    AppContext *context = noti.userInfo[@"context"];
    if(context != self.context) {
        return;
    }
    dispatch_async(self.queue, ^{
        NSArray * dataList = noti.userInfo[kNetworkTransactionUpdateUserInfoUpdateList];
        if(dataList.count == 0) return;
        NSMutableArray * transactionUpdates = [NSMutableArray arrayWithCapacity:dataList.count];
        for (NSDictionary * data in dataList) {
            ADHNetworkTransferRecord * record = [ADHNetworkTransferRecord recordWithData:data];
            ADHNetworkTransaction * transaction = nil;
            transaction = [self transactionWithRequestId:record.requestID];
            if(!transaction) continue;
            [transaction updateWithTransferRecord:record];
            [transactionUpdates addObject:transaction];
        }
        //cook for view
        [self cookList];
        [self updateDisplayList];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateTransactionsUI:transactionUpdates];
        });
    });
}

- (void)updateDisplayList
{
    NSMutableArray * displayList = [NSMutableArray array];
    NSArray * viewList = [self viewTransactionList];
    for (ADHNetworkTransaction * trans in viewList) {
        [displayList addObject:trans];
    }
    self.displayTransactionList = displayList;
}

- (void)updateTransactionsUI: (NSArray *)transactions
{
    BOOL needScrollToBottom = [self needScrollToBottom];
    [self.tableView reloadData];
    if(self.focusedTransaction){
        NSInteger focusRow = NSNotFound;
        for (NSInteger i=0; i<self.displayTransactionList.count; i++) {
            ADHNetworkTransaction * trans = self.displayTransactionList[i];
            if(trans == self.focusedTransaction){
                focusRow = i;
                break;
            }
        }
        if(focusRow != NSNotFound){
            NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:focusRow];
            [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
        }else{
            self.focusedTransaction = nil;
        }
    }
    [self updateTransactionCountUI];
    if(needScrollToBottom) {
        [self scrollToBottom];
    }
}

- (void)updateTransactionCountUI
{
    NSInteger count = self.transactionList.count;
    if(count > kAlertTransactionCount){
        NSString * message = [NSString stringWithFormat:@"count %zd , too much records",self.transactionList.count];
        self.alertLabel.stringValue = message;
        self.alertLabel.textColor = [Appearance colorWithRed:255 green:38 blue:0 alpha:0.6];
    }else if(count > 0){
        NSString * message = [NSString stringWithFormat:@"%zd records",self.transactionList.count];
        self.alertLabel.stringValue = message;
        self.alertLabel.textColor = [NSColor secondaryLabelColor];
    }else{
        self.alertLabel.stringValue = adhvf_const_emptystr();
    }
}

#pragma mark -----------------   other   ----------------

- (void)tryStartRecord
{
    if(self.context.isConnected){
        [self doStartRecord];
    }
}

- (void)doOnWorkAppStateUpdate
{
    if(!self.context.isConnected){
        self.stateOn = NO;
        [self updateStateUI];
    }
    if(self.shouldTryStart){
        [self tryStartRecord];
    }
}

- (void)doStartRecord {
    [self.startButton showHud];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.network" action:@"start" body:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        wself.stateOn = YES;
        [wself updateStateUI];
        [wself.startButton hideHud];
    } onFailed:^(NSError *error) {
        [wself.startButton hideHud];
    }];
}

- (void)doStopRecord {
    [self.pauseButton showHud];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.network" action:@"stop" body:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        wself.stateOn = NO;
        [wself updateStateUI];
        [wself.pauseButton hideHud];
    } onFailed:^(NSError *error) {
        [wself.pauseButton hideHud];
    }];
}

- (IBAction)startButtonPressed:(id)sender {
    self.shouldTryStart = YES;
    if(![self doCheckConnectionRoutine]) return;
    [self doStartRecord];
}

- (IBAction)endButtonPressed:(id)sender {
    self.shouldTryStart = NO;
    [self doStopRecord];
}

- (IBAction)clearButtonPressed:(id)sender {
    [self.transactionList removeAllObjects];
    [self.transactionsForRequestIdentifiers removeAllObjects];
    self.filteredTransactionList = nil;
    self.sortedTransactionList = nil;
    [self updateDisplayList];
    [self.tableView reloadData];
    [self.detailVC clearContent];
    self.focusedTransaction = nil;
    [self updateTransactionCountUI];
}

#pragma mark -----------------   cook   ----------------

- (void)cookList
{
    //排序
    [self sortTransactionList];
    //搜索
    if(self.isSearching){
        //if searching, filter list
        NSString * keywords = self.keywords;
        [self filterWithKeywords:keywords];
    }
}

#pragma mark -----------------   sort   ----------------
- (void)sortTransactionList
{
    NSArray * transactions = self.transactionList;
    NSSortDescriptor * descriptor = self.sortDescriptor;
    NSArray * sortedResult = transactions;
    NSString * sortKey = descriptor.key;
    BOOL ascending = descriptor.ascending;
    if([sortKey isEqualToString:@"Start"]){
        sortedResult = [transactions sortedArrayUsingComparator:^NSComparisonResult(ADHNetworkTransaction * trans1, ADHNetworkTransaction * trans2) {
            if(ascending){
                return [trans1.startTime compare:trans2.startTime];
            }else{
                return [trans2.startTime compare:trans1.startTime];
            }
            
        }];
    }else if([sortKey isEqualToString:@"Duration"]){
        sortedResult = [transactions sortedArrayUsingComparator:^NSComparisonResult(ADHNetworkTransaction * trans1, ADHNetworkTransaction * trans2) {
            if(ascending){
                if(trans1.duration < trans2.duration){
                    return NSOrderedAscending;
                }else if(trans1.duration > trans2.duration){
                    return NSOrderedDescending;
                }else{
                    return NSOrderedSame;
                }
            }else{
                if(trans2.duration < trans1.duration){
                    return NSOrderedAscending;
                }else if(trans2.duration > trans1.duration){
                    return NSOrderedDescending;
                }else{
                    return NSOrderedSame;
                }
            }
        }];
    }else if([sortKey isEqualToString:@"Size"]){
        sortedResult = [transactions sortedArrayUsingComparator:^NSComparisonResult(ADHNetworkTransaction * trans1, ADHNetworkTransaction * trans2) {
            if(ascending){
                if(trans1.receivedDataLength < trans2.receivedDataLength){
                    return NSOrderedAscending;
                }else if(trans1.receivedDataLength > trans2.receivedDataLength){
                    return NSOrderedDescending;
                }else{
                    return NSOrderedSame;
                }
            }else{
                if(trans2.receivedDataLength < trans1.receivedDataLength){
                    return NSOrderedAscending;
                }else if(trans2.receivedDataLength > trans1.receivedDataLength){
                    return NSOrderedDescending;
                }else{
                    return NSOrderedSame;
                }
            }
        }];
    }else if([sortKey isEqualToString:@"Host"]){
        sortedResult = [transactions sortedArrayUsingComparator:^NSComparisonResult(ADHNetworkTransaction * trans1, ADHNetworkTransaction * trans2) {
            if(ascending){
                return [trans1.request.URL.host compare:trans2.request.URL.host options:NSCaseInsensitiveSearch];
            }else{
                return [trans2.request.URL.host compare:trans1.request.URL.host options:NSCaseInsensitiveSearch];
            }
        }];
    }else if([sortKey isEqualToString:@"Path"]){
        sortedResult = [transactions sortedArrayUsingComparator:^NSComparisonResult(ADHNetworkTransaction * trans1, ADHNetworkTransaction * trans2) {
            if(ascending){
                return [trans1.requestPath compare:trans2.requestPath options:NSCaseInsensitiveSearch];
            }else{
                return [trans2.requestPath compare:trans1.requestPath options:NSCaseInsensitiveSearch];
            }
        }];
    }
    self.sortedTransactionList = sortedResult;
}

#pragma mark -----------------   search   ----------------

- (void)searchTextDidChange:(NSNotification *)notification
{
    NSString * keywords = self.filterTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)searchTextDidEndEditing:(NSNotification *)notification
{
    NSString * keywords = self.filterTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}

- (void)doSearchWithKeywords: (NSString *)keywords
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self filterWithKeywords:keywords];
        [self updateDisplayList];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)filterWithKeywords: (NSString *)keywords
{
    self.keywords = keywords;
    if(keywords.length == 0){
        self.filteredTransactionList = nil;
    }else{
        NSMutableArray * transactions = [NSMutableArray array];
        for (ADHNetworkTransaction * trans in self.sortedTransactionList) {
            NSString * url = trans.request.URL.absoluteString;
            if([url rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound){
                [transactions addObject:trans];
            }
        }
        self.filteredTransactionList = transactions;
    }
}

- (NSArray *)viewTransactionList
{
    NSArray * list = nil;
    if(!self.isSearching){
        list = self.sortedTransactionList;
    }else{
        list = self.filteredTransactionList;
    }
    return list;
}

- (BOOL)isSearching
{
    return (self.keywords.length > 0);
}

#pragma mark -----------------   postion   ----------------

- (BOOL)needScrollToBottom {
    //如果正在选中，不自动滚动
    if(self.focusedTransaction) return NO;
    BOOL scrollToBottom = NO;
    //更新位置
    NSScrollView * scrollView = self.tableView.enclosingScrollView;
    NSView * documentView = scrollView.documentView;
    CGFloat contentHeight = documentView.bounds.size.height;
    CGFloat scrolledHeight = scrollView.documentVisibleRect.origin.y;
    CGFloat frameHeight = scrollView.frame.size.height;
    CGFloat scrollableHeight = contentHeight - frameHeight;
    CGFloat leftScrollHeight = scrollableHeight - scrolledHeight;
    if(leftScrollHeight <= 20*3){
        scrollToBottom = YES;
    }
    return scrollToBottom;
}

- (void)scrollToBottom {
    [self.tableView scrollToEndOfDocument:nil];
}

- (IBAction)cookieButtonPressed:(id)sender {
    NetworkCookieViewController * cookieVC = [[NetworkCookieViewController alloc] init];
    cookieVC.context = self.context;
    [self presentViewControllerAsModalWindow:cookieVC];
    
}

@end

















