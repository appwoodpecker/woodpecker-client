//
//  ViewSKNode.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/16.
//  Copyright © 2019 lifebetter. All rights reserved.
//

@import SceneKit;
#import "ADHViewNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewDebugNode : SCNNode

@property (nonatomic, strong) ADHViewNode * viewNode;

+ (ViewDebugNode *)nodeWithVNode: (ADHViewNode *)viewNode scale: (CGFloat)scale;

- (void)addBorder;
- (void)setHighlighted: (BOOL)highlighted;
- (void)setSelected: (BOOL)selected;

- (void)updateAttrState: (NSString *)key snapshot: (NSData *)snapshot scale: (CGFloat)nodeScale;
- (void)updateSnapshot: (NSData *)imageData;

@end

NS_ASSUME_NONNULL_END
