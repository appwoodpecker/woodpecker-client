//
//  ADHFileNodeUtil.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/29.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHFileNode.h"

@interface ADHFileNodeUtil : NSObject

+ (ADHFileNode *)scanFolder: (NSString *)folerPath;
+ (NSArray<ADHFileNode *> *)getLeafNodes: (ADHFileNode *)rootNode;

@end
