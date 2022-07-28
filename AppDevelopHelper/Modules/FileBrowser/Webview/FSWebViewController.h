//
//  FSWebViewController.h
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHFilePreviewItem.h"


@interface FSWebViewController : NSViewController

@property (nonatomic, strong) ADHFilePreviewItem * fileItem;
@property (nonatomic, strong) NSString * filePath;
- (void)reload;

@end
