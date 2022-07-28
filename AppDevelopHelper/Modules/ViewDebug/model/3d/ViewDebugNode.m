//
//  ViewSKNode.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/16.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewDebugNode.h"
#import "ViewDebugDomain.h"

@interface ViewDebugNode ()

@end

@implementation ViewDebugNode

+ (ViewDebugNode *)nodeWithVNode: (ADHViewNode *)viewNode scale: (CGFloat)nodeScale {
    ADHViewAttribute *attr = [viewNode viewAttribute];
    if(attr.frame.width == 0 || attr.frame.height == 0) {
        return nil;
    }
    CGFloat width = attr.frame.width * nodeScale;
    CGFloat height = attr.frame.height * nodeScale;
    SCNPlane *plane = [SCNPlane planeWithWidth:width height:height];
    NSImage *image = [NSImage imageNamed:@"icon_transparent"];
    plane.firstMaterial.diffuse.contents = image;
    plane.firstMaterial.doubleSided = YES;
    ViewDebugNode *node = [[ViewDebugNode alloc] init];
    node.geometry = plane;
    node.viewNode = viewNode;
    if([ViewDebugNode isNodeTransparent:attr]) {
        [node addBorder];
    }
    return node;
}

+ (BOOL)isNodeTransparent: (ADHViewAttribute *)attr {
    BOOL isTransparent = NO;
    if (attr.backgroundColor.alpha == 0 || attr.alpha == 0) {
        isTransparent = YES;
    }
    return isTransparent;
}

- (void)addBorder {
    ViewDebugNode *node = self;
    SCNGeometry *gemotry = node.geometry;
    //add border
    SCNVector3 min, max;
    [gemotry getBoundingBoxMin:&min max:&max];
    SCNVector3 topLeft = SCNVector3Make(min.x, max.y, 0);
    SCNVector3 topRight = SCNVector3Make(max.x, max.y, 0);
    SCNVector3 bottomLeft = SCNVector3Make(min.x, min.y, 0);
    SCNVector3 bottomRight = SCNVector3Make(max.x, min.y, 0);
    
    NSColor *lineColor = [NSColor colorWithWhite:1.0 alpha:0.4];
    SCNNode *topLine = [self createLineFrom:topLeft to:topRight color:lineColor];
    SCNNode *leftLine = [self createLineFrom:topLeft to:bottomLeft color:lineColor];
    SCNNode *bottomLine = [self createLineFrom:bottomLeft to:bottomRight color:lineColor];
    SCNNode *rightLine = [self createLineFrom:topRight to:bottomRight color:lineColor];
    
    topLine.name = @"border";
    leftLine.name = @"border";
    bottomLine.name = @"border";
    rightLine.name = @"border";
    
    [node addChildNode:topLine];
    [node addChildNode:leftLine];
    [node addChildNode:bottomLine];
    [node addChildNode:rightLine];
}

- (NSArray<ViewDebugNode *> *)borderNodes {
    NSMutableArray *bNodes = [NSMutableArray array];
    NSArray *children = [self childNodes];
    for (SCNNode *node in children) {
        if([node.name isEqualToString:@"border"]) {
            [bNodes addObject:node];
        }
    }
    return bNodes;
}

- (void)recreateBorderIfNeeded {
    NSArray *borderNodes = [self borderNodes];
    if(borderNodes.count > 0) {
        for (SCNNode *node in borderNodes) {
            [node removeFromParentNode];
        }
        [self addBorder];
    }
}

- (void)addHighlightedBorder {
    ViewDebugNode *node = self;
    SCNNode * hNode = [node childNodeWithName:@"higlighted" recursively:NO];
    if(hNode) {
        //已经添加
        return;
    }
    SCNGeometry *gemotry = node.geometry;
    //add border
    SCNVector3 min, max;
    [gemotry getBoundingBoxMin:&min max:&max];
    SCNVector3 topLeft = SCNVector3Make(min.x, max.y, 0);
    SCNVector3 topRight = SCNVector3Make(max.x, max.y, 0);
    SCNVector3 bottomLeft = SCNVector3Make(min.x, min.y, 0);
    SCNVector3 bottomRight = SCNVector3Make(max.x, min.y, 0);
    
    NSColor *lineColor = [NSColor blueColor];
    SCNNode *topLine = [self createLineFrom:topLeft to:topRight color:lineColor];
    SCNNode *leftLine = [self createLineFrom:topLeft to:bottomLeft color:lineColor];
    SCNNode *bottomLine = [self createLineFrom:bottomLeft to:bottomRight color:lineColor];
    SCNNode *rightLine = [self createLineFrom:topRight to:bottomRight color:lineColor];
    
    topLine.name = @"higlighted";
    leftLine.name = @"higlighted";
    bottomLine.name = @"higlighted";
    rightLine.name = @"higlighted";
    
    [node addChildNode:topLine];
    [node addChildNode:leftLine];
    [node addChildNode:bottomLine];
    [node addChildNode:rightLine];

}

- (void)recreateSelectedNodeIfNeeded {
    NSArray *highlightNodes = [self highlightedNodes];
    if(highlightNodes.count > 0) {
        for (SCNNode *node in highlightNodes) {
            [node removeFromParentNode];
        }
    }
    SCNNode *selectedNode = [self selectedNode];
    BOOL selected = (selectedNode && !selectedNode.hidden);
    if(selectedNode) {
        [selectedNode removeFromParentNode];
    }
    if(selected) {
        [self addHighlightedBorder];
        [self setSelected:YES];
    }
}

- (NSArray<ViewDebugNode *> *)highlightedNodes {
    NSMutableArray *hNodes = [NSMutableArray array];
    NSArray *children = [self childNodes];
    for (SCNNode *node in children) {
        if([node.name isEqualToString:@"higlighted"]) {
            [hNodes addObject:node];
        }
    }
    return hNodes;
}

- (SCNNode *)selectedNode {
    SCNNode *sNode = [self childNodeWithName:@"selected" recursively:NO];
    return sNode;
}

- (void)setHighlighted: (BOOL)highlighted {
    if(highlighted) {
        //add highlighted border
        [self addHighlightedBorder];
        NSArray *hNodes = [self highlightedNodes];
        for (SCNNode *node in hNodes) {
            node.hidden = NO;
        }
    }else {
        NSArray *hNodes = [self highlightedNodes];
        for (SCNNode *node in hNodes) {
            node.hidden = YES;
        }
    }
}

- (void)setSelected: (BOOL)selected {
    ViewDebugNode *node = self;
    if(selected) {
        //add s node
        SCNPlane *plane = (SCNPlane *)node.geometry;
        SCNNode *sNode = [node childNodeWithName:@"selected" recursively:NO];
        if(!sNode) {
            SCNPlane *sPlane = [SCNPlane planeWithWidth:plane.width height:plane.height];
            sPlane.firstMaterial.diffuse.contents = [[NSColor blueColor] colorWithAlphaComponent:0.3];
            SCNNode *sNode = [SCNNode nodeWithGeometry:sPlane];
            sNode.name = @"selected";
            [node addChildNode:sNode];
        }else {
            sNode.hidden = NO;
        }
    }else {
        SCNNode *sNode = [node childNodeWithName:@"selected" recursively:NO];
        if(sNode) {
            sNode.hidden = YES;
        }
        [self setHighlighted:NO];
    }
}

                             

- (void)updateAttrState: (NSString *)key snapshot: (NSData *)snapshot scale: (CGFloat)nodeScale {
    ADHViewNode *viewNode = self.viewNode;
    SCNPlane *plane = (SCNPlane *)self.geometry;
    if([key isEqualToString:@"frame"]) {
        ADHViewAttribute *attr = [viewNode viewAttribute];
        
        CGFloat width = attr.frame.width * nodeScale;
        CGFloat height = attr.frame.height * nodeScale;
        BOOL sizeUpdate = NO;
        if(width != plane.width || height != plane.height) {
            sizeUpdate = YES;
        }
        plane.width = width;
        plane.height = height;
        ViewDebugNode *parent = (ViewDebugNode *)self.parentNode;
        if(parent) {
            SCNPlane *parentPlane = (SCNPlane *)(parent.geometry);
            CGFloat x = -(attr.frame.centerX * nodeScale - parentPlane.width/2.0f);
            CGFloat y = attr.frame.centerY * nodeScale - parentPlane.height/2.0f;
            SCNVector3 position = self.position;
            position.x = -x;
            position.y = -y;
            self.position = position;
        }
        if(sizeUpdate) {
            [self recreateBorderIfNeeded];
            [self recreateSelectedNodeIfNeeded];
        }
    }
    if(snapshot) {
        NSImage *image = [[NSImage alloc] initWithData:snapshot];
        if(image) {
            plane.firstMaterial.diffuse.contents = image;
        }
    }
}

- (void)updateSnapshot: (NSData *)imageData {
    NSImage *image = [[NSImage alloc] initWithData:imageData];
    SCNPlane *plane = (SCNPlane *)self.geometry;
    plane.firstMaterial.diffuse.contents = image;
}

#pragma mark -----------------   util   ----------------

- (SCNNode *)createLineFrom:(SCNVector3)start to: (SCNVector3)end color: (NSColor *)color {
    SCNGeometry *line = [self lineFrom:start toVector:end];
    SCNNode *lineNode = [SCNNode nodeWithGeometry:line];
    SCNMaterial * material = [[SCNMaterial alloc] init];
    material.diffuse.contents = color;
    line.materials = @[material];
    return lineNode;
}

- (SCNGeometry *)lineFrom: (SCNVector3 )start toVector: (SCNVector3)end {
    SCNVector3 vectors[2] = {start,end};
    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithVertices:vectors count:2];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:source.data primitiveType:SCNGeometryPrimitiveTypeLine primitiveCount:2 bytesPerIndex:source.data.length/2];
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[source] elements:@[element]];
    return geometry;
}


@end
