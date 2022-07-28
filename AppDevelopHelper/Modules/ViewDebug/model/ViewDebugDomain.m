//
//  ViewDebugDomain.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewDebugDomain.h"

CGFloat const kBaseNodeScale = 0.013;

NSString *const kViewDebugRootNodeUpdateNotification = @"kViewDebugRootNodeUpdateNotification";
NSString *const kViewDebugSnapshotUpdateNotification = @"kViewDebugSnapshotUpdateNotification";
NSString *const kViewDebugNodeSelectStateNotification = @"kViewDebugNodeSelectStateNotification";
NSString *const kViewDebugNodeAttributeUpdateNotification = @"kViewDebugNodeAttributeUpdateNotification";

static NSInteger const kSnapshotBatchCount = 30;

@interface ViewDebugDomain ()

@property (nonatomic, strong) NSMutableArray *leftSnapshotList;
@property (nonatomic, strong) NSString *batchTag;
@property (nonatomic, strong) NSMutableDictionary *mSnapshotData;

@end

@implementation ViewDebugDomain

#pragma mark -----------------   search   ----------------
/**
 检索
 第一步，找到所有符合检索条件的item,线性展开
 第二步，将线性结果，从底层找到上层
 */
- (ADHViewNode *)searchPreviewTree: (ADHViewNode *)rootItem withKeywords: (NSString *)keywords {
    [self resetSearchPreviewItem:rootItem];
    NSMutableArray * matchItems = [NSMutableArray array];
    [self searchPreviewItem:rootItem keywords:keywords intoResult:matchItems];
    ADHViewNode * matchTree = [self producePreviewTreeWithResult:matchItems];
    return matchTree;
}

- (void)resetSearchPreviewItem: (ADHViewNode *)previewItem {
    previewItem.filteredChildNodes = nil;
    for (ADHViewNode * subItem in previewItem.childNodes) {
        [self resetSearchPreviewItem:subItem];
    }
}

- (void)searchPreviewItem: (ADHViewNode *)previewItem keywords: (NSString *)keywords intoResult: (NSMutableArray *)matchItems {
    BOOL matched = ([previewItem.className rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound);
    if(matched){
        [matchItems addObject:previewItem];
    }
    if(previewItem.childNodes.count > 0){
        NSArray * subItems = previewItem.childNodes;
        for (ADHViewNode * subItem in subItems) {
            [self searchPreviewItem:subItem keywords:keywords intoResult:matchItems];
        }
    }
}

- (ADHViewNode *)producePreviewTreeWithResult: (NSArray *)matchList {
    if(!matchList){
        matchList = @[];
    }
    NSMutableArray * resultItemList = [NSMutableArray arrayWithArray:matchList];
    //找到最底层levels
    NSInteger maxLevel = -1;
    for (ADHViewNode * item in matchList) {
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
        for (ADHViewNode * item in resultItemList) {
            if(item.level == level){
                [levelItems addObject:item];
            }
        }
        for (ADHViewNode * item in levelItems) {
            //找出上层item
            ADHViewNode * parent = item.parent;
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
    for (ADHViewNode * item in resultItemList) {
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
    ADHViewNode * rootItem = levelItemList[rootKey][0];
    [self produceSubItem:@[rootItem] withLevelItemDic:levelItemList];
    return rootItem;
}

- (void)produceSubItem: (NSArray *)previewItems withLevelItemDic:(NSDictionary *)levelItemList {
    if(previewItems.count == 0){
        return;
    }
    ADHViewNode * firstItem = previewItems[0];
    NSInteger level = firstItem.level;
    NSInteger subLevel = level+1;
    NSNumber * subKey = [NSNumber numberWithInteger:subLevel];
    NSArray * subLevelItems = levelItemList[subKey];
    if(subLevelItems.count > 0){
        for (ADHViewNode * previewItem in previewItems) {
            if(previewItem.childNodes.count > 0){
                NSMutableArray * subItems = [NSMutableArray array];
                for (ADHViewNode * subItem in subLevelItems) {
                    if(subItem.parent == previewItem){
                        [subItems addObject:subItem];
                    }
                }
                previewItem.filteredChildNodes = subItems;
            }
        }
        [self produceSubItem:subLevelItems withLevelItemDic:levelItemList];
    }
}

#pragma mark -----------------   snapshot   ----------------

- (NSArray<NSString *> *)getNodeTreeAddrList: (ADHViewNode *)rootNode {
    NSMutableArray *list = [NSMutableArray array];
    [self traverseNodeAddr:rootNode intoData:list];
    return list;
}

- (void)traverseNodeAddr: (ADHViewNode *)node intoData: (NSMutableArray *)list {
    if(node.weakViewAddr) {
        [list addObject:node.weakViewAddr];
        for (ADHViewNode *child in node.childNodes) {
            [self traverseNodeAddr:child intoData:list];
        }
    }
}

- (NSDictionary *)snapshotData {
    return self.mSnapshotData;
}

- (void)resetSnapshot {
    if(self.mSnapshotData) {
        [self.mSnapshotData removeAllObjects];
    }else  {
        self.mSnapshotData = [NSMutableDictionary dictionary];
    }
    
}

- (void)loadSnapshotData {
    NSArray *list = [self getNodeTreeAddrList:self.rootNode];
    if(!list) {
        return;
    }
    self.leftSnapshotList = [list mutableCopy];
    self.batchTag = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
//    NSLog(@"total count: %zd",self.leftSnapshotList.count);
    [self batchLoadSnapshotData];
    
}

- (NSArray *)getNextBatchList {
    NSArray *list = nil;
    NSInteger leftCount = self.leftSnapshotList.count;
    NSInteger count = MIN(leftCount, kSnapshotBatchCount);
    if(count > 0) {
        list = [self.leftSnapshotList subarrayWithRange:NSMakeRange(0, count)];
        [self.leftSnapshotList removeObjectsInArray:list];
    }
    return list;
}

- (void)batchLoadSnapshotData {
    __weak typeof(self) wself = self;
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    NSArray *list = [self getNextBatchList];
    if(list.count == 0) {
//        NSLog(@"snapshot finish");
        return ;
    }
//    NSLog(@"load next : %zd",list.count);
    body[@"list"] = list;
    body[@"batchtag"] = adhvf_safestringfy(self.batchTag);
    [self.context.apiClient requestWithService:@"adh.viewdebug" action:@"snapshotData" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        BOOL success = [body[@"success"] boolValue];
        if(success) {
            NSString *tag = body[@"batchtag"];
            if([tag isEqualToString:wself.batchTag]) {
                [wself doAppendSnapshotData:payload];
            }
        }
        //load next if needed
        [wself batchLoadSnapshotData];
    } onFailed:^(NSError *error) {
        //load next if needed
        [wself batchLoadSnapshotData];
    }];
}

- (void)doAppendSnapshotData: (NSData *)data {
    NSDictionary *snapshotData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if(snapshotData) {
        [self.mSnapshotData addEntriesFromDictionary:snapshotData];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kViewDebugSnapshotUpdateNotification object:self];
}

- (void)updateNodeSnapshot: (ADHViewNode *)node snapshot: (NSData *)snapshot {
    NSString *key = node.weakViewAddr;
    if(snapshot && key) {
        [self.mSnapshotData setObject:snapshot forKey:key];
    }
}

@end
