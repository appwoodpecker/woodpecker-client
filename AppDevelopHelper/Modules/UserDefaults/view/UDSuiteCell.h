//
//  UDSuiteCell.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/10.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface UDSuiteCell : ADHBaseCell

- (void)setSelected: (BOOL)selected;

@end


@protocol UDSuiteCellDelegate <ADHBaseCellDelegate>

- (void)suiteCellDeleteRequest: (UDSuiteCell *)cell;

@end

NS_ASSUME_NONNULL_END
