//
//  ADHCloudItem.h
//  ADHClient
//
//  Created by 张小刚 on 2019/9/15.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ADHCloudItemStatus) {
    ADHCloudItemStatusNotDownload = 0,
    ADHCloudItemStatusDownloaded,
    ADHCloudItemStatusCurrent,
};

@interface ADHCloudItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) BOOL isDir;
@property (nonatomic, assign) NSTimeInterval creationTime;
@property (nonatomic, assign) NSTimeInterval updateTime;
@property (nonatomic, assign) uint32_t fileSize;
//has unresolved conflicts
@property (nonatomic, assign) BOOL conflicted;
@property (nonatomic, assign) ADHCloudItemStatus downloadStatus;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) float downloadPercent;
@property (nonatomic, strong) NSString *downloadError;
@property (nonatomic, assign) BOOL uploaded;
@property (nonatomic, assign) BOOL uploading;
@property (nonatomic, assign) float uploadPercent;
@property (nonatomic, strong) NSString *uploadError;

@property (nonatomic, weak) ADHCloudItem *parent;
@property (nonatomic, strong) NSArray<ADHCloudItem *> *subItems;

+ (ADHCloudItem *)item;

- (NSDictionary *)dicPresentation;
+ (ADHCloudItem *)itemWithDic: (NSDictionary *)data;

//preview
@property (nonatomic, strong) NSString *cacheFilePath;
- (NSString *)getStateText;
@property (nonatomic, strong) NSArray * filteredSubItems;
- (NSInteger)level;



@end
