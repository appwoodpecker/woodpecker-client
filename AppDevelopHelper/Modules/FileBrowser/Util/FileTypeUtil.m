//
//  FileTypeUtil.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "FileTypeUtil.h"

@implementation FileTypeUtil

#pragma mark -----------------   interface   ----------------

+ (BOOL)isPlainFileByMimeType: (NSString *)mimeType fileExt: (NSString *)fileExt
{
    BOOL ret = NO;
    if(mimeType.length > 0){
        ret = [FileTypeUtil isPlainFileByMimeType:mimeType];
    }else if(fileExt.length > 0){
        ret = [FileTypeUtil isPlainFileByExt:fileExt];
    }
    return ret;
}

#pragma mark -----------------   UTI   ----------------

+ (BOOL)isPlainFileByUTI: (CFStringRef)UTI
{
    BOOL ret = NO;
    //equal or conform
    CFStringRef plainUTI = (__bridge CFStringRef)@"public.text";
    if(UTTypeConformsTo(UTI, plainUTI)){
        ret = YES;
    }
    if(!ret){
        ret = [FileTypeUtil isPlistByUTI:UTI];
    }
    return ret;
}

+ (BOOL)isPlistByUTI: (CFStringRef)UTI
{
    BOOL ret = NO;
    CFStringRef plistUTI = (__bridge CFStringRef)@"com.apple.property-list";
    if(UTTypeConformsTo(UTI, plistUTI)){
        ret = YES;
    }
    return ret;
}

#pragma mark -----------------   MIME Type  ----------------

+ (BOOL)isPlainFileByMimeType: (NSString *)mimeType
{
    CFStringRef UTI = [FileTypeUtil getUTIByMimeType:mimeType];
    return [FileTypeUtil isPlainFileByUTI:UTI];
}

+ (BOOL)isPlistByMimeType: (NSString *)mimeType
{
    CFStringRef UTI = [FileTypeUtil getUTIByMimeType:mimeType];
    return [FileTypeUtil isPlistByUTI:UTI];
}

//UTI public.json
+ (BOOL)isJsonFileByMimeType: (NSString *)mimeType {
    CFStringRef UTI = [FileTypeUtil getUTIByMimeType:mimeType];
    BOOL ret = NO;
    //equal or conform
    CFStringRef jsonUTI = (__bridge CFStringRef)@"public.json";
    if(UTTypeConformsTo(UTI, jsonUTI)){
        ret = YES;
    }
    if(!ret) {
        if([mimeType isEqualToString:@"text/json"]) {
            ret = YES;
        }
    }
    return ret;
}

#pragma mark -----------------  File EXT   ----------------

+ (BOOL)isPlainFileByExt: (NSString *)fileExt
{
    CFStringRef UTI = [FileTypeUtil getUTIByFileExt:fileExt];
    return [FileTypeUtil isPlainFileByUTI:UTI];
}

+ (BOOL)isPlistByExt: (NSString *)fileExt
{
    CFStringRef UTI = [FileTypeUtil getUTIByFileExt:fileExt];
    return [FileTypeUtil isPlistByUTI:UTI];
}

+ (BOOL)isDBFileByExt: (NSString *)fileExt
{
    NSString * syntaxType = [FileTypeUtil syntaxType:fileExt];
    return [syntaxType isEqualToString:@"database"];
}

//https://sqlite.org/fileformat2.html
+ (BOOL)isDBFileByMetaData: (NSString *)filePath {
    BOOL val = NO;
    if([filePath isKindOfClass:[NSString class]] && filePath.length > 0) {
        NSFileHandle *handler = [NSFileHandle fileHandleForReadingAtPath:filePath];
        if(handler) {
            NSData *data = [handler readDataOfLength:16];
            if(data.length >= 16) {
                //SQLite format 3\000
                NSString *typeText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                if([typeText isKindOfClass:[NSString class]] && [typeText isEqualToString:@"SQLite format 3\000"]) {
                    val = YES;
                }
            }
        }
    }
    return val;
}

#pragma mark -----------------   plain syntax  ----------------

+ (NSArray *)fileTypeDefinitions
{
    return @[
             @{
                 @"syntax" : @"json",
                 @"ext" : @[@"json"],
                 },
             @{
                 @"syntax" : @"xml",
                 @"ext" : @[@"xml",@"dtd",@"xsd",@"xsl"],
                 },
             @{
                 @"syntax" : @"plist",
                 @"ext" : @[@"plist"],
                 },
             @{
                 @"syntax" : @"javascript",
                 @"ext" : @[@"js"],
                 },
             @{
                 @"syntax" : @"css",
                 @"ext" : @[@"css"],
                 },
             @{
                 @"syntax" : @"html",
                 @"ext" : @[@"html",@"htm",@"xhtml", @"shtml",@"shtm"],
                 },
             @{
                 @"syntax" : @"database",
                 @"ext" : @[@"db",@"sqlite",@"database"],
                 },
             ];
}

+ (NSString *)syntaxType: (NSString *)fileExt
{
    NSString * syntaxType = nil;
    NSArray * fileTypes = [FileTypeUtil fileTypeDefinitions];
    fileExt = [fileExt uppercaseString];
    for (NSDictionary * data in fileTypes) {
        NSArray * extList = data[@"ext"];
        for (NSString * ext in extList) {
            NSString * upperCaseExt = [ext uppercaseString];
            if([upperCaseExt isEqualToString:fileExt]){
                syntaxType = data[@"syntax"];
                break;
            }
        }
    }
    return syntaxType;
}

#pragma mark -----------------   UTI   ----------------

//UTI  /System/Library/CoreServices/CoreTypes.bundle/Contents/Info.plist
+ (CFStringRef)getUTIByFileExt: (NSString *) fileExt {
    if(!fileExt) return nil;
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) fileExt, NULL);
    return UTI;
}

+ (CFStringRef)getUTIByMimeType: (NSString *)mimeType
{
    if(!mimeType) return nil;
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef) mimeType, NULL);
    return UTI;
}

/*
+ (void)load {
    NSString *mime = @"application/json";
    BOOL isPlain = [FileTypeUtil isPlainFileByMimeType:mime];
    BOOL isJson = [FileTypeUtil isJsonFileByMimeType:mime];
    mime = @"text/json";
    isPlain = [FileTypeUtil isPlainFileByMimeType:mime];
    isJson = [FileTypeUtil isJsonFileByMimeType:mime];
}*/




@end














