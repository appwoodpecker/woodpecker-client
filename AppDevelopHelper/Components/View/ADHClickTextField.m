//
//  ADHClickTextField.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/6/21.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHClickTextField.h"

@implementation ADHClickTextField

- (void)setEditState: (BOOL)edit {
    self.selectable = edit;
    self.editable = edit;
}

- (void)mouseDown:(NSEvent *)event {
    if(!self.isEditable && event.clickCount == 2) {
        [self setEditState:YES];
        [self.window makeFirstResponder:self];
    }else {
        [super mouseDown:event];
    }
}

- (void)textDidEndEditing:(NSNotification *)notification {
    //需要访问一下textfield.stringValue
    if(self.adhDelegate && [self.adhDelegate respondsToSelector:@selector(clickTextFieldTextChanged:)]){
        [self.adhDelegate clickTextFieldTextChanged:self];
    }
    // resign first responder and hide the field editor
    [self.window endEditingFor:self];
    // configure textfield for non editable state
    [self setEditState:NO];
}


@end
