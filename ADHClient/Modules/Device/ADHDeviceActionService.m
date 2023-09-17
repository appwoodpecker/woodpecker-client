//
//  DeviceActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHDeviceActionService.h"
@import UIKit;

@implementation ADHDeviceActionService

+ (NSString *)serviceName
{
    return @"adh.device";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
            //spell fix
             @"screenshort" : NSStringFromSelector(@selector(onRequestScreenshot:)),
             @"screenshot" : NSStringFromSelector(@selector(onRequestScreenshot:)),
             @"info" : NSStringFromSelector(@selector(onRequestInfo:)),
             @"onTouchEvent" : NSStringFromSelector(@selector(onRequestTouchEvent:)),
             };
}

- (void)onRequestScreenshot: (ADHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplicationState state = [UIApplication.sharedApplication applicationState];
        if(state == UIApplicationStateActive) {
            UIScreen * screen = [UIScreen mainScreen];
            CGSize size = screen.bounds.size;
            UIGraphicsBeginImageContextWithOptions(size, NO, screen.scale);
            // Iterate over every window from back to front
            for (UIWindow *window in [[UIApplication sharedApplication] windows]){
                if (![window respondsToSelector:@selector(screen)] || [window screen] == screen){
                    [window drawViewHierarchyInRect:window.frame afterScreenUpdates:NO];
                }
            }
            // Retrieve the screenshot image
            UIImage * screenshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData * data = UIImagePNGRepresentation(screenshot);
            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
            NSDictionary * body = @{
                                    @"orientation" : adhvf_string_integer(orientation),
                                    };
            [request finishWithBody:body payload:data];
        }else {
            [request finish];
        }
    });
}

- (void)onRequestInfo: (ADHRequest *)request {
    /*
     Device:
     
     name;
     model;
     systemName;
     systemVersion;
     orientation
     */
    NSMutableArray * list = [NSMutableArray array];
    UIDevice * device = [UIDevice currentDevice];
    [list addObject:@{
                      @"name" : @"Device Name",
                      @"value" : adhvf_safestringfy([device name]),
                      }];
    [list addObject:@{
                      @"name" : @"Device Model",
                      @"value" : adhvf_safestringfy([device model]),
                      }];
    [list addObject:@{
                      @"name": @"System Name",
                      @"value" : adhvf_safestringfy([device systemName]),
                      }];
    [list addObject:@{
                      @"name": @"System Version",
                      @"value" : adhvf_safestringfy([device systemVersion]),
                      }];
    [list addObject:@{
                      @"name": @"Orientation",
                      @"value" : adhvf_safestringfy([self readbleOrientation:[device orientation]]),
                      }];
    /*
     Resolution
     Size(in points)
     Scale
     */
    UIScreen * screen = [UIScreen mainScreen];
    CGFloat screenWidth = screen.bounds.size.width;
    CGFloat screenHeight = screen.bounds.size.height;
    CGFloat scale = screen.scale;
    [list addObject:@{
                      @"name": @"Resolution",
                      @"value" : [NSString stringWithFormat:@"%.f x %.f",screenWidth*scale,screenHeight*scale],
                      }];
    [list addObject:@{
                      @"name": @"Size (in points)",
                      @"value" : [NSString stringWithFormat:@"%.f x %.f",screenWidth,screenHeight],
                      }];
    [list addObject:@{
                      @"name": @"Scale",
                      @"value" : [NSString stringWithFormat:@"%.1f",scale],
                      }];
    /*
     Process Info
     
     processName
     processIdentifier
     processorCount
     activeProcessorCount
     physicalMemory
     */
    NSProcessInfo * process = [NSProcessInfo processInfo];
    [list addObject:@{
                      @"name": @"Process Name",
                      @"value" : adhvf_safestringfy(adhvf_safestringfy([process processName])),
                      }];
    [list addObject:@{
                      @"name": @"Process ID",
                      @"value" : [NSString stringWithFormat:@"%d",[process processIdentifier]],
                      }];
    [list addObject:@{
                      @"name": @"Processor Count",
                      @"value" : adhvf_safestringfy(adhvf_string_integer([process processorCount])),
                      }];
    [list addObject:@{
                      @"name": @"Active Processor Count",
                      @"value" : adhvf_safestringfy(adhvf_string_integer([process activeProcessorCount])),
                      }];
    [list addObject:@{
                      @"name": @"Physical Memory",
                      @"value" : adhvf_safestringfy([self readblePhysicalMemory:[process physicalMemory]]),
                      }];
    /*
     App Info:
     app name
     app version
     app build
     font
     url scheme
     */
    NSDictionary * infoDic = [[NSBundle mainBundle] infoDictionary];
    [list addObject:@{
                      @"name": @"App Name",
                      @"value" : adhvf_safestringfy(infoDic[@"CFBundleDisplayName"]),
                      }];
    [list addObject:@{
                      @"name": @"App Bundle Identifier",
                      @"value" : adhvf_safestringfy(infoDic[@"CFBundleIdentifier"]),
                      }];
    [list addObject:@{
                      @"name": @"App Version",
                      @"value" : adhvf_safestringfy(infoDic[@"CFBundleShortVersionString"]),
                      }];
    [list addObject:@{
                      @"name": @"App Build",
                      @"value" : adhvf_safestringfy(infoDic[@"CFBundleVersion"]),
                      }];
    [list addObject:@{
                      @"name" : @"Fonts",
                      @"value" : adhvf_safestringfy([self getAppFonts:infoDic]),
                      }];
    [list addObject:@{
                      @"name" : @"URL Schemes",
                      @"value" : adhvf_safestringfy([self getUrlSchemes:infoDic]),
                      }];
    
    /*
     本地环境
     语言
     国家
     NSLocaleLanguageCode
     NSLocaleCountryCode
     */
    NSLocale * locale = [NSLocale currentLocale];
    
    [list addObject:@{
                      @"name": @"Locale Identifier",
                      @"value" : adhvf_safestringfy([locale objectForKey:NSLocaleIdentifier]),
                      }];
    [list addObject:@{
                      @"name": @"Locale Language Code",
                      @"value" : adhvf_safestringfy([locale objectForKey:NSLocaleLanguageCode]),
                      }];
    [list addObject:@{
                      @"name": @"Locale Country Code",
                      @"value" : adhvf_safestringfy([locale objectForKey:NSLocaleCountryCode]),
                      }];
    /*
     时区，日历
     */
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [list addObject:@{
                      @"name" : @"Local Timezone",
                      @"tip" : @"The localTimeZone always reflects the current system time zone",
                      @"value" : adhvf_safestringfy([self readbleTimeZone:localTimeZone]),
                      }];
    NSTimeZone *defaultTimeZone = [NSTimeZone defaultTimeZone];
    [list addObject:@{
                      @"name" : @"Default Timezone",
                      @"tip" : @"The defaultTimeZone is used by the app for date and time operations",
                      @"value" : adhvf_safestringfy([self readbleTimeZone:defaultTimeZone]),
                      }];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [list addObject:@{
                      @"name" : @"Current Calendar",
                      @"tip" : @"System Calendar",
                      @"value" : adhvf_safestringfy([self readbleCalendar:calendar]),
                      }];
    NSCalendar *autoupdateCalendar = [NSCalendar autoupdatingCurrentCalendar];
    [list addObject:@{
                      @"name" : @"Autoupdating Current Calendar",
                      @"tip" : @"Settings you get from this calendar do change as the user’s settings change (contrast with currentCalendar).",
                      @"value" : adhvf_safestringfy([self readbleCalendar:autoupdateCalendar]),
                      }];
    NSDictionary * data = @{
                            @"list" : list,
                            };
    [request finishWithBody:data];
}

//fonts
- (NSString *)getAppFonts: (NSDictionary *)infoData {
    NSString *text = nil;
    NSArray *fonts = infoData[@"UIAppFonts"];
    if(fonts && [fonts isKindOfClass:[NSArray class]]) {
        text = [fonts componentsJoinedByString:@","];
    }
    return text;
}

//url schemes
- (NSString *)getUrlSchemes: (NSDictionary *)infoData {
    NSString *text = nil;
    NSArray *types = infoData[@"CFBundleURLTypes"];
    NSMutableArray * typeList = [NSMutableArray array];
    if(types && [types isKindOfClass:[NSArray class]]) {
        for (NSDictionary *typeData in types) {
            NSArray *items = typeData[@"CFBundleURLSchemes"];
            if(items && [items isKindOfClass:[NSArray class]]) {
                NSString *typeText = [items componentsJoinedByString:@","];
                if(typeText.length > 0) {
                    [typeList addObject:typeText];
                }
            }
        }
    }
    if(typeList.count > 0) {
        text = [typeList componentsJoinedByString:@" "];
    }
    return text;
}

- (NSString *)readbleTimeZone: (NSTimeZone *)timezone {
    //name abbreviation，secondsFromGMT
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"%@ %@ %zd",timezone.name,timezone.abbreviation,timezone.secondsFromGMT];
    return text;
}

- (NSString *)readbleCalendar: (NSCalendar *)calendar {
    NSMutableString *text = [NSMutableString string];
    //calendarIdentifier
    [text appendFormat:@"%@",calendar.calendarIdentifier];
    return text;
}

- (NSString *)readblePhysicalMemory: (unsigned long long)physicalMemory
{
    NSString * result = nil;
    int kBytesPerMb = 1024 * 1024;
    int mbs = (int)(physicalMemory/kBytesPerMb);
    if(mbs >= 1024){
        float gbs = mbs / 1024.0f;
        result = [NSString stringWithFormat:@"%.1f GB",gbs];
    }else{
        result = [NSString stringWithFormat:@"%d MB",mbs];
    }
    return result;
}

- (NSString *)readbleOrientation: (UIDeviceOrientation)orientation
{
    NSString * text = nil;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            text = @"Portrait, home button on the bottom";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            text = @"PortraitUpsideDown, home button on the top";
            break;
        case UIDeviceOrientationLandscapeLeft:
            text = @"LandscapeLeft, home button on the right";
            break;
        case UIDeviceOrientationLandscapeRight:
            text = @"LandscapeRight, home button on the left";
            break;
        case UIDeviceOrientationFaceUp:
            text = @"FaceUp, Device oriented flat, face up";
            break;
        case UIDeviceOrientationFaceDown:
            text = @"FaceDown, Device oriented flat, face down";
            break;
        default:
            text = @"Unknown";
            break;
    }
    return text;
}

- (void)onRequestTouchEvent: (ADHRequest *)request
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * body = request.body;
        NSString * pointDes = body[@"point"];
        CGPoint point = CGPointFromString(pointDes);
        NSLog(@"%@",pointDes);
        CGPoint touchPoint = CGPointZero;
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        CGSize screenSize = window.bounds.size;
        touchPoint.x = point.x * screenSize.width;
        touchPoint.y = point.y * screenSize.height;
        UIView * view = [window hitTest:touchPoint withEvent:nil];
        NSLog(@"%@",view);
        if([view isKindOfClass:[UIControl class]]){
            UIControl * control = (UIControl*)view;
            [control sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    });
}



@end








