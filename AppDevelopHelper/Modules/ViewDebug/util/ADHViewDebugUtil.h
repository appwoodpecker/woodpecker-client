//
//  ADHViewDebugUtil.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/24.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADHViewDebugUtil : NSObject

//color
+ (NSString *)stringWithAdhColor: (ADH_COLOR)color;
+ (ADH_COLOR)colorWithString: (NSString *)value;

//adhframe
+ (NSString *)stringWithAdhFrame: (ADH_FRAME)rect;
+ (ADH_FRAME)frameWithString: (NSString *)value;
+ (CGRect)cgFrameWithAdhFrame:(ADH_FRAME)rect;

//adhint
+ (NSNumber *)numberWithAdhInt: (ADH_INT)value;
+ (ADH_INT)adhIntWithValue: (NSNumber *)value;

+ (NSString *)stringWithAdhInt: (ADH_INT)value;
+ (ADH_INT)adhIntWithString: (NSString *)value;

//insets
+ (NSString *)stringWithAdhInsets: (ADH_INSETS)insets;
+ (NSString *)presentStringWithAdhInsets: (ADH_INSETS)insets;
+ (ADH_INSETS)insetsWithString: (NSString *)value;

//cgpoint
+ (NSString *)stringWithCGPoint: (CGPoint)point;
+ (NSString *)presentStringWithCGPoint: (CGPoint)point;
+ (CGPoint)pointWithString: (NSString*)value;

//cgsize
+ (NSString *)stringWithCGSize: (CGSize)size;
+ (NSString *)presentStringWithCGSize: (CGSize)size;
+ (CGSize)sizeWithString: (NSString *)value;

//bool
+ (NSString *)stringWithBool: (BOOL)value;
//range
+ (NSString *)presentStringWithRange: (NSRange)range;
+ (NSString *)stringWithRange: (NSRange)range;
+ (NSRange)rangeWithString: (NSString *)value;

//NSTextAlignment
+ (NSArray *)textAlignmentItemList;
+ (NSString *)stringWithTextAlignment: (ADH_INT)textAlignment;

+ (NSString *)stringWithDataDetectorType: (ADH_INT)type;

+ (ADH_INT)mapControlStateWithIndex: (NSInteger)index;
+ (NSInteger)mapIndexWithControlState: (ADH_INT)state;

+ (NSString *)stringWithInstance: (id)instance;
+ (NSString *)stringWithInstance2: (id)instance;


@end

NS_ASSUME_NONNULL_END
