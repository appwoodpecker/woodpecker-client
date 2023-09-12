//
//  EncryptUtil.m
//  Magapp
//
//  Created by 张小刚 on 15/7/27.
//  Copyright (c) 2015年 DuoHuo Network Technology. All rights reserved.
//

#import "ADHEncryptUtil.h"
#import "ADHAESCrypt.h"

static NSString * kEncryptKey = @"pleasedogood";

@implementation ADHEncryptUtil

+ (NSString *)encryptContent: (NSString *)content
{
    return [ADHAESCrypt encrypt:content password:kEncryptKey];
}

+ (NSString *)decryptContent: (NSString *)content
{
    return [ADHAESCrypt decrypt:content password:kEncryptKey];
}

@end
