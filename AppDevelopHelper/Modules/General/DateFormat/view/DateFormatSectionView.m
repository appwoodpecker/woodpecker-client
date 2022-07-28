//
//  DateFormatSectionView.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/13.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "DateFormatSectionView.h"

@interface DateFormatSectionView ()

@end

@implementation DateFormatSectionView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textField.textColor = [Appearance tipThemeColor];
}

- (void)setText: (NSString *)text {
    self.textField.stringValue = text;
}

@end
