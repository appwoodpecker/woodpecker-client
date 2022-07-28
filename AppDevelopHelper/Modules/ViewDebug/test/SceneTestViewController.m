//
//  SceneTestViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/27.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "SceneTestViewController.h"
@import SceneKit;


@interface SceneTestViewController ()

@property (nonatomic, strong) SCNScene *scene;
@property (nonatomic, strong) SCNView *sceneView;

@end

@implementation SceneTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initScene];
}

- (void)initScene {
    NSView *contentView = self.view;
    SCNScene *scene = [[SCNScene alloc] init];
    SCNView *sceneView = [[SCNView alloc] initWithFrame:contentView.bounds];
    sceneView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    sceneView.scene = scene;
    sceneView.backgroundColor = [NSColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1.0f];
    self.sceneView = sceneView;
    self.scene = scene;
    
    SCNBox *box = [SCNBox boxWithWidth:1.0 height:1.0 length:1.0 chamferRadius:0];
    SCNNode *node = [SCNNode nodeWithGeometry:box];
    node.position = SCNVector3Zero;
    
    
    

    SCNCamera * camera = [[SCNCamera alloc] init];
    SCNNode * cameraNode = [[SCNNode alloc] init];
    cameraNode.camera = camera;
    sceneView.pointOfView = cameraNode;
    [contentView addSubview:self.sceneView];
}

@end
