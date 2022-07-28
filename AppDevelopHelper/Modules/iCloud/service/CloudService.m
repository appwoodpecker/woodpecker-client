//
//  CloudService.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/10/13.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "CloudService.h"

static NSMutableArray *serviceList = nil;

@implementation CloudService

+ (CloudService *)serviceWithContext: (AppContext *)context {
    if(!serviceList) {
        serviceList = [NSMutableArray array];
    }
    CloudService *targetService = nil;
    for (CloudService *service in serviceList) {
        if(service.context == context) {
            targetService = service;
            break;
        }
    }
    if(!targetService) {
        CloudService *service = [[CloudService alloc] init];
        service.context = context;
        [serviceList addObject:service];
        targetService = service;
    }
    return targetService;
}

#pragma mark -----------------   search   ----------------
/**
 检索
 第一步，找到所有符合检索条件的item,线性展开
 第二步，将线性结果，从底层找到上层
 */
- (ADHCloudItem *)searchPreviewTree: (ADHCloudItem *)rootItem withKeywords: (NSString *)keywords {
    [self resetSearchPreviewItem:rootItem];
    NSMutableArray * matchItems = [NSMutableArray array];
    [self searchPreviewItem:rootItem keywords:keywords intoResult:matchItems];
    ADHCloudItem * matchTree = [self producePreviewTreeWithResult:matchItems];
    return matchTree;
}

- (void)resetSearchPreviewItem: (ADHCloudItem *)cloudItem {
    cloudItem.filteredSubItems = nil;
    for (ADHCloudItem * subItem in cloudItem.subItems) {
        [self resetSearchPreviewItem:subItem];
    }
}

- (void)searchPreviewItem: (ADHCloudItem *)cloudItem keywords: (NSString *)keywords intoResult: (NSMutableArray *)matchItems {
    BOOL matched = ([cloudItem.name rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound);
    if(matched){
        [matchItems addObject:cloudItem];
    }
    if(cloudItem.isDir){
        NSArray * subItems = cloudItem.subItems;
        for (ADHCloudItem * subItem in subItems) {
            [self searchPreviewItem:subItem keywords:keywords intoResult:matchItems];
        }
    }
}

- (ADHCloudItem *)producePreviewTreeWithResult: (NSArray *)matchList {
    if(!matchList){
        matchList = @[];
    }
    NSMutableArray * resultItemList = [NSMutableArray arrayWithArray:matchList];
    //找到最底层levels
    NSInteger maxLevel = -1;
    for (ADHCloudItem * item in matchList) {
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
        for (ADHCloudItem * item in resultItemList) {
            if(item.level == level){
                [levelItems addObject:item];
            }
        }
        for (ADHCloudItem * item in levelItems) {
            //找出上层item
            ADHCloudItem * parent = item.parent;
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
    for (ADHCloudItem * item in resultItemList) {
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
    ADHCloudItem * rootItem = levelItemList[rootKey][0];
    [self produceSubItem:@[rootItem] withLevelItemDic:levelItemList];
    return rootItem;
}

- (void)produceSubItem: (NSArray *)previewItems withLevelItemDic:(NSDictionary *)levelItemList {
    if(previewItems.count == 0){
        return;
    }
    ADHCloudItem * firstItem = previewItems[0];
    NSInteger level = firstItem.level;
    NSInteger subLevel = level+1;
    NSNumber * subKey = [NSNumber numberWithInteger:subLevel];
    NSArray * subLevelItems = levelItemList[subKey];
    if(subLevelItems.count > 0){
        for (ADHCloudItem * previewItem in previewItems) {
            if(previewItem.isDir){
                NSMutableArray * subItems = [NSMutableArray array];
                for (ADHCloudItem * subItem in subLevelItems) {
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

@end
