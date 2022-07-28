//
//  UserDefaultSuiteViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/10.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const kUserDefaultStandardSuiteName;

NS_ASSUME_NONNULL_BEGIN

@interface UserDefaultSuiteViewController : NSViewController

@property (nonatomic, strong) NSString *currentSuiteName;
@property (nonatomic, copy) void (^completionBlock)(NSString *suiteName);

@end

NS_ASSUME_NONNULL_END
