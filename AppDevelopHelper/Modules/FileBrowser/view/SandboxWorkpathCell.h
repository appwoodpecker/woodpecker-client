//
//  SandboxWorkpathCell.h
//  Woodpecker
//
//  Created by 张小刚 on 2019/6/1.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SandboxWorkpathItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SandboxWorkpathCellDelegate;
@interface SandboxWorkpathCell : NSTableCellView

@property (nonatomic, weak) id<SandboxWorkpathCellDelegate> delegate;
- (void)setData: (SandboxWorkpathItem *)item;

@end

@protocol SandboxWorkpathCellDelegate <NSObject>

- (void)workpathCellPathSetup: (SandboxWorkpathCell *)cell;
- (void)workpathCellDelete: (SandboxWorkpathCell *)cell;

@end

NS_ASSUME_NONNULL_END
