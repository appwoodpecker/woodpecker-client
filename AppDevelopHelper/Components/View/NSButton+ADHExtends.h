//
//  NSButton+ADHExtends.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/5/12.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSButton (ADHExtends)

- (void)setTextColor: (NSColor *)textColor;

@end


@interface ADHButton: NSButton

//增加selected标识
@property (nonatomic, assign) BOOL selected;

@end
