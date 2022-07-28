//
//  FontAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/11.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewFontAttributeCell.h"
#import "ViewFontViewController.h"

@interface ViewFontAttributeCell ()

@property (weak) IBOutlet NSTextField *valueTextfield;
@property (weak) IBOutlet NSStepper *stepper;
@property (nonatomic, strong) ADHFont *font;
@property (nonatomic, strong) ViewFontViewController *fontVC;

@end

@implementation ViewFontAttributeCell

/**
 * size
 * fontName
 */
- (void)setData:(ADHFont *)font contentWidth:(CGFloat)contentWidth {
    self.font = font;
    if(self.font.fontName) {
        [self updateUI];
    }else {
        self.valueTextfield.stringValue = @"";
    }
    self.stepper.integerValue = self.font.fontSize;
}

- (void)updateUI {
    ADHFont *font = self.font;
    self.valueTextfield.stringValue = [NSString stringWithFormat:@"%@ %zd",font.fontName,font.fontSize];
}

- (IBAction)fontButtonPressed:(id)sender {
    ViewFontViewController *fontVC = [[ViewFontViewController alloc] init];
    fontVC.fontName = self.font.fontName;
    fontVC.fontSize = self.font.fontSize;
    NSViewController *contextVC = self.contextVC;
    fontVC.context = contextVC.context;
    [contextVC presentViewController:fontVC asPopoverRelativeToRect:self.bounds ofView:self preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorSemitransient];
    __weak typeof(self) wself = self;
    [fontVC setCompletionBlock:^(NSString * _Nonnull fontName, NSInteger fontSize) {
        wself.font = [ADHFont fontWithName:fontName size:fontSize];
        [wself updateUI];
        [wself onValueUpdate];
        if(wself.fontVC) {
            [wself.contextVC dismissViewController:wself.fontVC];
            wself.fontVC = nil;
        }
    }];
    self.fontVC = fontVC;
}

- (IBAction)stepperValueChanged:(id)sender {
    NSInteger fontSize = self.stepper.integerValue;
    self.font.fontSize = fontSize;
    [self updateUI];
    [self onValueUpdate];
}

- (void)onValueUpdate {
    NSString *value = [self.font stringValue];
    [self.delegate valueUpdateRequest:self value:value info:nil];
}

+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 32.0f;
}

@end
