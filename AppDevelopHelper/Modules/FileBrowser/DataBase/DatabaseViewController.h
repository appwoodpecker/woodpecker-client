//
//  DatabaseViewController.h
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/29.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHFilePreviewItem.h"

@interface DatabaseViewController : NSViewController

@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) ADHFilePreviewItem * fileItem;
@property (nonatomic, assign) BOOL editable;
- (void)reload;

@end
