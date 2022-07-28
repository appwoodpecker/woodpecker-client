//
//  UrlUtil.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/4/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "UrlUtil.h"

@implementation UrlUtil

+ (NSString *)filteredUrl: (NSString *)path {
    NSString * result = nil;
    if([path rangeOfString:@"http"].location == NSNotFound) {
        NSString * host = nil;
#if DEBUG
        host = @"http://127.0.0.1:4000";
#else
        host = @"http://www.woodpeck.cn";
#endif
        result = [NSString stringWithFormat:@"%@%@",host,path];
    }else {
        result = path;
    }
    return result;
}

+ (void)openExternalLocalizedUrl: (NSString *)urlKey {
    NSString * path = NSLocalizedString(urlKey, nil);
    [UrlUtil openExternalUrl:path];
}

+ (void)openExternalUrl: (NSString *)url {
    NSString * link = [UrlUtil filteredUrl:url];
    NSURL * requestURL = [NSURL URLWithString:link];
    [[NSWorkspace sharedWorkspace] openURL:requestURL];
}

+ (void)openInFinder: (NSString *)path {
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
}

@end
