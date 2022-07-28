//
//  LocalizationSectionView.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/6/24.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "LocalizationSectionView.h"

@interface LocalizationSectionView ()

@property (weak) IBOutlet NSTextField *valueTextfield;


@end

@implementation LocalizationSectionView

- (void)setText: (NSString *)text {
    self.valueTextfield.stringValue = text;
}

@end
