//
//  ADHAllowDeviceUtil.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/23.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHAllowDeviceUtil : NSObject

//allowed
+ (BOOL)checkName: (NSString *)name matchRule: (NSDictionary *)ruleData;

//not disallowed
+ (BOOL)checkName: (NSString *)name notDisallowed: (NSDictionary *)ruleData;

@end
