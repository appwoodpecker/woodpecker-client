//
//  PlainTextViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "PlainTextViewController.h"
#import <MGSFragaria/MGSFragaria.h>
#import "FileTypeUtil.h"
#import "NSData+Compress.h"

@interface PlainTextViewController ()

@property (nonatomic, strong) MGSFragaria * mgsTextView;

@end

@implementation PlainTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.filePath || self.transaction){
        [self loadContent];
    }
}

- (void)reload
{
    [self loadContent];
}

- (NSDictionary * )syntaxMapping
{
    return @{
             @"xml" : @"XML",
             @"plist" : @"Plist",
             @"html" : @"HTML",
             @"css" : @"CSS",
             @"javascript" : @"JavaScript",
             @"json" : @"JavaScript",
             };
}

- (NSString *)getFileSyntax
{
    NSString * syntax = nil;
    NSString * fileExt = [self.filePath pathExtension];
    NSString * syntaxType = [FileTypeUtil syntaxType:fileExt];
    if(syntaxType){
        syntax = [self syntaxMapping][syntaxType];
    }
    return syntax;
}

- (void)loadContent {
    // create an instance
    MGSFragaria * fragaria = [[MGSFragaria alloc] init];
    [fragaria setObject:self forKey:MGSFODelegate];
    // set the syntax colouring delegate
    [fragaria setObject:self forKey:MGSFOSyntaxColouringDelegate];
    NSString * syntaxName = [self getFileSyntax];
    if(syntaxName){
        // define our syntax definition
        [fragaria setObject:syntaxName forKey:MGSFOSyntaxDefinitionName];
        [fragaria setSyntaxColoured:YES];
    }else{
        [fragaria setSyntaxColoured:NO];
    }
    // embed editor in editView
    [fragaria embedInView:self.view];
    // access the NSTextView directly
    NSTextView *textView = fragaria.textView;
    [textView setEditable:NO];
    self.mgsTextView = fragaria;
    [self loadFileContent];
}

- (BOOL)shouldBeautyfyJson
{
    BOOL ret = NO;
    if(self.formatBeautify){
        NSString * fileExt = [[self.filePath pathExtension] lowercaseString];
        if([fileExt isEqualToString:@"json"]){
            ret = YES;
        }
    }
    return ret;
}

- (void)loadFileContent {
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * content = nil;
        if(wself.filePath) {
            NSStringEncoding encoding = 0;
            NSError *error = nil;
            content = [[NSString alloc] initWithContentsOfFile:wself.filePath usedEncoding:&encoding error:&error];
            if(!content){
                //maybe bplist
                NSString * fileExt = [self.filePath pathExtension];
                if([fileExt isEqualToString:@"plist"]) {
                    content = [[NSString alloc] initWithContentsOfFile:wself.filePath encoding:NSASCIIStringEncoding error:&error];
                    if([content hasPrefix:@"bplist"]) {
                        //确定为bplist，后面再处理
                    }
                }
            }
        }else if(self.transaction && self.bRequestBody) {
            NSData *body = self.transaction.requestBody;
            NSString *bodyEncoding = [self.transaction requestContentEncoding];
            body = [body inflateWithEncodeName:bodyEncoding];
            content = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        }
        if([wself shouldBeautyfyJson]){
            id jsonObject = [content adh_jsonObject];
            if(jsonObject){
                NSError * error = nil;
                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
                if(jsonData){
                    content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
            }
        }
        if(content){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [wself.mgsTextView setString:content];
            });
        }
    });
}

@end















