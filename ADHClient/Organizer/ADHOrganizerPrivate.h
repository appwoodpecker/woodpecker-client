//
//  ADHOrganizerPrivate.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/6/6.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kADHOrganizerWindowDidVisible;
extern NSString * const kADHOrganizerWorkStatusUpdate;
extern NSString * const kADHShowOnConnectionFailed;

@class ADHAppConnector;

@interface ADHOrganizer (Private)

- (ADHAppConnector *)connector;
- (ADHProtocol *)protocol;
- (ADHDispatcher *)dispatcher;
- (void)clearAutoConnectTry;
- (NSBundle *)adhBundle;
- (UINib *)nibWithName: (NSString *)nibName;

/**
 * is showing
 */
- (BOOL)isUIShowing;

/**
 working well
 */
- (BOOL)isWorking;

@end

