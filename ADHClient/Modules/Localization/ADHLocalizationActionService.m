//
//  ADHLocalizationActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2018/6/23.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ADHLocalizationActionService.h"
#import "ADHLocalizationBundle.h"

@implementation ADHLocalizationActionService

/**
 service name
 */
+ (NSString *)serviceName {
    return @"adh.localization";
}

/**
 action list
 
 return @{
 @"actionName1" : selector1 string,
 @"actionName2" : selector2 string,
 };
 */
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"info" : NSStringFromSelector(@selector(onRequestLocalizationInfo:)),
             @"getContent" : NSStringFromSelector(@selector(onRequestContent:)),
             };
}

- (void)onRequestLocalizationInfo: (ADHRequest *)request {
    NSMutableArray<ADHLocalizationBundle *> *lBundles = [NSMutableArray array];
    NSMutableArray *bundles = [NSMutableArray array];
    NSBundle *mainBundle = [NSBundle mainBundle];
    [bundles addObject:mainBundle];
    NSString *bundlePath = [mainBundle bundlePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:bundlePath];
    for (NSString *item in enumerator) {
        if([item hasSuffix:@".bundle"]) {
            NSString *itemPath = [bundlePath stringByAppendingPathComponent:item];
            NSBundle *bundle = [NSBundle bundleWithPath:itemPath];
            if(bundle) {
                [bundles addObject:bundle];
            }
        }
    }
    for (NSBundle *bundle in bundles) {
        NSArray<NSString *> * localizations = bundle.localizations;
        if(localizations.count == 0) {
            continue;
        }
        ADHLocalizationBundle * lBundle = [[ADHLocalizationBundle alloc] init];
        NSMutableDictionary *fileLanguagesMapping = [NSMutableDictionary dictionary];
        NSArray *languages = [bundle localizations];
        //所有文件
        NSMutableArray *localizationFiles = [NSMutableArray array];
        //所有string文件
        NSMutableArray *stringFiles = [NSMutableArray array];
        for (NSString *lang in languages) {
            NSString *langPath = [bundle pathForResource:lang ofType:@"lproj"];
            NSArray *items = [fm contentsOfDirectoryAtPath:langPath error:nil];
            for (NSString *itemName in items) {
                if(![self checkArray:localizationFiles containsItem:itemName]) {
                    [localizationFiles addObject:itemName];
                }
                if([itemName hasSuffix:@"strings"]) {
                    if(![self checkArray:stringFiles containsItem:itemName]) {
                        [stringFiles addObject:itemName];
                    }
                    NSMutableArray<NSString *>* fileLanguages = fileLanguagesMapping[itemName];
                    if(!fileLanguages) {
                        fileLanguages = [NSMutableArray array];
                        fileLanguagesMapping[itemName] = fileLanguages;
                    }
                    [fileLanguages addObject:lang];
                }
            }
        }
        if(stringFiles.count == 0) {
            //如果不包含string文件
            continue;
        }
        lBundle.bundle = bundle;
        lBundle.name = [bundle.bundlePath lastPathComponent];
        lBundle.isMainBundle = (bundle == [NSBundle mainBundle]);
        //去除Base
        NSMutableArray *validLanguages = [NSMutableArray array];
        for (NSString *lang in languages) {
            if(![lang isEqualToString:@"Base"]) {
                [validLanguages addObject:lang];
            }
        }
        [validLanguages sortUsingSelector:@selector(compare:)];
        lBundle.languages = validLanguages;
        //sort
        [stringFiles sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
        }];
        lBundle.stringFiles = stringFiles;
        lBundle.localizationFiles = localizationFiles;
        lBundle.fileLanguagesMapping = fileLanguagesMapping;
        
        [lBundles addObject:lBundle];
    }
    //sort bundle
    [lBundles sortUsingComparator:^NSComparisonResult(ADHLocalizationBundle *bundle1, ADHLocalizationBundle *bundle2) {
        NSComparisonResult result = [bundle1.name compare:bundle2.name options:NSCaseInsensitiveSearch];
        if(bundle1.isMainBundle) {
            result = NSOrderedAscending;
        }else if(bundle2.isMainBundle) {
            result = NSOrderedDescending;
        }
        return result;
    }];
    
    NSMutableArray *list = [NSMutableArray array];
    for (ADHLocalizationBundle *lBundle in lBundles) {
        NSDictionary *data = [lBundle dicRepresitation];
        [list addObject:data];
    }
    NSDictionary *data = @{
                           @"bundleList" : list,
                           };
    [request finishWithBody:data];
}

- (void)onRequestContent: (ADHRequest *)request {
    NSDictionary *data = request.body;
    NSString *bundleName = data[@"bundleName"];
    NSArray *fileNames = [data[@"fileNames"] adh_jsonObject];
    NSArray *languages = [data[@"languages"] adh_jsonObject];
    NSArray *list = [self getContentsInBundle:bundleName fileNames:fileNames languages:languages];
    NSDictionary *resultData = @{
                           @"contents" : list,
                           };
    [request finishWithBody:resultData];
}

- (BOOL)checkArray: (NSArray<NSString *> *)array containsItem: (NSString *)targetItem {
    BOOL ret = NO;
    for (NSString *item in array) {
        if([item isEqualToString:targetItem]) {
            ret = YES;
            break;
        }
    }
    return ret;
}

- (NSDictionary *)getContentsInBundle: (NSString *)bundleName fileName: (NSString *)fileName language: (NSString *)language {
    NSString *filePath = nil;
    NSBundle *targetBundle = nil;
    NSArray<NSBundle*> * bundles = [NSBundle allBundles];
    for (NSBundle *bundle in bundles) {
        NSString *name = [bundle.bundlePath lastPathComponent];
        if([name isEqualToString:bundleName]) {
            targetBundle = bundle;
            break;
        }
    }
    if(targetBundle) {
        NSString *langPath = [targetBundle pathForResource:language ofType:@"lproj"];
        filePath = [langPath stringByAppendingPathComponent:fileName];
    }
    NSDictionary *data = nil;
    if(filePath.length > 0) {
        data = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    return data;
}

- (NSArray *)getContentsInBundle: (NSString *)bundleName fileNames: (NSArray<NSString *> *)fileNames languages: (NSArray<NSString *> *)languages {
    NSMutableArray *list = [NSMutableArray array];
    for (NSString *fileName in fileNames) {
        NSMutableDictionary *fileNameData = [NSMutableDictionary dictionary];
        fileNameData[@"fileName"] = fileName;
        NSMutableDictionary *languageData = [NSMutableDictionary dictionary];
        for (NSString *lang in languages) {
            NSDictionary *contents = [self getContentsInBundle:bundleName fileName:fileName language:lang];
            if(contents) {
                languageData[lang] = contents;
            }
        }
        fileNameData[@"languages"] = languageData;
        [list addObject:fileNameData];
    }
    return list;
}

@end
