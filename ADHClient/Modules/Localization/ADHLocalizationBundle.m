//
//  ADHLocalizationBundle.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/6/23.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ADHLocalizationBundle.h"

@implementation ADHLocalizationBundle

- (NSDictionary *)dicRepresitation {
    ADHLocalizationBundle *lBundle = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if(lBundle.name) {
        data[@"name"] = lBundle.name;
    }
    data[@"isMainBundle"] = lBundle.isMainBundle?@1:@0;
    if(lBundle.stringFiles) {
        data[@"stringFiles"] = lBundle.stringFiles;
    }
    if(lBundle.languages) {
        data[@"languages"] = lBundle.languages;
    }
    if(lBundle.fileLanguagesMapping) {
        data[@"fileLanguagesMapping"] = lBundle.fileLanguagesMapping;
    }
    if(lBundle.localizationFiles) {
        data[@"localizationFiles"] = lBundle.localizationFiles;
    }
    return data;
}

+ (ADHLocalizationBundle *)bundleWithData: (NSDictionary *)data {
    ADHLocalizationBundle *lBundle = [[ADHLocalizationBundle alloc] init];
    lBundle.name = adhvf_safestringfy(data[@"name"]);
    lBundle.isMainBundle = [data[@"isMainBundle"] boolValue];
    lBundle.stringFiles = data[@"stringFiles"];
    lBundle.languages = data[@"languages"];
    lBundle.fileLanguagesMapping = data[@"fileLanguagesMapping"];
    lBundle.localizationFiles = data[@"localizationFiles"];
    return lBundle;
}

@end
