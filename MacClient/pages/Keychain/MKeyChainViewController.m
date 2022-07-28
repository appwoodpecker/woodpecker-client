//
//  MKeyChainViewController.m
//  MacClient
//
//  Created by 张小刚 on 2019/5/26.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "MKeyChainViewController.h"
static NSString *const kServiceName = @"saturday";

@interface MKeyChainViewController ()

@end

@implementation MKeyChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)addButtonClicked:(id)sender {
    [self add];
}


- (void)add {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[ocStr(kSecClass)] = ocStr(kSecClassGenericPassword);
    query[ocStr(kSecAttrService)] = kServiceName;
    NSString *account = [NSString stringWithFormat:@"user%d",arc4random()];
    NSString *password = [NSString stringWithFormat:@"password%d",arc4random()];
    query[ocStr(kSecAttrAccount)] = account;
    query[ocStr(kSecValueData)] = [password dataUsingEncoding:NSUTF8StringEncoding];
    query[ocStr(kSecAttrLabel)] = @"Application Label Here";
    query[ocStr(kSecAttrComment)] = @"Comment Here";
    query[ocStr(kSecAttrDescription)] = @"Description Here";
    query[ocStr(kSecAttrAccessible)] = ocStr(kSecAttrAccessibleAlways);
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd(cfDic(query), &result);
    NSLog(@"%d",status);
    if(status == errSecSuccess) {
        NSLog(@"Add success");
    }
}

NSString *ocStr(CFStringRef cfStr) {
    return (__bridge NSString *)cfStr;
}

CFDictionaryRef cfDic(NSDictionary *dic) {
    return (__bridge CFDictionaryRef)dic;
}

NSNumber *ocBool(CFBooleanRef cfBool) {
    return (__bridge NSNumber *)cfBool;
}


@end
