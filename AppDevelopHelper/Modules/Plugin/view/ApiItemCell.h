//
//  ApiItemCell.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ApiItemCellDelegate;
@interface ApiItemCell : NSTableCellView

@property (nonatomic, weak) id<ApiItemCellDelegate> delegate;
    
- (void)setData: (id)data contentWidth: (CGFloat)contentWidth;
+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth;
- (void)setSeperatorVisible: (BOOL)visible;
    
@end

@protocol ApiItemCellDelegate <NSObject>
    
- (void)apiCellRequestOpenFile:(ApiItemCell *)cell;
    
@end
