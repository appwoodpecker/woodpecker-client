//
//  ADHViewNode.m
//  ADHClient
//
//  Created by 张小刚 on 2019/2/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHViewNode.h"

@interface ADHViewNode ()

@property (nonatomic, strong) NSMutableArray *mChildNodes;

@end

@implementation ADHViewNode

+ (ADHViewNode *)node {
    return [[ADHViewNode alloc] init];
}

- (void)addChild: (ADHViewNode *)node {
    if(!self.mChildNodes) {
        self.mChildNodes = [NSMutableArray array];
    }
    [self.mChildNodes addObject:node];
}

- (NSArray<ADHViewNode *> *)childNodes {
    return self.mChildNodes;
}

- (NSDictionary *)dicPresentation {
    ADHViewNode *node = self;
    return [self traverseNode:node intoParent:nil];
}

- (NSDictionary *)traverseNode: (ADHViewNode *)node intoParent: (NSMutableArray *)nodeList {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"addr"] = adhvf_safestringfy(node.instanceAddr);
    data[@"weakAddr"] = adhvf_safestringfy(node.weakViewAddr);
    data[@"class"] = adhvf_safestringfy(node.className);
    if(node.classList) {
        data[@"classList"] = node.classList;
    }
    data[@"level"] = [NSNumber numberWithInt:node.level];
    NSMutableArray *attrList = [NSMutableArray array];
    for (ADHAttribute *attr in node.attributes) {
        NSDictionary *data = [attr dicPresentation];
        [attrList addObject:data];
    }
    data[@"attributes"] = attrList;
    if(!nodeList) {
        //root
    }else {
        [nodeList addObject:data];
    }
    if(node.childNodes.count > 0) {
        NSMutableArray *nodeList = [NSMutableArray array];
        data[@"children"] = nodeList;
        for (NSInteger i=0; i<node.childNodes.count; i++) {
            ADHViewNode *childNode = node.childNodes[i];
            [self traverseNode:childNode intoParent:nodeList];
        }
    }
    return data;
}

+ (ADHViewNode *)nodeWithData: (NSDictionary *)data {
    return [ADHViewNode traverseNodeData:data parent:nil];
}

+ (ADHViewNode *)traverseNodeData: (NSDictionary *)data parent: (ADHViewNode *)parent {
    ADHViewNode *node = [ADHViewNode node];
    node.level = [data[@"level"] intValue];
    node.instanceAddr = data[@"addr"];
    node.weakViewAddr = data[@"weakAddr"];
    node.className = adhvf_safestringfy(data[@"class"]);
    if(data[@"classList"]) {
        node.classList = data[@"classList"];
    }
    NSArray *attributeList = data[@"attributes"];
    if([attributeList isKindOfClass:[NSArray class]]) {
        NSMutableArray *attributes = [NSMutableArray array];
        for (NSDictionary *attrData in attributeList) {
            ADHAttribute *attr = [ADHAttribute attributeWithData:attrData];
            //set view node attribute
            attr.viewNode = node;
            [attributes addObject:attr];
        }
        node.attributes = attributes;
    }
    if(!parent) {
        //root node
    }else {
        [parent addChild:node];
        node.parent = parent;
    }
    NSArray *children = data[@"children"];
    if(children && children.count > 0) {
        for (NSInteger i=0; i<children.count; i++) {
            NSDictionary *childData = children[i];
            [self traverseNodeData:childData parent:node];
        }
    }
    return node;
}

- (ADHViewAttribute *)viewAttribute {
    ADHViewAttribute *viewAttr = nil;
    NSInteger count = self.attributes.count;
    for (NSInteger i=0; i<count; i++) {
        ADHAttribute *attr = self.attributes[count-1-i];
        if([attr isKindOfClass:[ADHViewAttribute class]]) {
            viewAttr = (ADHViewAttribute *)attr;
            break;
        }
    }
    return viewAttr;
}

@end
