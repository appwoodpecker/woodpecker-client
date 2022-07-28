//
//  LocalizationSelectionCell.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/21.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalizationSelectionCell : ADHBaseCell

- (void)setSelectionState: (BOOL)selected;

@end

@protocol LocalizationSelectionCellDelegate <ADHBaseCellDelegate>

- (void)selectionCell: (LocalizationSelectionCell *)cell selectionStateUpdate: (BOOL)selected;

@end

NS_ASSUME_NONNULL_END

