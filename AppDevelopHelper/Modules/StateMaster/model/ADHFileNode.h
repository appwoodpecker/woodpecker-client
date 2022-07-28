//
//  ADHFileNode.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/28.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHFileNode : NSObject

//基本属性
@property (nonatomic, strong) NSString *    name;
@property (nonatomic, assign) BOOL          isDir;
@property (nonatomic, assign) int32_t       fileSize;
@property (nonatomic, strong) NSMutableArray * children;
@property (nonatomic, weak) ADHFileNode *   parent;

///State
//正在编辑
@property (nonatomic, assign) BOOL editing;

- (NSString *)getPath;
- (void)deleteChild: (ADHFileNode *)child;
- (void)addChild: (ADHFileNode *)child atIndex: (NSInteger)index;
@end
