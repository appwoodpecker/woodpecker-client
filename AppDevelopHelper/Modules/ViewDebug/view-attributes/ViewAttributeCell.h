//
//  ViewAttributeCell.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/23.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHViewDebugUtil.h"
#import "ADHAttribute.h"


NS_ASSUME_NONNULL_BEGIN

@protocol ViewAttributeCellDelegate;
@interface ViewAttributeCell : NSTableCellView

@property (nonatomic, weak) id<ViewAttributeCellDelegate> delegate;
- (void)setData: (id)data contentWidth: (CGFloat)contentWidth;
+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth;

@property (nonatomic, weak) ADHAttrItem *item;
@property (nonatomic, weak) ADHAttribute *attribute;
@property (nonatomic, weak) id contextVC;

@end

@protocol ViewAttributeCellDelegate <NSObject>

@optional
/**
 * 更新App端数据请求
 */
- (void)valueUpdateRequest: (ViewAttributeCell *)cell value: (id)value info: (nullable NSDictionary *)info;

/**
 * 从App端获取数据请求
 */
- (void)valueRequest: (ViewAttributeCell *)cell info:(nullable NSDictionary *)info;

/**
 * 状态更新请求
 */
- (void)stateUpdateRequest: (ViewAttributeCell *)cell value: (id)value info: (nullable NSDictionary *)info;

/**
 * 通用Action
 */
- (void)actionRequest: (ViewAttributeCell *)cell;
@end

NS_ASSUME_NONNULL_END
