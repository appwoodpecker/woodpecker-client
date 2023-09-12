
//
//  AppContext.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/11/18.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "AppContext.h"

@interface AppContext ()

@property (nonatomic, weak) ADHApp *mApp;

@end

@implementation AppContext

+ (AppContext *)context {
    AppContext *context = [[AppContext alloc] init];
    return context;
}

- (ADHApiClient *)apiClient {
    return self.mApp.apiClient;
}

- (ADHProtocol *)protocol {
    return self.mApp.protocol;
}

- (void)setApp:(ADHApp *)app {
    self.mApp = app;
}

- (void)unsetApp {
    [self.mApp.apiClient setProtocol:nil];
    self.mApp = nil;
}

- (ADHApp *)app {
    return self.mApp;
}



@end
