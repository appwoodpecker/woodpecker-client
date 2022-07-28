//
//  ADHControllerHierarchy.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/4/22.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ControllerType) {
    ControllerTypeNormal=0, //ViewControler
    ControllerTypeNVC,      //NavigationController
    ControllerTypeTAB,      //TabBarController
    ControllerTypePAGE,     //PageViewController
};

@interface ADHControllerHierarchy : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, weak)  id instance;
@property (nonatomic, strong) NSString *instanceAddr;
//self.title or self.navigationitem.title or self.tabbarItem.title
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) ControllerType type;

@property (nonatomic, strong) NSArray<ADHControllerHierarchy *> *children;
@property (nonatomic, strong) ADHControllerHierarchy *parent;

@property (nonatomic, strong) ADHControllerHierarchy *presentedChild;
@property (nonatomic, strong) ADHControllerHierarchy *presentingParent;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL visible;

+ (ADHControllerHierarchy *)controllerWithDic: (NSDictionary *)data;
- (NSDictionary *)dicPresentation;

- (NSString *)traverseDescription;

@end











