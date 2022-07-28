//
//  ADHAlert.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/8/4.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ADHAlert.h"

@implementation ADHAlert

+ (void)alertWithMessage: (NSString*)message
                infoText: (NSString *)infoText
            comfirmBlock: (void (^)(void))confirmBlock
             cancelBlock: (void (^)(void))cancelBlock
{
    [ADHAlert alertWithMessage:message infoText:infoText confirmText:kAppLocalized(@"Confirm") cancelText:kAppLocalized(@"Cancel") comfirmBlock:confirmBlock cancelBlock:cancelBlock];
}

+ (void)alertWithMessage: (NSString*)message
                infoText: (NSString *)infoText
             confirmText: (NSString *)confirmText
              cancelText: (NSString *)cancelText
            comfirmBlock: (void (^)(void))confirmBlock
             cancelBlock: (void (^)(void))cancelBlock
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    alert.informativeText = infoText;
    [alert addButtonWithTitle:confirmText];
    [alert addButtonWithTitle:cancelText];
    NSModalResponse response = [alert runModal];
    if(response == NSAlertFirstButtonReturn) {
        if(confirmBlock) {
            confirmBlock();
        }
    }else if(response == NSAlertSecondButtonReturn) {
        if(cancelBlock) {
            cancelBlock();
        }
    }
}

+ (void)alertWithMessage: (NSString*)message
                infoText: (NSString *)infoText
            comfirmBlock: (void (^)(void))confirmBlock {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    alert.informativeText = infoText;
    [alert addButtonWithTitle:kAppLocalized(@"Confirm")];
    NSModalResponse response = [alert runModal];
    if(response == NSAlertFirstButtonReturn) {
        if(confirmBlock) {
            confirmBlock();
        }
    }
}

@end
