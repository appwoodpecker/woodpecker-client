//
//  MacOrganizer.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "MacOrganizer.h"
#import "MacConnector.h"
#import "AppContextManager.h"

@interface MacOrganizer ()

@property (nonatomic, strong) MacConnector * mConnector;

@end

@implementation MacOrganizer

+ (MacOrganizer *)organizer {
    static MacOrganizer * organizer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        organizer = [[MacOrganizer alloc] init];
    });
    return organizer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)start {
    MacConnector * connector = [[MacConnector alloc] init];
    connector.delegate = [AppContextManager manager];
    [connector startService];
    self.mConnector = connector;
}

- (MacConnector *)connector {
    return self.mConnector;
}

@end















