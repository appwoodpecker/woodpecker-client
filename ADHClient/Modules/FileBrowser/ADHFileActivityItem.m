//
//  ADHFileActivityItem.m
//  ADHClient
//
//  Created by 张小刚 on 2018/7/14.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ADHFileActivityItem.h"

@implementation ADHFileActivityItem

- (NSDictionary *)dicPresentation {
    ADHFileActivityItem *item = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"path"] = adhvf_safestringfy(item.path);
    data[@"type"] = [NSNumber numberWithInteger:item.type];
    data[@"isDir"] = [NSNumber numberWithBool:item.isDir];
    data[@"date"] = [NSNumber numberWithDouble:[item.date timeIntervalSince1970]];
    return data;
}

+ (ADHFileActivityItem *)itemWithData: (NSDictionary *)data {
    ADHFileActivityItem *item = [[ADHFileActivityItem alloc] init];
    item.path = adhvf_safestringfy(data[@"path"]);
    item.type = [data[@"type"] integerValue];
    item.isDir = [data[@"isDir"] boolValue];
    item.date = [NSDate dateWithTimeIntervalSince1970:[data[@"date"] doubleValue]];
    return item;
}

- (NSString *)readbleActivity {
    NSMutableString * content = [NSMutableString string];
    ADHFileActivityType type = self.type;
    NSString *typeText = nil;
    switch (type) {
        case ADHFileActivityAdd:
            typeText = @"Add";
            break;
        case ADHFileActivityEdit:
            typeText = @"Edit";
            break;
        case ADHFileActivityRemove:
            typeText = @"Remove";
            break;
        default:
            break;
    }
    NSString *fileTypeText = self.isDir ? @"Folder" : @"";
    [content appendFormat:@"%@ %@",typeText,fileTypeText];
    return content;
}

@end
