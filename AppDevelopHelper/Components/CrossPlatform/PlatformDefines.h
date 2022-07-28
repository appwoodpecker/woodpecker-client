//
//  PlatformDefines.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/24.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

//平台无关定义

#ifndef platformDefines_h
#define platformDefines_h

typedef enum : int32_t {
    ADHPlatformiOS = 0,
    ADHPlatformMacOS = 1,
    ADHPlatformAndroid = 2,
} ADHPlatform;

typedef int64_t ADH_INT;

/**
 mode(0,1,2) -> (rgb,gray,cmyk)
 实际使用发现iOS都可获取到rgb
 cocoa其他space也都可以转到rgb space
 所以目前mode都为0
 */
struct ADH_COLOR {
    int mode;
    CGFloat v1;
    CGFloat v2;
    CGFloat v3;
    CGFloat v4;
    CGFloat alpha;
};

typedef struct CG_BOXABLE ADH_COLOR ADH_COLOR;

struct ADH_FRAME {
    CGFloat centerX;
    CGFloat centerY;
    CGFloat width;
    CGFloat height;
};

typedef struct CG_BOXABLE ADH_FRAME ADH_FRAME;

struct ADH_INSETS {
    CGFloat top;
    CGFloat left;
    CGFloat bottom;
    CGFloat right;
};

typedef struct CG_BOXABLE ADH_INSETS ADH_INSETS;

#endif
extern ADH_COLOR adhColorZero(void);
extern ADH_COLOR adhColorMake(int mode,CGFloat v1, CGFloat v2, CGFloat v3, CGFloat v4, CGFloat alpha);
extern ADH_FRAME adhFrameMake(CGFloat centerX, CGFloat centerY, CGFloat width, CGFloat height);
extern ADH_INSETS adhInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);

@interface ADHFont : NSObject

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) NSInteger fontSize;

+ (ADHFont *)fontWithName: (NSString *)fontName size: (NSInteger)fontSize;
- (NSString *)stringValue;
+ (ADHFont *)fontWithString: (NSString *)value;

@end

@interface PlatformDefines : NSObject

@end
