//
//  LogItem.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/5/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogItem : NSObject

@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSColor * textColor;
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSString * fileName;

@property (nonatomic, strong) NSDate * date;

@end
