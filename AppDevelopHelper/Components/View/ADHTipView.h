//
//  ADHTipView.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/5/12.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^ADHTipViewActionBlock)(void);

@interface ADHTipView : NSView

- (void)setText: (NSString *)text actionText: (NSString *)actionText action: (ADHTipViewActionBlock)actionBlock;
- (void)showInView: (NSView *)containerView;

@end
