//
//  NetworkDetailViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/14.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NetworkDetailViewController.h"
#import "NetworkItemViewController.h"
#import "NetworkPreviewViewController.h"
#import "JsonTextViewController.h"
#import "PlainTextViewController.h"
#import "FileTypeUtil.h"

static NSString * const kTabOverview             = @"overview";
static NSString * const kTabRequest              = @"request";
static NSString * const kTabResponse             = @"response";

//Overview
static NSString * const kItemOverviewDefault     = @"default";
//request
static NSString * const kItemRequestHeader       = @"header";
static NSString * const kItemRequestQuery        = @"query";
static NSString * const kItemRequestForm         = @"form";
static NSString * const kItemRequestJson         = @"json";
static NSString * const kItemRequestPlainText    = @"plaintext";
static NSString * const kItemRequestCookie       = @"cookie";
//response
static NSString * const kItemResponseHeader      = @"header";
static NSString * const kItemResponseCookie      = @"cookie";
static NSString * const kItemResponseJsonText    = @"jsontext";
static NSString * const kItemResponseJsonView    = @"jsonview";
static NSString * const kItemResponseBody        = @"body";


@interface NetworkDetailViewController ()<NSTabViewDelegate>

@property (weak) IBOutlet NSTabView *tabView;

@property (weak) IBOutlet NSView *overviewView;
@property (weak) IBOutlet NSView *requestView;
@property (weak) IBOutlet NSView *responseView;

@property (weak) NSTabView *requestTabView;
@property (weak) NSTabView *responseTabView;

@property (nonatomic, strong) ADHNetworkTransaction * mTransaction;
@property (nonatomic, strong) NetworkItemViewController * overviewVC;

@property (nonatomic, strong) NSString * lastTabId;
@property (nonatomic, strong) NSString * lastRequestTabId;
@property (nonatomic, strong) NSString * lastResponseTabId;

@end

@implementation NetworkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
}

- (void)setupAfterXib {
    NetworkItemViewController * overviewVC = [[NetworkItemViewController alloc] init];
    overviewVC.context = self.context;
    NSView * view = overviewVC.view;
    view.frame = self.overviewView.bounds;
    view.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    [self.overviewView addSubview:view];
    self.overviewVC = overviewVC;
}

- (void)setTransaction: (ADHNetworkTransaction *)transaction {
    self.mTransaction = transaction;
    [self updateContent];
}

- (void)clearContent {
    self.mTransaction = nil;
    [self updateContent];
}

- (void)updateContent {
    if(self.mTransaction){
        [self updateOverView];
        [self updateRequest];
        [self updateResponse];
        //恢复用户上次选择位置
        [self recoverTabViewLastUI:self.requestTabView lastId:self.lastRequestTabId defaultId:kItemRequestHeader];
        [self recoverTabViewLastUI:self.responseTabView lastId:self.lastResponseTabId defaultId:kItemResponseHeader];
        [self recoverTabViewLastUI:self.tabView lastId:self.lastTabId defaultId:kTabOverview];
//        NSLog(@"recover tab: %@ request: %@ response: %@",self.lastTabId,self.lastRequestTabId,self.lastResponseTabId);
        self.view.hidden = NO;
    }else{
        [self resetRequestTab];
        [self resetResponseTab];
        self.view.hidden = YES;
    }
}

- (void)recoverTabViewLastUI: (NSTabView *)tabView lastId: (NSString *)lastId defaultId: (NSString *)defaultId  {
    NSInteger tabIndex = [tabView indexOfTabViewItemWithIdentifier:lastId];
    if(tabIndex == NSNotFound) {
        tabIndex = [tabView indexOfTabViewItemWithIdentifier:defaultId];
    }
    [tabView selectTabViewItemAtIndex:tabIndex];
}

- (void)updateOverView {
    [self.overviewVC setTransaction:self.mTransaction viewType:NetworkViewTypeRequestOverview];
}

- (void)resetRequestTab {
    [self.requestTabView removeFromSuperview];
    NSTabView *tabView = [[NSTabView alloc] initWithFrame:self.requestView.bounds];
    tabView.tabPosition = NSTabPositionBottom;
    tabView.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    self.requestTabView = tabView;
    [self.requestView addSubview:self.requestTabView];
}

- (void)updateRequest {
    [self resetRequestTab];
    //Header
    NSTabViewItem * headerItem = [[NSTabViewItem alloc] init];
    headerItem.label = @"Header";
    headerItem.identifier = kItemRequestHeader;
    NetworkItemViewController * headerVC = [[NetworkItemViewController alloc] init];
    headerVC.context = self.context;
    [headerVC setTransaction:self.mTransaction viewType:NetworkViewTypeRequestHeader];
    headerItem.viewController = headerVC;
    [self.requestTabView addTabViewItem:headerItem];
    //Query
    if([self.mTransaction hasQuery]){
        NSTabViewItem * item = [[NSTabViewItem alloc] init];
        item.label = @"Query String";
        item.identifier = kItemRequestQuery;
        NetworkItemViewController * vc = [[NetworkItemViewController alloc] init];
        vc.context = self.context;
        [vc setTransaction:self.mTransaction viewType:NetworkViewTypeRequestQuery];
        item.viewController = vc;
        [self.requestTabView addTabViewItem:item];
    }
    //Form
    if([self.mTransaction hasUrlEncodedForm]){
        NSTabViewItem * formItem = [[NSTabViewItem alloc] init];
        formItem.label = @"Form";
        formItem.identifier = kItemRequestForm;
        NetworkItemViewController * formVC = [[NetworkItemViewController alloc] init];
        formVC.context = self.context;
        [formVC setTransaction:self.mTransaction viewType:NetworkViewTypeRequestEncodedForm];
        formItem.viewController = formVC;
        [self.requestTabView addTabViewItem:formItem];
    }
    NSString * requestContentType = [self.mTransaction requestContentType];
    //json params
    if([FileTypeUtil isJsonFileByMimeType:requestContentType]) {
        //json viewer
        NSTabViewItem * jsonItem = [[NSTabViewItem alloc] init];
        jsonItem.label = @"JSON View";
        jsonItem.identifier = kItemRequestJson;
        JsonTextViewController * jsonVC = [[JsonTextViewController alloc] init];
        jsonVC.context = self.context;
        jsonVC.transaction = self.mTransaction;
        jsonVC.bRequestBody = YES;
        jsonItem.viewController = jsonVC;
        [self.requestTabView addTabViewItem:jsonItem];
    }
    //plain text request body
    if([FileTypeUtil isPlainFileByMimeType:requestContentType]) {
        NSTabViewItem * plainItem = [[NSTabViewItem alloc] init];
        plainItem.label = @"Plain Text";
        plainItem.identifier = kItemRequestPlainText;
        PlainTextViewController * plainVC = [[PlainTextViewController alloc] init];
        plainVC.context = self.context;
        plainVC.transaction = self.mTransaction;
        plainVC.bRequestBody = YES;
        plainItem.viewController = plainVC;
        [self.requestTabView addTabViewItem:plainItem];
    }
    //Cookie
    if([self.mTransaction requestHasCookie]){
        NSTabViewItem * item = [[NSTabViewItem alloc] init];
        item.label = @"Cookies";
        item.identifier = kItemRequestCookie;
        NetworkItemViewController * vc = [[NetworkItemViewController alloc] init];
        vc.context = self.context;
        [vc setTransaction:self.mTransaction viewType:NetworkViewTypeRequestCookie];
        item.viewController = vc;
        [self.requestTabView addTabViewItem:item];
    }
    /*
     * the first addTabViewItem: will trigger didSelectTabViewItem method
     * so we delay set delegate after adding items
     */
    self.requestTabView.delegate = self;
}

- (void)resetResponseTab {
    [self.responseTabView removeFromSuperview];
    NSTabView *tabView = [[NSTabView alloc] initWithFrame:self.responseView.bounds];
    tabView.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    tabView.tabPosition = NSTabPositionBottom;
    self.responseTabView = tabView;
    [self.responseView addSubview:self.responseTabView];
}

- (void)updateResponse {
    [self resetResponseTab];
    //Header
    NSTabViewItem * headerItem = [[NSTabViewItem alloc] init];
    headerItem.label = @"Header";
    headerItem.identifier = kItemResponseHeader;
    NetworkItemViewController * headerVC = [[NetworkItemViewController alloc] init];
    headerVC.context = self.context;
    [headerVC setTransaction:self.mTransaction viewType:NetworkViewTypeResponseHeader];
    headerItem.viewController = headerVC;
    [self.responseTabView addTabViewItem:headerItem];
    //Cookie
    if([self.mTransaction responseHasCookie]){
        NSTabViewItem * item = [[NSTabViewItem alloc] init];
        item.label = @"Set Cookie";
        item.identifier = kItemResponseCookie;
        NetworkItemViewController * vc = [[NetworkItemViewController alloc] init];
        vc.context = self.context;
        [vc setTransaction:self.mTransaction viewType:NetworkViewTypeResponseCookie];
        item.viewController = vc;
        [self.responseTabView addTabViewItem:item];
    }
    //Json
    if([self.mTransaction isJsonResponse]){
        //json text
        NSTabViewItem * bodyItem = [[NSTabViewItem alloc] init];
        bodyItem.label = @"JSON Text";
        bodyItem.identifier = kItemResponseJsonText;
        NetworkPreviewViewController * previewVC = [[NetworkPreviewViewController alloc] init];
        [previewVC setTransaction:self.mTransaction];
        previewVC.formatBeautify = YES;
        previewVC.context = self.context;
        bodyItem.viewController = previewVC;
        [self.responseTabView addTabViewItem:bodyItem];
        //json viewer
        NSTabViewItem * jsonItem = [[NSTabViewItem alloc] init];
        jsonItem.label = @"JSON View";
        jsonItem.identifier = kItemResponseJsonView;
        JsonTextViewController * jsonVC = [[JsonTextViewController alloc] init];
        jsonVC.context = self.context;
        [jsonVC setTransaction:self.mTransaction];
        jsonItem.viewController = jsonVC;
        [self.responseTabView addTabViewItem:jsonItem];
    }
    //Body
    NSTabViewItem * bodyItem = [[NSTabViewItem alloc] init];
    bodyItem.label = @"Body";
    bodyItem.identifier = kItemResponseBody;
    NetworkPreviewViewController * previewVC = [[NetworkPreviewViewController alloc] init];
    previewVC.context = self.context;
    [previewVC setTransaction:self.mTransaction];
    bodyItem.viewController = previewVC;
    [self.responseTabView addTabViewItem:bodyItem];
    self.responseTabView.delegate = self;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem {
    if(tabView == self.tabView) {
        //first level tab
        NSString *tabId = tabViewItem.identifier;
        self.lastTabId = tabId;
    }else if(tabView == self.requestTabView) {
        //request tab
        NSString *itemId = tabViewItem.identifier;
        self.lastRequestTabId = itemId;
    }else if(tabView == self.responseTabView) {
        //response tab
        NSString *itemId = tabViewItem.identifier;
        self.lastResponseTabId = itemId;
    }
}


@end










