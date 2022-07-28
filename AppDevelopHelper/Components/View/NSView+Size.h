//
//  NSView+Size.h
//  ADHClient
//
//  Created by 张小刚 on 2018/3/2.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Size)

/** Sets the origin.x property of the view to left. */
@property (nonatomic, assign) CGFloat left;

/** Sets the origin.x property of the view to 'right - self.frame.size.width'. */
@property (nonatomic, assign) CGFloat right;

/** Sets the origin.y property of the view to 'top'. */
@property (nonatomic, assign) CGFloat top;

/** Sets the origin.y property of the view to 'bottom - self.frame.size.height'. */
@property (nonatomic, assign) CGFloat bottom;

/** Sets the size.width property of the view to width. */
@property (nonatomic, assign) CGFloat width;

/** Sets the size.height property of the view to height. */
@property (nonatomic, assign) CGFloat height;

/** Sets the origin property of the view to 'origin'. */
@property (nonatomic, assign) CGPoint origin;

/** Sets the size property of the view to 'size'. */
@property (nonatomic, assign) CGSize size;

/** Sets the center property of the view to 'center'. */
@property (nonatomic, assign) CGPoint center;

@end
