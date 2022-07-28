//
//  UDKVItemCell.h
//  ADHClient
//
//  Created by 张小刚 on 2018/3/8.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHBaseCell.h"

@interface UDKVItemCell : ADHBaseCell

- (void)setTextColor: (NSColor *)color;
- (void)setEditState: (BOOL)canEdit;
//pin状态
- (void)setPinState: (BOOL)pin;


@end


@protocol UDKVItemCellDelegate <ADHBaseCellDelegate>

- (void)udkvItemCell: (UDKVItemCell *)cell contentUpdateRequest: (NSString *)newValue;

@end
