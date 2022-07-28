//
//  FSFileItem.h
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHFileItem : NSObject

@property (nonatomic, strong) NSString *    name;
@property (nonatomic, strong) NSString *    path;
@property (nonatomic, assign) BOOL          isDir;
@property (nonatomic, assign) int32_t       level;
@property (nonatomic, strong) NSArray *     subItems;
@property (nonatomic, strong) NSString *    md5Value;
@property (nonatomic, assign) NSTimeInterval updateTime;
@property (nonatomic, assign) int32_t       fileSize;
//
@property (nonatomic, weak) ADHFileItem *   parent;

- (NSDictionary *)dicPresentation;
+ (ADHFileItem *)itemWithDic: (NSDictionary *)dic;

- (ADHFileItem *)dumpCopy;

@end
