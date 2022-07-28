//
//  KeyChainTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2018/8/25.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "KeyChainTestViewController.h"

static NSString *const kServiceName = @"saturday";

@interface KeyChainTestViewController ()

@property (nonatomic, strong) NSMutableData * data;

@end

@implementation KeyChainTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)addButtonPressed:(id)sender {
        [self add];
    //    [self optionAdd];
    //    [self internetPasswordAdd];
//    [self passwordAccessControlAdd];
}

- (IBAction)queryButtonPressed:(id)sender {
//    [self query];
    //    [self accessTest];
    //    [self internetPasswordQuery];
    [self internetPasswordQuery];
}

- (IBAction)optionButtonPressed:(id)sender {
//    [self changePersistData];
//    [self accessControlAdd];
//    [self notPasswordAdd];
//    [self passwordAccessControlAdd];
//    [self internetPasswordAdd];
    [self encodePasswordAdd];
}

- (IBAction)deleteButtonPressed:(id)sender {
    [self delete];
    [self internetPasswordDelete];
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
    query[ocStr(kSecAttrCreator)] = @"1234";
    query[ocStr(kSecAttrAccessible)] = ocStr(kSecAttrAccessibleWhenUnlocked);
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd(cfDic(query), &result);
    if(status == errSecSuccess) {
        NSLog(@"Add success");
    }
}

- (void)encodePasswordAdd {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[ocStr(kSecClass)] = ocStr(kSecClassGenericPassword);
    query[ocStr(kSecAttrService)] = kServiceName;
    NSString *account = [NSString stringWithFormat:@"user%d",arc4random()];
    NSString *password = [NSString stringWithFormat:@"password%d",arc4random()];
    query[ocStr(kSecAttrAccount)] = account;
    query[ocStr(kSecValueData)] = [password dataUsingEncoding:NSUTF16StringEncoding];
    query[ocStr(kSecAttrLabel)] = @"Application Label Here";
    query[ocStr(kSecAttrComment)] = @"Comment Here";
    query[ocStr(kSecAttrDescription)] = @"Description Here";
    query[ocStr(kSecAttrCreator)] = @"1234";
    query[ocStr(kSecAttrAccessible)] = ocStr(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly);
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd(cfDic(query), &result);
    if(status == errSecSuccess) {
        NSLog(@"Add success");
    }
}

- (void)notPasswordAdd {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[ocStr(kSecClass)] = ocStr(kSecClassGenericPassword);
    query[ocStr(kSecAttrService)] = kServiceName;
    NSString *account = [NSString stringWithFormat:@"user%d",arc4random()];
    query[ocStr(kSecAttrAccount)] = account;
    query[ocStr(kSecAttrLabel)] = @"Application Label Here";
    query[ocStr(kSecAttrComment)] = @"Comment Here";
    query[ocStr(kSecAttrDescription)] = @"Description Here";
    query[ocStr(kSecAttrCreator)] = @"1234";
    query[ocStr(kSecAttrAccessible)] = ocStr(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly);
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd(cfDic(query), &result);
    if(status == errSecSuccess) {
        NSLog(@"No password add success");
    }
}

//获取时需要用户在场确认
- (void)accessControlAdd {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[ocStr(kSecClass)] = ocStr(kSecClassGenericPassword);
    query[ocStr(kSecAttrService)] = kServiceName;
    NSString *account = [NSString stringWithFormat:@"user%d",arc4random()];
    NSString *password = [NSString stringWithFormat:@"password%d",arc4random()];
    query[ocStr(kSecAttrAccount)] = account;
    query[ocStr(kSecValueData)] = [password dataUsingEncoding:NSUTF8StringEncoding];
    SecAccessControlRef control = SecAccessControlCreateWithFlags(NULL, kSecAttrAccessibleWhenUnlocked, kSecAccessControlUserPresence, NULL);
    query[ocStr(kSecAttrAccessControl)] = (__bridge id)control;
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd(cfDic(query), &result);
    if(status == errSecSuccess) {
        NSLog(@"Add success");
    }
}

//添加时设置密码
- (void)passwordAccessControlAdd {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[ocStr(kSecClass)] = ocStr(kSecClassGenericPassword);
    query[ocStr(kSecAttrService)] = kServiceName;
    NSString *account = [NSString stringWithFormat:@"user%d",arc4random()];
    NSString *password = [NSString stringWithFormat:@"password%d",arc4random()];
    query[ocStr(kSecAttrAccount)] = account;
    query[ocStr(kSecValueData)] = [password dataUsingEncoding:NSUTF8StringEncoding];
    query[ocStr(kSecAttrLabel)] = @"Application Label Here";
    SecAccessControlRef control = SecAccessControlCreateWithFlags(NULL, kSecAttrAccessibleWhenUnlocked, kSecAccessControlApplicationPassword, NULL);
    query[ocStr(kSecAttrAccessControl)] = (__bridge id)control;
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd(cfDic(query), &result);
    if(status == errSecSuccess) {
        NSLog(@"Add success");
    }
}

- (void)internetPasswordAdd {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[ocStr(kSecClass)] = ocStr(kSecClassInternetPassword);
//    query[ocStr(kSecAttrService)] = kServiceName;
    NSString *account = [NSString stringWithFormat:@"user%d",arc4random()];
    NSString *password = [NSString stringWithFormat:@"password%d",arc4random()];
    query[ocStr(kSecAttrServer)] = @"www.woodpeck.cn";
    query[ocStr(kSecAttrProtocol)] = ocStr(kSecAttrProtocolHTTP);
    query[ocStr(kSecAttrPath)] = @"/";
    query[ocStr(kSecAttrPort)] = @(80);
    query[ocStr(kSecAttrAuthenticationType)] = ocStr(kSecAttrAuthenticationTypeHTTPDigest);
    query[ocStr(kSecAttrAccount)] = account;
    query[ocStr(kSecValueData)] = [password dataUsingEncoding:NSUTF8StringEncoding];
    query[ocStr(kSecAttrAccessible)] = ocStr(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly);
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd(cfDic(query), &result);
    if(status == errSecSuccess) {
        NSLog(@"Add success");
    }
}



- (void)query {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    //accessGroup
    //service
    //account
    query[ocStr(kSecClass)] = ocStr(kSecClassGenericPassword);
    query[(NSString *)kSecAttrService] = kServiceName;
    query[ocStr(kSecMatchLimit)] = ocStr(kSecMatchLimitAll);
    query[ocStr(kSecReturnAttributes)] = ocBool(kCFBooleanTrue);
    query[ocStr(kSecReturnData)] = ocBool(kCFBooleanTrue);
    CFTypeRef result = nil;
    SecItemCopyMatching(cfDic(query), &result);
    id object = (__bridge id)result;
    if([object isKindOfClass:[NSArray class]]) {
        NSArray *array = object;
        for (NSDictionary *obj in array) {
//            NSString * accesible = obj[ocStr(kSecAttrAccessible)];
            NSLog(@"%@",obj);
        }
    }
}


- (void)internetPasswordQuery {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    //accessGroup
    //service
    //account
    query[ocStr(kSecClass)] = ocStr(kSecClassInternetPassword);
//    query[(NSString *)kSecAttrService] = kServiceName;
    query[ocStr(kSecMatchLimit)] = ocStr(kSecMatchLimitAll);
    query[ocStr(kSecReturnAttributes)] = ocBool(kCFBooleanTrue);
    query[ocStr(kSecReturnData)] = ocBool(kCFBooleanTrue);
    CFTypeRef result = nil;
    SecItemCopyMatching(cfDic(query), &result);
    id object = (__bridge id)result;
    if([object isKindOfClass:[NSArray class]]) {
        NSArray *array = object;
        for (NSDictionary *obj in array) {
            //            NSString * accesible = obj[ocStr(kSecAttrAccessible)];
            NSLog(@"%@",obj);
        }
    }
}

- (void)queryPersistRef: (NSData *)persistData {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[ocStr(kSecClass)] = ocStr(kSecClassGenericPassword);
    query[ocStr(kSecMatchLimit)] = ocStr(kSecMatchLimitAll);
    query[ocStr(kSecReturnAttributes)] = ocBool(kCFBooleanTrue);
    query[ocStr(kSecValuePersistentRef)] = persistData;
    CFTypeRef result = nil;
    SecItemCopyMatching(cfDic(query), &result);
    id object = (__bridge id)result;
    NSLog(@"%@",object);
}



- (void)changePersistData {
    NSString *value = [NSString stringWithFormat:@"%d",arc4random()];
    NSData * extraData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [self.data appendData:extraData];
}

- (void)delete {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[ocStr(kSecClass)] = ocStr(kSecClassGenericPassword);
    query[ocStr(kSecAttrService)] = kServiceName;
    OSStatus result = SecItemDelete(cfDic(query));
    if(errSecSuccess == result) {
        NSLog(@"deleted");
    }
}

- (void)internetPasswordDelete {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[ocStr(kSecClass)] = ocStr(kSecClassInternetPassword);
    OSStatus result = SecItemDelete(cfDic(query));
    if(errSecSuccess == result) {
        NSLog(@"deleted");
    }
}

/*
ak
ck
dk
aku
cku
dku
akpu
*/
- (void)accessTest {
    NSLog(@"%@",ocStr(kSecAttrAccessibleWhenUnlocked));
    NSLog(@"%@",ocStr(kSecAttrAccessibleAfterFirstUnlock));
    NSLog(@"%@",ocStr(kSecAttrAccessibleAlways));
    NSLog(@"%@",ocStr(kSecAttrAccessibleWhenUnlockedThisDeviceOnly));
    NSLog(@"%@",ocStr(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly));
    NSLog(@"%@",ocStr(kSecAttrAccessibleAlwaysThisDeviceOnly));
    NSLog(@"%@",ocStr(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly));
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

- (void)swiftTest {
    
}

@end
