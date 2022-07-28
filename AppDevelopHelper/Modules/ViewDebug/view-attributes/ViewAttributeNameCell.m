//
//  ViewAttributeNameCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewAttributeNameCell.h"

@interface ViewAttributeNameCell ()

@property (weak) IBOutlet NSTextField *nameTextfield;

@end

@implementation ViewAttributeNameCell

- (void)setData: (NSString *)name contentWidth: (CGFloat)contentWidth {
    if(!name) {
        name = adhvf_const_emptystr();
    }
    self.nameTextfield.stringValue = name;
    CGFloat textWidth = [ViewAttributeNameCell getTextWidth:contentWidth];
    CGSize textSize = [self.nameTextfield sizeThatFits:NSMakeSize(textWidth, CGFLOAT_MAX)];
    textSize.width = ceil(textSize.width);
    textSize.height = ceil(textSize.height);
    self.nameTextfield.size = textSize;
    self.nameTextfield.right = self.width;
    CGFloat height = textSize.height + 4*2;
    if(height < 24.0f) {
        height = 24.0f;
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
    CGFloat textHeight = self.nameTextfield.height;
    if(height - textHeight > 30.0f) {
        //靠顶部
        self.nameTextfield.bottom = self.height - 4.0f;
    }else {
        //居中
        self.nameTextfield.top = (self.height - self.nameTextfield.height)/2.0f;
    }
}

+ (CGFloat)getTextWidth: (CGFloat)contentWidth {
    CGFloat textWidth = contentWidth;
    return textWidth;
}

+ (CGFloat)heightForData: (NSString *)value contentWidth: (CGFloat)contentWidth {
    static ViewAttributeNameCell *templateCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:@"ViewAttributeNameCell" owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[ViewAttributeNameCell class]]){
                templateCell = object;
                break;
            }
        }
    });
    [templateCell setData:value contentWidth:contentWidth];
    CGFloat height = templateCell.height;
    return height;
}

@end
