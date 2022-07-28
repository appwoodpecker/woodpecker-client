//
//  NSViewController+ADHExtends.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/3/3.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NSViewController+ADHExtends.h"
#import "NSView+ADHHud.h"
#import "MacOrganizer.h"
#import "NSObject+ADHExtends.h"

@implementation NSViewController (ADHExtends)

- (void)showNotConnectToast
{
    [self.view showToastWithIcon:@"icon_notconnected" statusText:@"Not Connected"];
}

- (void)showSuccessWithText: (NSString *)text {
    [self.view showToastWithIcon:@"icon_status_ok" statusText:text];
}

- (void)showErrorWithText: (NSString *)text {
    [self.view showToastWithIcon:@"icon_status_error" statusText:text];
}

- (void)showSuccess {
    [self showSuccessWithText:nil];
}

- (void)showError {
    [self showErrorWithText:nil];
}

- (BOOL)doCheckConnectionRoutine {
    BOOL connected = NO;
    AppContext *context = self.context;
    if(!context.isConnected){
        [self showNotConnectToast];
    }else{
        connected = YES;
    }
    return connected;
}

@end
