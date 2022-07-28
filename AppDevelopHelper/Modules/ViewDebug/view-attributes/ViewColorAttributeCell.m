//
//  ViewColorAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewColorAttributeCell.h"

@interface ViewColorAttributeCell ()

@property (weak) IBOutlet NSColorWell *colorWell;
@property (weak) IBOutlet NSTextField *valueLabel;


@end

@implementation ViewColorAttributeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //支持alpha组件
    [NSColorPanel sharedColorPanel].showsAlpha = YES;
}

- (void)setData: (NSString *)colorValue contentWidth: (CGFloat)contentWidth {
    ADH_COLOR adhColor = [ADHViewDebugUtil colorWithString:colorValue];
    NSColor *color = nscolorFromAdhColor(adhColor);
    if(color) {
        self.colorWell.color = color;
    }
    CGFloat red = adhColor.v1;
    CGFloat green = adhColor.v2;
    CGFloat blue = adhColor.v3;
    CGFloat alpha = adhColor.alpha;
    int redInt = ceilf(255 * red);
    int greenInt = ceilf(255 * green);
    int blueInt = ceilf(255 * blue);
    self.valueLabel.stringValue = [NSString stringWithFormat:@"#%.2X%.2X%.2X %.2f",redInt,greenInt,blueInt,alpha];
}

- (IBAction)colorChanged:(NSColorWell *)colorWell {
    NSColor *color = colorWell.color;
    ADH_COLOR adhColor = adhColorFromNSColor(color);
    NSString *value = [ADHViewDebugUtil stringWithAdhColor:adhColor];
    [self.delegate valueUpdateRequest:self value:value info:nil];
}

+ (CGFloat)heightForData:(NSValue *)colorValue contentWidth:(CGFloat)contentWidth {
    return 36.0f;
}

@end
