//
//  ADHFileNode.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/28.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHFileNode.h"

@implementation ADHFileNode

- (NSString *)getPath {
    NSMutableArray *pathList = [NSMutableArray array];
    ADHFileNode *preNode = self;
    while (preNode) {
        if(preNode.name.length > 0) {
            [pathList insertObject:preNode.name atIndex:0];
        }
        preNode = preNode.parent;
    }
    NSString *path = [pathList componentsJoinedByString:@"/"];
    return path;
}

- (void)deleteChild: (ADHFileNode *)child {
    [self.children removeObject:child];
}

- (void)addChild: (ADHFileNode *)child atIndex: (NSInteger)index {
    child.parent = self;
    [self.children insertObject:child atIndex:index];
}

@end
