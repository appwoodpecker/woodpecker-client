//
//  DeviceManageCell.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/23.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "DeviceManageCell.h"

@interface DeviceManageCell ()

@property (nonatomic, strong) IBOutlet NSTextField *nameTextField;
@property (nonatomic, strong) IBOutlet NSView *lineView;
@property (nonatomic, strong) IBOutlet NSButton *deleteButton;
 
@end

@implementation DeviceManageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.deleteButton.alphaValue = 0.6;
    self.lineView.wantsLayer = YES;
}

- (void)setData:(NSDictionary *)rowData {
    NSDictionary * data = rowData[@"data"];
    NSString *name = data[@"n"];
    if(!name) {
        name = @"";
    }
    NSString *type = data[@"t"];
    NSString *typeText = nil;
    if([type isEqualToString:@"c"]) {
        typeText = @"≈";
    }
    if(typeText) {
        self.nameTextField.stringValue = [NSString stringWithFormat:@"%@ (%@)",name,typeText];
    }else {
        self.nameTextField.stringValue = name;
    }
    [self.deleteButton setTintColor:[Appearance actionImageColor]];
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
}

- (IBAction)deleteButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deviceManageCellDeleteRequest:)]){
        [self.delegate deviceManageCellDeleteRequest:self];
    }
}

@end
