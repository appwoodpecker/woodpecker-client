//
//  DateFormatItemCell.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/13.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "DateFormatItemCell.h"

@implementation DateFormatItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setText: (NSString *)text width: (CGFloat)contentWidth {
    self.textField.stringValue = text;
    CGFloat maxWidth = contentWidth - 10.0f - 12.0;
    CGSize textSize = [self.textField sizeThatFits:NSMakeSize(maxWidth, CGFLOAT_MAX)];
    self.textField.size = textSize;
}

- (void)layout {
    [super layout];
    self.textField.top = (self.height - self.textField.height)/2.0f;
}

@end
