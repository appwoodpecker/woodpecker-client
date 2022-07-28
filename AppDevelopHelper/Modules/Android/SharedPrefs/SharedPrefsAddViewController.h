//
//  SharedPrefsAddViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/7/6.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SharedPrefsAddViewController : NSViewController

@property (nonatomic, strong) NSString *suiteName;
@property (nonatomic, copy) void (^cancelBlock)(void);
@property (nonatomic, copy) void (^completionBlock)(NSString *key);

@end

NS_ASSUME_NONNULL_END
