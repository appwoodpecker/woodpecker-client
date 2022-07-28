//
//  DBAdapter.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DBAdapter.h"
#import "DBItemCell.h"
#import "DBRow.h"

@interface DBAdapter ()<DBItemCellDelegate,NSMenuDelegate>

@property (nonatomic, strong) NSMutableArray<DBRow *> * rowList;
@property (nonatomic, weak) NSTableView * mTableView;
@property (nonatomic, strong) DBTable * mTable;

@property (nonatomic, strong) NSArray<NSTableColumn *> *unorderedTableColumns;

@end

@implementation DBAdapter

- (void)setTableView: (NSTableView *)tableView
{
    self.mTableView = tableView;
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([DBItemCell class]) bundle:nil];
    [self.mTableView registerNib:nib forIdentifier:NSStringFromClass([DBItemCell class])];
    self.mTableView.rowHeight = [DBItemCell rowHeight];
}

- (void)resetColumns
{
    NSArray *columns = [self.mTableView.tableColumns mutableCopy];
    for (NSTableColumn * column in columns) {
        [self.mTableView removeTableColumn:column];
    }
    for (DBField * field in self.table.fields) {
        NSTableColumn * column = [[NSTableColumn alloc] init];
        column.identifier = field.name;
        NSString * title = field.name;
        if(field.isPrimaryKey){
            title = [NSString stringWithFormat:@"%@ (pk)",title];
        }
        column.title = title;
        column.width = 100.0f;
        column.minWidth = 60.0f;
        column.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:field.name ascending:YES];
        [self.mTableView addTableColumn:column];
    }
    self.unorderedTableColumns = [self.mTableView.tableColumns mutableCopy];
}

- (void)setTable:(DBTable *)table
{
    self.mTable = table;
    [self clearTable];
    [self resetColumns];
}

- (void)clearTable
{
    self.rowList = nil;
    [self.mTableView reloadData];
}

- (DBTable *)table
{
    return self.mTable;
}

- (void)reloadData
{
    [self loadData];
}

- (void)loadData
{
    __weak typeof(self) wself = self;
    [self.dao fetchDataInTable:self.table
                      pageStep:self.step
                     pageIndex:self.pageIndex
                     sortField:self.sortDescriptor.key
                     ascending:self.sortDescriptor.ascending
                   filterField:self.searchField
                filterKeywords:self.searchKeywords
                 oncCompletion:^(NSArray<DBRow *> *rowList, NSError *error) {
                     if(!rowList) {
                         rowList = @[];
                     }
                     wself.rowList = [rowList mutableCopy];
                     [wself.mTableView reloadData];
                 }];
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.rowList.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    DBItemCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([DBItemCell class]) owner:nil];
    DBRow * dbRow = self.rowList[row];
    NSArray<DBItem *> * itemList = dbRow.itemList;
    //由于我们的dbItem没有key，只能根据索引位置查找，所以我们找到该column原来所在的index
    NSInteger columnIndex = [self.unorderedTableColumns indexOfObject:tableColumn];
    DBItem * item = itemList[columnIndex];
    [cell setData:item];
    cell.delegate = self;
    return cell;
}

//排序
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    NSSortDescriptor * sortDescriptor = nil;
    if([aTableView sortDescriptors].count > 0){
        sortDescriptor = [[aTableView sortDescriptors] objectAtIndex:0];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(dbAdapter:sortChanged:)]){
        [self.delegate dbAdapter:self sortChanged:sortDescriptor];
    }
}

#pragma mark -----------------   table item delegate   ----------------

- (void)cellDoubleClicked: (DBItemCell *)cell
{
    if(!self.editable) {
        return;
    }
    BOOL editable = NO;
    if([self.mTable isEditable]){
        NSInteger columnIndex = [self.mTableView columnForView:cell];
        if(columnIndex >= 0) {
            NSTableColumn *column = [self.mTableView.tableColumns objectAtIndex:columnIndex];
            NSString *fieldName = column.identifier;
            DBField * field = [self.mTable fieldWithName:fieldName];
            editable = [field isEditable];
        }
    }
    if(editable){
        [cell setEditState:YES];
    }
}

- (void)dbItemCell: (DBItemCell *)itemCell contentUpdateRequest: (NSString *)newValue
{
    NSInteger columnIndex = [self.mTableView columnForView:itemCell];
    NSInteger rowIndex = [self.mTableView rowForView:itemCell];
    if(columnIndex < 0 || rowIndex < 0) {
        return;
    }
    DBRow * row = self.rowList[rowIndex];
    //目标key
    NSTableColumn *column = [self.mTableView.tableColumns objectAtIndex:columnIndex];
    NSString *fieldName = column.identifier;
    DBField * field = [self.mTable fieldWithName:fieldName];
    //主键keys
    NSArray * keyfields = self.mTable.keyFields;
    NSIndexSet * keyFieldsIndexSet = [self.mTable keyFieldsIndexSet];
    NSMutableArray * keyValues = [NSMutableArray array];
    [keyFieldsIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        DBItem * item = row.itemList[idx];
        [keyValues addObject:item.stringValue];
    }];
    
    [self.dao updateField:field
                 newValue:newValue
                keyFields:keyfields
                keyValues:keyValues
                    table:self.mTable
             onCompletion:^(BOOL success, NSError *error) {
                 if(success){
                     DBItem * item = row.itemList[columnIndex];
                     item.stringValue = newValue;
                     [itemCell setData:item];
                 }else{
//                     NSLog(@"%@",error);
                 }
    }];
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point
{
    NSInteger columnIndex = [self.mTableView columnForView:cell];
    NSTableColumn *column = [self.mTableView.tableColumns objectAtIndex:columnIndex];
    NSInteger originColumnIndex = [self.unorderedTableColumns indexOfObject:column];
    NSInteger rowIndex = [self.mTableView rowForView:cell];
    if(originColumnIndex < 0 || rowIndex < 0) {
        return;
    }
    DBRow * row = self.rowList[rowIndex];
    DBItem * item = [row itemAtIndex:originColumnIndex];

    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    if(!item.isBLOB) {
        //copy
        NSMenuItem * copyMenu = [[NSMenuItem alloc] initWithTitle:@"Copy" action:@selector(doCopyFieldValue:) keyEquivalent:adhvf_const_emptystr()];
        copyMenu.representedObject = item;
        copyMenu.target = self;
        [menu addItem:copyMenu];
    }
    //delete
    if(self.mTable.keyFields.count > 0) {
        NSMenuItem * deleteMenu = [[NSMenuItem alloc] initWithTitle:@"Delete Row" action:@selector(doDeleteMenu:) keyEquivalent:adhvf_const_emptystr()];
        deleteMenu.representedObject = row;
        deleteMenu.target = self;
        [menu addItem:deleteMenu];
    }
    if(menu.itemArray.count > 0) {
        [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
    }
}

- (void)doCopyFieldValue: (NSMenuItem *)menu
{
    DBItem * item = menu.representedObject;
    NSString * value = item.stringValue;
    if(value.length > 0){
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:value forType:NSPasteboardTypeString];
    }else if(item.dataValue){
        //BLOB数据如何处理
    }
}

- (void)doDeleteMenu: (NSMenuItem *)menu {
    DBRow * row = menu.representedObject;
    //主键keys
    NSArray * keyfields = self.mTable.keyFields;
    NSIndexSet * keyFieldsIndexSet = [self.mTable keyFieldsIndexSet];
    NSMutableArray * keyValues = [NSMutableArray array];
    [keyFieldsIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        DBItem * item = row.itemList[idx];
        [keyValues addObject:item.stringValue];
    }];
//    keyfields = @[[keyfields lastObject]];
//    keyValues = @[[keyValues lastObject]];
    __weak typeof(self) wself = self;
    [self.dao deleteRowWithkeyFields:keyfields keyValues:keyValues table:self.mTable onCompletion:^(BOOL success, NSError *error) {
        if(!success) return;
        NSInteger rowIndex = [self.rowList indexOfObject:row];
        if(rowIndex == NSNotFound || rowIndex > wself.rowList.count-1) {
            return ;
        }
        [wself.rowList removeObjectAtIndex:rowIndex];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:rowIndex];
        [wself.mTableView removeRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationEffectFade];
    }];
}


@end























