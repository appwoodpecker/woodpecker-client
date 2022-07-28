//
//  ConsoleTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/11.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ConsoleTestViewController.h"

@interface ConsoleTestViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger count;

@end

@implementation ConsoleTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.count = 0;
    
}

- (IBAction)nslogButtonPressed:(id)sender {
    NSLog(@"%@",[NSDate date]);
}

- (IBAction)printButtonPressed:(id)sender {
    NSString *content = [NSString stringWithFormat:@">>%@",[NSDate date]];
    printf("%s",[content UTF8String]);
}

- (IBAction)linkButtonPressed:(id)sender {
    NSLog(@"App home page: http://www.woodpeck.cn");
    NSLog(@"Email me: woodpeckerapp@163.com");
    NSLog(@"Phone number: 1734852485");
}
- (IBAction)bulkButtonPressed:(id)sender {
    NSLog(@"Start App home page: http://www.woodpeck.cn\n\n\n\n\n\n\n\n\n--->End App home page: http://www.woodpeck.cn");
}

- (IBAction)countButtonPressed:(id)sender {
    [self countLog];
}

- (IBAction)timerCountButtonPressed:(id)sender {
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }else {
        [self countLog];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(countLog) userInfo:nil repeats:YES];
    }
}

- (void)countLog {
    NSLog(@"timer fired : %zd",self.count++);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
