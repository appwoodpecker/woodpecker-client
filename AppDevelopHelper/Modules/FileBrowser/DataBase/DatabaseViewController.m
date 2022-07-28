//
//  DatabaseViewController.m
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/29.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DatabaseViewController.h"
#import "DBDao.h"
#import "DBTableCell.h"
#import "DBAdapter.h"
#import "xlsxwriter.h"

@interface DatabaseViewController ()<NSTableViewDataSource,NSTableViewDelegate,NSSplitViewDelegate,ADHBaseCellDelegate,DBAdapterDelegate>

@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *tblnameLayout;

@property (weak) IBOutlet NSView *contentLayout;

@property (weak) IBOutlet NSTableView *tblTableView;
@property (weak) IBOutlet NSTableView *contentTableView;

@property (weak) IBOutlet NSView *topLineView;
@property (weak) IBOutlet NSTextField *tableCountLabel;

@property (weak) IBOutlet NSTextField *totalPageLabel;
@property (weak) IBOutlet NSPopUpButton *pageStepPopButton;
@property (weak) IBOutlet NSTextField *currentPageLabel;

@property (weak) IBOutlet NSPopUpButton *filterPopupButton;
@property (weak) IBOutlet NSTextField *filterTextfield;
@property (weak) IBOutlet NSButton *exportButton;
@property (weak) IBOutlet NSButton *trashButton;
@property (weak) IBOutlet NSImageView *tableIcon;
@property (weak) IBOutlet NSButton *firstPageButton;
@property (weak) IBOutlet NSButton *prePageButton;
@property (weak) IBOutlet NSButton *nextPageButton;
@property (weak) IBOutlet NSButton *lastPageButton;

@property (nonatomic, strong) DBDao * dbDao;
@property (nonatomic, strong) NSArray * tables;
@property (nonatomic, strong) DBAdapter * contentAdapter;

@property (nonatomic, strong) DBTable * currentTable;

@property (nonatomic, assign) NSInteger pageStep;
@property (nonatomic, assign) NSInteger totalCount;
//from 0
@property (nonatomic, assign) NSInteger currentPage;
//sort
@property (nonatomic, assign) NSSortDescriptor * sortDescriptor;
//关键字
@property (nonatomic, strong) NSString *keywords;

@property (nonatomic, strong) NSArray * pageStepDefs;

@property (nonatomic, strong) NSArray<DBRow*> *exportRowList;


@end

@implementation DatabaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self initialValues];
    [self initialUI];
    self.dbDao = [[DBDao alloc] init];
    if(self.filePath){
        [self loadContent];
    }
}

- (void)setupAfterXib {
    self.view.wantsLayer = YES;
    self.tblTableView.dataSource = self;
    self.tblTableView.delegate = self;
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([DBTableCell class]) bundle:nil];
    [self.tblTableView registerNib:nib forIdentifier:NSStringFromClass([DBTableCell class])];
    self.tblTableView.rowHeight = [DBTableCell rowHeight];
    CGRect tblnameViewRect = self.tblnameLayout.frame;
    tblnameViewRect.size.width = [self tblnamePreferWidth];
    self.tblnameLayout.frame = tblnameViewRect;
    self.contentTableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask;
    //adapter
    DBAdapter * adapter = [[DBAdapter alloc] init];
    adapter.editable = self.editable;
    self.contentAdapter = adapter;
    self.contentAdapter.tableView = self.contentTableView;
    self.contentTableView.usesAlternatingRowBackgroundColors = YES;
    self.contentAdapter.delegate = self;
    self.topLineView.wantsLayer = YES;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange:) name:NSControlTextDidChangeNotification object:self.filterTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:self.filterTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    self.topLineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    self.view.layer.backgroundColor = [Appearance backgroundColor].CGColor;
    [self.exportButton setTintColor:[Appearance actionImageColor]];
    [self.trashButton setTintColor:[Appearance actionImageColor]];
    [self.tableIcon setTintColor:[Appearance actionImageColor]];
    [self.firstPageButton setTintColor:[NSColor labelColor]];
    [self.prePageButton setTintColor:[NSColor labelColor]];
    [self.nextPageButton setTintColor:[NSColor labelColor]];
    [self.lastPageButton setTintColor:[NSColor labelColor]];
}

- (void)initialValues
{
    self.pageStepDefs = @[@20,@50,@100];
    self.pageStep = [self.pageStepDefs[0] integerValue];
    self.totalCount = 0;
    self.currentPage = 0;
}

- (void)initialUI
{
    [self.filterPopupButton removeAllItems];
    [self.pageStepPopButton removeAllItems];
    for (NSNumber * step in self.pageStepDefs) {
        [self.pageStepPopButton addItemWithTitle:[NSString stringWithFormat:@"%@",step]];
    }
    [self updatePageUI];
}

- (void)reload
{
    [self loadContent];
}

- (void)loadContent
{
    [self setupContext];
    //load tables & others
    [self queryTables];
}

- (void)setupContext {
    [self.dbDao openWithPath:self.filePath];
}

#pragma mark -----------------   query tables   ----------------

- (void)queryTables {
    NSArray * tables = [self.dbDao tables];
    self.tables = tables;
    [self updateTblUI];
    [self loadFirstTable];
}

#pragma mark -----------------   tableview   ----------------

- (void)updateTblUI
{
    if(self.tables.count > 0){
        self.tableCountLabel.stringValue = [NSString stringWithFormat:@"Tables(%zd)",self.tables.count];
    }else{
        self.tableCountLabel.stringValue = @"Tables";
    }
    [self.tblTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.tables.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    DBTableCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([DBTableCell class]) owner:nil];
    [cell setData:self.tables[row]];
    cell.delegate = self;
    return cell;
}

- (void)cellClicked:(ADHBaseCell *)cell
{
    NSInteger row = [self.tblTableView rowForView:cell];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.tblTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [self resetSwitchTableUI];
    [self loadTableAtIndex:row];
}

- (void)resetSwitchTableUI {
    [self clearFilterKeywords];
}

- (void)loadFirstTable
{
    if(self.tables.count == 0) return;
    NSInteger tblIndex = 0;
    [self.tblTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:tblIndex] byExtendingSelection:NO];
    [self loadTableAtIndex:tblIndex];
}

- (void)resetTable
{
    self.currentTable = nil;
    self.totalCount = 0;
    self.currentPage = 0;
    self.pageStepPopButton.enabled = NO;
}

#pragma mark -----------------   filter   ----------------

- (IBAction)fieldPopupButtonChanged:(id)sender {
    [self clearFilterKeywords];
    [self doFilter];
    [self updateFilterTipUI];
}

- (void)updateFilterTipUI {
    DBField *searchField = nil;
    if(self.filterPopupButton.itemArray.count > 0) {
        NSInteger fieldIndex = [self.filterPopupButton.itemArray indexOfObject: self.filterPopupButton.selectedItem];
        if(fieldIndex != NSNotFound && fieldIndex <= self.currentTable.fields.count-1) {
            searchField = self.currentTable.fields[fieldIndex];
        }
    }
    NSString *tip = @"keywords";
    if(searchField.fieldType == DBDataTypeINTEGER) {
        tip = @" =";
    }
    self.filterTextfield.placeholderString = tip;
}

- (void)updateFilterUI {
    [self.filterPopupButton removeAllItems];
    //add empty item
    for (NSInteger i=0; i<self.currentTable.fields.count; i++) {
        DBField *field = self.currentTable.fields[i];
        if([field isSearchable]) {
            [self.filterPopupButton addItemWithTitle:field.name];
        }
    }
    [self updateFilterTipUI];
}

- (void)clearFilterKeywords {
    self.filterTextfield.stringValue = @"";
}

- (void)searchTextDidChange:(NSNotification *)notification
{
    [self doSearchWithKeywords:self.filterTextfield.stringValue];
}

- (void)searchTextDidEndEditing:(NSNotification *)notification
{
    [self doSearchWithKeywords:self.filterTextfield.stringValue];
}

- (void)doSearchWithKeywords: (NSString *)keywords {
    [self doFilter];
}

- (void)doFilter {
    //更新
    [self reloadPageContent];
    [self updateTableContent];
}

#pragma mark -----------------   page   ----------------

- (void)updatePageUI
{
    self.pageStepPopButton.enabled = (self.currentTable != nil);
    self.totalPageLabel.stringValue = [NSString stringWithFormat:@"%zd fields  %zd records",self.currentTable.fields.count, self.totalCount];
    [self updateCurrentPageUI];
}

- (NSInteger)pageCount
{
    NSInteger pageCount = (self.totalCount/self.pageStep) + ((self.totalCount%self.pageStep) > 0 ? 1:0);
    return pageCount;
}

- (void)updateCurrentPageUI
{
    NSInteger pageNo = 0;
    if([self pageCount] > 0){
        pageNo = self.currentPage+1;
    }
    self.currentPageLabel.stringValue = [NSString stringWithFormat:@"%zd/%zd",pageNo,self.pageCount];
}

- (void)loadTableAtIndex: (NSInteger)index
{
    self.currentTable = self.tables[index];
    [self reloadTableContent];
}

- (void)reloadTableContent {
    //加载总数，然后加载第一页
    self.contentAdapter.table = self.currentTable;
    self.contentAdapter.dao = self.dbDao;
    //更新数目
    [self reloadPageContent];
    [self updateFilterUI];
    [self updateTableContent];
}

/**
 * 总数，页数
 * 调用时机：切换table，搜索
 */
- (void)reloadPageContent {
    self.currentPage = 0;
    //filter
    DBField *searchField = nil;
    NSString *searchKeywords = nil;
    if(self.filterTextfield.stringValue.length > 0 && self.filterPopupButton.itemArray.count > 0) {
        NSInteger fieldIndex = [self.filterPopupButton.itemArray indexOfObject: self.filterPopupButton.selectedItem];
        if(fieldIndex != NSNotFound && fieldIndex <= self.currentTable.fields.count-1) {
            searchField = self.currentTable.fields[fieldIndex];
            searchKeywords = self.filterTextfield.stringValue;
        }
    }
    __weak typeof(self) wself = self;
    [self.dbDao fetchNumberOfRecordsInTable:self.currentTable filterField:searchField filterKeywords:searchKeywords oncCompletion:^(NSInteger count) {
        wself.totalCount = count;
        [wself updatePageUI];
    }];
}

//每页数目
- (IBAction)pageStepButtonPressed:(id)sender {
    NSInteger stepIndex = self.pageStepPopButton.indexOfSelectedItem;
    self.pageStep = [self.pageStepDefs[stepIndex] integerValue];
    //将当前页设置为0
    self.currentPage = 0;
    [self updateCurrentPageUI];
    [self updateTableContent];
}

//第一页
- (IBAction)firstPageButtonPressed:(id)sender {
    if(self.pageCount == 0) return;
    self.currentPage = 0;
    [self updateCurrentPageUI];
    [self updateTableContent];
}

//上一页
- (IBAction)previousPageButtonPressed:(id)sender {
    if(self.pageCount == 0) return;
    NSInteger page = self.currentPage;
    if(page > 0){
        page--;
    }
    self.currentPage = page;
    [self updateCurrentPageUI];
    [self updateTableContent];
}

//下一页
- (IBAction)nextPageButtonPressed:(id)sender {
    if(self.pageCount == 0) return;
    NSInteger page = self.currentPage;
    if(page < self.pageCount-1){
        page++;
    }
    self.currentPage = page;
    [self updateCurrentPageUI];
    [self updateTableContent];
}

//最后一页
- (IBAction)lastPageButtonPressed:(id)sender {
    if(self.pageCount == 0) return;
    self.currentPage = self.pageCount-1;
    [self updateCurrentPageUI];
    [self updateTableContent];
}

//排序
- (void)dbAdapter: (DBAdapter *)adapter sortChanged: (NSSortDescriptor *)sortDescriptor
{
    self.sortDescriptor = sortDescriptor;
    self.currentPage = 0;
    [self updateCurrentPageUI];
    [self updateTableContent];
}

- (void)updateTableContent {
    //收集最新pageStep, pageNo
    NSInteger step = self.pageStep;
    NSInteger pageIndex = self.currentPage;
    self.contentAdapter.step = step;
    self.contentAdapter.pageIndex = pageIndex;
    self.contentAdapter.sortDescriptor = self.sortDescriptor;
    //filter
    DBField *searchField = nil;
    NSString *searchKeywords = nil;
    if(self.filterTextfield.stringValue.length > 0 && self.filterPopupButton.itemArray.count > 0) {
        NSInteger fieldIndex = [self.filterPopupButton.itemArray indexOfObject: self.filterPopupButton.selectedItem];
        if(fieldIndex != NSNotFound && fieldIndex <= self.currentTable.fields.count-1) {
            searchField = self.currentTable.fields[fieldIndex];
            searchKeywords = self.filterTextfield.stringValue;
        }
    }
    self.contentAdapter.searchField = searchField;
    self.contentAdapter.searchKeywords = searchKeywords;
    [self.contentAdapter reloadData];
}

#pragma mark -----------------   split view delegate   ----------------

- (CGFloat)tblnamePreferWidth
{
    return 160.0f;
}

/**
 暂时不支持折叠
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    BOOL ret = NO;
    if(subview == self.tblnameScrollView){
        ret = YES;
    }
    return ret;
}*/

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    CGFloat minWidth = proposedMinimumPosition;
    if(dividerIndex == 0){
        minWidth = [self tblnamePreferWidth];
    }
    return minWidth;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    //如果splitview大小发生变化，计算子视图位置
    CGFloat splitWidth = splitView.bounds.size.width;
    CGFloat splitHeight = splitView.bounds.size.height;
    
    CGFloat dividerThickness = splitView.dividerThickness;
    CGFloat tblnameWidth = self.tblnameLayout.bounds.size.width;
    self.tblnameLayout.frame = CGRectMake(0, 0, tblnameWidth, splitHeight);
    
    CGFloat contentWidth = splitWidth - dividerThickness - tblnameWidth;
    //设置最小宽度防止闪退，应该是cell闪退
    if(contentWidth < 10){
        contentWidth = 10;
    }
    self.contentLayout.frame = CGRectMake(tblnameWidth+dividerThickness, 0, contentWidth, splitHeight);
}


- (IBAction)exportButtonPressed:(id)sender {
    //准备导出数据
    __weak typeof(self) wself = self;
    [self.dbDao fetchDataInTable:self.currentTable onCompletion:^(NSArray<DBRow *> *list, NSError *error) {
        if(list.count > 0) {
            wself.exportRowList = list;
            NSSavePanel *panel = [NSSavePanel savePanel];
            NSString *fileName = wself.currentTable.name;
            fileName = [fileName stringByAppendingString:@".xlsx"];
            panel.nameFieldStringValue = fileName;
            [panel beginSheetModalForWindow:wself.view.window completionHandler:^(NSModalResponse result) {
                if(result == NSModalResponseOK) {
                    NSURL *fileURL = panel.URL;
                    [wself doExportToURL:fileURL];
                }else {
                    [wself resetExportContext];
                }
            }];
        }
    }];
}

- (void)doExportToURL: (NSURL *)fileURL {
    [self.exportButton showHud];
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *fields = wself.currentTable.fields;
        //ready go
        const char *output =  [fileURL fileSystemRepresentation];
        lxw_workbook  *workbook   = new_workbook(output);
        //create sheet for this language
        lxw_worksheet *worksheet = workbook_add_worksheet(workbook,NULL);
        //column format
        lxw_format  *strongFormat = workbook_add_format(workbook);
        format_set_bold(strongFormat);
        format_set_align(strongFormat, LXW_ALIGN_LEFT);
        format_set_align(strongFormat, LXW_ALIGN_VERTICAL_CENTER);
        //pk format
        lxw_format *pkFormat = workbook_add_format(workbook);
        format_set_bold(pkFormat);
        format_set_italic(pkFormat);
        format_set_align(pkFormat, LXW_ALIGN_LEFT);
        format_set_align(pkFormat, LXW_ALIGN_VERTICAL_CENTER);
        //normal format
        lxw_format *alignFormat = workbook_add_format(workbook);
        format_set_align(alignFormat, LXW_ALIGN_LEFT);
        format_set_align(alignFormat, LXW_ALIGN_VERTICAL_CENTER);
        worksheet_set_column(worksheet, 0, fields.count, LXW_DEF_COL_WIDTH*1.6, alignFormat);
        worksheet_set_default_row(worksheet, LXW_DEF_ROW_HEIGHT*1.6, LXW_FALSE);
        //标题栏
        for (NSInteger i=0; i<fields.count; i++) {
            DBField *field = fields[i];
            NSString *name = field.name;
            const char *text = [name cStringUsingEncoding:NSUTF8StringEncoding];
            if(field.isPrimaryKey) {
                worksheet_write_string(worksheet, 0, i, text, pkFormat);
            }else {
                worksheet_write_string(worksheet, 0, i, text, strongFormat);
            }
        }
        //内容
        NSArray *rowList = wself.exportRowList;
        for (int32_t column=0; column<fields.count; column++) {
            for (int32_t row=0; row<rowList.count; row++) {
                DBRow *dataRow = rowList[row];
                DBItem *item = dataRow.itemList[column];
                NSString *text = @"";
                if(![item isBLOB]) {
                    text = item.stringValue;
                }
                worksheet_write_string(worksheet, row+1, column, [wself cString:text], NULL);
            }
        }
        workbook_close(workbook);
        [wself resetExportContext];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.exportButton hideHud];
        });
    });
}

- (void)resetExportContext {
    self.exportRowList = nil;
}

- (const char *)cString: (NSString *)string {
    const char *text = [string cStringUsingEncoding:NSUTF8StringEncoding];
    return text;
}

- (IBAction)emptyButtonPressed:(id)sender {
    __weak typeof(self) wself = self;
    [ADHAlert alertWithMessage:kAppLocalized(@"Empty Table") infoText:kAppLocalized(@"Empty Table Alert") comfirmBlock:^{
        [wself.dbDao emptyTable:wself.currentTable onCompletion:^(BOOL success, NSError *error) {
            if(success) {
                [wself reloadTableContent];
            }
        }];
    } cancelBlock:nil];
}


@end
