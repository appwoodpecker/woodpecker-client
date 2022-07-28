//
//  FileBrowserService.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/7.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHFileItem.h"
#import "ADHFilePreviewItem.h"
#import "SandboxWorkpathItem.h"

extern NSString *const kFileBrowserTreeUpdateNotification;
extern NSString *const kRequestContainerKey;
extern NSString *const kRequestWorkDirectoryKey;


typedef void (^FileBrowserUpdateBlock)(NSArray<ADHFilePreviewItem *> *items);

/**
 FileBrowser工具服务类
 */
@interface FileBrowserService : NSObject

+ (FileBrowserService *)serviceWithContext: (AppContext *)context;
//group container
@property (nonatomic, strong) NSString *containerName;
@property (nonatomic, strong) NSString *sandboxWorkpath;

//判断App目录是否已经同步
- (BOOL)isAppFolderSynced: (ADHFileItem *)appRootItem atLocalPath: (NSString *)localPath;
//同步App目录
- (void)syncAppFolder: (ADHFileItem *)appRootItem localPath: (NSString *)localPath;

- (void)syncDownloadResultWithItem: (ADHFilePreviewItem *)previewItem fileData: (NSData *)fileData localPath: (NSString *)localPath exteraData: (NSDictionary *)exteraData onCompletion: (void(^)(void))completionBlock;

- (void)syncUploadResultWithItem: (ADHFilePreviewItem *)previewItem;

- (void)refreshPreviewItemState: (ADHFilePreviewItem *)previewItem localPath: (NSString *)localPath onCompletion: (void(^)(void))completionBlock onError: (void(^)(NSError *error))failedBlock;

//仅本地文件更新时，刷新本地item tree
- (void)refreshLocalPreviewItemState: (ADHFilePreviewItem *)previewItem localPath: (NSString *)localPath onCompletion: (void(^)(void))completionBlock;
//本地文件更新时，更新本地属性，不做文件删减
- (void)updateLocalItemAttr: (ADHFilePreviewItem *)previewItem localPath: (NSString *)localPath onCompletion:(FileBrowserUpdateBlock)completionBlock;

- (void)removePreviewItem: (ADHFilePreviewItem *)previewItem localPath: (NSString *)localPath;
 
/**
 根据AppFS，和本地FS，生成PreviewFS
 */
- (ADHFilePreviewItem *)producePreviewTree: (ADHFileItem *)appRootItem localPath: (NSString *)localPath;

/**
 检索
 */
- (ADHFilePreviewItem *)searchPreviewTree: (ADHFilePreviewItem *)rootItem withKeywords: (NSString *)keywords;


- (void)monitorLocalFileStatus:(ADHFilePreviewItem *)previewItem localPath:(NSString *)path onUpdate: (FileBrowserUpdateBlock)updateBlock;

#pragma mark -----------------   sandbox workpath   ----------------

- (NSArray<SandboxWorkpathItem *> *)loadCustomWorkpathItems;
- (NSString *)getCustomWorkpath;
- (void)saveCustomWorkpaths: (NSArray<SandboxWorkpathItem *> *)items;

@end




