//
//  ViewAttriWebNaviCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/15.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewAttriWebNaviCell.h"

@interface ViewAttriWebNaviCell ()

@end

@implementation ViewAttriWebNaviCell

/*
 canGoBack
 canGoForward
 loading
 */
- (void)setData:(NSDictionary *)data contentWidth:(CGFloat)contentWidth {
    //不准确，暂时不使用
    /*
    BOOL canGoBack = [data[@"canGoBack"] boolValue];
    BOOL canGoForward = [data[@"canGoForward"] boolValue];
    BOOL loading = [data[@"loading"] boolValue];
    self.backButton.enabled = canGoBack;
    self.forwardButton.enabled = canGoForward;
    self.stopButton.enabled = loading;
     */
}

- (IBAction)debugButtonPressed:(id)sender {
    [self.delegate actionRequest:self];
}

+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 32.0f;
}



@end
