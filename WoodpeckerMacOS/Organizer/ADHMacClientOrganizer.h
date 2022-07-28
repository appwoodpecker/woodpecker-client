//
//  MacClientOrganizer.h
//  WoodpeckerMacOS
//
//  Created by 张小刚 on 2019/5/25.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * parameters that specify which mac client you'd like connect to
 * learn more at http://www.woodpeck.cn/connection.html
 */
extern NSString *const kADHHostName;
extern NSString *const kADHHostAddress;
extern NSString *const kADHAutoConnectEnabled;

@interface ADHMacClientOrganizer : NSObject

+ (ADHMacClientOrganizer *)sharedOrganizer;

/**
 * register your own ADHService
 * learn more about custom service, please visit http://www.woodpeck.cn/plugin.html
 */
- (void)registerService: (Class)serviceClazz;

@end

NS_ASSUME_NONNULL_END
