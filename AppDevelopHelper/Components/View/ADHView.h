//
//  ADHView.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/25.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ADHViewDelegate;
@interface ADHView : NSView

@property (nonatomic, assign) NSInteger vtag;
@property (nonatomic, weak) id<ADHViewDelegate> delegate;


@end

@protocol ADHViewDelegate<NSObject>

@optional

- (void)cellRightClicked: (ADHView *)view point: (NSPoint)point;

@end


@interface ADHTextField : NSTextField

@property (nonatomic, assign) BOOL userInteractionDisabled;

@end
