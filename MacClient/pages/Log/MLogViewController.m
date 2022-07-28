//
//  MLogViewController.m
//  MacClient
//
//  Created by 张小刚 on 2019/5/26.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "MLogViewController.h"
#import "ADHLogger.h"

@interface MLogViewController ()

@end

@implementation MLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)logButtonClicked:(id)sender {
    NSString *text = [self randomText];
    [[ADHLogger sharedLogger] logText:text];
}

- (IBAction)logFileClicked:(id)sender {
    NSString * imagePath = [[NSBundle mainBundle] pathForResource:@"hi" ofType:@"png"];
    NSData * data = [NSData dataWithContentsOfFile:imagePath];
    [[ADHLogger sharedLogger] logFileWithData:data fileName:@"hi.png" text:[self randomText]];
}

- (NSString *)randomText{
    NSString * repeatText = @"啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦";
    NSInteger times = arc4random() % 20 +1;
    NSMutableString * text = [NSMutableString string];
    for (NSInteger i=0; i<times; i++) {
        [text appendString:repeatText];
    }
    return text;
}

- (IBAction)nslogButtonClicked:(id)sender {
    NSString *text = [self randomText];
    NSLog(@"%@",text);
}

@end
