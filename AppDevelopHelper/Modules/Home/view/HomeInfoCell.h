//
//  HomeInfoCell.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/5.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHBaseCell.h"

@interface HomeInfoCell : ADHBaseCell

@property (nonatomic, assign) BOOL key;
- (void)setTextColor: (NSColor *)color;

@end
