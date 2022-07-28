//
//  ADHViewNode.h
//  ADHClient
//
//  Created by 张小刚 on 2019/2/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHAttribute.h"

@interface ADHViewNode : NSObject

@property (nonatomic, strong) id weakView;
@property (nonatomic, strong) NSString * instanceAddr;
@property (nonatomic, strong) NSString * weakViewAddr;
@property (nonatomic, strong) NSString * className;
@property (nonatomic, strong) NSArray<NSString *> *classList;
@property (nonatomic, strong) NSArray<ADHAttribute *> * attributes;
@property (nonatomic, assign) int32_t level;
//mac端使用
@property (nonatomic, strong) NSData *snapshot;
//3d展示level mac端使用
@property (nonatomic, assign) NSInteger d3Level;

@property (nonatomic, strong) ADHViewNode *parent;
- (NSArray<ADHViewNode *> *)childNodes;
- (void)addChild: (ADHViewNode *)node;

+ (ADHViewNode *)node;

- (NSDictionary *)dicPresentation;
+ (ADHViewNode *)nodeWithData: (NSDictionary *)data;

- (ADHViewAttribute *)viewAttribute;

//search
@property (nonatomic, strong) NSArray * filteredChildNodes;

@end
