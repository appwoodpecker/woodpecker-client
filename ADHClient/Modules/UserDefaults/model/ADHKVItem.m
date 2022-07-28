//
//  ADHKVItem.m
//  ADHClient
//
//  Created by 张小刚 on 2018/3/8.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHKVItem.h"

@implementation ADHKVItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.keyIndex = NSNotFound;
    }
    return self;
}

- (BOOL)isContainer
{
    return ([self isArray] || [self isDictioanry]);
}

- (BOOL)isArray
{
    return (self.type == ADHKVItemTypeArray);
}

- (BOOL)isDictioanry
{
    return (self.type == ADHKVItemTypeDictionary);
}

- (BOOL)isEditable
{
    return (self.type == ADHKVItemTypeString || self.type == ADHKVItemTypeNumber);
}

- (NSString *) stringValue
{
    NSString * strResult = nil;
    id value = self.value;
    ADHKVItemType type = self.type;
    if(type == ADHKVItemTypeString){
        strResult = value;
    }else if(type == ADHKVItemTypeData){
        NSData *data = value;
        strResult = [data description];
    }else if(type == ADHKVItemTypeNumber){
        strResult = [NSString stringWithFormat:@"%@",value];
    }else if(type == ADHKVItemTypeDate){
        strResult = [ADHDateUtil formatStringWithDate:value dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }else if(type == ADHKVItemTypeNull) {
        strResult = @"null";
    }
    return strResult;
}

//更新值
- (void)setStringValue: (NSString *)value {
    if(self.type == ADHKVItemTypeString){
        self.value = value;
    }else if(self.type == ADHKVItemTypeNumber){
        BOOL isDouble = NO;
        NSString * oldStrValue = [self.value stringValue];
        if([oldStrValue containsString:@"."]){
            isDouble = YES;
        }
        if(isDouble){
            double newValue = [value doubleValue];
            self.value = [NSNumber numberWithDouble:newValue];
        }else{
            NSInteger newValue = [value integerValue];
            self.value = [NSNumber numberWithInteger:newValue];
        }
    }
}

- (ADHKVItem *)topItem
{
    ADHKVItem * topItem = self;
    while (topItem.parent.parent) {
        topItem = topItem.parent;
    }
    return topItem;
}

+ (id)getKVItemValue: (ADHKVItem *)item
{
    id value = nil;
    if([item isArray]){
        NSMutableArray * subValues = [NSMutableArray array];
        NSArray * subItems = item.children;
        for (ADHKVItem * subItem in subItems) {
            id itemValue = [ADHKVItem getKVItemValue:subItem];
            [subValues addObject:itemValue];
        }
        value = subValues;
    }else if([item isDictioanry]){
        NSArray * subItems = item.children;
        NSMutableDictionary * subKeyValues = [NSMutableDictionary dictionary];
        for (ADHKVItem * subItem in subItems) {
            NSString * key = subItem.keyName;
            id value = [ADHKVItem getKVItemValue:subItem];
            subKeyValues[key] = value;
        }
        value = subKeyValues;
    }else{
        value = item.value;
    }
    return value;
}



+ (ADHKVItem *)item
{
    return [[ADHKVItem alloc] init];
}

+ (NSString *)readbleNameWithType: (ADHKVItemType)type
{
    NSString * name = nil;
    if(type == ADHKVItemTypeString){
        name = @"String";
    }else if(type == ADHKVItemTypeData){
        name = @"Data";
    }else if(type == ADHKVItemTypeNumber){
        name = @"Number";
    }else if(type == ADHKVItemTypeDate){
        name = @"Date";
    }else if(type == ADHKVItemTypeArray){
        name = @"Array";
    }else if(type == ADHKVItemTypeDictionary){
        name = @"Dictionary";
    }else if(type == ADHKVItemTypeNull) {
        name = @"Null";
    }
    return name;
}

+ (ADHKVItem *)kvItemWithData: (id)kvObj sort: (BOOL)sort {
    ADHKVItem * item = [ADHKVItem scanKVObj:kvObj parent:nil sort:sort];
    if([item isArray]) {
        item.keyName = @"array";
    }else if([item isDictioanry]) {
        item.keyName = @"object";
    }
    return item;
}

//dictionary -> kvItem
+ (ADHKVItem *)kvItemWithData: (id)data {
    return [ADHKVItem kvItemWithData:data sort:NO];
}

+ (ADHKVItem *)scanKVObj: (id)kvObj parent: (ADHKVItem *)parent sort: (BOOL)sort
{
    if(!kvObj){
        return parent;
    }
    ADHKVItem * thisItem = [ADHKVItem itemWithKVObj:kvObj];
    if([thisItem isContainer]){
        if([thisItem isArray]){
            NSArray * array = (NSArray *)kvObj;
            NSMutableArray * subItems = [NSMutableArray array];
            for (NSInteger i=0; i<array.count; i++) {
                id subKVObj = array[i];
                ADHKVItem * subItem = [ADHKVItem scanKVObj:subKVObj parent:thisItem sort:sort];
                subItem.keyIndex = i;
                [subItems addObject:subItem];
            }
            thisItem.children = subItems;
        }else if([thisItem isDictioanry]){
            NSDictionary * dictionary = (NSDictionary *)kvObj;
            NSArray * keys = [dictionary allKeys];
            if(sort) {
                keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull str1, NSString * _Nonnull str2) {
                    return [str1 compare:str2 options:NSCaseInsensitiveSearch];
                }];
            }
            NSMutableArray * subItems = [NSMutableArray array];
            for (NSString * key in keys) {
                id subKVObj = dictionary[key];
                ADHKVItem * subItem = [ADHKVItem scanKVObj:subKVObj parent:thisItem sort:sort];
                subItem.keyName = key;
                [subItems addObject:subItem];
            }
            thisItem.children = subItems;
        }
    }else{
        
    }
    thisItem.parent = parent;
    return thisItem;
}

+ (ADHKVItem *)itemWithKVObj: (id)kvObj
{
    ADHKVItem * item = [ADHKVItem item];
    ADHKVItemType type = ADHKVItemTypeUnknown;
    id value = nil;
    if([kvObj isKindOfClass:[NSString class]]){
        type = ADHKVItemTypeString;
        value = kvObj;
    }else if([kvObj isKindOfClass:[NSData class]]){
        type = ADHKVItemTypeData;
        value = kvObj;
    }else if([kvObj isKindOfClass:[NSNumber class]]){
        type = ADHKVItemTypeNumber;
        value = kvObj;
    }else if([kvObj isKindOfClass:[NSDate class]]){
        type = ADHKVItemTypeDate;
        value = kvObj;
    }else if([kvObj isKindOfClass:[NSDictionary class]]){
        type = ADHKVItemTypeDictionary;
    }else if([kvObj isKindOfClass:[NSArray class]]){
        type = ADHKVItemTypeArray;
    }else if([kvObj isKindOfClass:[NSNull class]]) {
        type = ADHKVItemTypeNull;
    }
    item.type = type;
    item.value = value;
    return item;
}

- (NSString *)searchedStringValue
{
    NSString * strResult = nil;
    id value = self.value;
    ADHKVItemType type = self.type;
    if(type == ADHKVItemTypeString){
        strResult = value;
    }else if(type == ADHKVItemTypeNumber){
        strResult = [NSString stringWithFormat:@"%@",value];
    }else if(type == ADHKVItemTypeDate){
        strResult = [ADHDateUtil formatStringWithDate:value dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return adhvf_safestringfy(strResult);
}

//只搜索第一级别（用户value具体内容，我们可能不需要干涉太多）
- (void)searchChildWithText: (NSString *)keywords {
    [self resetSearchResult];
    NSMutableArray<ADHKVItem *> *filteredItems = [NSMutableArray array];
    NSArray<ADHKVItem *> *list = nil;
    if(self.sortedChildren) {
        list = self.sortedChildren;
    }else {
        list = self.children;
    }
    for (ADHKVItem *item in list) {
        BOOL matched = NO;
        NSString *key = item.keyName;
        if([key rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound) {
            matched = YES;
        }
        if(!matched) {
            NSString *value = [item searchedStringValue];
            if([value rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound) {
                matched = YES;
            }
        }
        if(matched) {
            [filteredItems addObject:item];
        }
    }
    self.filteredChildren = filteredItems;
}

- (void)resetSearchResult {
    self.filteredChildren = nil;
}

- (NSArray<ADHKVItem *> *)viewChildren {
    NSArray<ADHKVItem *> *list = nil;
    if(self.filteredChildren) {
        list = self.filteredChildren;
    }else if(self.sortedChildren) {
        list = self.sortedChildren;
    }else {
        list = self.children;
    }
    return list;
}

- (void)sortWithPinlist:(NSArray *)pinList {
    NSArray<ADHKVItem *> *children = self.children;
    NSMutableArray<ADHKVItem *> *sortedChildren = [NSMutableArray array];
    NSMutableArray *pinItemlist = [NSMutableArray array];
    for (ADHKVItem *item in children) {
        BOOL isPin = NO;
        for (NSString *key in pinList) {
            if([key isEqualToString:item.keyName]) {
                isPin = YES;
                break;
            }
        }
        if(isPin) {
            item.pin = YES;
            [pinItemlist addObject:item];
        }else {
            item.pin = NO;
            [sortedChildren addObject:item];
        }
    }
    
    for (NSInteger i=0;i<pinList.count;i++) {
        NSInteger index = pinList.count-i-1;
        NSString *key = pinList[index];
        ADHKVItem *targetItem = nil;
        for (NSInteger j = 0;j<pinItemlist.count;j++) {
            ADHKVItem *pinItem = pinItemlist[j];
            if([pinItem.keyName isEqualToString:key]) {
                targetItem = pinItem;
                break;
            }
        }
        if(targetItem) {
            [sortedChildren insertObject:targetItem atIndex:0];
        }
    }
    self.sortedChildren = sortedChildren;
}

@end
