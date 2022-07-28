//
//  MacOrganizer.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacConnector.h"

@interface MacOrganizer : NSObject

+ (MacOrganizer *)organizer;
- (MacConnector *)connector;
- (void)start;


@end
