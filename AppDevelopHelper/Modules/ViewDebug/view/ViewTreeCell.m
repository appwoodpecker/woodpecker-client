//
//  ViewTreeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewTreeCell.h"
#import "ADHViewNode.h"

@interface ViewTreeCell ()

@property (weak) IBOutlet NSImageView *iconImageView;

@property (weak) IBOutlet NSTextField *titleLabel;

@end

@implementation ViewTreeCell

- (void)setData:(ADHViewNode *)viewNode {
    NSString *iconName = @"vd_view";
    if(viewNode.attributes.count > 0) {
        ADHAttribute *firstAttr = viewNode.attributes[0];
        iconName = [firstAttr classTypeIcon];
    }
    self.iconImageView.image = [NSImage imageNamed:iconName];
    self.titleLabel.stringValue = [NSString stringWithFormat:@"%@",viewNode.className];
}

@end
