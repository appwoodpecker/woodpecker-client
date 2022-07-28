//
//  ADHBaseCell.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ADHBaseCellDelegate;
@interface ADHBaseCell : NSTableCellView

@property (nonatomic, weak) id<ADHBaseCellDelegate> delegate;

- (void)setData: (id)data;

//固定高度
+ (CGFloat)rowHeight;
//动态高度
+ (CGFloat)heightForData: (id)data;

@end


@protocol ADHBaseCellDelegate<NSObject>
@optional
- (void)cellClicked: (ADHBaseCell *)cell;
- (void)cellDoubleClicked: (ADHBaseCell *)cell;
- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point;

@end
