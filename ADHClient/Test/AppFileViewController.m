//
//  ViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2017/10/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "AppFileViewController.h"
#import "ADHFileObserver.h"


@interface AppFileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) ADHFileObserver *fileObserver;

@end

@implementation AppFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Sandbox";
}

- (IBAction)addFolderButtonPressed:(id)sender {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString * folderName = [NSString stringWithFormat:@"%.f",interval];
    NSString * path = [[ADHFileUtil documentPath] stringByAppendingPathComponent:folderName];
    [ADHFileUtil createDirAtPath:path];
    NSLog(@"add folder -> %@",folderName);
}

- (IBAction)addFileButtonPressed:(id)sender {
    NSString * imagePath = [[NSBundle mainBundle] pathForResource:@"hi" ofType:@"plist"];
    NSData * data = [NSData dataWithContentsOfFile:imagePath];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString * fileName = [NSString stringWithFormat:@"%.f.plist",interval];
    NSString * path = [[ADHFileUtil documentPath] stringByAppendingPathComponent:fileName];
    [ADHFileUtil saveData:data atPath:path];
    NSLog(@"add file -> %@",fileName);
}

- (IBAction)sendButtonPressed:(id)sender {
    NSString * content = self.textView.text;
    if(content.length == 0) return;
    NSDictionary * data = @{
                            @"content" : content,
                            };
    [[ADHApiClient sharedApi] requestWithService:nil action:nil body:data progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        NSLog(@"%@",body);
    } onFailed:^(NSError *error) {
        
    }];
}

- (IBAction)startMonitorButtonPressed:(id)sender {
    if(!self.fileObserver) {
        self.fileObserver = [[ADHFileObserver alloc] init];
        NSString * workPath = @"";
        [self.fileObserver startWithPath:workPath];
    }else {
        [self.fileObserver stop];
        self.fileObserver = nil;
    }
    
}
- (IBAction)extensionButtonPressed:(id)sender {
    [self extensionAdd];
}

- (IBAction)extensionReadButtonPressed:(id)sender {
    [self extensionRead];
}

- (void)extensionAdd {
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.lifebetter.woodpecker.keyboardtest"];
    NSURL *fileURL = [containerURL URLByAppendingPathComponent:@"test.txt"];
    NSString *text = @"11111";
    NSError *error = nil;
    if(![text writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"%@",error);
    }else {
        NSLog(@"write success");
    }
}

- (void)extensionRead {
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.lifebetter.woodpecker.keyboardtest"];
    NSURL *fileURL = [containerURL URLByAppendingPathComponent:@"test.txt"];
    NSString *path = [fileURL absoluteString];
    path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    BOOL isDir = NO;
    BOOL isExists = NO;
    isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    NSString *content = [[NSString alloc] initWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@",content);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end








