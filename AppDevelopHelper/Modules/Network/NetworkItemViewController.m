//
//  NetworkItemViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/14.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NetworkItemViewController.h"
#import "ADHNetworkTransaction.h"
#import "NetworkItemCell.h"

static NSString * const kColumnKeyIdentifier = @"key";
static NSString * const kColumnValueIdentifier = @"value";

@interface NetworkItemViewController ()<NSTableViewDelegate, NSTableViewDataSource,ADHBaseCellDelegate>
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) ADHNetworkTransaction * mTransaction;
@property (nonatomic, assign) NetworkViewType viewType;

@property (nonatomic, strong) NSArray * keyList;
@property (nonatomic, strong) NSArray * valueList;

@end

@implementation NetworkItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
}

- (void)setupAfterXib {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([NetworkItemCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([NetworkItemCell class])];
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.rowHeight = [NetworkItemCell rowHeight];
    [self setupColumns];
}

- (void)addNotification {
    
}

- (void)setupColumns {
    NSArray *columns = [self.tableView.tableColumns mutableCopy];
    for (NSTableColumn * column in columns) {
        [self.tableView removeTableColumn:column];
    }
    //key
    NSTableColumn * keyColumn = [[NSTableColumn alloc] init];
    keyColumn.identifier = kColumnKeyIdentifier;
    keyColumn.title = @"Name";
    keyColumn.width = 180.0f;
    keyColumn.headerCell.alignment = NSTextAlignmentRight;
    [self.tableView addTableColumn:keyColumn];
    //value
    NSTableColumn * valueColumn = [[NSTableColumn alloc] init];
    valueColumn.title = @"Value";
    valueColumn.identifier = kColumnValueIdentifier;
    valueColumn.width = self.tableView.bounds.size.width - keyColumn.width;
    [self.tableView addTableColumn:valueColumn];
}

- (void)setTransaction: (ADHNetworkTransaction *)transaction viewType: (NetworkViewType)viewType
{
    self.mTransaction = transaction;
    self.viewType = viewType;
    [self cookTransaction];
    [self.tableView reloadData];
}

- (void)cookTransaction
{
    if(self.viewType == NetworkViewTypeRequestOverview){
        [self cookRequestOverview];
    }else if(self.viewType == NetworkViewTypeRequestHeader){
        [self cookRequestHeader];
    }else if(self.viewType == NetworkViewTypeRequestQuery){
        [self cookRequestQuery];
    }else if(self.viewType == NetworkViewTypeRequestEncodedForm){
        [self cookRequestEncodedForm];
    }else if(self.viewType == NetworkViewTypeRequestCookie){
        [self cookRequestCookie];
    }else if(self.viewType == NetworkViewTypeResponseHeader){
        [self cookResposneHeader];
    }else if(self.viewType == NetworkViewTypeResponseCookie){
        [self cookResponseCookie];
    }
    
}

- (void)cookRequestOverview
{
    ADHNetworkTransaction * trans = self.mTransaction;
    NSURLRequest * request = trans.request;
    NSHTTPURLResponse * response = trans.response;
    //URL,status,Response Code,,Method,StartTime,EndTime,Duration,Size
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    NSString * url = @"-";
    NSString * status = @"-";
    NSString * responseCode = @"-";
    NSString * protocol = @"-";
    NSString * method = @"-";
    NSString * contentType = @"-";
    NSString * startTime = @"-";
    NSString * endTime = @"-";
    NSString * duration = @"-";
    NSString * requestBodySize = @"-";
    NSString * responseBodySize = @"-";
    if(request){
        url = adhvf_safestringfy(request.URL.absoluteString);
        protocol = adhvf_safestringfy(request.URL.scheme);
        method = adhvf_safestringfy(request.HTTPMethod);
    }
    status = [ADHNetworkTransaction readableStringFromTransactionState:trans.transactionState];
    if(response){
        NSInteger statusCode = response.statusCode;
        NSString * readableStatusCode = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
        responseCode = [NSString stringWithFormat:@"%zd %@",statusCode,readableStatusCode];
        contentType = adhvf_safestringfy([trans responseContentType]);
    }
    if(trans.startTime){
        startTime = [ADHDateUtil formatStringWithDate:trans.startTime dateFormat:@"yy-MM-dd HH:mm:ss"];
    }
    if(trans.duration > 0){
        NSTimeInterval endTimeInterval = [trans.startTime timeIntervalSince1970] + trans.duration;
        endTime = [ADHDateUtil formatStringWithTimeInterval:endTimeInterval dateFormat:@"yy-MM-dd HH:mm:ss"];
        duration = [NSString stringWithFormat:@"%.2f",trans.duration];
    }
    requestBodySize = [NSString stringWithFormat:@"%lld Bytes (%@)",trans.sentDataLength,[trans readbleSentBodySize]];
    responseBodySize = [NSString stringWithFormat:@"%lld Bytes (%@)",trans.receivedDataLength,[trans readableReceivedBodySize]];
    data[@"URL"] = url;
    data[@"Status"] = status;
    data[@"Response Code"] = responseCode;
    data[@"Protocol"] = protocol;
    data[@"Method"] = method;
    data[@"Content-Type"] = contentType;
    data[@"Start Time"] = startTime;
    data[@"End Time"] = endTime;
    data[@"Duration"] = [trans readableDuration];
    data[@"Request Size"] = requestBodySize;
    data[@"Response Size"] = responseBodySize;
    
    NSArray * keys = @[
                       @"URL",
                       @"Status",
                       @"Response Code",
                       @"Protocol",
                       @"Method",
                       @"Content-Type",
                       @"Start Time",
                       @"End Time",
                       @"Duration",
                       @"Request Size",
                       @"Response Size",
                       ];
    NSMutableArray * keyList = [keys mutableCopy];
    NSMutableArray * valueList = [NSMutableArray arrayWithCapacity:keyList.count];
    for (NSString * key in keyList) {
        NSString * value = data[key];
        [valueList addObject:value];
    }
    self.valueList = valueList;
    self.keyList = keyList;
}

- (void)cookRequestHeader
{
    NSDictionary * fields = self.mTransaction.request.allHTTPHeaderFields;
    NSArray * keys = [fields allKeys];
    if(!keys){
        keys = @[];
    }
    NSMutableArray * keyList = [keys mutableCopy];
    NSMutableArray * valueList = [NSMutableArray arrayWithCapacity:keyList.count];
    for (NSString * key in keyList) {
        NSString * value = fields[key];
        [valueList addObject:value];
    }
    self.valueList = valueList;
    self.keyList = keyList;
}

- (void)cookRequestQuery
{
    NSURL * requestURL = self.mTransaction.request.URL;
    NSURLComponents * components = [NSURLComponents componentsWithURL:requestURL resolvingAgainstBaseURL:NO];
    NSArray * queryItems = [components queryItems];
    NSMutableArray * keyList = [NSMutableArray array];
    NSMutableArray * valueList = [NSMutableArray array];
    for (NSURLQueryItem * query in queryItems) {
        [keyList addObject:adhvf_safestringfy(query.name)];
        [valueList addObject:adhvf_safestringfy(query.value)];
    }
    self.valueList = valueList;
    self.keyList = keyList;
}

- (void)cookRequestEncodedForm
{
    NSData * data = self.mTransaction.requestBody;
    NSString * content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray * components = [content componentsSeparatedByString:@"&"];
    if(components.count == 0) return;
    NSMutableArray * keyList = [NSMutableArray array];
    NSMutableArray * valueList = [NSMutableArray array];
    for (NSString * query in components) {
        NSString * decodedQuery = [query stringByRemovingPercentEncoding];
        NSArray * kvComponents = [decodedQuery componentsSeparatedByString:@"="];
        if(kvComponents.count == 0){
            continue;
        }
        NSString * key = nil;
        NSString * value = nil;
        if(kvComponents.count > 0){
            key = adhvf_safestringfy(kvComponents[0]);
        }
        if(kvComponents.count > 1){
            value = adhvf_safestringfy(kvComponents[1]);
        }
        [keyList addObject:adhvf_safestringfy(key)];
        [valueList addObject:adhvf_safestringfy(value)];
    }
    self.keyList = keyList;
    self.valueList = valueList;
}

- (void)cookRequestCookie
{
    NSString * cookieValue = [self.mTransaction requestCookie];
    NSArray * cookieItems = [cookieValue componentsSeparatedByString:@"; "];
    if(cookieItems.count == 0) return;
    NSMutableArray * keyList = [NSMutableArray array];
    NSMutableArray * valueList = [NSMutableArray array];
    for (NSString * cookie in cookieItems) {
        NSArray * kvComponents = [cookie componentsSeparatedByString:@"="];
        if(kvComponents.count == 0){
            continue;
        }
        NSString * key = nil;
        NSString * value = nil;
        if(kvComponents.count > 0){
            key = adhvf_safestringfy(kvComponents[0]);
        }
        if(kvComponents.count > 1){
            value = adhvf_safestringfy(kvComponents[1]);
        }
        [keyList addObject:adhvf_safestringfy(key)];
        [valueList addObject:adhvf_safestringfy(value)];
    }
    self.keyList = keyList;
    self.valueList = valueList;
}

- (void)cookResposneHeader
{
    NSDictionary * fields = self.mTransaction.response.allHeaderFields;
    NSArray * keys = [fields allKeys];
    if(!keys){
        keys = @[];
    }
    NSMutableArray * keyList = [keys mutableCopy];
    NSMutableArray * valueList = [NSMutableArray arrayWithCapacity:keyList.count];
    for (NSString * key in keyList) {
        NSString * value = fields[key];
        [valueList addObject:value];
    }
    self.valueList = valueList;
    self.keyList = keyList;
}

- (void)cookResponseCookie
{
    NSString * cookieValue = [self.mTransaction responseCookie];
    NSArray * cookieItems = [cookieValue componentsSeparatedByString:@"; "];
    if(cookieItems.count == 0) return;
    NSMutableArray * keyList = [NSMutableArray array];
    NSMutableArray * valueList = [NSMutableArray array];
    for (NSString * cookie in cookieItems) {
        NSArray * kvComponents = [cookie componentsSeparatedByString:@"="];
        if(kvComponents.count == 0){
            continue;
        }
        NSString * key = nil;
        NSString * value = nil;
        if(kvComponents.count > 0){
            key = adhvf_safestringfy(kvComponents[0]);
        }
        if(kvComponents.count > 1){
            value = adhvf_safestringfy(kvComponents[1]);
        }
        [keyList addObject:adhvf_safestringfy(key)];
        [valueList addObject:adhvf_safestringfy(value)];
    }
    self.keyList = keyList;
    self.valueList = valueList;
}



#pragma mark -----------------   tableview   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.keyList.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NetworkItemCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([NetworkItemCell class]) owner:nil];
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    if([tableColumn.identifier isEqualToString:kColumnKeyIdentifier]){
        NSString * key = self.keyList[row];
        data[@"key"] = adhvf_safestringfy(key);
    }else{
        NSString * value = self.valueList[row];
        data[@"value"] = adhvf_safestringfy(value);
    }
    [cell setData:data];
    cell.delegate = self;
    return cell;
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point
{
    NSInteger row = [self.tableView rowForView:cell];
    if(row < 0) return;
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    
    //copy name
    NSMenuItem * keyItem = [[NSMenuItem alloc] initWithTitle:@"Copy Name" action:@selector(copyKeyMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    keyItem.target = self;
    keyItem.representedObject = [NSNumber numberWithInteger:row];
    [menu addItem:keyItem];
    
    //copy value
    NSMenuItem * valueItem = [[NSMenuItem alloc] initWithTitle:@"Copy Value" action:@selector(copyValueMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    valueItem.target = self;
    valueItem.representedObject = [NSNumber numberWithInteger:row];
    [menu addItem:valueItem];

    [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
}

- (void)copyValueMenuSelected: (NSMenuItem *)menu
{
    NSInteger row = [menu.representedObject integerValue];
    NSString * value = self.valueList[row];
    if(value.length > 0){
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:value forType:NSPasteboardTypeString];
    }
}

- (void)copyKeyMenuSelected: (NSMenuItem *)menu
{
    NSInteger row = [menu.representedObject integerValue];
    NSString * value = self.keyList[row];
    if(value.length > 0){
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:value forType:NSPasteboardTypeString];
    }
}

@end















