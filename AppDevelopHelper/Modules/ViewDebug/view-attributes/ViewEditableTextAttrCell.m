//
//  ViewEditableTextAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/26.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewEditableTextAttrCell.h"

@interface ViewEditableTextAttrCell ()<NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *valueTextfield;

@end

@implementation ViewEditableTextAttrCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.valueTextfield.maximumNumberOfLines = 5;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEdit:) name:NSControlTextDidEndEditingNotification object:self.valueTextfield];
}

- (void)setData: (NSString *)value contentWidth: (CGFloat)contentWidth {
    if(!value) {
        value = @"";
    }
    self.valueTextfield.stringValue = value;
    CGFloat textWidth = [ViewEditableTextAttrCell getTextWidth:contentWidth];
    CGSize textSize = [self.valueTextfield sizeThatFits:NSMakeSize(textWidth, CGFLOAT_MAX)];
    self.valueTextfield.size = NSMakeSize(textWidth, textSize.height);
    CGFloat height = textSize.height + 6*2;
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
    CGFloat textWidth = contentWidth - 6 - 6;
    return textWidth;
}

+ (CGFloat)heightForData: (NSString *)value contentWidth: (CGFloat)contentWidth {
    static ViewEditableTextAttrCell *templateCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:@"ViewEditableTextAttrCell" owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[ViewEditableTextAttrCell class]]){
                templateCell = object;
                break;
            }
        }
    });
    [templateCell setData:value contentWidth:contentWidth];
    CGFloat height = templateCell.height;
    return height;
}

- (void)textDidEndEdit: (NSNotification *)notification {
    NSString *value = self.valueTextfield.stringValue;
    if(!value) {
        value = adhvf_const_emptystr();
    }
    [self.delegate valueUpdateRequest:self value:value info:nil];
}

@end
