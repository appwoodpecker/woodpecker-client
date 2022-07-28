//
//  RichTextPreviewTestViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "RichTextPreviewTestViewController.h"
#import <MGSFragaria/MGSFragaria.h>

@interface RichTextPreviewTestViewController ()

@property (nonatomic, strong) MGSFragaria * fragaria;

@end

@implementation RichTextPreviewTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    
}
- (void)setup
{
    
    // create an instance
    MGSFragaria * fragaria = [[MGSFragaria alloc] init];
    
    // define initial object configuration
    //
    // see MGSFragaria.h for details
    //
    [fragaria setObject:self forKey:MGSFODelegate];
    
    // set the syntax colouring delegate
    [fragaria setObject:self forKey:MGSFOSyntaxColouringDelegate];
    
    // define our syntax definition
    [fragaria setObject:@"XML" forKey:MGSFOSyntaxDefinitionName];
    
    // embed editor in editView
    [fragaria embedInView:self.view];
    
    //
    // assign user defaults.
    // a number of properties are derived from the user defaults system rather than the doc spec.
    //
    // see MGSFragariaPreferences.h for details
    //
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsAutocompleteSuggestAutomatically];
    
    // get initial text - in this case a test file from the bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hi" ofType:@"plist"];
    NSString *fileText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // set text
    //[fragaria performSelector:@selector(setString:) withObject:fileText afterDelay:0];
    [fragaria setString:fileText];
    
    // access the NSTextView directly
    NSTextView *textView = [fragaria objectForKey:ro_MGSFOTextView];
    [textView setEditable:YES];
}


@end













