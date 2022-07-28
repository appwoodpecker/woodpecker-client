//
//  DeviceTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "DeviceTestViewController.h"

@interface DeviceTestViewController ()

@end

@implementation DeviceTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
}

- (IBAction)snapshotButtonPressed:(id)sender {
//    UIDevice * device = [UIDevice currentDevice];
    UIScreen * screen = [UIScreen mainScreen];
    UIView * view = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, screen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(image);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
