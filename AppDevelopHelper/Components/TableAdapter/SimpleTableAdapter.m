//
//  SimpleTableAdapter.m
//  ADHClient
//
//  Created by 张小刚 on 2018/5/14.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "SimpleTableAdapter.h"
#import "SimpleTableCell.h"

@interface SimpleTableAdapter ()<NSTableViewDelegate,NSTableViewDataSource>

@property (nonatomic, strong) NSTableView *mTableView;

@end

@implementation SimpleTableAdapter

- (void)setTableView: (NSTableView *)tableView {
    self.mTableView = tableView;
    self.mTableView.dataSource = self;
    self.mTableView.delegate = self;
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([SimpleTableCell class]) bundle:nil];
    [self.mTableView registerNib:nib forIdentifier:NSStringFromClass([SimpleTableCell class])];
}

- (NSTableView *)tableView {
    return self.mTableView;
}

- (void)update {
    [self setupColumns];
    [self updateRows];
}

- (void)setupColumns
{
    NSArray *columns = [self.mTableView.tableColumns mutableCopy];
    for (NSTableColumn * column in columns) {
        [self.mTableView removeTableColumn:column];
    }
    NSArray<SimpleTableColumn *> *columnList = [self columnList];
    for (SimpleTableColumn * scolumn in columnList) {
        NSString * name = scolumn.title;
        NSTableColumn * column = [[NSTableColumn alloc] init];
        column.identifier = scolumn.key;
        NSString * title = name;
        column.title = title;
        column.headerCell.alignment = scolumn.headerTextAlignment;
        column.headerCell.textColor = scolumn.cellTextColor;
        if(scolumn.width > 0) {
            column.width = scolumn.width;
        }
        [self.mTableView addTableColumn:column];
    }
}

- (void)updateRows {
    [self.mTableView reloadData];
}

#pragma mark -----------------   tableview datasource & delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self numberOfRows];
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    SimpleTableCell * cell = [tableView makeViewWithIdentifier:NSStringFromClass([SimpleTableCell class]) owner:nil];
    NSInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];
    SimpleTableColumn *column = [self columnList][columnIndex];
    NSString * value = [self valueAtRow:row columnKey:tableColumn.identifier];
    [cell setValue:value];
    [cell setTextColor:column.cellTextColor];
    [cell setTextAlignment:column.cellTextAlignment];
    return cell;
}


#pragma mark -----------------   protocol   ----------------

- (NSArray<SimpleTableColumn *>*) columnList {
    NSAssert(false, @"[SimpleTableAdapter] subclass must implements");
    return nil;
}

- (NSInteger)numberOfRows {
    NSAssert(false, @"[SimpleTableAdapter] subclass must implements");
    return 0;
}

- (NSString *)valueAtRow: (NSInteger)row columnKey: (NSString *)key {
    NSAssert(false, @"[SimpleTableAdapter] subclass must implements");
    return nil;
}


@end


@implementation SimpleTableColumn

@end
