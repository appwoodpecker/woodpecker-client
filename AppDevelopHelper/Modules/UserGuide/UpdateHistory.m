//
//  UpdateHistory.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/6/3.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "UpdateHistory.h"
#import "Preference.h"
#import "DeviceUtil.h"

@interface UpdateHistory ()

@property (nonatomic, strong) NSArray * historyList;
@property (nonatomic, strong) NSArray * updateList;

@end

@implementation UpdateHistory

+ (UpdateHistory *)shared {
    static UpdateHistory *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[UpdateHistory alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadContent];
    }
    return self;
}

- (void)loadContent {
    //history list
    self.historyList = @[
                        @{
                            @"title" : NSLocalizedString(@"update_v129_1", nil),
                            @"version" : @"1.2.9",
                        },
                        @{
                            @"title" : NSLocalizedString(@"update_v128_1", nil),
                            @"version" : @"1.2.8",
                        },
                        @{
                            @"title" : NSLocalizedString(@"update_v127_1", nil),
                            @"version" : @"1.2.7",
                        },
                        @{
                            @"title" : NSLocalizedString(@"update_v127_2", nil),
                            @"version" : @"1.2.7",
                        },
                        @{
                            @"title" : NSLocalizedString(@"update_v126_1", nil),
                            @"version" : @"1.2.6",
                        },
                        @{
                            @"title" : NSLocalizedString(@"update_v125_1", nil),
                            @"version" : @"1.2.5",
                        },
                        @{
                            @"title" : NSLocalizedString(@"update_v124_1", nil),
                            @"version" : @"1.2.4",
                        },
                         @{
                             @"title" : NSLocalizedString(@"update_v123_1", nil),
                             @"version" : @"1.2.3",
                             },
                         @{
                             @"title" : NSLocalizedString(@"update_v122_1", nil),
                             @"version" : @"1.2.2",
                             },
                         @{
                             @"title" : NSLocalizedString(@"update_tool_bundle", nil),
                             @"link" : [self getUrl:NSLocalizedString(@"web_versionlist",nil)],
                             @"version" : @"1.2.0",
                             },
                         @{
                             @"title" : NSLocalizedString(@"update_tool_view", nil),
                             @"link" : [self getUrl:NSLocalizedString(@"web_versionlist",nil)],
                             @"version" : @"1.2.0",
                             },
                         @{
                             @"title" : NSLocalizedString(@"update_tool_keychain", nil),
                             @"link" : [self getUrl:NSLocalizedString(@"web_tool_keychain",nil)],
                             @"version" : @"1.1.3",
                             },
                         @{
                             @"title" : NSLocalizedString(@"update_tool_file_activity", nil),
                             @"link" : [self getUrl:NSLocalizedString(@"web_tool_sandbox",nil)],
                             @"version" : @"1.1.1",
                             },
                         @{
                             @"title" : NSLocalizedString(@"update_tool_localization", nil),
                             @"link" : [self getUrl:NSLocalizedString(@"web_tool_localization",nil)],
                             @"version" : @"1.1.1",
                             },
                         @{
                             @"title" : NSLocalizedString(@"update_tool_io_console", nil),
                             @"link" : [self getUrl:NSLocalizedString(@"web_tool_io",nil)],
                             @"version" : @"1.1.0",
                             },
                        @{
                            @"title" : NSLocalizedString(@"update_tool_notification", nil),
                            @"link" : [self getUrl:NSLocalizedString(@"web_tool_notification",nil)],
                            @"version" : @"1.0.9",
                            },
                        ];
    //update list
    //previous
    NSString *previousVersionText = [Preference latestVersion];
    NSInteger previousVersion = [self getVersionValue:previousVersionText];
    //current
    NSString *versionText = [DeviceUtil appVersion];
    NSInteger version = [self getVersionValue:versionText];
    if(previousVersion == 0) {
        //如果之前没有记录，则标记为前一个版本
        previousVersion = version-1;
    }
    NSMutableArray * updateList = [NSMutableArray array];
    for (NSDictionary *data in self.historyList) {
        NSString * thisVersionText = data[@"version"];
        NSInteger thisVersion = [self getVersionValue:thisVersionText];
        if(thisVersion > previousVersion) {
            [updateList addObject:data];
        }
    }
    self.updateList = updateList;
}

- (NSInteger)getVersionValue: (NSString *)versionText {
    NSString * version = [versionText stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSInteger versionValue = [version integerValue];
    return versionValue;
}

- (NSString *)getUrl: (NSString *)path {
    return [UrlUtil filteredUrl:path];
}

- (BOOL)shouldShowUpdate {
    return (self.updateList.count > 0);
}

- (NSArray *)updationList {
    return self.updateList;
}

@end





