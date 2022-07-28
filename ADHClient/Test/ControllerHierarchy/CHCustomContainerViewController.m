//
//  CHCustomContainerViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/4/24.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "CHCustomContainerViewController.h"
#import "ControllerHierarchyTestViewController.h"

@interface CHCustomContainerViewController ()

@end

@implementation CHCustomContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContent];
}

- (void)loadContent {
    for (NSInteger i=0; i<3; i++) {
        ControllerHierarchyTestViewController *vc = [[ControllerHierarchyTestViewController alloc] init];
        vc.index = i;
        [self addChildViewController:vc];
        if(i == 0) {
            UIView *subview = vc.view;
            subview.backgroundColor = [UIColor brownColor];
            [self.view addSubview:subview];
            [vc didMoveToParentViewController:self];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
