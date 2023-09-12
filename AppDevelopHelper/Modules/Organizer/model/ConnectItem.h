//
//  ConnectItem.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/3/2.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UseStatus) {
    UseStatusNone,
    UseStatusUsing,
};

/**
 记录每一个连接过的应用
 */
@interface ConnectItem : NSObject

@property (nonatomic, strong) NSString * deviceName;
@property (nonatomic, strong) NSString * appName;
@property (nonatomic, strong) NSString * bundleId;
//是否在使用
@property (nonatomic, assign) UseStatus useStatus;
//是否处于连接状态
@property (nonatomic, assign,getter=isConnected) BOOL connected;


@end
