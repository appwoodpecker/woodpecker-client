//
//  ViewFrameAttibuteCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewFrameAttributeCell.h"
#import "NumberAttrView.h"

@interface ViewFrameAttributeCell() <NumberAttrViewDelegate>

@property (nonatomic, strong) NumberAttrView *xView;
@property (nonatomic, strong) NumberAttrView *yView;
@property (nonatomic, strong) NumberAttrView *wView;
@property (nonatomic, strong) NumberAttrView *hView;

@end

@implementation ViewFrameAttributeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSView *contentView = self;
    
    NumberAttrView *xView = [NumberAttrView make];
    [xView setName:@"X"];
    [xView setMin:-NSIntegerMin max:CGFLOAT_MAX];
    xView.delegate = self;
    self.xView = xView;
    [contentView addSubview:self.xView];
    
    NumberAttrView *yView = [NumberAttrView make];
    [yView setName:@"Y"];
    [yView setMin:-NSIntegerMin max:CGFLOAT_MAX];
    yView.delegate = self;
    self.yView = yView;
    [contentView addSubview:self.yView];
    
    NumberAttrView *wView = [NumberAttrView make];
    [wView setName:@"W"];
    [wView setMin:0 max:CGFLOAT_MAX];
    wView.delegate = self;
    self.wView = wView;
    [contentView addSubview:self.wView];
    
    NumberAttrView *hView = [NumberAttrView make];
    [hView setName:@"H"];
    [hView setMin:0 max:CGFLOAT_MAX];
    hView.delegate = self;
    self.hView = hView;
    [contentView addSubview:self.hView];
    
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
    NSArray *views = @[self.wView,self.hView,self.xView,self.yView];
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

- (void)setData: (NSString *)frameValue contentWidth: (CGFloat)contentWidth {
    ADH_FRAME adhFrame = [ADHViewDebugUtil frameWithString:frameValue];
    CGFloat centerX = adhFrame.centerX;
    CGFloat centerY = adhFrame.centerY;
    CGFloat width = adhFrame.width;
    CGFloat height = adhFrame.height;
    [self.xView setValue:(centerX - width/2.0f)];
    [self.yView setValue:(centerY - height/2.0f)];
    [self.wView setValue:width];
    [self.hView setValue:height];
}

+ (CGFloat)heightForData: (NSValue *)frameValue contentWidth: (CGFloat)contentWidth {
    return 48.0f * 2;
}

- (void)numberAttrValueUpdate: (NumberAttrView *)numView value: (double)value {
    CGFloat x = [self.xView value];
    CGFloat y = [self.yView value];
    CGFloat width = [self.wView value];
    CGFloat height = [self.hView value];
    CGFloat centerX = x + width/2.0f;
    CGFloat centerY = y + height/2.0f;
    ADH_FRAME frame = adhFrameMake(centerX, centerY, width, height);
    NSString *frameValue = [ADHViewDebugUtil stringWithAdhFrame:frame];
    [self.delegate valueUpdateRequest:self value:frameValue info:nil];
}

@end
