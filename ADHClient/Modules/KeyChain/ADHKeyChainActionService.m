//
//  ADHKeyChainActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2018/8/25.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ADHKeyChainActionService.h"

@implementation ADHKeyChainActionService

/**
 service name
 */
+ (NSString *)serviceName {
    return @"adh.keychain";
}

/**
 action list
 
 return @{
 @"actionName1" : selector1 string,
 @"actionName2" : selector2 string,
 };
 */
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"list" : NSStringFromSelector(@selector(onRequestItemList:)),
             @"getPassword" : NSStringFromSelector(@selector(onRequestItemPassword:)),
             };
}

- (void)onRequestItemList: (ADHRequest *)request {
    NSInteger type = [request.body[@"type"] integerValue];
    NSArray *list = nil;
    if(type == 1) {
        list = [self fetchInternetPasswordList];
    }else {
        list = [self fetchGenericPasswordList];
    }
    if(!list) {
        list = @[];
    }
    NSString *content = [list adh_jsonPresentation];
    [request finishWithBody:@{@"list":adhvf_safestringfy(content)}];
}

- (void)onRequestItemPassword: (ADHRequest *)request {
    NSData *valueData = nil;
    NSDictionary *body =request.body;
    NSString *content = body[occf(kSecValuePersistentRef)];
    NSInteger type = [body[@"type"] intValue];
    if(content.length > 0) {
        NSData *valueRef = [[NSData alloc] initWithBase64EncodedString:content options:0];
        if(valueRef) {
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            if(type == 1) {
                query[occf(kSecClass)] = occf(kSecClassInternetPassword);
            }else {
                query[occf(kSecClass)] = occf(kSecClassGenericPassword);
            }
            query[occf(kSecValuePersistentRef)] = valueRef;
            query[occf(kSecMatchLimit)] = occf(kSecMatchLimitOne);
            query[occf(kSecReturnAttributes)] = occf(kCFBooleanTrue);
            query[occf(kSecReturnData)] = occf(kCFBooleanTrue);
            CFTypeRef result = nil;
            OSStatus ret = SecItemCopyMatching(cfoc(query), &result);
            if(ret == errSecSuccess) {
                id dic = occf(result);
                if([dic isKindOfClass:[NSDictionary class]]) {
                    valueData = dic[occf(kSecValueData)];
                }
            }
        }
    }
    if(valueData) {
        NSString *value = [valueData base64EncodedStringWithOptions:0];
        if(value) {
            NSDictionary *body = @{
                                   occf(kSecValueData) : value,
                                   };
            [request finishWithBody:body];
        }
    }else {
        [request finish];
    }
}

#pragma mark -----------------   service   ----------------

- (NSArray *)fetchGenericPasswordList {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[occf(kSecClass)] = occf(kSecClassGenericPassword);
    query[occf(kSecMatchLimit)] = occf(kSecMatchLimitAll);
    query[occf(kSecReturnAttributes)] = occf(kCFBooleanTrue);
    query[occf(kSecReturnPersistentRef)] = occf(kCFBooleanTrue);
    CFTypeRef result = nil;
    SecItemCopyMatching(cfoc(query), &result);
    id object = (__bridge id)result;
    NSMutableArray *list = [NSMutableArray array];
    if([object isKindOfClass:[NSArray class]]) {
        NSArray *array = object;
        /*
        accc = "<SecAccessControlRef: 0x103f2bc80>";
        acct = user1598190122;
        agrp = "8HG49Q463F.lifebetter.woodpecker.demo";
        cdat = "2018-09-01 03:54:16 +0000";
        mdat = "2018-09-01 03:54:16 +0000";
        crtr = 1234;
        desc = "Description Here";
        icmt = "Comment Here";
        labl = "Application Label Here";
        musr = <>;
        pdmn = akpu;
        persistref = <>;
        sha1 = <b8da607f 1073bb18 db6386c8 7cde0e20 4aacdc4c>;
        svce = saturday;
        sync = 0;
        tomb = 0;
        "v_Data" = <70617373 776f7264 32363030 34353433 38>;
        */
        for (NSDictionary *item in array) {
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            //label
            if(item[occf(kSecAttrLabel)]) {
                data[occf(kSecAttrLabel)] = item[occf(kSecAttrLabel)];
            }
            //account
            if(item[occf(kSecAttrAccount)]) {
                id accountData = item[occf(kSecAttrAccount)];
                NSString *account = nil;
                if([accountData isKindOfClass:[NSString class]]) {
                    account = accountData;
                }else if([accountData isKindOfClass:[NSData class]]) {
                    account = [[NSString alloc] initWithData:accountData encoding:NSUTF8StringEncoding];
                }
                if(account) {
                    data[occf(kSecAttrAccount)] = account;
                }
            }
            //service
            if(item[occf(kSecAttrService)]) {
                data[occf(kSecAttrService)] = item[occf(kSecAttrService)];
            }
            //access group
            if(item[occf(kSecAttrAccessGroup)]) {
                data[occf(kSecAttrAccessGroup)] = item[occf(kSecAttrAccessGroup)];
            }
            //create date
            if(item[occf(kSecAttrCreationDate)]) {
                NSDate *date = item[occf(kSecAttrCreationDate)];
                NSTimeInterval interval = [date timeIntervalSince1970];
                data[occf(kSecAttrCreationDate)] = [NSNumber numberWithDouble:interval];
            }
            //modify date
            if(item[occf(kSecAttrModificationDate)]) {
                NSDate *date = item[occf(kSecAttrCreationDate)];
                NSTimeInterval interval = [date timeIntervalSince1970];
                data[occf(kSecAttrModificationDate)] = [NSNumber numberWithDouble:interval];
            }
            //accessible
            if(item[occf(kSecAttrAccessible)]) {
                data[occf(kSecAttrAccessible)] = item[occf(kSecAttrAccessible)];
            }
            //sync
            if(item[occf(kSecAttrSynchronizable)]) {
                data[occf(kSecAttrSynchronizable)] = item[occf(kSecAttrSynchronizable)];
            }
            //value refer
            if(item[occf(kSecValuePersistentRef)]) {
                NSData *dataRef = item[occf(kSecValuePersistentRef)];
                NSString *content = [dataRef base64EncodedStringWithOptions:0];
                data[occf(kSecValuePersistentRef)] = adhvf_safestringfy(content);
            }
            [list addObject:data];
        }
        [list sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary * obj2) {
            NSString *label1 = obj1[occf(kSecAttrLabel)];
            NSString *label2 = obj2[occf(kSecAttrLabel)];
            return [label1 compare:label2];
        }];
    }
    return list;
}

- (NSArray *)fetchInternetPasswordList {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[occf(kSecClass)] = occf(kSecClassInternetPassword);
    query[occf(kSecMatchLimit)] = occf(kSecMatchLimitAll);
    query[occf(kSecReturnAttributes)] = occf(kCFBooleanTrue);
    query[occf(kSecReturnPersistentRef)] = occf(kCFBooleanTrue);
    CFTypeRef result = nil;
    SecItemCopyMatching(cfoc(query), &result);
    id object = (__bridge id)result;
    NSMutableArray *list = [NSMutableArray array];
    if([object isKindOfClass:[NSArray class]]) {
        NSArray *array = object;
        /*
        accc = "<SecAccessControlRef: 0x101c29310>";
        acct = "user-1513370662";
        agrp = "8HG49Q463F.lifebetter.woodpecker.demo";
        atyp = httd;
        cdat = "2018-09-02 03:49:34 +0000";
        mdat = "2018-09-02 03:49:34 +0000";
        path = "/";
        pdmn = akpu;
        port = 80;
        ptcl = http;
        sha1 = <8aba9883 4c7f7926 25607166 a9dd5c55 564ca3fa>;
        srvr = "www.woodpeck.cn";
        sync = 0;
        "v_Data" = <70617373 776f7264 2d313735 31323332 333633>;
        */
        for (NSDictionary *item in array) {
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            //label
            if(item[occf(kSecAttrLabel)]) {
                data[occf(kSecAttrLabel)] = item[occf(kSecAttrLabel)];
            }
            //account
            if(item[occf(kSecAttrAccount)]) {
                data[occf(kSecAttrAccount)] = item[occf(kSecAttrAccount)];
            }
            //protocol
            if(item[occf(kSecAttrProtocol)]) {
                data[occf(kSecAttrProtocol)] = item[occf(kSecAttrProtocol)];
            }
            //server
            if(item[occf(kSecAttrServer)]) {
                data[occf(kSecAttrServer)] = item[occf(kSecAttrServer)];
            }
            //path
            if(item[occf(kSecAttrPath)]) {
                data[occf(kSecAttrPath)] = item[occf(kSecAttrPath)];
            }
            //port
            if(item[occf(kSecAttrServer)]) {
                data[occf(kSecAttrServer)] = item[occf(kSecAttrServer)];
            }
            //auth type
            if(item[occf(kSecAttrAuthenticationType)]) {
                data[occf(kSecAttrAuthenticationType)] = item[occf(kSecAttrAuthenticationType)];
            }
            //access group
            if(item[occf(kSecAttrAccessGroup)]) {
                data[occf(kSecAttrAccessGroup)] = item[occf(kSecAttrAccessGroup)];
            }
            //create date
            if(item[occf(kSecAttrCreationDate)]) {
                NSDate *date = item[occf(kSecAttrCreationDate)];
                NSTimeInterval interval = [date timeIntervalSince1970];
                data[occf(kSecAttrCreationDate)] = [NSNumber numberWithDouble:interval];
            }
            //modify date
            if(item[occf(kSecAttrModificationDate)]) {
                NSDate *date = item[occf(kSecAttrCreationDate)];
                NSTimeInterval interval = [date timeIntervalSince1970];
                data[occf(kSecAttrModificationDate)] = [NSNumber numberWithDouble:interval];
            }
            //accessible
            if(item[occf(kSecAttrAccessible)]) {
                data[occf(kSecAttrAccessible)] = item[occf(kSecAttrAccessible)];
            }
            //sync
            if(item[occf(kSecAttrSynchronizable)]) {
                data[occf(kSecAttrSynchronizable)] = item[occf(kSecAttrSynchronizable)];
            }
            //value refer
            if(item[occf(kSecValuePersistentRef)]) {
                NSData *dataRef = item[occf(kSecValuePersistentRef)];
                NSString *content = [dataRef base64EncodedStringWithOptions:0];
                data[occf(kSecValuePersistentRef)] = adhvf_safestringfy(content);
            }
            [list addObject:data];
        }
        [list sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary * obj2) {
            NSString *label1 = obj1[occf(kSecAttrLabel)];
            NSString *label2 = obj2[occf(kSecAttrLabel)];
            return [label1 compare:label2];
        }];
    }
    return list;
}

#pragma mark -----------------   util   ----------------

id occf(CFTypeRef cfObject) {
    return (__bridge id)cfObject;
}

CFTypeRef cfoc(id object) {
    return  (__bridge CFTypeRef)object;
}


@end
