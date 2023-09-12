//
//  ADHRemoteServiceCell.m
//  ADHClient
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHRemoteServiceCell.h"
#import "ADHRemoteServiceItem.h"

static CGFloat const kPaddingY = 30.0f;
static CGFloat const kPaddingX = 20.0f;
static CGFloat const kTitlePaddingRight = 107.0f;

@interface ADHRemoteServiceCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *connectSwitch;
@property (weak, nonatomic) IBOutlet UILabel *disallowLabel;


@end

@implementation ADHRemoteServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.connectSwitch.onTintColor = [self themeColor];
    self.connectSwitch.on = NO;
    self.disallowLabel.textColor = [self themeColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat textWidth = [ADHRemoteServiceCell getTextWidth];
    CGFloat height = CGRectGetHeight(self.contentView.bounds);
    self.titleLabel.frame = CGRectMake(kPaddingX, kPaddingY, textWidth, height-2*kPaddingY);
    CGRect switchFrame = self.connectSwitch.frame;
    switchFrame.origin.y = (height - switchFrame.size.height)/2.0f;
    self.connectSwitch.frame = switchFrame;
    CGRect disallowFrame = self.disallowLabel.frame;
    disallowFrame.origin.y = (height - disallowFrame.size.height)/2.0f;
    self.disallowLabel.frame = disallowFrame;
}

- (void)setData: (ADHRemoteServiceItem *)item {
    ADHRemoteServiceStatus status = item.connectStatus;
    UIColor *textColor = nil;
    if(status == ADHRemoteServiceStatusUnConnect){
        self.connectSwitch.on = NO;
        textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    }else if(status == ADHRemoteServiceStatusConnecting){
        textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    }else if(status == ADHRemoteServiceStatusConnected){
        self.connectSwitch.on = YES;
        textColor = [UIColor whiteColor];
    }
    self.titleLabel.textColor = textColor;
    NSString *name = item.name;
    if (item.simulator) {
        name = [NSString stringWithFormat:@"%@ (Simulator)",name];
    } else if (item.usb) {
        name = [NSString stringWithFormat:@"%@ (USB)",name];
    }
    self.titleLabel.text = [NSString stringWithFormat:@"%@",name];
    self.connectSwitch.hidden = NO;
    self.disallowLabel.hidden = YES;
}

+ (CGFloat)getTextWidth {
    CGFloat containerWidth = [UIScreen mainScreen].bounds.size.width - 16.0f*2;
    CGFloat textWidth = containerWidth - kPaddingX - kTitlePaddingRight;
    return textWidth;
}

+ (CGFloat)heightForData: (ADHRemoteServiceItem *)item {
    CGFloat textWidth = [ADHRemoteServiceCell getTextWidth];
    NSString *text = [NSString stringWithFormat:@"%@",item.name];
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:19.0],
                            };
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    CGFloat height = textSize.height + kPaddingY*2 + 1;
    return height;
}

- (IBAction)switchValueChanged:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(adhRemoteServiceCellActionRequest:)]){
        [self.delegate adhRemoteServiceCellActionRequest:self];
    }
}

- (UIColor *)themeColor {
    return [UIColor colorWithRed:0x25/255.0f green:0xA2/255.0 blue:0x61/255.0f alpha:1];
}

#pragma mark -----------------   util   ----------------

- (UIColor *)colorWithHex: (NSInteger)value {
    return [self colorWithHex:value alpha:1.0f];
}

- (UIColor *)colorWithHex: (NSInteger)value alpha: (float)alpha{
    NSInteger red = (0xFF0000 & value) >> 16;
    NSInteger green = (0x00FF00 & value) >> 8;
    NSInteger blue = 0x0000FF & value;
    UIColor *color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
    return color;
}


@end














