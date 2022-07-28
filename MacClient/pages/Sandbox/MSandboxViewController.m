//
//  MSandboxViewController.m
//  MacClient
//
//  Created by 张小刚 on 2019/5/27.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "MSandboxViewController.h"

@interface MSandboxViewController ()

@end

@implementation MSandboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)filePath {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"test.txt"];
    return path;
}

- (NSString *)folderPath {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"ABC"];
    return path;
}

- (IBAction)addFileButtonClicked:(id)sender {
    NSString *path = [self filePath];
    NSString *text = [NSString stringWithFormat:@"%@",[NSDate date]];
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
}

- (IBAction)editFileButtonClicked:(id)sender {
    NSString *path = [self filePath];
    NSString *text = [NSString stringWithFormat:@"%@",[NSDate date]];
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:path atomically:YES];
}

- (IBAction)deleteFileButtonClicked:(id)sender {
    NSString *path = [self filePath];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (IBAction)addFolderButtonClicked:(id)sender {
    NSString *folderPath = [self folderPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (IBAction)deleteFolderButtonClicked:(id)sender {
    NSString *folderPath = [self folderPath];
    [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
}


@end
