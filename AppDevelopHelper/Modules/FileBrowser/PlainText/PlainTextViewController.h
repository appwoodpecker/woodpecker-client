//
//  PlainTextViewController.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHFilePreviewItem.h"
#import "ADHNetworkTransaction.h"

@interface PlainTextViewController : NSViewController

@property (nonatomic, strong) ADHFilePreviewItem * fileItem;
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) ADHNetworkTransaction *transaction;
@property (nonatomic, assign) BOOL bRequestBody;

@property (nonatomic, assign) BOOL formatBeautify;
- (void)reload;

@end
