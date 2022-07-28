//
//  MacClientOrganizerPrivate.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2019/5/25.
//  Copyright © 2019 lifebetter. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ADHMacClientOrganizer.h"

extern NSString * const kADHOrganizerWindowDidVisible;
extern NSString * const kADHOrganizerWorkStatusUpdate;
extern NSString * const kADHShowOnConnectionFailed;

@class ADHAppConnector;

@interface ADHMacClientOrganizer (Private)

- (ADHAppConnector *) connector;
- (ADHProtocol *)protocol;
- (ADHDispatcher *)dispatcher;
- (void)clearAutoConnectTry;
- (NSBundle *)adhBundle;
/**
 * show connection UI
 */
- (void)showUI;

/**
 * is showing
 */
- (BOOL)isUIShowing;

/**
 working well
 */
- (BOOL)isWorking;

@end
