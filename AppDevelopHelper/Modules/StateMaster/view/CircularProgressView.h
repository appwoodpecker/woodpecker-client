//
//  RoundProgressView.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/6/19.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CircularProgressView : NSView

- (void)setProgress: (float)progress;
- (void)resetProgress;

@end
