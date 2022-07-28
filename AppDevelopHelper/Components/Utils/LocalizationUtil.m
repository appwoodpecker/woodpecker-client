//
//  LocalizationUtil.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/8/4.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "LocalizationUtil.h"

@implementation LocalizationUtil

+ (BOOL)isChinese {
    BOOL ret = NO;
    NSString *lang = [LocalizationUtil appLanguage];
    if([lang isEqualToString:@"zh-Hans"]) {
        ret = YES;
    }
    return ret;
}

+ (NSString *)appLanguage {
    NSString *lang = nil;
    NSArray *langs = [[NSBundle mainBundle] preferredLocalizations];
    if(langs.count > 0) {
        lang = langs[0];
    }
    return lang;
}

@end

NSString* kLocalized(NSString* key) {
    return NSLocalizedString(key, nil);
}

NSString* kAppLocalized(NSString* key) {
    return NSLocalizedStringFromTable(key, @"App", nil);
}
