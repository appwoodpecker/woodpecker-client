//
//  ADHFilePreviewController.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/27.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHFilePreviewItem.h"

@interface ADHFilePreviewController : NSViewController

@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSString * mimeType;

//for fsbrowser
@property (nonatomic, strong) ADHFilePreviewItem * fileItem;
@property (nonatomic, assign) BOOL formatBeautify;

@property (nonatomic, assign) BOOL editable;

- (void)reload;

@end
