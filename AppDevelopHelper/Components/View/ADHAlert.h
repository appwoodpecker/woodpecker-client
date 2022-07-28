//
//  ADHAlert.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/8/4.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ADHAlert : NSObject

+ (void)alertWithMessage: (NSString*)message
                infoText: (NSString *)infoText
            comfirmBlock: (void (^)(void))confirmBlock
             cancelBlock: (void (^)(void))cancelBlock;

+ (void)alertWithMessage: (NSString*)message
                infoText: (NSString *)infoText
             confirmText: (NSString *)confirmText
              cancelText: (NSString *)cancelText
            comfirmBlock: (void (^)(void))confirmBlock
             cancelBlock: (void (^)(void))cancelBlock;

+ (void)alertWithMessage: (NSString*)message
                infoText: (NSString *)infoText
            comfirmBlock: (void (^)(void))confirmBlock;




@end
