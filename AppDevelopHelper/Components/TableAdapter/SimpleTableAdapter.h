//
//  SimpleTableAdapter.h
//  ADHClient
//
//  Created by 张小刚 on 2018/5/14.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleTableColumn : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSColor *headerTextColor;
@property (nonatomic, assign) NSTextAlignment headerTextAlignment;
@property (nonatomic, assign) NSTextAlignment cellTextAlignment;
@property (nonatomic, strong) NSColor *cellTextColor;
@property (nonatomic, assign) CGFloat width;


@end

@protocol SimpleTableAdapterProtocol <NSObject>

//subclass must provides
@required
- (NSArray<SimpleTableColumn *>*) columnList;
- (NSInteger)numberOfRows;
- (NSString *)valueAtRow: (NSInteger)row columnKey: (NSString *)key;

@end



@interface SimpleTableAdapter : NSObject<SimpleTableAdapterProtocol>

//strong reference
- (void)setTableView: (NSTableView *)tableView;
- (NSTableView *)tableView;
//update column and rows
- (void)update;
//update rows only
- (void)updateRows;

@end
















