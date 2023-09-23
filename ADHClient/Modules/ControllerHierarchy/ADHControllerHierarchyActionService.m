//
//  ControllerHierarchyActionService.m
//  Demo
//
//  Created by zxd on 2018/4/21.
//  Copyright © 2018年 zhangxg. All rights reserved.
//

#import "ADHControllerHierarchyActionService.h"
#import "ADHControllerHierarchy.h"

@interface ADHControllerHierarchyActionService ()

@property (nonatomic, strong) NSArray *visibleViewControllers;

@end

@implementation ADHControllerHierarchyActionService

/**
 service name
 */
+ (NSString *)serviceName {
    return @"adh.controller-hierarchy";
}

/**
 action list
 
 return @{
 "actionName1" : selector1 string,
 "actionName2" : selector2 string,
 };
 */
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"hierarchy" : NSStringFromSelector(@selector(controllerHierarchyRequest:)),
             @"top" : NSStringFromSelector(@selector(topControllerRequest:)),
             };
}

/**
 YES: all request use one shared service instance.
 NO: each request use a new service instance.
 */
+ (BOOL)isShared {
    return YES;
}

- (void)updateVisibleViewController {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *vc = window.rootViewController;
    NSArray *vcs = [self traverseVisibleViewController:@[vc]];
    self.visibleViewControllers = vcs;
}

/**
 是否有presentedVC
 有则下级为presentedVC
 没有，检查是否为容器
 为容器，则下级为子controller
 非容器，没有下级
 ------
 有无下级
 有下级继续遍历
 没有则自己为顶层
 */
- (NSArray *)traverseVisibleViewController: (NSArray *)vcs {
    NSMutableArray *resultVCS = [NSMutableArray array];
    for (UIViewController *vc in vcs) {
        NSMutableArray *thisTopVCS = [NSMutableArray array];
        if(vc.presentedViewController){
            //优先present
            [thisTopVCS addObject:vc.presentedViewController];
        }else {
            if([vc isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nvc = (UINavigationController *)vc;
                if([nvc visibleViewController]) {
                    [thisTopVCS addObject:[nvc visibleViewController]];
                }
            }else if([vc isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabVC = (UITabBarController *)vc;
                if(tabVC.selectedViewController){
                    [thisTopVCS addObject:tabVC.selectedViewController];
                }
            }else if([vc isKindOfClass:[UIPageViewController class]]) {
                UIPageViewController *pageVC = (UIPageViewController *)vc;
                if(pageVC.viewControllers) {
                    [thisTopVCS addObjectsFromArray:pageVC.viewControllers];
                }
            }else if(vc.childViewControllers.count > 0){
                //取最后一个
                [thisTopVCS addObject:[vc.childViewControllers lastObject]];
            }
        }
        if(thisTopVCS.count > 0){
            //存在下级controller，则继续遍历
            NSArray *topVCS = [self traverseVisibleViewController:thisTopVCS];
            [resultVCS addObjectsFromArray:topVCS];
        }else {
            //不存在自己则为顶层
            [resultVCS addObject:vc];
        }
    }
    return resultVCS;
}

- (void)topControllerRequest: (ADHRequest *)request {
    __weak typeof(self) wself = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [wself updateVisibleViewController];
        UIViewController *topVC = self.visibleViewControllers.lastObject;
        if (topVC != nil) {
            NSString *className = NSStringFromClass(topVC.class) ?: @"";
            NSString *addr = [self getInstanceAddr:topVC] ?: @"";
            NSString *content = [NSString stringWithFormat:@"%@ (%@)",className,addr];
            [request finishWithBody:@{
                @"success" : @(1),
                @"content" : adhvf_safestringfy(content),
            }];
        } else {
            [request finishWithBody:@{
                @"success" : @(0),
            }];
        }
        //release
        wself.visibleViewControllers = nil;
    });
}


- (void)controllerHierarchyRequest: (ADHRequest *)request {
    __weak typeof(self) wself = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [wself updateVisibleViewController];
        //switch to main thread
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *vc = window.rootViewController;
        ADHControllerHierarchy * controller = [wself traverseViewController:vc hierarchyIndex:0];
        //release
        wself.visibleViewControllers = nil;
        NSDictionary *data = [controller dicPresentation];
        NSString *content = [data adh_jsonPresentation];
        [request finishWithBody:@{
                                  @"content" : adhvf_safestringfy(content),
                                  }];
    });
}

- (NSString *)getInstanceAddr: (UIViewController *)vc {
    return [NSString stringWithFormat:@"%p",vc];
}

- (ADHControllerHierarchy *)traverseViewController: (UIViewController *)vc hierarchyIndex:(NSInteger)index {
    ADHControllerHierarchy *controller = [[ADHControllerHierarchy alloc] init];
    controller.index = index;
    controller.className = NSStringFromClass([vc class]);
    NSString *title = vc.title;
    if(title.length == 0) {
        if(vc.navigationController) {
            title = vc.navigationItem.title;
        }
    }
    if(title.length == 0) {
        if(vc.tabBarController) {
            title = vc.tabBarItem.title;
        }
    }
    controller.title = title;
    controller.instance = vc;
    controller.instanceAddr = [self getInstanceAddr:vc];
    BOOL visible = NO;
    if([self.visibleViewControllers containsObject:vc]) {
        visible = YES;
    }
    controller.visible = visible;
    ControllerType type = ControllerTypeNormal;
    if([vc isKindOfClass:[UINavigationController class]]) {
        type = ControllerTypeNVC;
    }else if([vc isKindOfClass:[UITabBarController class]]) {
        type = ControllerTypeTAB;
    }else if([vc isKindOfClass:[UIPageViewController class]]) {
        type = ControllerTypePAGE;
    }
    controller.type = type;
    
    //child
    NSArray *childVCs = vc.childViewControllers;
    if(childVCs.count > 0) {
        NSMutableArray *childrens = [NSMutableArray arrayWithCapacity:childVCs.count];
        for (UIViewController *childVC in childVCs) {
            ADHControllerHierarchy *child = [self traverseViewController:childVC hierarchyIndex:index+1];
            child.parent = controller;
            [childrens addObject:child];
        }
        controller.children = childrens;
    }
    //present
    UIViewController *presentedVC = vc.presentedViewController;
    if(presentedVC && presentedVC.presentingViewController == vc) {
        ADHControllerHierarchy *presented = [self traverseViewController:presentedVC hierarchyIndex:index+1];
        presented.presentingParent = controller;
        controller.presentedChild = presented;
    }
    return controller;
}

@end












