//
//  UpdateInfoCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/4/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "UpdateInfoCell.h"

@interface UpdateInfoCell ()

@property (weak) IBOutlet NSTextField *titleLabel;


@end

@implementation UpdateInfoCell

- (void)setData: (id)data contentWidth: (CGFloat)contentWidth {
    NSString * text = data[@"title"];
    self.titleLabel.stringValue = text;
    CGFloat textWidth = [self getTextWidth:contentWidth];
    CGSize textSize = [self.titleLabel sizeThatFits:NSMakeSize(textWidth, CGFLOAT_MAX)];
    textSize.width = ceil(textSize.width);
    textSize.height = ceil(textSize.height);
    self.titleLabel.size = textSize;
    CGFloat height = textSize.height + 12.0f*2;
    if(height < 46.0f) {
        height = 46.0f;
    }
    self.height = height;
    [self layoutContent];
}

- (void)layout {
    [super layout];
    [self layoutContent];
}

- (void)layoutContent {
    CGFloat height = self.height;
    CGFloat textHeight = self.titleLabel.height;
    self.titleLabel.top = (height - textHeight)/2.0f;
}

- (CGFloat)getTextWidth: (CGFloat)contentWidth {
    return contentWidth - 40.0f*2;
}

+ (CGFloat)heightForData: (NSDictionary *)data contentWidth: (CGFloat)contentWidth {
    static dispatch_once_t onceToken;
    static UpdateInfoCell * templateCell = nil;
    dispatch_once(&onceToken, ^{
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:@"UpdateInfoCell" owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[UpdateInfoCell class]]){
                templateCell = object;
                break;
            }
        }
    });
    [templateCell setData:data contentWidth:contentWidth];
    CGFloat height = templateCell.frame.size.height;
    return height;
}

@end
