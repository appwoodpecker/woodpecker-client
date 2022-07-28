//
//  ApiActionItem.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/5/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiActionRequest.h"

@interface ApiActionItem : NSObject

//request
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) ApiActionRequest * actionRequest;
//response
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * filePath;

@end
