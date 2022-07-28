//
//  ViewValueAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/10.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewValueAttributeCell.h"

@interface ViewValueAttributeCell ()

@property (weak) IBOutlet NSTextField *valueTextfield;
@property (nonatomic, strong) NSDictionary *data;
@property (weak) IBOutlet NSStepper *stepper;
@property (nonatomic, assign) BOOL stepperEnabled;
@property (nonatomic, assign) ADHAttrValueFormat format;

@end

@implementation ViewValueAttributeCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.stepper.continuous = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEdit:) name:NSControlTextDidEndEditingNotification object:self.valueTextfield];

}

/**
 * value
 * format : ADHAttrValueFormat
 * stepper : @(YES)
 * step : 0.1
 * min : 0
 * max : 1
 */
- (void)setData:(id)data contentWidth:(CGFloat)contentWidth {
    self.data = data;
    BOOL stepperEnabled = YES;
    if(data[@"stepper"]) {
        stepperEnabled = [data[@"stepper"] boolValue];
    }
    self.stepperEnabled = stepperEnabled;
    CGFloat width = MAX(self.width, contentWidth);
    if(stepperEnabled) {
        self.valueTextfield.width = width - 6 - 30.0f;
        self.stepper.hidden = NO;
        double step = [data[@"step"] doubleValue];
        self.stepper.increment = step;
        if(data[@"min"]) {
            double min = [data[@"min"] doubleValue];
            self.stepper.minValue = min;
        }else {
            self.stepper.minValue = NSIntegerMin;
        }
        if(data[@"max"]) {
            double max = [data[@"max"] doubleValue];
            self.stepper.maxValue = max;
        }else {
            self.stepper.maxValue = DBL_MAX;
        }
    }else {
        self.valueTextfield.width = width - 6 - 8.0f;
        self.stepper.hidden = YES;
    }
    ADHAttrValueFormat format = [data[@"format"] integerValue];
    self.format = format;
    double value = [data[@"value"] doubleValue];
    self.stepper.doubleValue = value;
    [self updateUI:value];
}

- (void)updateUI: (double)value {
    if(self.data[@"min"]) {
        double minValue = [self.data[@"min"] doubleValue];
        value = MAX(minValue, value);
    }
    if(self.data[@"max"]) {
        double maxValue = [self.data[@"max"] doubleValue];
        value = MIN(maxValue, value);
    }
    if(self.format == ADHAttrValueFormatInt) {
        self.valueTextfield.stringValue = [NSString stringWithFormat:@"%.f",value];
    }else if(self.format == ADHAttrValueFormatFloat2) {
        self.valueTextfield.stringValue = [NSString stringWithFormat:@"%.2f",value];
    }else {
        self.valueTextfield.stringValue = [NSString stringWithFormat:@"%.1f",value];
    }
    if(self.stepperEnabled) {
        self.stepper.doubleValue = value;
    }
}

- (IBAction)stepperValueChanged:(id)sender {
    double value = [self.stepper doubleValue];
    [self updateUI:value];
    [self onValueUpdate];
}

- (void)textDidEndEdit: (NSNotification *)noti {
    NSString *text = self.valueTextfield.stringValue;
    double value = [text doubleValue];
    if(self.stepperEnabled) {
        value = MAX(self.stepper.minValue, value);
        value = MIN(self.stepper.maxValue, value);
    }
    [self updateUI:value];
    [self onValueUpdate];
}

- (void)onValueUpdate {
    [self.delegate valueUpdateRequest:self value:[NSNumber numberWithDouble:self.stepper.doubleValue] info:nil];
}


+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 32.0f;
}

@end
