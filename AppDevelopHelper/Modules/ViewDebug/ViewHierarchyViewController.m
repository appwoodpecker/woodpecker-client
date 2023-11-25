//
//  ViewDebugViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewHierarchyViewController.h"
#import "ADHViewNode.h"
#import "ViewDebugNode.h"
#import "ADHViewDebugUtil.h"
#import "ViewDebugIndicatorNode.h"
#import "Woodpecker-Swift.h"
@import Masonry;
@import SceneKit;

static CGFloat const kNodeZSpace = 0.3;

@interface ViewNodeLevelInfo : NSObject

@property (nonatomic, strong) NSMutableArray *viewNodes;
@property (nonatomic, assign) CGRect unionRect;

@end

@implementation ViewNodeLevelInfo

@end

@interface ViewHierarchyViewController ()

@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSView *contentView;
@property (nonatomic, strong) SCNScene *scene;
@property (nonatomic, strong) SCNView *sceneView;
@property (weak) IBOutlet NSTextField *tipLabel;

@property (nonatomic, strong) ADHViewNode *nodeTree;
@property (nonatomic, strong) NSDictionary *snapshotData;
@property (nonatomic, strong) ViewDebugNode *contentNode;

@property (nonatomic, weak) ViewDebugNode *selectedNode;
@property (nonatomic, weak) ViewDebugNode *highlightedNode;

@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL bViewLayouted;
@property (nonatomic, strong) ViewMeasurePreviewView *measureView;


@property (nonatomic, assign) BOOL optionPressed;

@end

@implementation ViewHierarchyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValue];
    [self setupAfterXib];
    [self initUI];
    [self addNotification];
}

- (void)initValue {
    
}

- (void)setupAfterXib {
    self.actionLayout.wantsLayer = YES;
    [self updateAppearanceUI];
    [self.view addSubview:self.measureView];
    [self.measureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).inset(320);
        make.right.equalTo(self.view).inset(200);
    }];
}

- (void)initUI {
    self.tipLabel.stringValue = @"";
    [self initScene];
}

- (void)initScene {
    SCNScene *scene = [[SCNScene alloc] init];
    SCNView *sceneView = [[SCNView alloc] initWithFrame:self.contentView.bounds];
    sceneView.allowsCameraControl = YES;
    sceneView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    sceneView.scene = scene;
    sceneView.backgroundColor = [NSColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1.0f];
    self.sceneView = sceneView;
    self.scene = scene;
    CGFloat scale = 0.013;
    scene.rootNode.scale = SCNVector3Make(scale, scale, 1);
    SCNCamera * camera = [[SCNCamera alloc] init];
    camera.usesOrthographicProjection = YES;
    camera.orthographicScale = 5;
    camera.automaticallyAdjustsZRange = YES;
    
    SCNNode * cameraNode = [[SCNNode alloc] init];
    cameraNode.camera = camera;
    cameraNode.position = SCNVector3Make(0, 0, 10000);
    sceneView.pointOfView = cameraNode;
    [self.contentView addSubview:self.sceneView];
    
    NSClickGestureRecognizer *recognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(clickGestureRecognized:)];
    [self.sceneView addGestureRecognizer:recognizer];
    //double click to flatten
    NSClickGestureRecognizer *doubleClick = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClickRecognized:)];
    doubleClick.numberOfClicksRequired = 2;
    [self.sceneView addGestureRecognizer:doubleClick];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRootNodeUpdate:) name:kViewDebugRootNodeUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSnapshotUpdate:) name:kViewDebugSnapshotUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNodeSelectStateUpdate:) name:kViewDebugNodeSelectStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNodeAttrUpdate:) name:kViewDebugNodeAttributeUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
    
}

- (void)updateAppearanceUI {
    self.actionLayout.layer.backgroundColor = [Appearance barBackgroundColor].CGColor;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [self installTrackingArea];
    if(!self.bViewLayouted) {
        [self.view.window makeFirstResponder:self.sceneView];
        self.bViewLayouted = YES;
    }
}

- (void)installTrackingArea {
    if(self.trackingArea) {
        [self.sceneView removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.sceneView.bounds options:NSTrackingMouseMoved|NSTrackingActiveWhenFirstResponder owner:self userInfo:nil];
    [self.sceneView addTrackingArea:trackingArea];
    self.trackingArea = trackingArea;
}

//root node update
- (void)onRootNodeUpdate: (NSNotification *)noti {
    self.nodeTree = self.domain.rootNode;
    self.snapshotData = self.domain.snapshotData;
    [self renderNodeTree];
    self.measureView.rootNode = self.domain.rootNode;
}

- (void)onSnapshotUpdate: (NSNotification *)noti {
    [self updateTreeSnapshot];
}

- (void)renderNodeTree {
    //reset
    if(self.contentNode) {
        [self.contentNode removeFromParentNode];
        self.contentNode = nil;
    }
    self.selectedNode = nil;
    self.highlightedNode = nil;
    [self updateNodeTipUI];
    if (self.context.app.frameworkVersionValue >= 131) {
        //调整展示level
        NSMutableDictionary<NSNumber *, ViewNodeLevelInfo *> *levelInfo = [NSMutableDictionary dictionary];
        [self traverseNodeLevel:self.nodeTree minLevel:self.nodeTree.level leveledViewNodes:levelInfo];
        [self renderNode:self.nodeTree parent:nil];
    } else {
        //兼容131之前版本，因为之前版本view没有frameInWindow属性
        int level = 0;
        [self renderNode:self.nodeTree parent:nil baseLevel:0 level:&level];
    }
    [self flattenHierarchyView];
}

- (void)traverseNodeLevel:(ADHViewNode *)vNode minLevel:(NSInteger)minLevel leveledViewNodes:(NSMutableDictionary<NSNumber *, ViewNodeLevelInfo *> *)levelInfos {
    NSArray *levelKeys = [levelInfos allKeys];
    NSArray *levels = [levelKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber *level1, NSNumber *level2) {
        return [level1 compare:level2];
    }];
    NSInteger maxLevel = minLevel;
    if (levels.count > 0) {
        maxLevel = [[levels lastObject] integerValue];
    }
    NSInteger thisLevel = minLevel;
    ADHViewAttribute *attr = [vNode viewAttribute];
    CGRect thisFrame = [ADHViewDebugUtil cgFrameWithAdhFrame:attr.frameInWindow];
    BOOL overwrap = NO;
    for (NSInteger testLevel = maxLevel;testLevel >= minLevel; testLevel--) {
        //遍历每一层level的view
        NSNumber *key = [NSNumber numberWithInteger:testLevel];
        ViewNodeLevelInfo *levelInfo = levelInfos[key];
        if (!levelInfo) {
            continue;
        }
        //levelInfo.unionRect存储有该level所有view的frame最大覆盖区域，可以快速检查，如果与最大区域有交集再具体检查
        CGRect resultFrame = CGRectIntersection(levelInfo.unionRect,thisFrame);
        if (!CGRectIsNull(resultFrame) && (resultFrame.size.width > 0.01 && resultFrame.size.height > 0.01)) {
            NSMutableArray *viewNodes = levelInfo.viewNodes;
            for (ADHViewNode *vNode in viewNodes) {
                ADHViewAttribute *attr = [vNode viewAttribute];
                CGRect viewFrame = [ADHViewDebugUtil cgFrameWithAdhFrame:attr.frameInWindow];
                CGRect resultFrame = CGRectIntersection(viewFrame,thisFrame);
                if (!CGRectIsNull(resultFrame) && (resultFrame.size.width > 0.01 && resultFrame.size.height > 0.01)) {
                    overwrap = YES;
                    break;
                }
            }
            if (overwrap) {
                thisLevel = testLevel + 1;
                break;
            }
        }
    }
    vNode.d3Level = thisLevel;
    NSNumber *levelKey = [NSNumber numberWithInteger:thisLevel];
    ViewNodeLevelInfo *thisLevelInfo = levelInfos[levelKey];
    if (!thisLevelInfo) {
        thisLevelInfo = [ViewNodeLevelInfo new];
        thisLevelInfo.viewNodes = [NSMutableArray array];
        thisLevelInfo.unionRect = CGRectZero;
        levelInfos[levelKey] = thisLevelInfo;
    }
    [thisLevelInfo.viewNodes addObject:vNode];
    thisLevelInfo.unionRect = CGRectUnion(thisLevelInfo.unionRect, thisFrame);
    for (ADHViewNode *subNode in vNode.childNodes) {
        [self traverseNodeLevel:subNode minLevel:thisLevel+1 leveledViewNodes:levelInfos];
    }
}

- (void)renderNode: (ADHViewNode *)vNode parent: (SCNNode *)parent {
    ADHViewAttribute *attr = [vNode viewAttribute];
    ViewDebugNode *node = [ViewDebugNode nodeWithVNode:vNode];
    if(!node) {
        return;
    }
    if(!parent) {
        //root
        node.position = SCNVector3Zero;
        [self.scene.rootNode addChildNode:node];
        self.contentNode = node;
    }else {
        SCNPlane *parentPlane = (SCNPlane *)(parent.geometry);
        CGFloat x = -(attr.frame.centerX - parentPlane.width/2.0f);
        CGFloat y = attr.frame.centerY - parentPlane.height/2.0f;
        CGFloat z = (vNode.d3Level-vNode.parent.d3Level) * kNodeZSpace;
        SCNVector3 position = SCNVector3Make(-x, -y, z);
        node.position = position;
        [parent addChildNode:node];
    }
    if(vNode.childNodes.count > 0) {
        for (NSInteger i=0; i<vNode.childNodes.count; i++) {
            ADHViewNode *childVNode = vNode.childNodes[i];
            [self renderNode:childVNode parent:node];
        }
    }
}

- (void)renderNode: (ADHViewNode *)vNode parent: (SCNNode *)parent baseLevel: (int)baseLevel level: (int *)level {
    ADHViewAttribute *attr = [vNode viewAttribute];
    ViewDebugNode *node = [ViewDebugNode nodeWithVNode:vNode];
    if(!node) {
        return;
    }
    if(!parent) {
        //root
        node.position = SCNVector3Zero;
        [self.scene.rootNode addChildNode:node];
        self.contentNode = node;
    }else {
        SCNPlane *parentPlane = (SCNPlane *)(parent.geometry);
        CGFloat x = -(attr.frame.centerX - parentPlane.width/2.0f);
        CGFloat y = attr.frame.centerY - parentPlane.height/2.0f;
        CGFloat z = (*level - baseLevel) * kNodeZSpace;
        SCNVector3 position = SCNVector3Make(-x, -y, z);
        node.position = position;
        [parent addChildNode:node];
    }
    if(vNode.childNodes.count > 0) {
        baseLevel = *level;
        *level += 1;
        for (NSInteger i=0; i<vNode.childNodes.count; i++) {
            ADHViewNode *childVNode = vNode.childNodes[i];
            int thisLevel = *level;
            [self renderNode:childVNode parent:node baseLevel:baseLevel level:level];
            if(*level > thisLevel && i < vNode.childNodes.count-1) {
                *level += 1;
            }
        }
    }
}


- (void)updateTreeSnapshot {
    if(!self.contentNode) {
        return;
    }
    NSDictionary *snapshotData = self.domain.snapshotData;
    ADHViewNode *vNode = self.contentNode.viewNode;
    NSString *key = vNode.weakViewAddr;
    NSData *imageData = snapshotData[key];
    [self.contentNode updateSnapshot:imageData];
    [self traverseUpdateNodeSnapshot:self.contentNode data:snapshotData];
}

- (void)traverseUpdateNodeSnapshot:(ViewDebugNode *)node data: (NSDictionary *)snapshotData {
    for (ViewDebugNode *child in node.childNodes) {
        if([child isKindOfClass:[ViewDebugNode class]]) {
            ADHViewNode *vNode = child.viewNode;
            NSString *key = vNode.weakViewAddr;
            NSData *imageData = snapshotData[key];
            [child updateSnapshot:imageData];
        }
    }
    for (ViewDebugNode *child in node.childNodes) {
        [self traverseUpdateNodeSnapshot:child data:snapshotData];
    }
}

#pragma mark -----------------   notification   ----------------

- (void)onNodeSelectStateUpdate:(NSNotification *)noti {
    if(noti.object == self) {
        return;
    }
    ADHViewNode *vnode = noti.userInfo[@"node"];
    ViewDebugNode *node = nil;
    if(vnode) {
        node = [self findDebugNodeWithvNode:vnode];
    }
    [self updateSelectedNode:node];
}

- (ViewDebugNode *)findDebugNodeWithvNode:(ADHViewNode *)vnode {
    ViewDebugNode *targetNode = [self traverseNode:self.contentNode targetNode:vnode];
    return targetNode;
}

- (ViewDebugNode *)traverseNode:(ViewDebugNode *)node targetNode: (ADHViewNode *)vNode {
    ViewDebugNode *targetNode = nil;
    if(node.viewNode != vNode) {
        if(node.childNodes) {
            for (ViewDebugNode *child in node.childNodes) {
                if([child isKindOfClass:[ViewDebugNode class]]) {
                    targetNode = [self traverseNode:child targetNode:vNode];
                    if(targetNode) {
                        break;
                    }
                }
            }
        }
    }else {
        targetNode = node;
    }
    return targetNode;
}

//node属性更新
- (void)onNodeAttrUpdate: (NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    NSString *key = userInfo[@"key"];
    ADHViewNode *node = userInfo[@"node"];
    if(key && node) {
        ViewDebugNode *dNode = [self findDebugNodeWithvNode:node];
        if(dNode) {
            NSData *snapshot = [self.domain snapshotData][node.weakViewAddr];
            [dNode updateAttrState:key snapshot:snapshot];
        }
    }
}

#pragma mark -----------------   event   ----------------

- (void)mouseMoved:(NSEvent *)event {
    NSPoint eventLocation = [event locationInWindow];
    NSPoint location = [self.view convertPoint:eventLocation fromView:nil];
    SCNHitTestResult *result = [[self.sceneView hitTest:location options:nil] firstObject];
    SCNNode *testNode = (SCNNode *)result.node;
    ViewDebugNode *node = nil;
    if ([testNode isKindOfClass:[ViewDebugIndicatorNode class]]) {
        node = [(ViewDebugIndicatorNode *)testNode mainNode];
    } else if ([testNode isKindOfClass:[ViewDebugNode class]]) {
        node = (ViewDebugNode *)testNode;
    }
    if(![node isKindOfClass:[ViewDebugNode class]]) {
        if(self.highlightedNode && self.highlightedNode != self.selectedNode) {
            [self.highlightedNode setHighlighted:NO];
            [self.highlightedNode setFocused:NO];
            self.highlightedNode = nil;
        }
    } else {
        if(self.highlightedNode == node) {
            return;
        }
        if(self.highlightedNode && self.highlightedNode != self.selectedNode) {
            [self.highlightedNode setHighlighted:NO];
            [self.highlightedNode setFocused:NO];
            self.highlightedNode = nil;
        }
        [node setHighlighted:YES];
        self.highlightedNode = node;
        if (self.optionPressed) {
            [node setFocused:YES];
        }
    }
}

- (void)clickGestureRecognized:(NSClickGestureRecognizer *)recognizer {
    NSPoint location = [recognizer locationInView:self.sceneView];
    SCNHitTestResult *result = [[self.sceneView hitTest:location options:nil] firstObject];
    ViewDebugNode *node = (ViewDebugNode *)result.node;
    [self updateSelectedNode:node];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if(self.selectedNode) {
        ADHViewNode *vnode = self.selectedNode.viewNode;
        if(vnode) {
            info[@"node"] = vnode;
        }
    }
    [self updateMeasureUI];
    //notify
    [[NSNotificationCenter defaultCenter] postNotificationName:kViewDebugNodeSelectStateNotification object:self userInfo:info];
}

- (void)updateSelectedNode:(ViewDebugNode *)node {
    if(![node isKindOfClass:[ViewDebugNode class]]) {
        if(self.selectedNode) {
            [self.selectedNode setSelected:NO];
            self.selectedNode = nil;
        }
    }else {
        
        if(self.selectedNode == node) {
            return;
        }
        if(self.selectedNode) {
            [self.selectedNode setSelected:NO];
            self.selectedNode = nil;
        }
        [node setSelected:YES];
        self.selectedNode = node;
    }
    [self updateNodeTipUI];
}

- (void)updateNodeTipUI {
    if(self.selectedNode) {
        ADHViewNode *viewNode = self.selectedNode.viewNode;
        self.tipLabel.stringValue = [NSString stringWithFormat:@"%@  %@",viewNode.className,viewNode.instanceAddr];
    }else {
        self.tipLabel.stringValue = @"";
    }
}


//down可能多次， up有一次
- (void)flagsChanged:(NSEvent *)event {
    if(event.modifierFlags & NSEventModifierFlagOption) {
        NSLog(@"alt is down!!!");
        if (self.optionPressed) {
            return;
        }
        self.optionPressed = YES;
        [self onOptionPressed];
    }
    else if([event keyCode] == 58 || [event keyCode] == 61) {
        NSLog(@"alt is up!!!");
        self.optionPressed = NO;
        [self onOptionReleased];
    }
}

- (void)onOptionPressed {
    if (self.highlightedNode == nil) {
        return;
    }
    [self.highlightedNode setFocused:YES];
    [self updateMeasureUI];
}

- (void)onOptionReleased {
    if (self.highlightedNode == nil) {
        return;
    }
    [self.highlightedNode setFocused:NO];
    [self updateMeasureUI];
}


- (void)doubleClickRecognized:(NSClickGestureRecognizer *)recognizer {
    NSPoint location = [recognizer locationInView:self.sceneView];
    SCNHitTestResult *result = [[self.sceneView hitTest:location options:nil] firstObject];
    if(!result) {
        [self flattenHierarchyView];
    }
}

- (void)flattenHierarchyView {
    SCNNode *camera = self.sceneView.pointOfView;
    camera.eulerAngles = SCNVector3Zero;
    camera.position = SCNVector3Make(0, 0, 10000);
}

#pragma mark measure

- (ViewMeasurePreviewView *)measureView {
    if (!_measureView) {
        _measureView = [ViewMeasurePreviewView createView];
    }
    return _measureView;
}

- (void)updateMeasureUI {
    self.measureView.mainNode = self.selectedNode.viewNode;
    self.measureView.targetNode = self.highlightedNode.viewNode;
}

@end
