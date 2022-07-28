//
//  ViewStepperAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/3.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewStepperAttributeCell.h"

@interface ViewStepperAttributeCell()

@property (weak) IBOutlet NSTextField *valueTextfield;
@property (weak) IBOutlet NSStepper *stepper;

@end

@implementation ViewStepperAttributeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stepper.continuous = YES;
    self.stepper.autorepeat = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEdit:) name:NSControlTextDidEndEditingNotification object:self.valueTextfield];
}

- (void)setData:(NSDictionary *)data contentWidth:(CGFloat)contentWidth {
    double min = [data[@"min"] doubleValue];
    double max = [data[@"max"] doubleValue];
    double step = [data[@"step"] doubleValue];
    float value = [data[@"value"] doubleValue];
    self.stepper.minValue = min;
    self.stepper.maxValue = max;
    self.stepper.increment = step;
    self.stepper.doubleValue = value;
    [self updateTextValueUI];
}

- (void)updateTextValueUI {
    float value = self.stepper.doubleValue;
    if(self.stepper.maxValue < 1) {
        // (max < 1)时，支持小数点2位
        self.valueTextfield.stringValue = [NSString stringWithFormat:@"%.2f",value];
    }else {
        self.valueTextfield.stringValue = [NSString stringWithFormat:@"%.1f",value];
    }
}

- (IBAction)stepperValueChanged:(id)sender {
    [self updateTextValueUI];
    [self onValueUpdate];
}

- (void)textDidEndEdit: (NSNotification *)noti {
    float value = [self.valueTextfield.stringValue doubleValue];
    value = MAX(self.stepper.minValue, value);
    value = MIN(self.stepper.maxValue, value);
    self.stepper.doubleValue = value;
    [self updateTextValueUI];
    [self onValueUpdate];
}

- (void)onValueUpdate {
    [self.delegate valueUpdateRequest:self value:[NSNumber numberWithFloat:self.stepper.doubleValue] info:nil];
}

+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 32.0f;
}

@end
