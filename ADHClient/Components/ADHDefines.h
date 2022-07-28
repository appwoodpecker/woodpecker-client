//
//  ADHDefines.h
//  ADHClient
//
//  Created by 张小刚 on 2019/2/24.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import CoreGraphics;

extern ADH_COLOR adhColorFromUIColor(UIColor *color);
extern UIColor *uicolorFromAdhColor(ADH_COLOR color);

extern ADH_FRAME adhFrameFromFrame(CGRect frame);
extern CGRect frameFromAdhFrame(ADH_FRAME frame);

extern ADH_INSETS adhInsetsFromInsets(UIEdgeInsets insets);
extern UIEdgeInsets uiinsetsFromAdhInsets(ADH_INSETS insets);

extern ADHFont* adhFontFromUIFont(UIFont *font);
extern UIFont *uifontFromAdhFont(ADHFont *font);

@interface ADHDefines : NSObject

+ (NSString *)stringWithFont: (UIFont *)font;

@end
