//
//  DBAdapter.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBDao.h"

@protocol DBAdapterDelegate;
@interface DBAdapter : NSObject<NSTableViewDelegate,NSTableViewDataSource>

@property (nonatomic, weak) DBDao * dao;

@property (nonatomic,weak) id<DBAdapterDelegate> delegate;

- (void)setTableView: (NSTableView *)tableView;
- (void)setTable:(DBTable *)table;

//20,50,100
@property (nonatomic, assign) NSInteger step;
//from 0
@property (nonatomic, assign) NSInteger pageIndex;
//sort
@property (nonatomic, strong) NSSortDescriptor * sortDescriptor;
//search
@property (nonatomic, strong) DBField *searchField;
@property (nonatomic, strong) NSString *searchKeywords;

@property (nonatomic, assign) BOOL editable;

- (void)reloadData;

@end

@protocol DBAdapterDelegate<NSObject>

- (void)dbAdapter: (DBAdapter *)adapter sortChanged: (NSSortDescriptor *)sortDescriptor;

@end










