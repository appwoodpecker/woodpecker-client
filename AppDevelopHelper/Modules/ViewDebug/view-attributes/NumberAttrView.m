//
//  NumberAttrView.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "NumberAttrView.h"

@interface NumberAttrView ()

@property (weak) IBOutlet NSTextField *valueTextfield;
@property (weak) IBOutlet NSStepper *stepper;
@property (weak) IBOutlet NSTextField *titleLabel;

@end

@implementation NumberAttrView

+ (NumberAttrView *)make {
    NumberAttrView *instanceView = nil;
    NSArray * topObjects = nil;
    [[NSBundle mainBundle] loadNibNamed:@"NumberAttrView" owner:nil topLevelObjects:&topObjects];
    for(id object in topObjects){
        if([object isKindOfClass:[NumberAttrView class]]){
            instanceView = object;
            break;
        }
    }
    return instanceView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stepper.increment = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEdit:) name:NSControlTextDidEndEditingNotification object:self.valueTextfield];
}

- (void)setName: (NSString *)name {
    self.titleLabel.stringValue = name;
}

- (void)setValue: (float)value {
    self.valueTextfield.stringValue = [NSString stringWithFormat:@"%.1f",value];
    self.stepper.floatValue = value;
}

- (float)value {
    return self.stepper.floatValue;
}

- (void)setMin: (float)min max: (float)max {
    self.stepper.minValue = (double)min;
    self.stepper.maxValue = (double)max;
}

- (IBAction)stepperValueChanged:(id)sender {
    float value = self.stepper.floatValue;
    self.valueTextfield.stringValue = [NSString stringWithFormat:@"%.1f",value];
    [self onValueUpdate:value];
}

- (void)textDidEndEdit: (NSNotification *)noti {
    NSString *text = self.valueTextfield.stringValue;
    float value = [text floatValue];
    value = MAX(self.stepper.minValue, value);
    value = MIN(self.stepper.maxValue, value);
    self.stepper.floatValue = value;
    [self onValueUpdate:value];
}

- (void)onValueUpdate: (float)value {
    [self.delegate numberAttrValueUpdate:self value:value];
}


@end
