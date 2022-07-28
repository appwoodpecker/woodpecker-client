//
//  ADHMacRemoteServiceCell.h
//  WoodpeckerMacOS
//
//  Created by 张小刚 on 2019/5/25.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHRemoteServiceItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADHMacRemoteServiceCellDegate;
@interface ADHMacRemoteServiceCell : NSTableCellView

@property (nonatomic, weak) id<ADHMacRemoteServiceCellDegate> delegate;
- (void)setData: (ADHRemoteServiceItem *)data;

@end

@protocol ADHMacRemoteServiceCellDegate <NSObject>

- (void)adhMacRemoteServiceCellActionRequest: (ADHMacRemoteServiceCell *)cell;

@end

NS_ASSUME_NONNULL_END
