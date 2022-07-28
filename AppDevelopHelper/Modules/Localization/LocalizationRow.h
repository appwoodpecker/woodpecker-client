//
//  LocalizationRow.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/6/25.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalizationRow : NSObject

@property (nonatomic, assign) BOOL isHeader;
@property (nonatomic, strong) NSString *stringFile;
@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSDictionary *langValues;
@property (nonatomic, assign) BOOL missing;

@end
