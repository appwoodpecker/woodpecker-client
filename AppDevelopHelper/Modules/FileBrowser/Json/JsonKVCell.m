//
//  JsonKVCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/5/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "JsonKVCell.h"

@interface JsonKVCell ()

@property (weak) IBOutlet NSTextField *keyTextfield;
@property (weak) IBOutlet NSTextField *seperatorTextfield;
@property (weak) IBOutlet NSTextField *valueTextfield;

@end

@implementation JsonKVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //最多显示5行，需要配合wrap才能实现换行
    self.valueTextfield.maximumNumberOfLines = 5;
}

- (void)setData: (ADHKVItem *)kvItem contentWidth: (CGFloat)contentWidth {
    CGFloat left = 4.0f;
    //key
    NSString * key = kvItem.keyName;
    if(key.length == 0 && kvItem.keyIndex != NSNotFound){
        key = [NSString stringWithFormat:@"%zd",kvItem.keyIndex];
    }
    self.keyTextfield.stringValue = adhvf_safestringfy(key);
    NSSize textSize = [self.keyTextfield sizeThatFits:NSMakeSize(CGFLOAT_MAX, 20.0f)];
    self.keyTextfield.width = textSize.width + 2.0f;
    left += self.keyTextfield.width;
    self.keyTextfield.textColor = [self itemKeyColor:kvItem];
    //seperator
    CGFloat seperatorWidth = 4;
    if(![kvItem isContainer]) {
        self.seperatorTextfield.hidden = NO;
        seperatorWidth = self.seperatorTextfield.width;
        self.seperatorTextfield.left = left;
    }else {
        self.seperatorTextfield.hidden = YES;
    }
    left += seperatorWidth;
    //value
    NSString * value = nil;
    if(![kvItem isContainer]){
        value = [kvItem stringValue];
    }else{
        if(kvItem.type == ADHKVItemTypeArray) {
            value = [NSString stringWithFormat:@"[%zd]",kvItem.children.count];
        }else if(kvItem.type == ADHKVItemTypeDictionary){
            value = [NSString stringWithFormat:@"{%zd}",kvItem.children.count];
        }
    }
    self.valueTextfield.stringValue = adhvf_safestringfy(value);
    CGFloat valueWidth = contentWidth - left-2.0f;
    if(valueWidth < 10.0f) {
        valueWidth = 10.0f;
    }
    
    textSize = [self.valueTextfield sizeThatFits:NSMakeSize(valueWidth, CGFLOAT_MAX)];
    if(textSize.height < 18.0f) {
        textSize.height = 18.0f;
    }
    textSize = NSMakeSize(ceilf(textSize.width), ceil(textSize.height));
    CGFloat cellHeight = textSize.height + 3.0f*2;
    self.valueTextfield.size = textSize;
    self.valueTextfield.textColor = [self itemValueColor:kvItem];
    self.valueTextfield.top = 3.0f;
    self.valueTextfield.left = left;
    self.height = cellHeight;
}

- (NSColor *)itemKeyColor: (ADHKVItem *)item {
    ADHKVItemType type = item.type;
    NSColor * textColor = [NSColor labelColor];
    if(type == ADHKVItemTypeArray || type == ADHKVItemTypeDictionary) {
        if(item.children.count > 0) {
            textColor = [NSColor secondaryLabelColor];
        }
    }
    return textColor;
}

- (NSColor *)itemValueColor: (ADHKVItem *)item {
    ADHKVItemType type = item.type;
    NSColor * textColor = [NSColor labelColor];
    BOOL dark = [Appearance isDark];
    if(type == ADHKVItemTypeNumber) {
        textColor = [Appearance colorWithHex:0xEC3929];
    }else if(type == ADHKVItemTypeNull) {
        if(dark) {
            textColor = [Appearance colorWithHex:0x0045FF];
        }else {
            textColor = [Appearance colorWithHex:0x0045CC];
        }
    }else if(type == ADHKVItemTypeArray || type == ADHKVItemTypeDictionary) {
        textColor = [NSColor secondaryLabelColor];
    }else if(type == ADHKVItemTypeString) {
        if(dark) {
            textColor = [Appearance themeColor];
        }else {
            textColor = [Appearance colorWithHex:0x31744A];
        }
    }
    return textColor;
}

+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth {
    static dispatch_once_t onceToken;
    static JsonKVCell * templateCell = nil;
    dispatch_once(&onceToken, ^{
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JsonKVCell class]) owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[JsonKVCell class]]){
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





