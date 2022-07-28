//
//  JsonTextViewController.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/5/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHNetworkTransaction.h"

@interface JsonTextViewController : NSViewController

@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) ADHNetworkTransaction *transaction;
@property (nonatomic, assign) BOOL bRequestBody;

@end
