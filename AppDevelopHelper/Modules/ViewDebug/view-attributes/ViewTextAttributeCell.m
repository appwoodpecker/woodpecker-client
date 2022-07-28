//
//  ViewTextAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewTextAttributeCell.h"

@interface ViewTextAttributeCell ()

@property (weak) IBOutlet NSTextField *valueTextfield;

@end

@implementation ViewTextAttributeCell

- (void)setData: (NSString *)value contentWidth: (CGFloat)contentWidth {
    self.valueTextfield.stringValue = adhvf_safestringfy(value);
    CGFloat textWidth = [ViewTextAttributeCell getTextWidth:contentWidth];
    CGSize textSize = [self.valueTextfield sizeThatFits:NSMakeSize(textWidth, CGFLOAT_MAX)];
    textSize.width = ceil(textSize.width);
    textSize.height = ceil(textSize.height);
    self.valueTextfield.size = textSize;
    CGFloat height = textSize.height + 4*2;
    if(height < 24.0f) {
        height = 24.0f;
    }
    self.height = height;
    [self layoutContent];
}

- (void)layout {
    [super layout];
    [self layoutContent];
}

- (void)layoutContent {
    CGFloat height = self.height;
    CGFloat textHeight = self.valueTextfield.height;
    self.valueTextfield.top = (height - textHeight)/2.0f;
}

+ (CGFloat)getTextWidth: (CGFloat)contentWidth {
    CGFloat textWidth = contentWidth - 6 - 8;
    return textWidth;
}

+ (CGFloat)heightForData: (NSString *)value contentWidth: (CGFloat)contentWidth {
    static ViewTextAttributeCell *templateCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:@"ViewTextAttributeCell" owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[ViewTextAttributeCell class]]){
                templateCell = object;
                break;
            }
        }
    });
    [templateCell setData:value contentWidth:contentWidth];
    CGFloat height = templateCell.height;
    return height;
}


@end
