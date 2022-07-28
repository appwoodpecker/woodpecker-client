//
//  FileBrowserService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/7.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "FileBrowserService.h"
#import "ADHFileBrowserUtil.h"

NSString *const kFileBrowserTreeUpdateNotification = @"kFileBrowserTreeUpdateNotification";
NSTimeInterval const kUpdateInterval = 0.8;
static NSString *const kPreferenceWorkpathListKey = @"workpathList";

NSString *const kRequestContainerKey = @"container";
NSString *const kRequestWorkDirectoryKey = @"workdir";

@import CoreServices;


static NSMutableArray *serviceList = nil;

@interface FileBrowserService ()

@property (nonatomic, strong) NSString *monitorFilePath;
@property (nonatomic, weak) ADHFilePreviewItem *monitorPreviewItem;
@property (nonatomic, assign) FSEventStreamRef stream;
@property (nonatomic, assign) BOOL bLocalNeedUpdate;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, copy) FileBrowserUpdateBlock updateBlock;

@end

@implementation FileBrowserService

+ (FileBrowserService *)serviceWithContext: (AppContext *)context {
    if(!serviceList) {
        serviceList = [NSMutableArray array];
    }
    FileBrowserService *targetService = nil;
    for (FileBrowserService *service in serviceList) {
        if(service.context == context) {
            targetService = service;
            break;
        }
    }
    if(!targetService) {
        FileBrowserService *service = [[FileBrowserService alloc] init];
        service.context = context;
        [serviceList addObject:service];
        targetService = service;
    }
    return targetService;
}

/**
 同步App文件目录结构
 */
- (BOOL)isAppFolderSynced: (ADHFileItem *)appRootItem atLocalPath: (NSString *)localPath
{
    NSString * rootPath = [localPath stringByAppendingPathComponent:appRootItem.path];
    return [ADHFileUtil dirExistsAtPath:rootPath];
}

- (void)syncAppFolder: (ADHFileItem *)appRootItem localPath: (NSString *)localPath
{
    [self syncFolderItem:appRootItem relativePath:localPath];
}

/**
 同步目录结构
 */
- (void)syncFolderItem: (ADHFileItem *)fileItem relativePath: (NSString *)relativePath
{
    //当前目录
    if(!fileItem.isDir) return;
    NSString * itemPath = [relativePath stringByAppendingPathComponent:fileItem.path];
    if(![ADHFileUtil dirExistsAtPath:itemPath]){
        [ADHFileUtil createDirAtPath:itemPath];
    }
    //子目录，以及子文件
    NSArray * subItems = fileItem.subItems;
    for (ADHFileItem * subItem in subItems) {
        [self syncFolderItem:subItem relativePath:relativePath];
    }
}

/**
 */
- (void)syncDownloadResultWithItem: (ADHFilePreviewItem *)previewItem fileData: (NSData *)fileData localPath: (NSString *)localPath exteraData: (NSDictionary *)exteraData onCompletion: (void(^)(void))completionBlock {
    if(!previewItem.isDir){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //更新文件数据
            ADHFileItem * fileItem = previewItem.fileItem;
            NSString * filePath = [localPath stringByAppendingPathComponent:fileItem.path];
            NSTimeInterval updateTime = [exteraData[@"updateTime"] doubleValue];
            [ADHFileUtil saveData:fileData atPath:filePath modificationDate:updateTime];
            //更新preview状态
            ADHFileItem * localFileItem = previewItem.localFileItem;
            if(updateTime > 0) {
                //更新updateTime
                localFileItem.updateTime = updateTime;
                fileItem.updateTime = updateTime;
            }else {
                localFileItem.updateTime = fileItem.updateTime;
            }
            localFileItem.fileSize = fileItem.fileSize;
            //标记已存在(当然可能只是更新)
            previewItem.localExists = YES;
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(completionBlock){
                    completionBlock();
                }
            });
        });
    }else{
        //创建本地目录
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ADHFileItem * fileItem = previewItem.fileItem;
            NSString * filePath = [localPath stringByAppendingPathComponent:fileItem.path];
            [ADHFileUtil createDirAtPath:filePath];
            //更新preview状态
            previewItem.localExists = YES;
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(completionBlock){
                    completionBlock();
                }
            });
        });
    }
}

/**
 */
- (void)syncUploadResultWithItem: (ADHFilePreviewItem *)previewItem
{
    //更新preview状态
    ADHFileItem * localFileItem = previewItem.localFileItem;
    ADHFileItem * appFileItem = previewItem.fileItem;
    appFileItem.updateTime = localFileItem.updateTime;
    appFileItem.fileSize = localFileItem.fileSize;
    previewItem.remoteExists = YES;
}


/**
 刷新单个文件的状态
 */
- (void)refreshPreviewItemState: (ADHFilePreviewItem *)previewItem localPath: (NSString *)localPath onCompletion: (void(^)(void))completionBlock onError: (void(^)(NSError *error))failedBlock {
    NSString * path = previewItem.viewFileItem.path;
    BOOL isDir = previewItem.isDir;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"path"] = adhvf_safestringfy(path);
    data[@"isdir"] = [NSNumber numberWithBool:isDir];
    if(self.containerName.length > 0) {
        data[kRequestContainerKey] = self.containerName;
    }
    if(self.sandboxWorkpath.length > 0) {
        data[kRequestWorkDirectoryKey] = self.sandboxWorkpath;
    }
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.sandbox" action:@"readfilestate" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //sync may take some time
            NSString * content = body[@"content"];
            ADHFileItem * appFileItem = nil;
            NSDictionary * fsData = [content adh_jsonObject];
            if([fsData isKindOfClass:[NSDictionary class]]) {
                appFileItem = [ADHFileItem itemWithDic:fsData];
            }
            if(appFileItem){
                previewItem.remoteExists = YES;
                previewItem.fileItem = appFileItem;
            }else{
                previewItem.fileItem = nil;
                previewItem.remoteExists = NO;
            }
            //local
            ADHFileItem * localFileItem = nil;
            if(isDir){
                localFileItem = [ADHFileBrowserUtil scanFolder:path relativePath:localPath];
            }else{
                localFileItem = [ADHFileBrowserUtil scanFileAtPath:path relativePath:localPath];
            }
            if(localFileItem){
                previewItem.localFileItem = localFileItem;
                previewItem.localExists = YES;
            }else{
                previewItem.localFileItem = nil;
                previewItem.localExists = NO;
            }
            [wself syncDumpPreviewItem:previewItem];
            [wself syncPreviewState:previewItem];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(completionBlock){
                    completionBlock();
                }
            });
        });
    } onFailed:^(NSError *error) {
        if(failedBlock) {
            failedBlock(error);
        }
    }];
}

//刷新本地item tree
- (void)refreshLocalPreviewItemState: (ADHFilePreviewItem *)previewItem localPath: (NSString *)localPath onCompletion: (void(^)(void))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * path = previewItem.viewFileItem.path;
        BOOL isDir = previewItem.isDir;
        //local
        ADHFileItem * localFileItem = nil;
        if(isDir){
            localFileItem = [ADHFileBrowserUtil scanFolder:path relativePath:localPath];
        }else{
            localFileItem = [ADHFileBrowserUtil scanFileAtPath:path relativePath:localPath];
        }
        if(localFileItem){
            previewItem.localFileItem = localFileItem;
            previewItem.localExists = YES;
        }else{
            previewItem.localFileItem = nil;
            previewItem.localExists = NO;
        }
        [self syncDumpPreviewItem:previewItem];
        [self syncPreviewState:previewItem];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(completionBlock){
                completionBlock();
            }
        });
    });
}

//仅更新本地item tree属性
- (void)updateLocalItemAttr: (ADHFilePreviewItem *)previewItem localPath: (NSString *)localPath onCompletion:(FileBrowserUpdateBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *updateItems = [NSMutableArray array];
        [self _updateLocalItemAttr:previewItem localPath:localPath updateList:updateItems];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(completionBlock){
                completionBlock(updateItems);
            }
        });
    });
}

/**
 更新本地文件的删除，修改
 其余变化让用户手动刷新
 */
- (void)_updateLocalItemAttr: (ADHFilePreviewItem *)previewItem localPath: (NSString *)localPath updateList:(NSMutableArray *)results {
    if(previewItem.localExists) {
        ADHFileItem *localItem = previewItem.localFileItem;
        if(!previewItem.isDir) {
            //文件
            NSString *itemFilePath = [localPath stringByAppendingPathComponent:localItem.path];
            if([ADHFileUtil fileExistsAtPath:itemFilePath]){
                NSTimeInterval oldUpdateTime = localItem.updateTime;
                NSFileManager * fileManager = [NSFileManager defaultManager];
                NSError * error = nil;
                NSDictionary * attributes = [fileManager attributesOfItemAtPath:itemFilePath error:&error];
                NSNumber * fileSize = attributes[NSFileSize];
                NSDate * updateDate = attributes[NSFileModificationDate];
                localItem.fileSize = [fileSize intValue];
                localItem.updateTime = [updateDate timeIntervalSince1970];
                if(ABS(localItem.updateTime - oldUpdateTime) > kADHFilePreviewItemMinInterval) {
                    [results addObject:previewItem];
                }
            }else {
                //文件不存在
                previewItem.localExists = NO;
                [results addObject:previewItem];
            }
        }else {
            //dir
            NSArray *subItems = previewItem.subItems;
            for (ADHFilePreviewItem *subItem in subItems) {
                [self _updateLocalItemAttr:subItem localPath:localPath updateList:results];
            }
        }
    }
}

#pragma mark -----------------   util   ----------------

/**
 根据AppFS，和本地FS，生成PreviewFS
 */
- (ADHFilePreviewItem *)producePreviewTree: (ADHFileItem *)appRootItem localPath: (NSString *)localPath
{
    //遍历本地FSTree
    ADHFileItem * localRootItem = [ADHFileBrowserUtil scanRootFolder:localPath];
    //开始生成预览tree，以App目录为准，开始逐个目录遍历
    ADHFilePreviewItem * rootPreviewItem = [[ADHFilePreviewItem alloc] init];
    rootPreviewItem.fileItem = appRootItem;
    rootPreviewItem.localFileItem = localRootItem;
    rootPreviewItem.localExists = YES;
    rootPreviewItem.remoteExists = YES;
    rootPreviewItem.parent = nil;
    [self syncPreviewState:rootPreviewItem];
    return rootPreviewItem;
}

- (void)syncPreviewState: (ADHFilePreviewItem *)previewItem
{
    ADHFileItem * appItem = previewItem.fileItem;
    ADHFileItem * localItem = previewItem.localFileItem;
    if(previewItem.isDir){
        NSMutableArray * subPreviewItems = [NSMutableArray array];
        if(appItem && localItem){
            /*
             App:     AB
             Local:   BC
             Result   B,A,C
             */
            NSArray * appSubItems = appItem.subItems;
            NSArray * localSubItems = localItem.subItems;
            //保存本地Item，方便后期比较
            NSMutableArray * localExistsItems = [NSMutableArray array];
            for (ADHFileItem * appItem in appSubItems) {
                ADHFileItem * localFileItem = nil;
                for (ADHFileItem * localItem in localSubItems) {
                    if([appItem.name isEqualToString:localItem.name] && appItem.isDir == localItem.isDir){
                        localFileItem = localItem;
                        break;
                    }
                }
                if(localFileItem){
                    //本地存在
                    [localExistsItems addObject:localFileItem];
                    ADHFilePreviewItem * previewItem = [[ADHFilePreviewItem alloc] init];
                    previewItem.fileItem = appItem;
                    previewItem.localFileItem = localFileItem;
                    previewItem.remoteExists = YES;
                    previewItem.localExists = YES;
                    [subPreviewItems addObject:previewItem];
                }else{
                    //只有App存在
                    ADHFilePreviewItem * previewItem = [[ADHFilePreviewItem alloc] init];
                    previewItem.fileItem = appItem;
                    previewItem.localFileItem = nil;
                    previewItem.remoteExists = YES;
                    [subPreviewItems addObject:previewItem];
                }
            }
            //找出只在存在本地存在
            for (ADHFileItem * localItem in localSubItems) {
                BOOL isExists = NO;
                for (ADHFileItem * leItem in localExistsItems) {
                    if(leItem == localItem){
                        isExists = YES;
                        break;
                    }
                }
                if(!isExists){
                    ADHFilePreviewItem * previewItem = [[ADHFilePreviewItem alloc] init];
                    previewItem.fileItem = nil;
                    previewItem.localFileItem = localItem;
                    previewItem.localExists = YES;
                    [subPreviewItems addObject:previewItem];
                }
            }
        }else if(appItem){
            NSArray * appSubItems = appItem.subItems;
            for (ADHFileItem * appItem in appSubItems) {
                ADHFilePreviewItem * previewItem = [[ADHFilePreviewItem alloc] init];
                previewItem.fileItem = appItem;
                previewItem.localFileItem = nil;
                previewItem.remoteExists = YES;
                [subPreviewItems addObject:previewItem];
            }
        }else if(localItem){
            NSArray * localSubItems = localItem.subItems;
            for (ADHFileItem * localItem in localSubItems) {
                ADHFilePreviewItem * previewItem = [[ADHFilePreviewItem alloc] init];
                previewItem.fileItem = nil;
                previewItem.localFileItem = localItem;
                previewItem.localExists = YES;
                [subPreviewItems addObject:previewItem];
            }
        }
        //移除无效preview项
        NSArray * ignoredFiles = @[
                                   @".DS_Store",
                                   @".com.apple.mobile_container_manager.metadata.plist",
                                   [ADHFileUtil containerRootName],
                                   ];
        NSMutableArray * ignoreItems = [NSMutableArray array];
        for (ADHFilePreviewItem * previewItem in subPreviewItems) {
            ADHFileItem * fileItem = [previewItem viewFileItem];
            NSString * fileName = fileItem.name;
            BOOL shouldIgnore = NO;
            for (NSString * ignoreName in ignoredFiles) {
                if([fileName isEqualToString:ignoreName]){
                    shouldIgnore = YES;
                    break;
                }
            }
            if(shouldIgnore){
                [ignoreItems addObject:previewItem];
            }
        }
        [subPreviewItems removeObjectsInArray:ignoreItems];
        //dump相互不存在的item
        for (ADHFilePreviewItem * subPreviewItem in subPreviewItems) {
            [self syncDumpPreviewItem:subPreviewItem];
        }
        for (ADHFilePreviewItem * subPreviewItem in subPreviewItems) {
            if(subPreviewItem.isDir){
                [self syncPreviewState:subPreviewItem];
            }
        }
        //设置parent
        for (ADHFilePreviewItem * subItem in subPreviewItems) {
            subItem.parent = previewItem;
        }
        previewItem.subItems = subPreviewItems;
    }
}

/**
 双向创建空fileItem
 */
- (void)syncDumpPreviewItem: (ADHFilePreviewItem *)previewItem
{
    ADHFileItem * appFileItem = previewItem.fileItem;
    ADHFileItem * localFileItem = previewItem.localFileItem;
    if(appFileItem && !localFileItem){
        localFileItem = [self dumpFSfileItem:appFileItem];
        previewItem.localFileItem = localFileItem;
    }else if(!appFileItem && localFileItem){
        appFileItem = [self dumpFSfileItem:localFileItem];
        previewItem.fileItem = appFileItem;
    }
}

/**
 创建空fileItem Tree
 */
- (ADHFileItem *)dumpFSfileItem: (ADHFileItem *)fileItem
{
    ADHFileItem * resultFileItem = nil;
    ADHFileItem * tFileItem = [fileItem dumpCopy];
    resultFileItem = tFileItem;
    return resultFileItem;
}

#pragma mark -----------------   delete   ----------------

- (void)removePreviewItem: (ADHFilePreviewItem *)previewItem localPath: (NSString *)localPath {
    if(previewItem.localExists) {
        //delte local
        ADHFileItem *localItem = previewItem.localFileItem;
        NSString *path = [localPath stringByAppendingPathComponent:localItem.path];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
    //remove local item
    ADHFilePreviewItem *parentPreviewItem = previewItem.parent;
    if(previewItem.localFileItem) {
        ADHFileItem *parent = parentPreviewItem.localFileItem;
        ADHFileItem *localItem = previewItem.localFileItem;
        NSArray *subItems = parent.subItems;
        NSMutableArray *mutableSubItems = [subItems mutableCopy];
        [mutableSubItems removeObject:localItem];
        parent.subItems = mutableSubItems;
    }
    //remove remote item
    if(previewItem.fileItem) {
        ADHFileItem *parent = parentPreviewItem.fileItem;
        ADHFileItem *fileItem = previewItem.fileItem;
        NSArray *subItems = parent.subItems;
        NSMutableArray *mutableSubItems = [subItems mutableCopy];
        [mutableSubItems removeObject:fileItem];
        parent.subItems = mutableSubItems;
    }
    //remove preview item
    {
        NSArray *subItems = parentPreviewItem.subItems;
        NSMutableArray *mutableSubItems = [subItems mutableCopy];
        [mutableSubItems removeObject:previewItem];
        parentPreviewItem.subItems = mutableSubItems;
        if([parentPreviewItem.filteredSubItems containsObject:previewItem]) {
            NSMutableArray *mutableFilteredSubItems = [parentPreviewItem.filteredSubItems mutableCopy];
            [mutableFilteredSubItems removeObject:previewItem];
            parentPreviewItem.filteredSubItems = mutableFilteredSubItems;
        }
    }
}


#pragma mark -----------------   search   ----------------
/**
 检索
 第一步，找到所有符合检索条件的item,线性展开
 第二步，将线性结果，从底层找到上层
 */
- (ADHFilePreviewItem *)searchPreviewTree: (ADHFilePreviewItem *)rootItem withKeywords: (NSString *)keywords
{
    [self resetSearchPreviewItem:rootItem];
    NSMutableArray * matchItems = [NSMutableArray array];
    [self searchPreviewItem:rootItem keywords:keywords intoResult:matchItems];
    ADHFilePreviewItem * matchTree = [self producePreviewTreeWithResult:matchItems];
    return matchTree;
}

- (void)resetSearchPreviewItem: (ADHFilePreviewItem *)previewItem
{
    previewItem.filteredSubItems = nil;
    for (ADHFilePreviewItem * subItem in previewItem.subItems) {
        [self resetSearchPreviewItem:subItem];
    }
}

- (void)searchPreviewItem: (ADHFilePreviewItem *)previewItem keywords: (NSString *)keywords intoResult: (NSMutableArray *)matchItems
{
    BOOL matched = ([previewItem.viewFileItem.name rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound);
    if(matched){
        [matchItems addObject:previewItem];
    }
    if(previewItem.isDir){
        NSArray * subItems = previewItem.subItems;
        for (ADHFilePreviewItem * subItem in subItems) {
            [self searchPreviewItem:subItem keywords:keywords intoResult:matchItems];
        }
    }
}

- (ADHFilePreviewItem *)producePreviewTreeWithResult: (NSArray *)matchList
{
    if(!matchList){
        matchList = @[];
    }
    NSMutableArray * resultItemList = [NSMutableArray arrayWithArray:matchList];
    //找到最底层levels
    NSInteger maxLevel = -1;
    for (ADHFilePreviewItem * item in matchList) {
        if(item.level > maxLevel){
            maxLevel = item.level;
        }
    }
    if(maxLevel == -1){
        return nil;
    }
    NSInteger level = maxLevel;
    while (level >=0) {
        //找到当前level items
        NSMutableArray * levelItems = [NSMutableArray array];
        for (ADHFilePreviewItem * item in resultItemList) {
            if(item.level == level){
                [levelItems addObject:item];
            }
        }
        for (ADHFilePreviewItem * item in levelItems) {
            //找出上层item
            ADHFilePreviewItem * parent = item.parent;
            if(parent && ![resultItemList containsObject:parent]){
                [resultItemList addObject:parent];
            }
        }
        //查找上一层级
        level--;
    }
    //此时resultItemList包含所有有效item，那么顶层到下层
    if(resultItemList.count == 0){
        return nil;
    }
    //构建每个层级的level itemlist，方便查找
    NSMutableDictionary * levelItemList = [NSMutableDictionary dictionary];
    for (ADHFilePreviewItem * item in resultItemList) {
         NSNumber * levelNo = [NSNumber numberWithInteger:item.level];
         NSMutableArray * list = levelItemList[levelNo];
         if(!list){
             list = [NSMutableArray array];
             levelItemList[levelNo] = list;
         }
         [list addObject:item];
    }
    //找到顶层item
    NSNumber * rootKey = [NSNumber numberWithInteger:0];
    ADHFilePreviewItem * rootItem = levelItemList[rootKey][0];
    [self produceSubItem:@[rootItem] withLevelItemDic:levelItemList];
    return rootItem;
}

- (void)produceSubItem: (NSArray *)previewItems withLevelItemDic:(NSDictionary *)levelItemList
{
    if(previewItems.count == 0){
        return;
    }
    ADHFilePreviewItem * firstItem = previewItems[0];
    NSInteger level = firstItem.level;
    NSInteger subLevel = level+1;
    NSNumber * subKey = [NSNumber numberWithInteger:subLevel];
    NSArray * subLevelItems = levelItemList[subKey];
    if(subLevelItems.count > 0){
        for (ADHFilePreviewItem * previewItem in previewItems) {
            if(previewItem.isDir){
                NSMutableArray * subItems = [NSMutableArray array];
                for (ADHFilePreviewItem * subItem in subLevelItems) {
                    if(subItem.parent == previewItem){
                        [subItems addObject:subItem];
                    }
                }
                previewItem.filteredSubItems = subItems;
            }
        }
        [self produceSubItem:subLevelItems withLevelItemDic:levelItemList];
    }
}

#pragma mark -----------------   monitor file update   ----------------

/**
 * flag可以设置事件的颗粒度
 * None时，颗粒度较大，增删改文件都会发出kFSEventStreamEventFlagNone事件
 * FileEvents时，颗粒度教细，增删改文件都会发出具体事件
 * 但这里我们只需要知道FS变化即可，设置为None
 */
- (void)monitorLocalFileStatus:(ADHFilePreviewItem *)previewItem localPath:(NSString *)path onUpdate: (FileBrowserUpdateBlock)updateBlock {
    [self stopMonitor];
    self.monitorPreviewItem = previewItem;
    self.monitorFilePath = path;
    self.updateBlock = updateBlock;
    CFStringRef mypath = (__bridge CFStringRef)path;
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    // could put stream-specific data here.
    FSEventStreamContext context;
    context.info = (__bridge void * _Nullable)(self);
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    FSEventStreamRef stream;
    // Latency in seconds
    CFAbsoluteTime latency = 1.0;
    // Create the stream, passing in a callback
    stream = FSEventStreamCreate(NULL,
                                 &treeUpdateCallback,
                                 &context,
                                 pathsToWatch,
                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                 latency,
                                 kFSEventStreamCreateFlagFileEvents /* Flags explained in reference */
                                 );
    //schedule
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(),kCFRunLoopDefaultMode);
    BOOL result = FSEventStreamStart(stream);
    if(result) {
        self.stream = stream;
        NSTimer *updateTimer = [NSTimer scheduledTimerWithTimeInterval:kUpdateInterval target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];
        self.updateTimer = updateTimer;
    }else {
        NSLog(@"fsstream start failed");
    }
}

- (void)stopMonitor {
    self.monitorFilePath = nil;
    self.monitorPreviewItem = nil;
    self.updateBlock = nil;
    if(self.stream) {
        FSEventStreamStop(self.stream);
        FSEventStreamInvalidate(self.stream);
        FSEventStreamRelease(self.stream);
        self.stream = NULL;
    }
    [self stopUpdateTimer];
}

void treeUpdateCallback(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[])
{
    FileBrowserService *service = (__bridge FileBrowserService *)(clientCallBackInfo);
    service.bLocalNeedUpdate = YES;
}

- (void)updateTimerFired: (NSTimer *)timer {
    if(self.bLocalNeedUpdate) {
        self.bLocalNeedUpdate = NO;
        [self updateLocalItemAttr:self.monitorPreviewItem localPath:self.monitorFilePath onCompletion:^(NSArray<ADHFilePreviewItem *> *items) {
            if(items.count > 0) {
                if(self.updateBlock) {
                    self.updateBlock(items);
                }
            }
        }];
    }
}

- (void)stopUpdateTimer {
    if(self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
        self.bLocalNeedUpdate = NO;
    }
}

void logEventFlag(FSEventStreamEventFlags event) {
    NSMutableArray *texts = [NSMutableArray array];
    if(event & kFSEventStreamEventFlagMustScanSubDirs) {
        [texts addObject:@"Scan Sub Dirs"];
    }
    if(event & kFSEventStreamEventFlagRootChanged) {
        [texts addObject:@"Root Changed"];
    }
    if(event & kFSEventStreamEventFlagItemCreated) {
        [texts addObject:@"Item Created"];
    }
    if(event & kFSEventStreamEventFlagItemRemoved) {
        [texts addObject:@"Item Removed"];
    }
    if(event & kFSEventStreamEventFlagItemInodeMetaMod) {
        [texts addObject:@"Item Inode MetaMod"];
    }
    if(event & kFSEventStreamEventFlagItemRenamed) {
        [texts addObject:@"Item Renamed"];
    }
    if(event & kFSEventStreamEventFlagItemModified) {
        [texts addObject:@"Item Modified"];
    }
    if(event & kFSEventStreamEventFlagItemFinderInfoMod) {
        [texts addObject:@"Item Finder Info Mod"];
    }
    if(event & kFSEventStreamEventFlagItemChangeOwner) {
        [texts addObject:@"Item Change Owner"];
    }
    if(event & kFSEventStreamEventFlagItemXattrMod) {
        [texts addObject:@"Item Xattr Mod"];
    }
    if (@available(macOS 10.13, *)) {
        if(event & kFSEventStreamEventFlagItemCloned) {
            [texts addObject:@"Item Cloned"];
        }
    }
    if(texts.count > 0) {
        NSString *message = [texts componentsJoinedByString:@"\n"];
        NSLog(@"\n%@",message);
    }
}

#pragma mark -----------------   sandbox workpath   ----------------

- (NSArray<SandboxWorkpathItem *> *)loadCustomWorkpathItems {
    NSArray *list = [Preference defaultValueForKey:kPreferenceWorkpathListKey inDomain:kToolModuleSandbox];
    NSMutableArray *itemList = [NSMutableArray array];
    for (NSDictionary *data in list) {
        SandboxWorkpathItem *item = [SandboxWorkpathItem itemWithData:data];
        [itemList addObject:item];
    }
    return itemList;
}

- (void)saveCustomWorkpaths: (NSArray<SandboxWorkpathItem *> *)items {
    NSMutableArray *list = [NSMutableArray array];
    for (SandboxWorkpathItem *item in items) {
        if(item.path.length > 0) {
            NSDictionary *data = [item dicPresentation];
            [list addObject:data];
        }
    }
    [Preference setDefaultValue:list forKey:kPreferenceWorkpathListKey inDomain:kToolModuleSandbox];
}

- (NSString *)getCustomWorkpath {
    NSString *bundleId = self.context.bundleId;
    NSArray *itemList = [self loadCustomWorkpathItems];
    NSString *targetPath = nil;
    for (SandboxWorkpathItem *item in itemList) {
        if([item.bundleId isEqualToString:bundleId]) {
            targetPath = item.path;
            break;
        }
    }
    return targetPath;
}



@end
