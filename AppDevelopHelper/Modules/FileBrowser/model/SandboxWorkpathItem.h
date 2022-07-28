//
//  SandboxWorkpathItem.h
//  Woodpecker
//
//  Created by 张小刚 on 2019/6/1.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SandboxWorkpathItem : NSObject

@property (nonatomic, strong) NSString *bundleId;
@property (nonatomic, strong) NSString *path;

+ (SandboxWorkpathItem *)itemWithData: (NSDictionary *)data;
- (NSDictionary *)dicPresentation;

@end
