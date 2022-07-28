//
//  NSViewController+ADHExtends.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/3/3.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppContext;
@interface NSViewController (ADHExtends)

- (void)showNotConnectToast;
- (void)showSuccessWithText: (NSString *)text;
- (void)showErrorWithText: (NSString *)text;
- (void)showSuccess;
- (void)showError;
- (BOOL)doCheckConnectionRoutine;

@end
