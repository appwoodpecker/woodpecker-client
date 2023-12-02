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
#import "Woodpecker-Swift.h"

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
    [self addRectBorder:@"border" color:[[NSColor alloc] initWithHex:0xB7B7B7]];
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

- (SCNNode *)borderNodeWith:(CGFloat)width height:(CGFloat)height {
    SCNPlane *plane = [SCNPlane planeWithWidth:width height:height];
    return [SCNNode nodeWithGeometry:plane];
}

- (void)addRectBorder:(NSString *)name color:(NSColor *)color {
    SCNNode *node = self;
    SCNPlane *plane = (SCNPlane *)node.geometry;
    CGFloat borderWidth = 1;
    SCNNode *topBorder = [self borderNodeWith:plane.width + borderWidth height:borderWidth];
    SCNNode *bottomBorder = [self borderNodeWith:plane.width  + borderWidth height:borderWidth];
    SCNNode *leftBorder = [self borderNodeWith:borderWidth height:plane.height];
    SCNNode *rightBorder = [self borderNodeWith:borderWidth height:plane.height];
    SCNMaterial * material = [[SCNMaterial alloc] init];
    material.diffuse.contents = color;
    for (SCNNode *node in @[topBorder, bottomBorder, leftBorder, rightBorder]) {
        node.geometry.materials = @[material];
    }
    topBorder.position = SCNVector3Make(0, plane.height / 2, 0);
    bottomBorder.position = SCNVector3Make(0, -plane.height / 2, 0);
    leftBorder.position = SCNVector3Make(-plane.width / 2, 0, 0);
    rightBorder.position = SCNVector3Make(plane.width / 2, 0, 0);
    
    [node addChildNode:topBorder];
    [node addChildNode:bottomBorder];
    [node addChildNode:leftBorder];
    [node addChildNode:rightBorder];
}

@end
