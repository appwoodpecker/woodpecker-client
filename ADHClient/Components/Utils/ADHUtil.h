//
//  ADHUtil.h
//  ADHClient
//
//  Created by 张小刚 on 2020/7/5.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHUtil : NSObject

+ (NSString *)getDeviceModel;
+ (NSString *)getSSID;
+ (NSString *)getLocalIPAddress;
+ (NSString *)localUSBIP;
+ (BOOL)isSimulator;

//mac only
+ (BOOL)isSandboxed;
+ (NSString *)deviceName;

@end
