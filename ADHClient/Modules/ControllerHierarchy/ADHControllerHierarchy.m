//
//  ADHControllerHierarchy.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/4/22.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHControllerHierarchy.h"

@implementation ADHControllerHierarchy

- (NSDictionary *)dicPresentation {
    ADHControllerHierarchy * controller = self;
    NSDictionary * data = [self traverseControllerData:controller];
    return data;
}

- (NSMutableDictionary *)traverseControllerData: (ADHControllerHierarchy *)controller
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"className"] = adhvf_safestringfy(controller.className);
    data[@"address"] = adhvf_safestringfy(controller.instanceAddr);
    data[@"title"] = adhvf_safestringfy(controller.title);
    data[@"type"] = [NSNumber numberWithInteger:controller.type];
    data[@"visible"] = controller.visible ?adhvf_const_strtrue():adhvf_const_strfalse();
    if(controller.children) {
        NSMutableArray *childenList = [NSMutableArray arrayWithCapacity:controller.children.count];
        for (ADHControllerHierarchy *child in controller.children) {
            NSMutableDictionary * subData = [self traverseControllerData:child];
            [childenList addObject:subData];
        }
        data[@"children"] = childenList;
    }
    if(controller.presentedChild) {
        NSMutableDictionary *subData = [self traverseControllerData:controller.presentedChild];
        data[@"presentedChild"] = subData;
    }
    data[@"index"] = [NSNumber numberWithInteger:controller.index];
    return data;
}

+ (ADHControllerHierarchy *)controllerWithDic: (NSDictionary *)dic
{
    ADHControllerHierarchy *controller = [ADHControllerHierarchy traverseDataController:dic];
    return controller;
}

+ (ADHControllerHierarchy *)traverseDataController: (NSDictionary *)data
{
    ADHControllerHierarchy *controller = [[ADHControllerHierarchy alloc] init];
    controller.className = data[@"className"];
    controller.instanceAddr = data[@"address"];
    controller.title = data[@"title"];
    controller.type = [data[@"type"] integerValue];
    controller.index = [data[@"index"] integerValue];
    controller.visible = [data[@"visible"] boolValue];
    NSArray *childenList = data[@"children"];
    if(childenList.count > 0){
        NSMutableArray * children = [NSMutableArray array];
        for (NSDictionary * subData in childenList) {
            ADHControllerHierarchy *child = [ADHControllerHierarchy traverseDataController:subData];
            child.parent = controller;
            [children addObject:child];
        }
        controller.children = children;
    }
    if(data[@"presentedChild"]) {
        NSDictionary *subData = data[@"presentedChild"];
        ADHControllerHierarchy *child = [ADHControllerHierarchy traverseDataController:subData];
        child.presentingParent = controller;
        controller.presentedChild = child;
    }
    return controller;
}

#pragma mark -----------------   debug   ----------------

- (NSString *)description {
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"%ld [%@]",(long)self.index, self.className];
    if(self.title.length > 0) {
        [content appendFormat:@" [%@]",self.title];
    }
    NSString *typeText = [ADHControllerHierarchy readbleType:self.type];
    if(typeText.length > 0) {
        [content appendFormat:@" [%@]",typeText];
    }
    if(self.children.count > 0) {
        [content appendFormat:@" [children: %zd]",(long)(self.children.count)];
    }
    if(self.presentingParent) {
        [content appendFormat:@" [presented]"];
    }
    if(self.presentedChild) {
        [content appendFormat:@" [presenting]"];
    }
    return content;
}

+ (NSString *)readbleType: (ControllerType)type {
    NSString * typeText = nil;
    switch (type) {
        case ControllerTypeNVC:
            typeText = @"Navigation";
            break;
        case ControllerTypeTAB:
            typeText = @"TabBar";
            break;
        case ControllerTypePAGE:
            typeText = @"PageView";
            break;
        default:
            typeText = @"";
            break;
    }
    return typeText;
}

- (NSString *)traverseDescription {
    NSString * text = [self traverseControllerDescription:self];
    return text;
}

- (NSString *)traverseControllerDescription: (ADHControllerHierarchy *)controller {
    NSMutableString *content = [NSMutableString string];
    NSInteger index = controller.index;
    for (NSInteger i=0; i<index; i++) {
        [content appendFormat:@"\t"];
    }
    [content appendFormat:@"%@\n",controller];
    for (ADHControllerHierarchy *child in controller.children) {
        NSString * childContent = [self traverseControllerDescription:child];
        [content appendString:childContent];
    }
    if(controller.presentedChild) {
        NSString *presentedContent = [self traverseControllerDescription:controller.presentedChild];
        [content appendString:presentedContent];
    }
    return content;
}




@end
