//
//  ADHMacRemoteServiceCell.m
//  WoodpeckerMacOS
//
//  Created by 张小刚 on 2019/5/25.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHMacRemoteServiceCell.h"

@interface ADHMacRemoteServiceCell ()

@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSButton *connectSwitch;

@end

@implementation ADHMacRemoteServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.connectSwitch.image = [self offImage];
    self.connectSwitch.alternateImage = [self onImage];
}

- (void)setData: (ADHRemoteServiceItem *)item {
    ADHRemoteServiceStatus status = item.connectStatus;
    NSColor *textColor = nil;
    if(status == ADHRemoteServiceStatusUnConnect){
        self.connectSwitch.state = NSControlStateValueOff;
        textColor = [NSColor secondaryLabelColor];
        self.connectSwitch.image = [self offImage];
    }else if(status == ADHRemoteServiceStatusConnecting){
        textColor = [NSColor secondaryLabelColor];
    }else if(status == ADHRemoteServiceStatusConnected){
        self.connectSwitch.state = NSControlStateValueOn;
        textColor = [NSColor labelColor];
        self.connectSwitch.image = [self onImage];
    }
    self.titleLabel.textColor = textColor;
    self.titleLabel.stringValue = [NSString stringWithFormat:@"%@",item.name];
}

- (NSImage *)offImage {
    NSBundle *bundle = [[ADHMacClientOrganizer sharedOrganizer] adhBundle];
    NSImage *offImage = [bundle imageForResource:@"switch_off"];
    return offImage;
}

- (NSImage *)onImage {
    NSBundle *bundle = [[ADHMacClientOrganizer sharedOrganizer] adhBundle];
    NSImage *onImage = [bundle imageForResource:@"switch_on"];
    return onImage;
}

- (IBAction)connectButtonClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(adhMacRemoteServiceCellActionRequest:)]){
        [self.delegate adhMacRemoteServiceCellActionRequest:self];
    }
}

@end
