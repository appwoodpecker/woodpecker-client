//
//  ADHFileObserver.h
//  ADHClient
//
//  Created by 张小刚 on 2018/7/5.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADHFileItem;

@interface ADHFileObserver : NSObject

- (void)startWithPath: (NSString *)workPath;
- (void)stop;

@property (nonatomic, strong) NSString *containerName;
@property (nonatomic, strong) NSString *workDir;

@end
