//
//  ADHLocalizationBundle.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/6/23.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHLocalizationBundle : NSObject

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL isMainBundle;
@property (nonatomic, strong) NSArray<NSString*> *stringFiles;
@property (nonatomic, strong) NSArray<NSString*> *languages;
@property (nonatomic, strong) NSDictionary<NSString *,NSArray<NSString *>*> *fileLanguagesMapping;
@property (nonatomic, strong) NSArray<NSString *> *localizationFiles;

- (NSDictionary *)dicRepresitation;
+ (ADHLocalizationBundle *)bundleWithData: (NSDictionary *)data;

@end
