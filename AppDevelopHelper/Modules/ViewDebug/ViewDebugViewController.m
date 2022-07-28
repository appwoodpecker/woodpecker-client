//
//  ViewDebugViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewDebugViewController.h"
#import "ViewHierarchyViewController.h"
#import "ViewAttributeViewController.h"
#import "ViewDebugDomain.h"
#import "ViewTreeViewController.h"


@interface ViewDebugViewController ()

@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *treeLayout;
@property (weak) IBOutlet NSView *hierarchyLayout;
@property (weak) IBOutlet NSView *attributeLayout;

@property (nonatomic, strong) ViewTreeViewController *treeVC;
@property (nonatomic, strong) ViewHierarchyViewController *hierarchyVC;
@property (nonatomic, strong) ViewAttributeViewController *attributeVC;

@property (nonatomic, strong) ViewDebugDomain *domain;

@end

@implementation ViewDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValue];
    [self setupAfterXib];
}

- (void)initValue {
    ViewDebugDomain *domain = [[ViewDebugDomain alloc] init];
    domain.context = self.context;
    self.domain = domain;
    self.domain.nodeScale = kBaseNodeScale;
}

- (void)setupAfterXib {
    ViewTreeViewController *tree = [[ViewTreeViewController alloc] init];
    tree.context = self.context;
    NSView *treeView = tree.view;
    treeView.frame = self.treeLayout.bounds;
    treeView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.treeLayout addSubview:treeView];
    self.treeVC = tree;
    self.treeVC.domain = self.domain;
    
    ViewHierarchyViewController *hierarchy = [[ViewHierarchyViewController alloc] init];
    hierarchy.context = self.context;
    NSView *hierarchyView = hierarchy.view;
    hierarchyView.frame = self.hierarchyLayout.bounds;
    hierarchyView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.hierarchyLayout addSubview:hierarchyView];
    self.hierarchyVC = hierarchy;
    self.hierarchyVC.domain = self.domain;
    
    ViewAttributeViewController *attribute = [[ViewAttributeViewController alloc] init];
    attribute.context = self.context;
    NSView *attributeView = attribute.view;
    attributeView.frame = self.attributeLayout.bounds;
    attributeView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.attributeLayout addSubview:attributeView];
    self.attributeVC = attribute;
    self.attributeVC.domain = self.domain;
    
    [self.hierarchyVC setAttributeVC:self.attributeVC];
    
    //tree view size
    CGRect treeViewRect = self.treeLayout.frame;
    treeViewRect.size.width = [self treePreferWidth];
    self.treeLayout.frame = treeViewRect;
    //attribute view size
    CGRect attrViewRect = self.attributeLayout.frame;
    attrViewRect.size.width = [self attributePreferWidth];
    self.attributeLayout.frame = attrViewRect;
    
}

- (CGFloat)treePreferWidth {
    return 300;
}

- (CGFloat)attributePreferWidth {
    return 300;
}

- (void)initUI {
    
}

@end
