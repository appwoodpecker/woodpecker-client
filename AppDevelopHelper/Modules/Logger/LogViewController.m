//
//  IOViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "LogViewController.h"
#import "LogRecorder.h"
#import "LogCell.h"
#import "LogConsoleCell.h"
#import "MacOrganizer.h"

@interface LogViewController ()<NSTableViewDelegate,NSTableViewDataSource,LogCellDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *tableColumn;
@property (weak) IBOutlet NSSearchField *filterTextfield;
@property (weak) IBOutlet NSScrollView *tableScrollView;

@property (strong) IBOutlet NSView *headerView;
@property (strong) IBOutlet NSView *footerView;

@property (strong) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *pauseButton;
@property (weak) IBOutlet NSButton *trashButton;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL shouldTryStart;
@property (nonatomic, strong) NSArray * itemList;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSArray * filteredItemList;

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    LogRecorder *recorder = [LogRecorder recorderWithContext:self.context];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogItemUpdated:) name:kLogRecorderUpdateNotification object:recorder];
    [self initValue];
    [self initialUI];
}

- (void)setupAfterXib {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([LogCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([LogCell class])];
    {
        //log console
        NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([LogConsoleCell class]) bundle:nil];
        [self.tableView registerNib:nib forIdentifier:NSStringFromClass([LogConsoleCell class])];
    }
    self.tableView.backgroundColor = [Appearance colorWithRed:0x1F green:0x20 blue:0x29 alpha:1.0];
    self.tableColumn.maxWidth = CGFLOAT_MAX;
    self.tableColumn.width = self.tableView.frame.size.width;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.filterTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.filterTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    self.actionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
    [self.startButton setTintColor:[Appearance actionImageColor]];
    [self.trashButton setTintColor:[Appearance actionImageColor]];
    if([Appearance isDark]) {
        
    }else {
        
    }
}

- (void)initValue {
    self.started = NO;
    self.shouldTryStart = YES;
}

- (void)initialUI {
    [self updateStartStateUI];
}

- (void)updateStartStateUI {
    self.startButton.hidden = self.started;
    self.pauseButton.hidden = !self.startButton.hidden;
}

- (void)viewDidAppear {
    [super viewDidAppear];
    if(self.shouldTryStart) {
        [self doConsoleStart];
        [self loadContent];
    }
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    if(self.started) {
        [self doConsoleStop];
    }
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [self.tableView reloadData];
}

- (void)doConsoleStart {
    [self.startButton showHud];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.console" action:@"start" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.startButton hideHud];
        wself.started = YES;
        [wself updateStartStateUI];
    } onFailed:^(NSError *error) {
        [wself.startButton hideHud];
    }];
}

- (void)doConsoleStop {
    [self.pauseButton showHud];
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.console" action:@"stop" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.pauseButton hideHud];
        wself.started = NO;
        [wself updateStartStateUI];
    } onFailed:^(NSError *error) {
        [wself.pauseButton hideHud];
    }];
}

- (IBAction)startButtonPressed:(id)sender {
    self.shouldTryStart = YES;
    if(![self doCheckConnectionRoutine]) return;
    [self doConsoleStart];
}

- (IBAction)pauseButtonPressed:(id)sender {
    self.shouldTryStart = NO;
    if(![self doCheckConnectionRoutine]) return;
    [self doConsoleStop];
}

- (IBAction)trashButtonPressed:(id)sender {
    LogRecorder *recorder = [LogRecorder recorderWithContext:self.context];
    [recorder clearRecords];
    self.itemList = nil;
    self.filteredItemList = nil;
    [self.tableView reloadData];
}

- (void)doOnWorkAppStateUpdate {
    if(self.context.isConnected){
        if(self.shouldTryStart){
            [self doConsoleStart];
        }
    }else {
        self.started = NO;
        [self updateStartStateUI];
    }
}

- (void)loadContent {
    LogRecorder *recorder = [LogRecorder recorderWithContext:self.context];
    self.itemList = [recorder itemList];
    if(self.isSearching){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * keywords = self.filterTextfield.stringValue;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self filterWithKeywords:keywords];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateContentUI];
                });
            });
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateContentUI];
        });
    }
}

- (void)onLogItemUpdated: (NSNotification *)noti {
    [self loadContent];
}

- (void)updateContentUI {
    //更新位置
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.viewItemList.count + 2;
}
    
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat height = 0.0f;
    if(row == 0) {
        height = self.headerView.frame.size.height;
    }else if(row < self.tableView.numberOfRows-1){
        NSInteger itemRow = row-1;
        id item = self.viewItemList[itemRow];
        if([item isKindOfClass:[LogItem class]]) {
            height = [LogCell heightForData:item contentWidth:tableView.frame.size.width];
        }else if([item isKindOfClass:[NSString class]]) {
            height = [LogConsoleCell heightForData:item contentWidth:tableView.frame.size.width];
        }
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
        id item = self.viewItemList[itemRow];
        if([item isKindOfClass:[LogItem class]]) {
            LogCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([LogCell class]) owner:nil];
            CGFloat contentWidth = tableView.bounds.size.width;
            [cell setData:item contentWidth:contentWidth];
            cell.delegate = self;
            [cell setSeperatorVisible:(row != 1)];
            view = cell;
        }else if([item isKindOfClass:[NSString class]]) {
            LogConsoleCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([LogConsoleCell class]) owner:nil];
            CGFloat contentWidth = tableView.bounds.size.width;
            [cell setData:item contentWidth:contentWidth];
            view = cell;
        }
    }else{
        view = self.footerView;
    }
    return view;
}
    
#pragma mark -----------------   cell delegate   ----------------

- (void)logCellRequestOpenFile:(LogCell *)cell{
    NSInteger row = [self.tableView rowForView:cell];
    if(row <= 0) {
        return;
    }
    NSInteger itemRow = row - 1;
    LogItem * item = self.viewItemList[itemRow];
    if(![item isKindOfClass:[LogItem class]]) {
        return;
    }
    NSString * filePath = item.filePath;
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
}

    
#pragma mark -----------------   search   ----------------
    
- (void)searchTextDidChange:(NSNotification *)notification {
    NSString * keywords = self.filterTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}
    
- (void)searchTextDidEndEditing:(NSNotification *)notification {
    NSString * keywords = self.filterTextfield.stringValue;
    [self doSearchWithKeywords:keywords];
}
    
- (void)doSearchWithKeywords: (NSString *)keywords {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self filterWithKeywords:keywords];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}
    
- (void)filterWithKeywords: (NSString *)keywords {
    if(keywords.length == 0){
        self.isSearching = NO;
        self.filteredItemList = nil;
    }else{
        self.isSearching = YES;
        NSMutableArray * itemList = [NSMutableArray array];
        for (id item in self.itemList) {
            if([item isKindOfClass:[LogItem class]]) {
                LogItem *logItem = (LogItem *)item;
                NSString * text = logItem.text;
                if([text rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound){
                    [itemList addObject:item];
                }
            }else if([item isKindOfClass:[NSString class]]) {
                NSString * text = (NSString *)item;
                if([text rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound){
                    [itemList addObject:item];
                }
            }
        }
        self.filteredItemList = itemList;
    }
}
    
- (NSArray *)viewItemList {
    NSArray * list = nil;
    if(!self.isSearching){
        list = self.itemList;
    }else{
        list = self.filteredItemList;
    }
    return list;
}



@end













