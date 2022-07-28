//
//  ADHInfoItem.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/4.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ADHInfoType) {
    ADHInfoTypeString,
    ADHInfoTypeArray,
};


@interface ADHInfoItem : NSObject

@property (nonatomic, assign) ADHInfoType type;

- (BOOL)isContainer;

@property (nonatomic, weak) ADHInfoItem * parent;
//key
@property (nonatomic, strong) NSString * keyName;
@property (nonatomic, assign) NSInteger keyIndex;
//value
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSArray<ADHInfoItem *> * children;
//tip
@property (nonatomic, strong) NSString *tip;
//icon
@property (nonatomic, strong) NSString *iconName;

+ (ADHInfoItem *)kvItemWithData: (NSDictionary *)data;

@end
