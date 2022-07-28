//
//  KeyChainValueCell.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/9/2.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol KeyChainValueCellDelegate;

@interface KeyChainValueCell : NSTableCellView

@property (nonatomic, weak) id <KeyChainValueCellDelegate> delegate;
- (NSView *)actionView;
- (void)setData: (id)data;

@end

@protocol KeyChainValueCellDelegate <NSObject>

- (void)keyChainValueCellRequestValue: (KeyChainValueCell *)cell;

@end


