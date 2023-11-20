//
//  ViewDebugIndicatorNode.h
//  Woodpecker
//
//  Created by 张小刚 on 2023/11/19.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "ViewDebugNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewDebugIndicatorNode : SCNNode

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL focused;
@property (nonatomic, assign) BOOL highlighted;
- (void)updateStyle;

@property (nonatomic, weak) ViewDebugNode *mainNode;


@end

NS_ASSUME_NONNULL_END
