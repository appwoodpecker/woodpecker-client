//
//  LogTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2017/12/30.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "LogTestViewController.h"
#import "ADHLogger.h"

@interface LogTestViewController ()

@end

@implementation LogTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)logDateButtonPressed:(id)sender {
     [[ADHLogger sharedLogger] logText:[self randomText]];
}
    
- (IBAction)logFileButtonPressed:(id)sender {
    NSString * imagePath = [[NSBundle mainBundle] pathForResource:@"hi" ofType:@"sqlite"];
    NSData * data = [NSData dataWithContentsOfFile:imagePath];
    [[ADHLogger sharedLogger] logFileWithData:data fileName:@"hi.sqlite" text:[self randomText]];
}
    
- (NSString *)randomText{
    NSString * repeatText = @"啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦";
    NSInteger times = arc4random() % 20;
    NSMutableString * text = [NSMutableString string];
    for (NSInteger i=0; i<times; i++) {
        [text appendString:repeatText];
    }
    return text;
}


- (IBAction)logRichTextButtonPressed:(id)sender {
    NSString * text = [self randomText];
    CGFloat red = 0x25/256.0f;
    CGFloat green = 0xA2/256.0f;
    CGFloat blue = 0x61/256.0f;
    CGFloat alpha = 1.0f;
    UIColor * color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    [[ADHLogger sharedLogger] logText:text color:color];
}

- (IBAction)logTextButtonPressed:(id)sender {
    NSString *text = [self randomText];
    NSLog(@"%@",text);
}

- (IBAction)logLinkButtonPressed:(id)sender {
    NSString *text = @"啦啦啦啊http://www.baidu.com牛逼http://www.woodpeck.cn哈哈哈";
    NSLog(@"%@",text);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end


















