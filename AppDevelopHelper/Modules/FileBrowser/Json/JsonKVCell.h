//
//  JsonKVCell.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/5/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHKVItem.h"

@interface JsonKVCell : ADHBaseCell

- (void)setData: (ADHKVItem *)kvItem contentWidth: (CGFloat)contentWidth;
+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth;

@end
