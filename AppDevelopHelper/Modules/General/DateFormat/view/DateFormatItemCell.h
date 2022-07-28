//
//  DateFormatItemCell.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/13.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DateFormatItemCell : NSTableCellView

- (void)setText: (NSString *)text width: (CGFloat)contentWidth;

@end
