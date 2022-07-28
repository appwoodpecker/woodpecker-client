//
//  LocalizationItemCell.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/6/24.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHBaseCell.h"


@interface LocalizationItemCell : ADHBaseCell

- (void)setText: (NSString *)text;
- (void)setMissing: (BOOL)missing isKeyColumn: (BOOL)keyColumn;

@end
