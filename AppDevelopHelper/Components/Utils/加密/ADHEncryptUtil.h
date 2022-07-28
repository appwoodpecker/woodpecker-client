//
//  EncryptUtil.h
//  Magapp
//
//  Created by Woodpecker on 15/7/27.
//  Copyright (c) 2015年 woodpecker All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHEncryptUtil : NSObject

+ (NSString *)encryptContent: (NSString *)content;
+ (NSString *)decryptContent: (NSString *)content;

@end
