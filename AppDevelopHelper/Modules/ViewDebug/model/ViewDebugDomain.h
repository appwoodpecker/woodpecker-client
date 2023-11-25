//
//  ViewDebugDomain.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHViewNode.h"

extern CGFloat const kBaseNodeScale;
//node tree
extern NSString *const kViewDebugRootNodeUpdateNotification;
//node tree snapshot
extern NSString *const kViewDebugSnapshotUpdateNotification;
//选中node更新 {node:}
extern NSString *const kViewDebugNodeSelectStateNotification;
/**
 attribute page node属性更新通知
 {
    key: attr item.key
    node: which view node
 }
 */
extern NSString *const kViewDebugNodeAttributeUpdateNotification;

//ViewDebug域共用对象
@interface ViewDebugDomain : NSObject

@property (nonatomic, assign) CGSize appWindowSize;
@property (nonatomic, assign) CGFloat appWindowScale;
@property (nonatomic, strong) ADHViewNode *rootNode;
- (NSDictionary *)snapshotData;

/**
 根据关键字搜索node tree
 */
- (ADHViewNode *)searchPreviewTree: (ADHViewNode *)rootItem withKeywords: (NSString *)keywords;

/**
 snapshot
 */
- (void)resetSnapshot;
- (NSArray<NSString *> *)getNodeTreeAddrList: (ADHViewNode *)rootNode;
- (void)loadSnapshotData;

- (void)updateNodeSnapshot: (ADHViewNode *)node snapshot: (NSData *)snapshot;

@property (nonatomic, strong) NSString * serviceAddr;

@end
