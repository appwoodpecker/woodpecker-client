//
//  CHPageViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/4/24.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "CHPageViewController.h"
#import "ControllerHierarchyTestViewController.h"

@interface CHPageViewController ()<UIPageViewControllerDataSource>

@property (nonatomic, strong) NSArray *contentVCs;

@end

@implementation CHPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Page View";
    [self loadContent];
    self.dataSource = self;
}

- (void)loadContent {
    NSMutableArray *vcs = [NSMutableArray array];
    for (NSInteger i=0; i<10; i++) {
        ControllerHierarchyTestViewController *vc = [[ControllerHierarchyTestViewController alloc] init];
        vc.index = i;
        vc.tabBarItem.title = [NSString stringWithFormat:@"Tab %zd",i];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [vcs addObject:nvc];
    }
    self.contentVCs = vcs;
    [self setViewControllers:@[self.contentVCs[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    UIViewController *resultVC = nil;
    UINavigationController *nvc = (UINavigationController *)viewController;
    ControllerHierarchyTestViewController *vc = nvc.viewControllers[0];
    NSInteger nextIndex = vc.index - 1;
    if(nextIndex >= 0) {
        resultVC = self.contentVCs[nextIndex];
    }
    return resultVC;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    UIViewController *resultVC = nil;
    UINavigationController *nvc = (UINavigationController *)viewController;
    ControllerHierarchyTestViewController *vc = nvc.viewControllers[0];
    NSInteger nextIndex = vc.index + 1;
    if(nextIndex < self.contentVCs.count) {
        resultVC = self.contentVCs[nextIndex];
    }
    return resultVC;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end





