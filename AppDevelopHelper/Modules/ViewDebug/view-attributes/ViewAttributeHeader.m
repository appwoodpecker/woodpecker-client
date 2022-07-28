//
//  ViewAttributeHeader.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/21.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewAttributeHeader.h"

@interface ViewAttributeHeader ()

@property (weak) IBOutlet NSTextField *titleTextfield;

@end

@implementation ViewAttributeHeader

- (void)setData: (ADHAttribute *)attribute contentWidth:(CGFloat)contentWidth {
    self.titleTextfield.stringValue = attribute.className;
}

+ (CGFloat)heightForData:(ADHAttribute *)attribute contentWidth:(CGFloat)contentWidth {
    return 25.0f;
}

@end
