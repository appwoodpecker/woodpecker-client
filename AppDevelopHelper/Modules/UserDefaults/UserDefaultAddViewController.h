//
//  UserDefaultAddViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/12/6.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserDefaultAddViewController : NSViewController

@property (nonatomic, strong) NSString *suiteName;
@property (nonatomic, assign) BOOL iCloud;
@property (nonatomic, copy) void (^cancelBlock)(void);
@property (nonatomic, copy) void (^completionBlock)(NSString *key);
@property (nonatomic, copy) void (^valueBlock)(NSString *key, NSString *value);

@end

NS_ASSUME_NONNULL_END
