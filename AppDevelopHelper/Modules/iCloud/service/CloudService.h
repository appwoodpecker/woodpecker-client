//
//  CloudService.h
//  Woodpecker
//
//  Created by 张小刚 on 2019/10/13.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHCloudItem.h"

@interface CloudService : NSObject

+ (CloudService *)serviceWithContext: (AppContext *)context;
@property (nonatomic, strong) NSString *containerId;

/**
 检索
 */
- (ADHCloudItem *)searchPreviewTree: (ADHCloudItem *)rootItem withKeywords: (NSString *)keywords;

@end
