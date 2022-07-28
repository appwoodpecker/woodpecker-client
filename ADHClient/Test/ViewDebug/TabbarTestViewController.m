//
//  TabbarTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2019/3/10.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "TabbarTestViewController.h"
#import "StackTestViewController.h"

@interface TabbarTestViewController ()

@end

@implementation TabbarTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContent];
}

- (void)loadContent {
    NSMutableArray *controllers = [NSMutableArray array];
    for (NSInteger i=0; i<4; i++) {
        StackTestViewController *vc = [[StackTestViewController alloc] init];
        UITabBarItem *item = [[UITabBarItem alloc] init];
        item.title = [NSString stringWithFormat:@"Title %zd",i+1];
        vc.tabBarItem = item;
        [controllers addObject:vc];
    }
    self.viewControllers = controllers;
}

@end
