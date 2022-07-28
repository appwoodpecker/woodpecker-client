//
//  ControllerHierarchyTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/4/22.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ControllerHierarchyTestViewController.h"
#import "CHTabBarController.h"
#import "CHPageViewController.h"
#import "CHCustomContainerViewController.h"

@interface ControllerHierarchyTestViewController ()

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation ControllerHierarchyTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.title = [NSString stringWithFormat:@"Page %zd",self.index];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.dismissButton.hidden = (self.presentingViewController == nil);
}

- (IBAction)pushButtonPressed:(id)sender {
    ControllerHierarchyTestViewController *vc = [[ControllerHierarchyTestViewController alloc] init];
    vc.index = self.index + 1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)presentButtonPressed:(id)sender {
    ControllerHierarchyTestViewController *vc = [[ControllerHierarchyTestViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)dismissButtonPressed:(id)sender {
    if(self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)tabbarButtonPressed:(id)sender {
    CHTabBarController *tabVC = [[CHTabBarController alloc] init];
    [self.navigationController pushViewController:tabVC animated:YES];
}
- (IBAction)pageviewButtonPressed:(id)sender {
    CHPageViewController *pageVC = [[CHPageViewController alloc] init];
    [self.navigationController pushViewController:pageVC animated:YES];
}

- (IBAction)customContainerButtonPressed:(id)sender {
    CHCustomContainerViewController *customVC = [[CHCustomContainerViewController alloc] init];
    [self.navigationController pushViewController:customVC animated:YES];
}

- (IBAction)normalPresentButtonPressed:(id)sender {
    ControllerHierarchyTestViewController *vc = [[ControllerHierarchyTestViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
















