//
//  LocalizationSelectionCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/21.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "LocalizationSelectionCell.h"

@interface LocalizationSelectionCell ()

@property (weak) IBOutlet NSButton *selectionButton;


@end

@implementation LocalizationSelectionCell

- (void)setData:(id)data {
    
}

- (void)setSelectionState: (BOOL)selected {
    self.selectionButton.state = selected?NSControlStateValueOn:NSControlStateValueOff;
}

- (IBAction)selectionButtonPressed:(id)sender {
    id<LocalizationSelectionCellDelegate> delegate = (id<LocalizationSelectionCellDelegate>)(self.delegate);
    if(delegate && [delegate respondsToSelector:@selector(selectionCell:selectionStateUpdate:)]){
        [delegate selectionCell:self selectionStateUpdate:self.selectionButton.state];
    }
}

@end
