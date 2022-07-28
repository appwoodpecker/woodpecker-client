//
//  ADHClickTextField.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/6/21.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ADHClickTextFieldDelegate;
@interface ADHClickTextField : NSTextField

@property (nonatomic, weak) id<ADHClickTextFieldDelegate> adhDelegate;
- (void)setEditState: (BOOL)edit;

@end

@protocol ADHClickTextFieldDelegate <NSObject>

- (void)clickTextFieldTextChanged: (ADHClickTextField *)textField;

@end

