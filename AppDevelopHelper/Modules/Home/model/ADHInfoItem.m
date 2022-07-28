//
//  ADHInfoItem.m
//  Woodpecker
//
//  Created by 张小刚 on 2020/7/4.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHInfoItem.h"

@implementation ADHInfoItem

+ (ADHInfoItem *)item {
    ADHInfoItem *item = [[ADHInfoItem alloc] init];
    item.keyIndex = NSNotFound;
    return item;
}

+ (ADHInfoItem *)kvItemWithData: (NSDictionary *)data {
    ADHInfoItem *rootItem = [ADHInfoItem scanData:data parent:nil];
    return rootItem;
}

+ (ADHInfoItem *)scanData: (NSDictionary *)data parent: (ADHInfoItem *)parent {
    ADHInfoItem *item = [ADHInfoItem item];
    item.keyName = data[@"name"];
    id value = data[@"value"];
    item.value = value;
    if(data[@"tip"]) {
        item.tip = data[@"tip"];
    }
    item.parent = parent;
    if([value isKindOfClass:[NSArray class]]){
        NSArray * array = (NSArray *)value;
        NSMutableArray * children = [NSMutableArray array];
        for (NSInteger i=0; i<array.count; i++) {
            id subData = array[i];
            ADHInfoItem * subItem = [ADHInfoItem scanData:subData parent:item];
            subItem.keyIndex = i;
            [children addObject:subItem];
        }
        item.children = children;
    }
    return item;
}

- (BOOL)isContainer {
    return (self.children != nil);
}

@end
