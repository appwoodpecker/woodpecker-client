//
//  ADHFileActivityItem.h
//  ADHClient
//
//  Created by 张小刚 on 2018/7/14.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ADHFileActivityType) {
    ADHFileActivityAdd,
    ADHFileActivityEdit,
    ADHFileActivityRemove,
};

@interface ADHFileActivityItem : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) ADHFileActivityType type;
@property (nonatomic, assign) BOOL isDir;
@property (nonatomic, strong) NSDate* date;

- (NSDictionary *)dicPresentation;
+ (ADHFileActivityItem *)itemWithData: (NSDictionary *)data;

- (NSString *)readbleActivity;

@end
