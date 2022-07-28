//
//  ApiViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/5/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ApiViewController.h"
#import "ApiActionItem.h"
#import "ApiItemCell.h"
#import "LogRecorder.h"

@interface ApiViewController ()<ApiItemCellDelegate>

@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSPopUpButton *servicePopButton;
@property (weak) IBOutlet NSPopUpButton *actionPopButton;
@property (weak) IBOutlet NSTextView *bodyTextView;
@property (weak) IBOutlet NSView *payloadFileLayout;
@property (weak) IBOutlet NSTextField *filenameLabel;
@property (weak) IBOutlet NSTableView *tableView;

@property (strong) IBOutlet NSView *footerView;
@property (strong) IBOutlet NSView *headerView;

@property (nonatomic, strong) NSArray * serviceList;
@property (nonatomic, strong) NSArray * actionList;
@property (nonatomic, strong) NSString * filePath;

@property (nonatomic, strong) NSMutableArray *itemList;

@end

@implementation ApiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self initValue];
    [self initUI];
    [self dataRequestForAction];
}

- (void)setupAfterXib {
    self.actionLayout.wantsLayer = YES;
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([ApiItemCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([ApiItemCell class])];
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    if([Appearance isDark]) {
        self.actionLayout.layer.backgroundColor = [Appearance backgroundColor].CGColor;
    }else {
        self.actionLayout.layer.backgroundColor = [Appearance colorWithRed:236 green:236 blue:236 alpha:1.0].CGColor;
    }
}

- (void)initValue {
    self.itemList = [NSMutableArray array];
}

- (void)initUI {
    [self updateFileUI];
    [self updateActionContentUI];
}

- (void)loadContent {
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself updateContentUI];
    });
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [self.tableView reloadData];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    self.view.window.title = @"Send Api";
}

#pragma mark -----------------   Action   ----------------

- (void)dataRequestForAction {
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.woodpecker" action:@"actionlist" onSuccess:^(NSDictionary *body, NSData *payload) {
        BOOL needUpdate = (wself.serviceList.count == 0);
        NSDictionary * actionData = body;
        wself.serviceList = actionData[@"service"];
        wself.actionList = actionData[@"action"];
        if(needUpdate){
            [wself updateActionContentUI];
        }
    } onFailed:^(NSError *error) {
        
    }];
}

- (void)updateActionContentUI {
    [self.servicePopButton removeAllItems];
    [self.actionPopButton removeAllItems];
    for (NSString * service in self.serviceList) {
        [self.servicePopButton addItemWithTitle:service];
    }
    if(self.serviceList.count > 0){
        NSString * firstService = self.serviceList[0];
        [self updateActionWithService:firstService];
    }
}

- (void)updateActionWithService: (NSString *)service {
    [self.actionPopButton removeAllItems];
    NSMutableArray * actionList = [NSMutableArray array];
    for (NSDictionary * data in self.actionList) {
        NSString * aService = data[@"service"];
        NSString * action = data[@"action"];
        if([aService isEqualToString:service]){
            [actionList addObject:action];
        }
    }
    for (NSString * action in actionList) {
        [self.actionPopButton addItemWithTitle:action];
    }
}


#pragma mark -----------------   Api   ----------------

- (IBAction)servicePopButtonSelected:(id)sender {
    NSInteger index = [self.servicePopButton indexOfSelectedItem];
    NSString * service = self.serviceList[index];
    [self updateActionWithService:service];
}

- (IBAction)payloadButtonPressed:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = NO;
    NSURL * directoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
    panel.directoryURL = directoryURL;
    [panel setAllowedFileTypes:nil];
    __weak typeof(self) wself = self;
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) {
            NSURL * fileURL = [panel URL];
            NSString * filePath = [fileURL path];
            wself.filePath = filePath;
            [wself updateFileUI];
        }
    }];
}

- (void)updateFileUI
{
    if(self.filePath){
        NSString * fileName = self.filePath.lastPathComponent;
        self.filenameLabel.stringValue = adhvf_safestringfy(fileName);
        [self.filenameLabel sizeToFit];
        CGRect fileNameRect = self.filenameLabel.frame;
        fileNameRect.size.height = 20.0f;
        self.filenameLabel.frame = fileNameRect;
        CGRect fileLayoutRect = self.payloadFileLayout.frame;
        fileLayoutRect.size.width = 8.0f + self.filenameLabel.frame.size.width + 42.0f;
        self.payloadFileLayout.frame = fileLayoutRect;
        self.payloadFileLayout.hidden = NO;
    }else{
        self.payloadFileLayout.hidden = YES;
    }
}

- (IBAction)payloadDeleteButtonPressed:(id)sender {
    self.filePath = nil;
    [self updateFileUI];
}

- (BOOL)validateInputValues {
    NSString * message = nil;
    BOOL pass = NO;
    do {
        NSInteger serviceIndex = [self.servicePopButton indexOfSelectedItem];
        if(serviceIndex < 0) {
            message = @"Please select Service";
            break;
        }
        NSInteger actionIndex = [self.actionPopButton indexOfSelectedItem];
        if(actionIndex < 0) {
            message = @"Please select Action";
            break;
        }
        NSString * bodyJson = self.bodyTextView.string;
        if(bodyJson.length > 0){
            NSDictionary * body = [bodyJson adh_jsonObject];
            if(!body){
                message = @"Body is not a valid json";
                break;
            }
        }
        pass = YES;
    } while (0);
    if(!pass){
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = @"Invalid Request";
        alert.informativeText = message;
        [alert runModal];
    }
    return pass;
}

- (IBAction)sendButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    if(![self validateInputValues]){
        return;
    }
    NSString * service = [self.servicePopButton titleOfSelectedItem];
    NSString * action = [self.actionPopButton titleOfSelectedItem];
    NSDictionary * body = nil;
    NSString * bodyJson = self.bodyTextView.string;
    if(bodyJson.length > 0){
        body = [bodyJson adh_jsonObject];
    }
    ApiActionRequest * request = [[ApiActionRequest alloc] init];
    request.service = service;
    request.action = action;
    request.body = body;
    request.filePath = self.filePath;
    [self doSendActionRequest:request];
}

- (void)doSendActionRequest: (ApiActionRequest *)request {
    ApiActionItem * item = [[ApiActionItem alloc] init];
    item.date = [NSDate date];
    item.actionRequest = request;
    [self.itemList addObject:item];
    [self loadContent];
    __weak typeof(self) wself = self;
    if(request.filePath){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData * payload = [[NSData alloc] initWithContentsOfFile:request.filePath];
            [wself.apiClient requestWithService:request.service action:request.action body:request.body payload:payload progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
                [wself onActionRequestFinish:item withBody:body payload:payload];
            } onFailed:^(NSError *error) {
                
            }];
        });
    }else{
        [wself.apiClient requestWithService:request.service action:request.action body:request.body onSuccess:^(NSDictionary *body, NSData *payload) {
            [wself onActionRequestFinish:item withBody:body payload:payload];
        } onFailed:^(NSError *error) {
            
        }];
    }
}

- (void)onActionRequestFinish: (ApiActionItem *)item withBody: (NSDictionary *)body payload: (NSData *)payload {
    if(body){
        NSString * text = [NSString stringWithFormat:@"%@",body];
        item.text = adhvf_safestringfy(text);
    }
    if(payload){
        __weak typeof(self) wself = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            LogRecorder * recorder = [LogRecorder recorderWithContext:wself.context];
            NSString * filePath = [recorder saveFileWithData:payload fileName:nil];
            item.filePath = filePath;
            dispatch_async(dispatch_get_main_queue(), ^{
                //update ui
                [self.tableView reloadData];
            });
        });
    }else{
        [self.tableView reloadData];
    }
}

- (void)resetActionContent {
    self.bodyTextView.string = adhvf_const_emptystr();
    self.filePath = nil;
    [self updateFileUI];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.itemList.count + 2;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat height = 0.0f;
    if(row == 0) {
        height = self.headerView.frame.size.height;
    }else if(row < self.tableView.numberOfRows-1){
        NSInteger itemRow = row-1;
        id item = self.itemList[itemRow];
        height = [ApiItemCell heightForData:item contentWidth:tableView.frame.size.width];
    }else{
        height = self.footerView.frame.size.height;
    }
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView * view = nil;
    if(row == 0) {
        view = self.headerView;
    }else if(row < self.tableView.numberOfRows - 1){
        NSInteger itemRow = row-1;
        id item = self.itemList[itemRow];
        ApiItemCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([ApiItemCell class]) owner:nil];
        CGFloat contentWidth = tableView.bounds.size.width;
        [cell setData:item contentWidth:contentWidth];
        cell.delegate = self;
        [cell setSeperatorVisible:(row != 1)];
        view = cell;
    }else{
        view = self.footerView;
    }
    return view;
}

#pragma mark -----------------   cell delegate   ----------------

- (void)apiCellRequestOpenFile:(ApiItemCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    if(row <= 0) {
        return;
    }
    NSInteger itemRow = row - 1;
    LogItem * item = self.itemList[itemRow];
    if(![item isKindOfClass:[LogItem class]]) {
        return;
    }
    NSString * filePath = item.filePath;
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
}

//更新位置
- (void)updateContentUI {
    NSScrollView * scrollView = self.tableView.enclosingScrollView;
    NSView * documentView = scrollView.documentView;
    CGFloat contentHeight = documentView.bounds.size.height;
    CGFloat scrolledHeight = scrollView.documentVisibleRect.origin.y;
    CGFloat frameHeight = scrollView.frame.size.height;
    CGFloat scrollableHeight = contentHeight - frameHeight;
    CGFloat leftScrollHeight = scrollableHeight - scrolledHeight;
    [self.tableView reloadData];
    if(leftScrollHeight <= self.footerView.frame.size.height){
        [self.tableView scrollToEndOfDocument:nil];
    }
}

@end
