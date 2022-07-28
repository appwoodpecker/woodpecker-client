//
//  ADHLogUtil.m
//  ADHClient
//
//  Created by 张小刚 on 2018/5/13.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHLogUtil.h"

void adhConsoleLog(NSString *format, ...) {
    va_list ap;
    // Initialize a variable argument list.
    va_start (ap, format);
    NSString * text = [[NSString alloc] initWithFormat:format arguments:ap];
    // End using variable argument list.
    va_end (ap);
    NSString *prefix = @"[🌿Woodpecker]: ";
    NSString *content = [NSString stringWithFormat:@"%@%@",prefix,text];
    const char * cString = [content UTF8String];
    printf("%s\n",cString);
}



void adhDebugLog(NSString *format, ...) {
#warning 发布上线前注释
    /*
    //do nothing
    va_list ap;
    // Initialize a variable argument list.
    va_start (ap, format);
    NSString * text = [[NSString alloc] initWithFormat:format arguments:ap];
    // End using variable argument list.
    va_end (ap);
    adhConsoleLog(text);
     */
}
