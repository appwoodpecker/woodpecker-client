//
//  NSData+Compress.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/5/31.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Compress)
//unzip
- (NSData *)gzipInflate;
- (NSData *)gzipDeflate;
- (NSData *)zlibInflate;
- (NSData *)zlibDeflate;

- (NSData *)inflateWithEncodeName:(NSString *)name;
//async, result on main thread
- (void)inflateWithEncodeName: (NSString *)name onFinish: (void(^)(NSData *data))finishBlock;

@end
