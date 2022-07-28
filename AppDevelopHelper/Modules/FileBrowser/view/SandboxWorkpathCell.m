//
//  SandboxWorkpathCell.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/6/1.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "SandboxWorkpathCell.h"

@interface SandboxWorkpathCell ()

@property (weak) IBOutlet NSTextField *bundleIdLabel;
@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSView *deleteLayout;
@property (weak) IBOutlet NSTextField *tipLabel;
@property (weak) IBOutlet NSView *lineView;

@end

@implementation SandboxWorkpathCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineView.wantsLayer = YES;
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
}

- (void)setData: (SandboxWorkpathItem *)item {
    self.bundleIdLabel.stringValue = adhvf_safestringfy(item.bundleId);
    if(item.path.length > 0) {
        self.pathControl.hidden = NO;
        self.tipLabel.hidden = YES;
        self.deleteLayout.hidden = NO;
        NSURL *fileURL = [NSURL fileURLWithPath:item.path];
        [self.pathControl setURL:fileURL];
    }else {
        self.pathControl.hidden = YES;
        self.tipLabel.hidden = NO;
        self.deleteLayout.hidden = YES;
    }
}

- (IBAction)deleteButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(workpathCellDelete:)]){
        [self.delegate workpathCellDelete:self];
    }
}

- (IBAction)folderButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(workpathCellPathSetup:)]){
        [self.delegate workpathCellPathSetup:self];
    }
}


@end
