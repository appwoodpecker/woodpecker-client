//
//  ViewSliderAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/3.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewSliderAttributeCell.h"

@interface ViewSliderAttributeCell () <NSTextFieldDelegate>

@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSTextField *valueTextfield;

@end

@implementation ViewSliderAttributeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.slider.continuous = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEdit:) name:NSControlTextDidEndEditingNotification object:self.valueTextfield];
}

- (void)setData:(NSDictionary *)data contentWidth:(CGFloat)contentWidth {
    float min = [data[@"min"] floatValue];
    float max = [data[@"max"] floatValue];
    float value = [data[@"value"] floatValue];
    self.slider.minValue = min;
    self.slider.maxValue = max;
    self.slider.floatValue = value;
    [self updateTextValueUI];
}

- (void)updateTextValueUI {
    float value = self.slider.floatValue;
    if(self.slider.maxValue < 10) {
        // (max < 10)时，支持小数点2位
        self.valueTextfield.stringValue = [NSString stringWithFormat:@"%.2f",value];
    }else {
        self.valueTextfield.stringValue = [NSString stringWithFormat:@"%.1f",value];
    }
}

- (IBAction)slideValueUpdate:(id)sender {
    [self updateTextValueUI];
    [self onValueUpdate];
}

- (void)textDidEndEdit: (NSNotification *)noti {
    float value = [self.valueTextfield.stringValue floatValue];
    value = MAX(self.slider.minValue, value);
    value = MIN(self.slider.maxValue, value);
    self.slider.floatValue = value;
    [self updateTextValueUI];
    [self onValueUpdate];
}

- (void)onValueUpdate {
    [self.delegate valueUpdateRequest:self value:[NSNumber numberWithFloat:self.slider.floatValue] info:nil];
}

+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 32.0f;
}

@end
