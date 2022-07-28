//
//  DBItemCell.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DBItemCellDelegate;
@interface DBItemCell : ADHBaseCell

- (void)setEditState: (BOOL)canEdit;

@end

@protocol DBItemCellDelegate <ADHBaseCellDelegate>

@optional
- (BOOL)dbItemCellCanEdit: (DBItemCell *)itemCell;
- (void)dbItemCell: (DBItemCell *)itemCell contentUpdateRequest: (NSString *)newValue;

@end
