//
//  StateMasterService.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/30.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "StateMasterService.h"
#import "ADHFileNode.h"
#import "ADHFileNodeUtil.h"

NSString *const kStateConfigName = @"config.plist";
NSString *const kStateConfigTitleKey = @"title";
NSString *const kStateConfigSortKey = @"sort";

NSString *const kStateItemSandbox = @"Sandbox";
NSString *const kStateItemUserDefaults = @"UserDefaults";

static NSMutableArray *serviceList = nil;

@interface StateMasterService ()

@property (nonatomic, strong) NSMutableArray<StateItem *> *mApplist;
@property (nonatomic, strong) NSMutableArray<StateItem *> *mSharedList;

@property (nonatomic, assign) BOOL syncFlag;
@property (nonatomic, strong) NSString *statePath;
@property (nonatomic, strong) NSString *sandboxPath;
@property (nonatomic, strong) void (^progressBlock)(float progress);
@property (nonatomic, strong) void (^completionBlock)(void);
@property (nonatomic, strong) void (^failedBlock)(BOOL paused);
@property (nonatomic, strong) ADHFileNode *rootNode;
@property (nonatomic, strong) NSMutableArray<ADHFileNode *> *leafNodes;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger finishCount;

@end

@implementation StateMasterService

+ (StateMasterService *)serviceWithContext: (AppContext *)context {
    if(!serviceList) {
        serviceList = [NSMutableArray array];
    }
    StateMasterService *targetService = nil;
    for (StateMasterService *service in serviceList) {
        if(service.context == context) {
            targetService = service;
            break;
        }
    }
    if(!targetService) {
        StateMasterService *service = [[StateMasterService alloc] init];
        service.context = context;
        [serviceList addObject:service];
        targetService = service;
    }
    return targetService;
}

- (void)clearContext {
    self.syncFlag = NO;
    self.completionBlock = nil;
    self.failedBlock = nil;
    self.progressBlock = nil;
    self.rootNode = nil;
    self.leafNodes = nil;
    self.totalCount = 0;
    self.finishCount = 0;
    
}

- (void)syncStateAtPath: (NSString *)statePath onProgress:(void (^)(float progress))progressBlock onCompletion: (void (^)(void))completionBlock onFailed:(void (^)(BOOL paused))failedBlock {
    if(self.syncFlag) {
        if(self.failedBlock) {
            self.failedBlock(YES);
        }
    }
    [self clearContext];
    self.statePath = statePath;
    self.progressBlock = progressBlock;
    self.completionBlock = completionBlock;
    self.failedBlock = failedBlock;
    [self beginSync];
}

- (void)pauseCurrentSync {
    [self clearContext];
}

- (void)beginSync {
    [self prepareForSync];
    [self syncSandbox];
}

- (void)prepareForSync {
    NSInteger totalCount = 0;
    BOOL sandboxExists = NO;
    BOOL userdefaultExists = NO;
    //sandbox
    NSString *sandboxPath = [self.statePath stringByAppendingPathComponent:@"Sandbox"];
    self.sandboxPath = sandboxPath;
    ADHFileNode *rootNode = [ADHFileNodeUtil scanFolder:sandboxPath];
    rootNode.name = @"";
    NSArray<ADHFileNode *> * leafNodes = [ADHFileNodeUtil getLeafNodes:rootNode];
    self.leafNodes = [leafNodes mutableCopy];
    self.rootNode = rootNode;
    sandboxExists = (self.leafNodes.count > 0);
    totalCount += self.leafNodes.count;
    //user defaults
    NSString *userdefaultPath = [self.statePath stringByAppendingPathComponent:@"UserDefaults"];
    NSString *path = [userdefaultPath stringByAppendingPathComponent:@"standard.plist"];
    if([ADHFileUtil fileExistsAtPath:path]) {
        userdefaultExists = YES;
        totalCount += 1;
    }
    self.totalCount = totalCount;
    self.finishCount = 0;
}

//sandbox
- (void)syncSandbox {
    [self trySandboxSyncNextNode];
}

- (void)trySandboxSyncNextNode {
    if(self.leafNodes.count > 0) {
        ADHFileNode *nextNode = self.leafNodes[0];
        [self.leafNodes removeObject:nextNode];
        [self syncFileNode:nextNode];
    }else {
        [self onSandboxSyncSucceed];
    }
}

- (void)onSandboxSyncSucceed {
    NSLog(@"sandbox sync succeed");
    [self syncUserDefaults];
}

- (void)syncFileNode: (ADHFileNode *)fileNode {
    NSString *path = [self getFileNodePath:fileNode];
    NSString *nodePath = [fileNode getPath];
    NSLog(@"sandbox sync next: %@  left: %zd",nodePath,self.leafNodes.count);
    NSData *payload = nil;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"path"] = nodePath;
    if(fileNode.isDir) {
        data[@"dir"] = @(1);
    }else {
        payload = [[NSData alloc] initWithContentsOfFile:path];
    }
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.statemaster" action:@"filesync" body:data payload:payload progressChanged:^(float progress){
        [wself onCurrentProgressUpdate:progress];
    } onSuccess:^(NSDictionary *body, NSData *payload) {
        wself.finishCount += 1;
        [wself onCurrentProgressUpdate:1.0];
        [wself trySandboxSyncNextNode];
    } onFailed:^(NSError *error) {
        [wself onSyncFailed];
    }];
}

- (void)onCurrentProgressUpdate: (float)progress {
    float eachPercent = 1.0/self.totalCount;
    float finishProgress = self.finishCount*eachPercent;
    finishProgress += progress *eachPercent;
    if(self.progressBlock) {
        self.progressBlock(finishProgress);
    }
}

- (void)syncUserDefaults {
    NSLog(@"sync userdefaults");
    NSString *userdefaultPath = [self.statePath stringByAppendingPathComponent:@"UserDefaults"];
    NSString *path = [userdefaultPath stringByAppendingPathComponent:@"standard.plist"];
    if([ADHFileUtil fileExistsAtPath:path]) {
        NSData *payload = [[NSData alloc] initWithContentsOfFile:path];
        __weak typeof(self) wself = self;
        [self.apiClient requestWithService:@"adh.statemaster" action:@"userdefaultsync" body:nil payload:payload progressChanged:^(float progress){
            [wself onCurrentProgressUpdate:progress];
        } onSuccess:^(NSDictionary *body, NSData *payload) {
            [wself onCurrentProgressUpdate:1.0];
            [wself onSyncSucceed];
        } onFailed:^(NSError *error) {
            [wself onSyncFailed];
        }];
    }else {
        [self onSyncSucceed];
    }
}

- (void)onSyncSucceed {
    NSLog(@"sync succeed");
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.completionBlock) {
            self.completionBlock();
        }
        [self clearContext];
    });
}

- (void)onSyncFailed {
    NSLog(@"sync failed");
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.failedBlock) {
            self.failedBlock(NO);
        }
        [self clearContext];
    });
}

- (NSString *)getFileNodePath: (ADHFileNode *)node {
    NSString *workPath = self.sandboxPath;
    NSString *nodePath = [node getPath];
    NSString *path = [workPath stringByAppendingPathComponent:nodePath];
    return path;
}

//state management
- (void)refreshStateWithCompletion: (void (^)(void))completionBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *appPath = [self getWorkPath];
        NSMutableArray *appList = [[self loadListAtPath:appPath shared:NO] mutableCopy];
        self.mApplist = appList;
        //shared
        NSString *sharedPath = [self getSharedPath];
        NSMutableArray * sharedList = [[self loadListAtPath:sharedPath shared:YES] mutableCopy];
        self.mSharedList = sharedList;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock) {
                completionBlock();
            }
        });
    });
}

- (NSArray<StateItem *> *)loadListAtPath: (NSString *)path shared: (BOOL)shared {
    NSMutableArray *list = [NSMutableArray array];
    NSArray *itemList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *item in itemList) {
        NSString *itemPath = [path stringByAppendingPathComponent:item];
        if([ADHFileUtil dirExistsAtPath:itemPath]) {
            NSString *configPath = [itemPath stringByAppendingPathComponent:kStateConfigName];
            NSDictionary *configData = [[NSDictionary alloc] initWithContentsOfFile:configPath];
            if([configData isKindOfClass:[NSDictionary class]]) {
                NSString *title = configData[kStateConfigTitleKey];
                NSInteger sortIndex = [configData[kStateConfigSortKey] integerValue];
                StateItem *stateItem = [[StateItem alloc] init];
                stateItem.title = title;
                stateItem.workPath = itemPath;
                stateItem.sortIndex = sortIndex;
                [list addObject:stateItem];
            }
        }
    }
    [list sortUsingComparator:^NSComparisonResult(StateItem *obj1, StateItem *obj2) {
      if(obj1.sortIndex < obj2.sortIndex) {
          return NSOrderedAscending;
      }else {
          return NSOrderedDescending;
      }
    }];
    return list;
}

- (NSArray<StateItem *> *)getAppItems {
    return self.mApplist;
}

- (NSArray<StateItem *> *)getSharedItems {
    return self.mSharedList;
}

- (void)moveStateItemForward: (StateItem *)stateItem {
    NSMutableArray *list = nil;
    if(stateItem.shared) {
        list = self.mSharedList;
    }else {
        list = self.mApplist;
    }
    NSInteger oldIndex = [list indexOfObject:stateItem];
    if(oldIndex == NSNotFound || oldIndex == 0) {
        return;
    }
    NSInteger newIndex = oldIndex-1;
    StateItem * preItem = list[newIndex];
    NSInteger sortIndex = preItem.sortIndex - 1;
    stateItem.sortIndex = sortIndex;
    //save
    [self saveStateItemData:stateItem];
}

- (void)saveStateItemData: (StateItem *)item {
    NSString *statePath = item.workPath;
    NSString *configPath = [statePath stringByAppendingPathComponent:kStateConfigName];
    NSDictionary *configData = [[NSDictionary alloc] initWithContentsOfFile:configPath];
    if(!configData) {
        configData = @{};
    }
    NSMutableDictionary *mConfigData = [configData mutableCopy];
    mConfigData[kStateConfigTitleKey] = item.title;
    mConfigData[kStateConfigSortKey] = [NSNumber numberWithInteger:item.sortIndex];
    [mConfigData writeToFile:configPath atomically:YES];
}

#pragma mark -----------------   add   ----------------
- (NSMenuItem *)makeStateMasterMenu: (id)target action: (SEL)selector {
    NSInteger count = self.mApplist.count + self.mSharedList.count;
    if(count > 0) {
        NSMenuItem *syncMenu = [[NSMenuItem alloc] init];
        syncMenu.title = @"Sync to State Master";
        NSMenu *menu = [[NSMenu alloc] init];
        for (NSInteger i=0; i<self.mApplist.count; i++) {
            StateItem *item = self.mApplist[i];
            NSMenuItem *subItem = [[NSMenuItem alloc] initWithTitle:item.title action:selector keyEquivalent:adhvf_const_emptystr()];
            subItem.representedObject = item;
            subItem.target = target;
            [menu addItem:subItem];
        }
        if(self.mApplist.count > 0 && self.mSharedList.count > 0) {
            NSMenuItem *sep = [NSMenuItem separatorItem];
            [menu addItem:sep];
        }
        for (NSInteger i=0; i<self.mSharedList.count; i++) {
            StateItem *item = self.mSharedList[i];
            NSString *title = [NSString stringWithFormat:@"%@(shared)",item.title];
            NSMenuItem *subItem = [[NSMenuItem alloc] initWithTitle:title action:selector keyEquivalent:adhvf_const_emptystr()];
            subItem.representedObject = item;
            subItem.target = target;
            [menu addItem:subItem];
        }
        syncMenu.submenu = menu;
        return syncMenu;
    }else {
        return nil;
    }
}

- (void)addFileAtPath: (NSString *)filePath toState: (StateItem *)stateItem statePath: (NSString *)statePath {
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *sandboxPath = [[stateItem workPath] stringByAppendingPathComponent:kStateItemSandbox];
    NSString *toPath = [sandboxPath stringByAppendingPathComponent:statePath];
    [ADHFileUtil saveData:data atPath:toPath];
}

- (void)addUserDefaultsItem: (NSString *)key value: (id)value toState: (StateItem *)stateItem {
    if(!key || !value) {
        return;
    }
    NSString *workPath = [[stateItem workPath] stringByAppendingPathComponent:kStateItemUserDefaults];
    NSString *fileName = @"standard.plist";
    NSString *path = [workPath stringByAppendingPathComponent:fileName];
    NSDictionary * data = [[NSDictionary alloc] initWithContentsOfFile:path];
    if(!data) {
        data = @{};
    }
    NSMutableDictionary *rootData = [data mutableCopy];
    rootData[key] = value;
    [rootData writeToFile:path atomically:YES];
}

#pragma mark -----------------   util   ----------------

- (NSString *)getWorkPath {
    NSString * rootPath = [EnvtService.service stateMasterPath];
    ADHApp * app = self.context.app;
    NSString *appPath = app.bundleId;
    NSString * resultPath = [rootPath stringByAppendingPathComponent:appPath];
    return resultPath;
}

- (NSString *)getSharedPath {
    NSString * rootPath = [EnvtService.service stateMasterPath];
    NSString *resultPath = [rootPath stringByAppendingPathComponent:@"shared"];
    return resultPath;
}


@end

