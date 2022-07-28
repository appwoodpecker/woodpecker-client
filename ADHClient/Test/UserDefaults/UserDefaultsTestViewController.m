//
//  UserDefaultsTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/8.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "UserDefaultsTestViewController.h"
@import CoreFoundation;

@interface UserDefaultsTestViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textfield;


@end

@implementation UserDefaultsTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)test
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[NSDate date] forKey:@"date"];
    [standardUserDefaults synchronize];
}

- (NSString *)randomSuiteName
{
    NSString * name = [NSString stringWithFormat:@"suite%zd",arc4random()];
    return name;
}

- (IBAction)suiteTestButtonPressed:(id)sender {
    NSUserDefaults * userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"TestSuite"];
    [userDefaults setObject:[NSDate date] forKey:@"testSuiteDate"];
    [userDefaults synchronize];
}

- (IBAction)standardDefaultsButtonPressed:(id)sender {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * value = [standardUserDefaults dictionaryRepresentation];
    NSLog(@"%@",value);
}

- (IBAction)testsuiteDefaultsButtonPressed:(id)sender {
    NSUserDefaults * userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"TestSuite"];
    NSDictionary * value = [userDefaults dictionaryRepresentation];
    NSLog(@"%@",value);
}

- (IBAction)registerDefaultButtonPressed:(id)sender {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSDictionary * values = @{
                              @"test-defaults" : [NSDate date],
                              };
    [ud registerDefaults:values];
    [ud synchronize];
}

- (IBAction)persistentButtonPressed:(id)sender {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * value = @{
                             @"test-persistent" : [NSDate date],
                             };
    [standardUserDefaults setPersistentDomain:value forName:NSGlobalDomain];
}

- (IBAction)persistentSuiteButtonPressed:(id)sender {
    NSUserDefaults * userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"TestSuite"];
    NSDictionary * value = @{
                             @"test-suite-persistent" : [NSDate date],
                             };
    [userDefaults setPersistentDomain:value forName:@"TestSuite"];
}

- (IBAction)globalDomain:(id)sender {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSDictionary * value = [ud persistentDomainForName:NSGlobalDomain];
    NSLog(@"%@",value);
}

- (IBAction)generalTestButtonPressed:(id)sender {
    /*
    //deprecated
    NSArray * domains = [[NSUserDefaults standardUserDefaults] persistentDomainNames];
    NSLog(@"%@",domains);
     */
    [self testDataTypes];
}

/*
NSString,
NSData,
NSNumber,
NSDate,
NSArray,
NSDictionary
*/
- (void)testDataTypes
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * string = @"This is a test message";
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSNumber * number = [NSNumber numberWithInteger:100];
    NSNumber * boolNumber = [NSNumber numberWithBool:YES];
    NSDate * date = [NSDate date];
    NSArray * array = @[
                        string,
                        data,
                        number,
                        ];
    NSDictionary * dictionary = @{
                                  @"a string" : string,
                                  @"a data" : data,
                                  @"a number" : number,
                                  };
    [ud setObject:string forKey:@"string"];
    [ud setObject:data forKey:@"data"];
    [ud setObject:number forKey:@"number"];
    [ud setObject:boolNumber forKey:@"bool-number"];
    [ud setObject:date forKey:@"date"];
    [ud setObject:array forKey:@"array"];
    [ud setObject:dictionary forKey:@"dictionary"];
    [ud synchronize];
}

- (IBAction)addButtonPressed:(id)sender {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.lifebetter.lbkeyboard"];
    [userDefaults setObject:@"33" forKey:@"host-keyboard"];
    [userDefaults synchronize];
    [self.textfield resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end




















