//
//  CocoaDefines.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/30.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern ADH_COLOR adhColorFromNSColor(NSColor *color);
extern NSColor * nscolorFromAdhColor(ADH_COLOR adhColor);

NS_ASSUME_NONNULL_BEGIN

@interface CocoaDefines : NSObject

@end

NS_ASSUME_NONNULL_END
