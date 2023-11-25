//
//  ViewSKNode.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/16.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewDebugNode.h"
#import "ViewDebugDomain.h"
#import "DeviceUtil.h"
#import "ViewDebugIndicatorNode.h"

@interface ViewDebugNode ()

@property (nonatomic, strong) ViewDebugIndicatorNode *indicatorNode;

@end

@implementation ViewDebugNode

+ (ViewDebugNode *)nodeWithVNode: (ADHViewNode *)viewNode {
    ADHViewAttribute *attr = [viewNode viewAttribute];
    if(attr.frame.width == 0 || attr.frame.height == 0) {
        return nil;
    }
    CGFloat width = attr.frame.width;
    CGFloat height = attr.frame.height;
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

#pragma mark alpha node border

- (void)addBorder {
    NSColor *lineColor = [NSColor colorWithWhite:1.0 alpha:0.4];
    [self addRectBorder:@"border" color:lineColor];
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

#pragma mark indicator

- (void)addIndicatorNodeIfNeeded {
    if (self.indicatorNode != nil) {
        return;
    }
    SCNPlane *plane = (SCNPlane *)self.geometry;
    SCNPlane *indicatorPlane = [SCNPlane planeWithWidth:plane.width height:plane.height];
    ViewDebugIndicatorNode *indicatorNode = (ViewDebugIndicatorNode *)[ViewDebugIndicatorNode nodeWithGeometry:indicatorPlane];
    indicatorNode.mainNode = self;
    [self addChildNode:indicatorNode];
    self.indicatorNode = indicatorNode;
}

#pragma mark highlighted

- (void)setHighlighted:(BOOL)highlighted {
    [self addIndicatorNodeIfNeeded];
    self.indicatorNode.highlighted = highlighted;
}

#pragma mark selected

- (void)setSelected:(BOOL)selected {
    [self addIndicatorNodeIfNeeded];
    self.indicatorNode.selected = selected;
}

#pragma mark focused

- (void)setFocused:(BOOL)focused {
    [self addIndicatorNodeIfNeeded];
    self.indicatorNode.focused = focused;
}

#pragma mark actions

- (void)updateAttrState: (NSString *)key snapshot: (NSData *)snapshot {
    ADHViewNode *viewNode = self.viewNode;
    SCNPlane *plane = (SCNPlane *)self.geometry;
    if([key isEqualToString:@"frame"]) {
        ADHViewAttribute *attr = [viewNode viewAttribute];
        
        CGFloat width = attr.frame.width;
        CGFloat height = attr.frame.height;
        BOOL sizeUpdate = NO;
        if(width != plane.width || height != plane.height) {
            sizeUpdate = YES;
        }
        plane.width = width;
        plane.height = height;
        ViewDebugNode *parent = (ViewDebugNode *)self.parentNode;
        if(parent) {
            SCNPlane *parentPlane = (SCNPlane *)(parent.geometry);
            CGFloat x = -(attr.frame.centerX - parentPlane.width/2.0f);
            CGFloat y = attr.frame.centerY - parentPlane.height/2.0f;
            SCNVector3 position = self.position;
            position.x = -x;
            position.y = -y;
            self.position = position;
        }
        if(sizeUpdate) {
            [self recreateBorderIfNeeded];
            if (self.indicatorNode) {
                [self.indicatorNode updateStyle];
            }
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

- (void)addRectBorder:(NSString *)name color:(NSColor *)color {
    ViewDebugNode *node = self;
    SCNGeometry *gemotry = node.geometry;
    //add border
    SCNVector3 min, max;
    [gemotry getBoundingBoxMin:&min max:&max];
    SCNVector3 topLeft = SCNVector3Make(min.x, max.y, 0);
    SCNVector3 topRight = SCNVector3Make(max.x, max.y, 0);
    SCNVector3 bottomLeft = SCNVector3Make(min.x, min.y, 0);
    SCNVector3 bottomRight = SCNVector3Make(max.x, min.y, 0);
    
    SCNNode *topLine = [self createLineFrom:topLeft to:topRight color:color];
    SCNNode *leftLine = [self createLineFrom:topLeft to:bottomLeft color:color];
    SCNNode *bottomLine = [self createLineFrom:bottomLeft to:bottomRight color:color];
    SCNNode *rightLine = [self createLineFrom:topRight to:bottomRight color:color];
    
    topLine.name = name;
    leftLine.name = name;
    bottomLine.name = name;
    rightLine.name = name;
    
    [node addChildNode:topLine];
    [node addChildNode:leftLine];
    [node addChildNode:bottomLine];
    [node addChildNode:rightLine];
}

@end
