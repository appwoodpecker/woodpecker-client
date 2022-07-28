//
//  TestViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/19.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DispatchQueueTestViewController.h"

@interface DispatchQueueTestViewController ()

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation DispatchQueueTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self doDispatchTest];
}

- (void)doDispatchTest
{
    const char * name = "TestQueue";
    self.queue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);
    for (NSInteger i=0; i<10; i++) {
        dispatch_async(self.queue, ^{
            [self demoTask:i+1];
        });
    }
    NSLog(@"dispatch finished:");
}

- (void)demoTask: (NSInteger)number
{
    sleep(1);
    NSLog(@"task %zd finished on thread: %@",number,[NSThread currentThread]);
}


@end
