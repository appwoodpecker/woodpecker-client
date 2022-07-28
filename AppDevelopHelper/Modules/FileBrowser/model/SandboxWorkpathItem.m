//
//  SandboxWorkpathItem.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/6/1.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "SandboxWorkpathItem.h"

@implementation SandboxWorkpathItem

+ (SandboxWorkpathItem *)itemWithData: (NSDictionary *)data {
    SandboxWorkpathItem *item = [[SandboxWorkpathItem alloc] init];
    item.bundleId = data[@"bundleId"];
    item.path = data[@"path"];
    return item;
}

- (NSDictionary *)dicPresentation {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"bundleId"] = adhvf_safestringfy(self.bundleId);
    data[@"path"] = adhvf_safestringfy(self.path);
    return data;
}

@end
