//
//  WoodPeckeriOSTests.m
//  WoodPeckeriOSTests
//
//  Created by 张小刚 on 2018/10/15.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface WoodPeckeriOSTests : XCTestCase

@end

@implementation WoodPeckeriOSTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPreferedIp {
    NSString *localIp = @"192.168.0.104";
    NSArray *addresses = @[
                           @"192.168.0.1",
                           @"192.168.0.200",
                           @"AAAA:BBBB:CCCC:DDDD:EEEE:FFFF",
                           @"",
                           ];
    NSInteger localComponentsCount = [localIp componentsSeparatedByString:@"."].count;
    NSInteger maxSameCount = 0;
    NSInteger possibleIndex = NSNotFound;
    for (NSInteger addrIndex = 0;addrIndex < addresses.count; addrIndex++) {
        NSString *host = addresses[addrIndex];
        NSInteger thisComponentsCount = [host componentsSeparatedByString:@"."].count;
        if(localComponentsCount != thisComponentsCount) {
            continue;
        }
        NSInteger maxLength = MIN(localIp.length, host.length) ;
        NSInteger sameCount = 0;
        for (NSInteger i=0; i<maxLength; i++) {
            NSRange range = NSMakeRange(0, i+1);
            NSString * letterA = [localIp substringWithRange:range];
            NSString *letterB = [host substringWithRange:range];
            if([letterA isEqualToString:letterB]) {
                sameCount = i+1;
            }else {
                break;
            }
        }
        if(sameCount > maxSameCount) {
            maxSameCount = sameCount;
            possibleIndex = addrIndex;
        }
    }
    NSString *hitIp = nil;
    if(possibleIndex != NSNotFound) {
        hitIp = addresses[possibleIndex];
    }
    NSAssert([hitIp isEqualToString:@"192.168.0.100"], @"");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
