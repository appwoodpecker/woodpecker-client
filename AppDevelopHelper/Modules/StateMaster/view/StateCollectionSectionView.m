//
//  StateCollectionSectionView.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/6/12.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "StateCollectionSectionView.h"

@interface StateCollectionSectionView ()

@property (nonatomic, strong) NSTextField *titleLabel;

@end

@implementation StateCollectionSectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(60.0, 0, 0, 0)];
    titleLabel.editable = NO;
    titleLabel.bezeled = NO;
    titleLabel.drawsBackground = NO;
    titleLabel.font = [NSFont systemFontOfSize:15.0f weight:NSFontWeightBold];
    titleLabel.textColor = [NSColor tertiaryLabelColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)setData: (NSDictionary *)data {
    self.titleLabel.stringValue = data[@"title"];
    [self.titleLabel sizeToFit];
    self.titleLabel.top = (self.height - self.titleLabel.height)/2.0f;
}

@end
