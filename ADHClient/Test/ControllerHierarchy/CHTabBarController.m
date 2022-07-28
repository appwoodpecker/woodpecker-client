//
//  CHTabBarController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/4/24.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "CHTabBarController.h"
#import "ControllerHierarchyTestViewController.h"

@interface CHTabBarController ()

@end

@implementation CHTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContent];
}

- (void)loadContent {
    NSMutableArray *vcs = [NSMutableArray array];
    for (NSInteger i=0; i<3; i++) {
        ControllerHierarchyTestViewController *vc = [[ControllerHierarchyTestViewController alloc] init];
        vc.index = i;
        vc.tabBarItem.title = [NSString stringWithFormat:@"Tab Item %zd",i];
        vc.title = [NSString stringWithFormat:@"Tab %zd",i];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [vcs addObject:nvc];
    }
    self.viewControllers = vcs;
    [self.tabBar setBarTintColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

















