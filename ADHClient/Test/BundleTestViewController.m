//
//  BundleTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2019/1/20.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "BundleTestViewController.h"
#import "ADHFileBrowserUtil.h"

@interface BundleTestViewController ()

@end

@implementation BundleTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)bundleButtonPressed:(id)sender {
    NSBundle * bundle = [NSBundle mainBundle];
    NSString *path = [bundle bundlePath];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ADHFileItem * fileItem = [ADHFileBrowserUtil scanRootFolder:path];
        NSDictionary * dic = [fileItem dicPresentation];
        NSLog(@"%@",dic);
    });
}


@end
