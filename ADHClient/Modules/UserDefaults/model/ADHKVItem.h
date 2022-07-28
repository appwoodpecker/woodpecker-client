//
//  ADHKVItem.h
//  ADHClient
//
//  Created by 张小刚 on 2018/3/8.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 NSString,
 NSData,
 NSNumber,
 NSDate,
 NSArray,
 NSDictionary
 */
typedef NS_ENUM(NSUInteger, ADHKVItemType) {
    ADHKVItemTypeUnknown,
    ADHKVItemTypeString,
    ADHKVItemTypeData,
    ADHKVItemTypeNumber,
    ADHKVItemTypeDate,
    ADHKVItemTypeArray,
    ADHKVItemTypeDictionary,
    ADHKVItemTypeNull,
};

@interface ADHKVItem : NSObject

@property (nonatomic, assign) ADHKVItemType type;
- (BOOL)isContainer;
- (BOOL)isArray;
- (BOOL)isDictioanry;
- (BOOL)isEditable;

@property (nonatomic, weak) ADHKVItem * parent;
//key
@property (nonatomic, strong) NSString * keyName;
@property (nonatomic, assign) NSInteger keyIndex;
//value
@property (nonatomic, strong) NSArray<ADHKVItem *> * children;
//sort with pin
@property (nonatomic, strong) NSArray<ADHKVItem *> * sortedChildren;
@property (nonatomic, strong) NSArray<ADHKVItem *> * filteredChildren;

@property (nonatomic, assign) BOOL pin;


- (NSArray<ADHKVItem *> *)viewChildren;

@property (nonatomic, strong) id value;
- (NSString *) stringValue;

- (void)setStringValue: (NSString *)value;

- (ADHKVItem *)topItem;
+ (id)getKVItemValue: (ADHKVItem *)item;


+ (ADHKVItem *)kvItemWithData: (id)kvObj;
+ (ADHKVItem *)kvItemWithData: (id)kvObj sort: (BOOL)sort;
+ (NSString *)readbleNameWithType: (ADHKVItemType)type;

- (void)searchChildWithText: (NSString *)keywords;
- (void)resetSearchResult;

- (void)sortWithPinlist: (NSArray *)pinlist;


@end



















