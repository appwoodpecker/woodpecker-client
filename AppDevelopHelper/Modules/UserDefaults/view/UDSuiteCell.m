//
//  UDSuiteCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/10.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "UDSuiteCell.h"

@interface UDSuiteCell ()

@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSView *deleteLayout;
@property (weak) IBOutlet NSButton *deleteButton;
@property (weak) IBOutlet NSImageView *deleteIcon;
@property (weak) IBOutlet NSImageView *checkIcon;
@property (weak) IBOutlet NSView *lineView;



@end

@implementation UDSuiteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.deleteIcon.alphaValue = 0.6;
    self.lineView.wantsLayer = YES;
}

- (void)setData:(id)data {
    NSString *title = data[@"title"];
    if([title isEqualToString:@"standard"]) {
        title = @"standard (default)";
    }
    BOOL fix = [data[@"fix"] boolValue];
    self.titleLabel.stringValue = title;
    self.deleteLayout.hidden = fix;
    [self.deleteIcon setTintColor:[Appearance actionImageColor]];
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
}

- (void)setSelected: (BOOL)selected {
    self.checkIcon.hidden = !selected;
}

- (IBAction)deleteButtonPressed:(id)sender {
    id<UDSuiteCellDelegate> delegate = (id<UDSuiteCellDelegate>)self.delegate;
    if(delegate && [delegate respondsToSelector:@selector(suiteCellDeleteRequest:)]){
        [delegate suiteCellDeleteRequest:self];
    }
}


@end
