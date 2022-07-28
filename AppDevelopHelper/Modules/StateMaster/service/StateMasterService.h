//
//  StateMasterService.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/30.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StateItem.h"

extern NSString *const kStateConfigName;
extern NSString *const kStateConfigTitleKey;
extern NSString *const kStateConfigSortKey;

extern NSString *const kStateItemSandbox;
extern NSString *const kStateItemUserDefaults;

@interface StateMasterService : NSObject

@property (nonatomic, weak) AppContext *context;

+ (StateMasterService *)serviceWithContext: (AppContext *)context;

//sync
- (void)syncStateAtPath: (NSString *)statePath onProgress:(void (^)(float progress))progressBlock onCompletion: (void (^)(void))completionBlock onFailed:(void (^)(BOOL paused))failedBlock;
//pause
- (void)pauseCurrentSync;

//state management
- (void)refreshStateWithCompletion: (void (^)(void))completionBlock;
- (NSArray<StateItem *> *)getAppItems;
- (NSArray<StateItem *> *)getSharedItems;
- (void)moveStateItemForward: (StateItem *)stateItem;
- (void)saveStateItemData: (StateItem *)item;

//add util
- (NSMenuItem *)makeStateMasterMenu: (id)target action: (SEL)selector;
- (void)addFileAtPath: (NSString *)filePath toState: (StateItem *)stateItem statePath: (NSString *)statePath;
- (void)addUserDefaultsItem: (NSString *)key value: (id)value toState: (StateItem *)stateItem;

@end
