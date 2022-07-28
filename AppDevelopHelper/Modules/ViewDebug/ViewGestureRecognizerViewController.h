//
//  ViewGestureRecognizerViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHAttribute.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GestureRecognizerUpdateBlock)(NSString *key, id value, NSDictionary *info);
@interface ViewGestureRecognizerViewController : NSViewController

@property (nonatomic, strong) ADHViewAttribute *viewAttribute;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) GestureRecognizerUpdateBlock updationBlock;

@end

NS_ASSUME_NONNULL_END
