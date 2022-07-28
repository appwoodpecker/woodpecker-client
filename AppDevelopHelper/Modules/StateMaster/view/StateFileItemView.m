//
//  StateFileItemView.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/29.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "StateFileItemView.h"
#import "ADHFileNode.h"

@interface StateFileItemView ()

@property (weak) IBOutlet NSImageView *fileIcon;
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSTextField *contentTextfield;

@end

@implementation StateFileItemView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setEditState:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEdit:) name:NSControlTextDidEndEditingNotification object:self.contentTextfield];
}

- (void)setData:(ADHFileNode *)item {
    self.nameLabel.stringValue = item.name;
    if(item.isDir){
        NSString *fileExt = [item.name pathExtension];
        NSImage *icon = nil;
        if(fileExt.length > 0) {
            icon = [[NSWorkspace sharedWorkspace] iconForFileType:fileExt];
        }
        if(!icon) {
            icon = [NSImage imageNamed:NSImageNameFolder];
        }
        self.fileIcon.image = icon;
    }else {
        NSString *fileExt = [item.name pathExtension];
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:fileExt];
        if(icon) {
            self.fileIcon.image = icon;
        }else {
            self.fileIcon.image = [NSImage imageNamed:@"icon_file"];
            if([Appearance isDark]) {
                [self.fileIcon setTintColor:[Appearance actionImageColor]];
            }
        }
    }
}

- (void)setEditState: (BOOL)edit {
    if(!edit){
        self.contentTextfield.hidden = YES;
        self.nameLabel.hidden = NO;
    }else{
        self.contentTextfield.hidden = NO;
        self.nameLabel.hidden = YES;
        self.contentTextfield.stringValue = self.nameLabel.stringValue;
        [self.contentTextfield becomeFirstResponder];
    }
}

- (void)textFieldDidEndEdit: (NSNotification *)notification {
    [self setEditState:NO];
    NSString * newValue = self.contentTextfield.stringValue;
    BOOL updated = ![newValue isEqualToString:self.nameLabel.stringValue];
    if(updated){
        if(self.delegate && [self.delegate respondsToSelector:@selector(stateItemView:contentUpdateRequest:)]){
            [(id<StateFileItemViewDelegate>)(self.delegate) stateItemView:self contentUpdateRequest:newValue];
        }
    }
}


@end

