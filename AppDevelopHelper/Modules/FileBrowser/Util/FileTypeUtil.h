//
//  FileTypeUtil.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileTypeUtil : NSObject

+ (BOOL)isDBFileByMetaData: (NSString *)filePath;
+ (BOOL)isDBFileByExt: (NSString *)fileExt;
+ (BOOL)isPlainFileByExt: (NSString *)fileExt;

+ (BOOL)isPlainFileByMimeType: (NSString *)mimeType;

+ (BOOL)isPlainFileByMimeType: (NSString *)mimeType fileExt: (NSString *)fileExt;

+ (BOOL)isJsonFileByMimeType: (NSString *)mimeType;

+ (NSString *)syntaxType: (NSString *)fileExt;

@end
