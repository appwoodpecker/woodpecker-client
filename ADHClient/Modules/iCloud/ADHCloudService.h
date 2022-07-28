//
//  ADHCloudService.h
//  ADHClient
//
//  Created by 张小刚 on 2019/9/13.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ADHCloudServiceFetchBlock)(NSDictionary *data, NSString *errorMsg);
@interface ADHCloudService : NSObject

+ (ADHCloudService *)serviceWithId: (NSString *)containerId;
- (BOOL)iCloudEnabled;
- (BOOL)isContainerAvailable;

//icloud available
- (void)fetchCloudItemsOnCompletion: (ADHCloudServiceFetchBlock)completionBlock;

//read file
- (void)readFile: (NSString *)path onCompletion: (void (^)(NSData *fileData, NSString *errorMsg))completionBlock;

@end
