//
//  ViewInsetsAttributeCell.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/9/27.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ViewInsetsAttributeCell.h"
#import "NumberAttrView.h"

@interface ViewInsetsAttributeCell() <NumberAttrViewDelegate>

@property (nonatomic, strong) NumberAttrView *topView;
@property (nonatomic, strong) NumberAttrView *bottomView;
@property (nonatomic, strong) NumberAttrView *leftView;
@property (nonatomic, strong) NumberAttrView *rightView;

@end

@implementation ViewInsetsAttributeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSView *contentView = self;
    
    NumberAttrView *topView = [NumberAttrView make];
    [topView setName:@"Top"];
    [topView setMin:-NSIntegerMin max:CGFLOAT_MAX];
    topView.delegate = self;
    self.topView = topView;
    [contentView addSubview:self.topView];
    
    NumberAttrView *bottomView = [NumberAttrView make];
    [bottomView setName:@"Bottom"];
    [bottomView setMin:-NSIntegerMin max:CGFLOAT_MAX];
    bottomView.delegate = self;
    self.bottomView = bottomView;
    [contentView addSubview:self.bottomView];
    
    NumberAttrView *leftView = [NumberAttrView make];
    [leftView setName:@"Left"];
    [leftView setMin:0 max:CGFLOAT_MAX];
    leftView.delegate = self;
    self.leftView = leftView;
    [contentView addSubview:self.leftView];
    
    NumberAttrView *rightView = [NumberAttrView make];
    [rightView setName:@"Right"];
    [rightView setMin:0 max:CGFLOAT_MAX];
    rightView.delegate = self;
    self.rightView = rightView;
    [contentView addSubview:self.rightView];
    
    [self layoutFrameViews];
}

- (void)layout {
    [super layout];
    [self layoutFrameViews];
}

- (void)layoutFrameViews {
    CGFloat contentWidth = self.width;
    CGFloat space = 4.0f;
    CGFloat itemWidth = floor((contentWidth - space)/2.0f);
    CGFloat itemHeight = 48.0f;
    NSArray *views = @[self.leftView,self.rightView,self.topView,self.bottomView];
    int countPerRow = 2;
    for (int i=0; i<views.count; i++) {
        int row = i/countPerRow;
        int column = i%countPerRow;
        NSView *view = views[i];
        view.left =  column * itemWidth + (column > 0 ? (column-1)*space:0);
        view.top = row * itemHeight;
        view.width = itemWidth;
        view.height = itemHeight;
    }
}

- (void)setData: (NSString *)insetsValue contentWidth: (CGFloat)contentWidth {
    ADH_INSETS insets = [ADHViewDebugUtil insetsWithString:insetsValue];
    [self.topView setValue:insets.top];
    [self.bottomView setValue:insets.bottom];
    [self.leftView setValue:insets.left];
    [self.rightView setValue:insets.right];
}

+ (CGFloat)heightForData: (NSValue *)frameValue contentWidth: (CGFloat)contentWidth {
    return 48.0f * 2;
}

- (void)numberAttrValueUpdate: (NumberAttrView *)numView value: (double)value {
    CGFloat top = [self.topView value];
    CGFloat bottom = [self.bottomView value];
    CGFloat left = [self.leftView value];
    CGFloat right = [self.rightView value];
    ADH_INSETS insets = adhInsetsMake(top, left, bottom, right);
    NSString *insetsValue = [ADHViewDebugUtil stringWithAdhInsets:insets];
    [self.delegate valueUpdateRequest:self value:insetsValue info:nil];
}

@end

