//
//  SimpleTableCell.h
//  ADHClient
//
//  Created by 张小刚 on 2018/5/14.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SimpleTableCell : NSTableCellView

- (void)setValue: (NSString *)value;
- (void)setTextColor: (NSColor *)color;
- (void)setTextAlignment: (NSTextAlignment)alignment;

@end
