//
//  RemoteServiceItem.h
//  ADHClient
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ADHRemoteServiceStatus) {
    ADHRemoteServiceStatusUnConnect,
    ADHRemoteServiceStatusConnecting,
    ADHRemoteServiceStatusConnected,
};

@interface ADHRemoteServiceItem : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * host;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, strong) NSDictionary *ruleData;
@property (nonatomic, assign) BOOL simulator;
@property (nonatomic, assign) BOOL usb;

@property (nonatomic, assign) ADHRemoteServiceStatus connectStatus;

//allowed
- (BOOL)isRuleMatch;

//not disallowed
- (BOOL)isNotDisallowed;

@end
