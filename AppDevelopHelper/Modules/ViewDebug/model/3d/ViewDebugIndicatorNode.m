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
    return [[NSColor blueColor] colorWithAlphaComponent:0.3];
}

- (NSColor *)highlightedBorderColor {
    return [NSColor blueColor];
}

- (NSColor *)focusedBorderColor {
    return [NSColor redColor];
}

- (NSColor *)focusedPlaneColor {
    return [[NSColor redColor] colorWithAlphaComponent:0.3];
}

#pragma mark util

- (SCNNode *)createLineFrom:(SCNVector3)start to:(SCNVector3)end {
    SCNVector3 vectors[2] = {start,end};
    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithVertices:vectors count:2];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:source.data primitiveType:SCNGeometryPrimitiveTypeLine primitiveCount:2 bytesPerIndex:source.data.length/2];
    SCNGeometry *line = [SCNGeometry geometryWithSources:@[source] elements:@[element]];
    SCNNode *lineNode = [SCNNode nodeWithGeometry:line];
    return lineNode;
}

- (void)addRectBorder {
    SCNNode *node = self;
    SCNGeometry *gemotry = node.geometry;
    //add border
    SCNVector3 min, max;
    [gemotry getBoundingBoxMin:&min max:&max];
    SCNVector3 topLeft = SCNVector3Make(min.x, max.y, 0);
    SCNVector3 topRight = SCNVector3Make(max.x, max.y, 0);
    SCNVector3 bottomLeft = SCNVector3Make(min.x, min.y, 0);
    SCNVector3 bottomRight = SCNVector3Make(max.x, min.y, 0);
    
    SCNNode *topLine = [self createLineFrom:topLeft to:topRight];
    SCNNode *leftLine = [self createLineFrom:topLeft to:bottomLeft];
    SCNNode *bottomLine = [self createLineFrom:bottomLeft to:bottomRight];
    SCNNode *rightLine = [self createLineFrom:topRight to:bottomRight];
    [node addChildNode:topLine];
    [node addChildNode:leftLine];
    [node addChildNode:bottomLine];
    [node addChildNode:rightLine];
    self.topLine = topLine;
    self.leftLine = leftLine;
    self.bottomLine = bottomLine;
    self.rightLine = rightLine;
}

@end

