//
//  ADHViewDebugUtil.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/24.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHViewDebugUtil.h"
#import "ADHAttribute.h"

@import CoreGraphics;

@implementation ADHViewDebugUtil

+ (NSString *)stringWithAdhColor: (ADH_COLOR)color {
    return [NSString stringWithFormat:@"%d,%f,%f,%f,%f,%f",color.mode,color.v1,color.v2,color.v3,color.v4,color.alpha];
}

+ (ADH_COLOR)colorWithString: (NSString *)value {
    NSArray *values = [value componentsSeparatedByString:@","];
    ADH_COLOR color = adhColorMake([values[0] intValue],
                                        [values[1] floatValue],
                                        [values[2] floatValue],
                                        [values[3] floatValue],
                                        [values[4] floatValue],
                                        [values[5] floatValue]
                                   );
    return color;
}

+ (NSString *)stringWithAdhFrame: (ADH_FRAME)frame {
    return [NSString stringWithFormat:@"%f,%f,%f,%f",frame.centerX,frame.centerY,frame.width,frame.height];
}

+ (ADH_FRAME)frameWithString: (NSString *)value {
    NSArray *values = [value componentsSeparatedByString:@","];
    ADH_FRAME frame = adhFrameMake([values[0] floatValue],
                                   [values[1] floatValue],
                                   [values[2] floatValue],
                                   [values[3] floatValue]);
    return frame;
}

+ (CGRect)cgFrameWithAdhFrame:(ADH_FRAME)rect {
    CGRect frame = CGRectMake(rect.centerX-rect.width/2, rect.centerY-rect.height/2, rect.width, rect.height);
    return frame;
}

+ (NSString *)stringWithAdhInsets: (ADH_INSETS)insets {
    return [NSString stringWithFormat:@"%f,%f,%f,%f",insets.top,insets.left,insets.bottom,insets.right];
}

+ (NSString *)presentStringWithAdhInsets: (ADH_INSETS)insets {
    return [NSString stringWithFormat:@"[%.1f, %.1f, %.1f, %.1f]",insets.top,insets.left,insets.bottom,insets.right];
}

+ (ADH_INSETS)insetsWithString: (NSString *)value {
    NSArray *values = [value componentsSeparatedByString:@","];
    ADH_INSETS insets = adhInsetsMake([values[0] floatValue],
                                   [values[1] floatValue],
                                   [values[2] floatValue],
                                   [values[3] floatValue]);
    return insets;
}

//cgpoint
+ (NSString *)stringWithCGPoint: (CGPoint)point {
    return [NSString stringWithFormat:@"%.1f,%.1f",point.x,point.y];
}

+ (NSString *)presentStringWithCGPoint: (CGPoint)point {
    return [NSString stringWithFormat:@"[%.1f,%.1f]",point.x,point.y];
}

+ (CGPoint)pointWithString: (NSString*)value {
    NSArray *values = [value componentsSeparatedByString:@","];
    CGPoint point = CGPointMake([values[0] floatValue], [values[1] floatValue]);
    return point;
}

//cgsize
+ (NSString *)stringWithCGSize: (CGSize)size {
    return [NSString stringWithFormat:@"%.1f,%.1f",size.width,size.height];
}

+ (NSString *)presentStringWithCGSize: (CGSize)size {
    return [NSString stringWithFormat:@"[%.1f,%.1f]",size.width,size.height];
}

+ (CGSize)sizeWithString: (NSString *)value {
    NSArray *values = [value componentsSeparatedByString:@","];
    CGSize size = CGSizeMake([values[0] floatValue], [values[1] floatValue]);
    return size;
}

+ (NSNumber *)numberWithAdhInt: (ADH_INT)value {
    return [NSNumber numberWithLongLong:value];
}

+ (ADH_INT)adhIntWithValue: (NSNumber *)value {
    return [value longLongValue];
}

+ (NSString *)stringWithAdhInt: (ADH_INT)value {
    return [NSString stringWithFormat:@"%lld",value];
}

+ (ADH_INT)adhIntWithString: (NSString *)value {
    return [value longLongValue];
}

+ (NSString *)stringWithBool: (BOOL)value {
    return value ? @"YES" : @"NO";
}

+ (NSString *)presentStringWithRange: (NSRange)range {
    NSString *text = nil;
    if(range.location == NSNotFound) {
        text = [NSString stringWithFormat:@"-"];
    }else {
        text = [NSString stringWithFormat:@"%zd - %zd",range.location,range.location + range.length];
    }
    return text;
}

+ (NSString *)stringWithRange: (NSRange)range {
    return NSStringFromRange(range);
}

+ (NSRange)rangeWithString: (NSString *)value {
    return NSRangeFromString(value);
}

#pragma mark -----------------   detail   ----------------

+ (NSArray *)textAlignmentItemList {
    return @[
             ADH_POPUP(@"Left", 0),
             ADH_POPUP(@"Center", 1),
             ADH_POPUP(@"Right", 2),
             ADH_POPUP(@"Justified", 3),
             ADH_POPUP(@"Natural", 4),
             ];
}

+ (NSString *)stringWithTextAlignment: (ADH_INT)textAlignment {
    /*
     NSTextAlignmentLeft      = 0,
     NSTextAlignmentCenter    = 1,
     NSTextAlignmentRight     = 2,
     NSTextAlignmentJustified = 3,
     NSTextAlignmentNatural   = 4,
     */
    NSString *text = nil;
    switch (textAlignment) {
        case 0:
            text = @"Left";
            break;
        case 1:
            text = @"Center";
            break;
        case 2:
            text = @"Right";
            break;
        case 3:
            text = @"Justified";
            break;
        case 4:
            text = @"Natural";
            break;
        default:
            break;
    }
    return text;
}

+ (NSString *)stringWithDataDetectorType: (ADH_INT)type {
    NSMutableArray *texts = [NSMutableArray array];
    if(type == 0) {
        [texts addObject:@"None"];
    }else if(type == NSUIntegerMax) {
        [texts addObject:@"All"];
    }else {
        if(type & 1 << 0) {
            [texts addObject:@"Phone Number"];
        }
        if(type & 1 << 0) {
            [texts addObject:@"Link"];
        }
        if(type & 1 << 0) {
            [texts addObject:@"Address"];
        }
        if(type & 1 << 0) {
            [texts addObject:@"Calendar Event"];
        }
        if(type & 1 << 0) {
            [texts addObject:@"Shipment Tracking Number"];
        }
        if(type & 1 << 0) {
            [texts addObject:@"Flight Number"];
        }
        if(type & 1 << 0) {
            [texts addObject:@"Lookup Suggestion"];
        }
    }
    NSString *text = [texts componentsJoinedByString:@"\n"];
    return text;
    /*
    UIDataDetectorTypePhoneNumber                                        = 1 << 0, // Phone number detection
    UIDataDetectorTypeLink                                               = 1 << 1, // URL detection
    UIDataDetectorTypeAddress NS_ENUM_AVAILABLE_IOS(4_0)                 = 1 << 2, // Street address detection
    UIDataDetectorTypeCalendarEvent NS_ENUM_AVAILABLE_IOS(4_0)           = 1 << 3, // Event detection
    UIDataDetectorTypeShipmentTrackingNumber NS_ENUM_AVAILABLE_IOS(10_0) = 1 << 4, // Shipment tracking number detection
    UIDataDetectorTypeFlightNumber NS_ENUM_AVAILABLE_IOS(10_0)           = 1 << 5, // Flight number detection
    UIDataDetectorTypeLookupSuggestion NS_ENUM_AVAILABLE_IOS(10_0)       = 1 << 6, // Information users may want to look up
    UIDataDetectorTypeNone          = 0,               // Disable detection
    UIDataDetectorTypeAll           = NSUIntegerMax    // Enable all types, including types that may be added later
     */
}


+ (ADH_INT)mapControlStateWithIndex: (NSInteger)index {
    /*
     UIControlStateNormal       = 0,
     UIControlStateHighlighted  = 1 << 0,
     UIControlStateDisabled     = 1 << 1,
     UIControlStateSelected     = 1 << 2,
     */
    NSArray *list = @[
                      @(0),
                      @(1 << 0),
                      @(1 << 1),
                      @(1 << 2),
                      ];
    ADH_INT value = 0;
    if(index >=0 && index < list.count) {
        value = [ADHViewDebugUtil adhIntWithValue:list[index]];
    }
    return value;
}

+ (NSInteger)mapIndexWithControlState: (ADH_INT)state {
    NSArray *list = @[
                      @(0),
                      @(1 << 0),
                      @(1 << 1),
                      @(1 << 2),
                      ];
    NSInteger index = NSNotFound;
    for (NSInteger i=0; i<list.count; i++) {
        ADH_INT value = [ADHViewDebugUtil adhIntWithValue:list[i]];
        if(state == value) {
            index = i;
            break;
        }
    }
    return index;
}

+ (NSString *)stringWithInstance: (id)instance {
    NSString *text = nil;
    if(instance) {
        NSString *addr = [NSString stringWithFormat:@"%p",instance];
        NSString *className = NSStringFromClass([instance class]);
        text = [NSString stringWithFormat:@"%@ %@",className,addr];
    }else {
        text = adhvf_const_emptystr();
    }
    return text;
}

+ (NSString *)stringWithInstance2: (id)instance {
    NSString *text = nil;
    if(instance) {
        NSString *addr = [NSString stringWithFormat:@"%p",instance];
        text = addr;
    }else {
        text = adhvf_const_emptystr();
    }
    return text;
}

@end


