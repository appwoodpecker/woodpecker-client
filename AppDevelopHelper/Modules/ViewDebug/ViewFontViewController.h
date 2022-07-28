//
//  FontViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/11.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewFontViewController : NSViewController

@property (nonatomic, copy) void (^completionBlock)(NSString *fontName, NSInteger fontSize);

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) NSInteger fontSize;

@end

NS_ASSUME_NONNULL_END
