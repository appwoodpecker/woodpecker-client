//
//  NSObject+ADHExtends.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/24.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppContext.h"

@interface NSObject (ADHExtends)

- (void)setContext: (AppContext *)context;
- (AppContext *)context;
- (ADHApiClient *)apiClient;

@end
