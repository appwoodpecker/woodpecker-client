//
//  UtilityTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2020/9/21.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "UtilityTestViewController.h"

@interface UtilityTestViewController ()

@end

@implementation UtilityTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)pbButtonPressed:(id)sender {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    NSString *text = [formatter stringFromDate:date];
    [[UIPasteboard generalPasteboard] setString:text];
}

- (IBAction)pbReadButtonPressed:(id)sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    NSArray *items = [pb items];
    NSLog(@"total: %zd",items.count);
    NSLog(@"%@",items);
    UIImage *image = [pb image];
    NSURL *url = [pb URL];
    NSString *text = [pb string];
    if(image) {
        NSLog(@"image: %@",image);
    }
    if(url) {
        NSLog(@"url: %@",url);
    }
    if(text) {
        NSLog(@"text: %@",text);
    }
}


- (IBAction)bundleIdDefaults:(id)sender {
    NSDictionary * info = [[NSBundle mainBundle] infoDictionary];
    NSString * bundleId = info[@"CFBundleIdentifier"];
    NSDictionary *values = [[NSUserDefaults standardUserDefaults] persistentDomainForName:bundleId];
    NSLog(@"%@",values);
}

- (IBAction)otherDomainDefaults:(id)sender {
    /*
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *domains = [ud persistentDomainNames];
    NSLog(@"%@",domains);
    domains = [ud volatileDomainNames];
    NSLog(@"%@",domains);
    NSDictionary *values = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSArgumentDomain];
    NSLog(@"%@",values);
    
    values = [ud volatileDomainForName:NSArgumentDomain];
    NSLog(@"%@",values);
    */
    [[NSUserDefaults standardUserDefaults] setVolatileDomain:@{@"hhhh":@"111"} forName:NSArgumentDomain];
}


@end
