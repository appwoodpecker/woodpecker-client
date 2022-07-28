//
//  FSPreviewItem.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/21.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHFileItem.h"

extern NSTimeInterval const kADHFilePreviewItemMinInterval;

@interface ADHFilePreviewItem : NSObject

//local mac file item
@property (nonatomic, strong) ADHFileItem * localFileItem;
//remote app file item
@property (nonatomic, strong) ADHFileItem * fileItem;

@property (nonatomic, strong) NSArray * subItems;

@property (nonatomic, assign) BOOL localExists;
@property (nonatomic, assign) BOOL remoteExists;


@property (nonatomic, weak) ADHFilePreviewItem * parent;
@property (nonatomic, strong) NSArray * filteredSubItems;

- (ADHFileItem *)viewFileItem;

- (BOOL)isDir;

- (BOOL)bothExists;

- (BOOL)needSync;
- (BOOL)localNeedSync;
- (BOOL)remoteNeedSync;

- (BOOL)isWell;

//file preview
- (NSString *)fileExtension;
- (NSString *)localFilePath;

- (NSInteger)level;

@end









