//
//  ViewDebugIndicatorNode.m
//  Woodpecker
//
//  Created by 张小刚 on 2023/11/19.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import "ViewDebugIndicatorNode.h"
#import "ViewDebugDomain.h"

@interface ViewDebugIndicatorNode ()

//border
@property (nonatomic, strong) SCNNode *topLine;
@property (nonatomic, strong) SCNNode *leftLine;
@property (nonatomic, strong) SCNNode *bottomLine;
@property (nonatomic, strong) SCNNode *rightLine;

@end

@implementation ViewDebugIndicatorNode

- (void)updateStyle {
    SCNPlane *plane = (SCNPlane *)self.geometry;
    NSColor *planeColor = [NSColor clearColor];
    NSColor *borderColor = [NSColor clearColor];
    if (self.selected) {
        planeColor = [self selectedPlaneColor];
    } else if (self.focused) {
        planeColor = [self focusedPlaneColor];
        borderColor = [self focusedBorderColor];
    } else if (self.highlighted) {
        borderColor = [self highlightedBorderColor];
    }
    plane.firstMaterial.diffuse.contents = planeColor;
    NSArray *borderLines = self.borderLines;
    for (SCNNode *lineNode in borderLines) {
        SCNGeometry *line = lineNode.geometry;
        line.firstMaterial.diffuse.contents = borderColor;
    }
}

- (void)createBorderIfNeeded {
    if (self.topLine != nil) {
        return;
    }
    [self addRectBorder];
}

- (NSArray *)borderLines {
    return @[self.topLine, self.leftLine, self.bottomLine, self.rightLine];
}

- (void)setSelected:(BOOL)selected {
    [self createBorderIfNeeded];
    _selected = selected;
    [self updateStyle];
}

- (void)setFocused:(BOOL)focused {
    [self createBorderIfNeeded];
    _focused = focused;
    [self updateStyle];
}

- (void)setHighlighted:(BOOL)highlighted {
    [self createBorderIfNeeded];
    _highlighted = highlighted;
    [self updateStyle];
}

- (NSColor *)selectedPlaneColor {
    return [[NSColor systemBlueColor] colorWithAlphaComponent:0.5];
}

- (NSColor *)highlightedBorderColor {
    return [NSColor systemBlueColor];
}

- (NSColor *)focusedBorderColor {
    return [NSColor systemRedColor];
}

- (NSColor *)focusedPlaneColor {
    return [[NSColor systemRedColor] colorWithAlphaComponent:0.3];
}

#pragma mark util

- (SCNNode *)borderNodeWith:(CGFloat)width height:(CGFloat)height {
    SCNPlane *plane = [SCNPlane planeWithWidth:width height:height];
    return [SCNNode nodeWithGeometry:plane];
}

- (void)addRectBorder {
    SCNNode *node = self;
    SCNPlane *plane = (SCNPlane *)node.geometry;
    CGFloat borderWidth = 1;
    SCNNode *topBorder = [self borderNodeWith:plane.width + borderWidth height:borderWidth];
    SCNNode *bottomBorder = [self borderNodeWith:plane.width  + borderWidth height:borderWidth];
    SCNNode *leftBorder = [self borderNodeWith:borderWidth height:plane.height];
    SCNNode *rightBorder = [self borderNodeWith:borderWidth height:plane.height];
    
    topBorder.position = SCNVector3Make(0, plane.height / 2, 0);
    bottomBorder.position = SCNVector3Make(0, -plane.height / 2, 0);
    leftBorder.position = SCNVector3Make(-plane.width / 2, 0, 0);
    rightBorder.position = SCNVector3Make(plane.width / 2, 0, 0);
    
    [node addChildNode:topBorder];
    [node addChildNode:bottomBorder];
    [node addChildNode:leftBorder];
    [node addChildNode:rightBorder];
    self.topLine = topBorder;
    self.bottomLine = bottomBorder;
    self.leftLine = leftBorder;
    self.rightLine = rightBorder;
}

@end

