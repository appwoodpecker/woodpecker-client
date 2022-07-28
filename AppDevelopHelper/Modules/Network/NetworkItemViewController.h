//
//  NetworkItemViewController.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/14.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ADHNetworkTransaction;

typedef NS_ENUM(NSUInteger, NetworkViewType) {
    NetworkViewTypeRequestOverview = 0,
    NetworkViewTypeRequestHeader,
    NetworkViewTypeRequestQuery,
    NetworkViewTypeRequestEncodedForm,
    NetworkViewTypeRequestCookie,
    NetworkViewTypeResponseHeader,
    NetworkViewTypeResponseCookie,
};

@interface NetworkItemViewController : NSViewController

- (void)setTransaction: (ADHNetworkTransaction *)transaction viewType: (NetworkViewType)viewType;

@end
