//
//  AttributeTyper.m
//  Niuyouguo
//
//  Created by 张小刚 on 2018/10/22.
//  Copyright © 2018 kuajie. All rights reserved.
//

#import "AttributeTyper.h"

@interface AttributeTyper ()

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableDictionary *attributes;

@property (nonatomic,strong,readwrite) AttributeTyperObjectBlock font;
@property (nonatomic,strong,readwrite) AttributeTyperObjectBlock color;
@property (nonatomic,strong,readwrite) AttributeTyperIntegerBlock underline;
@property (nonatomic,strong,readwrite) AttributeTyperIntegerBlock strikethrough;


@end

@implementation AttributeTyper

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare {
    self.attributes = [NSMutableDictionary dictionary];
    __weak typeof(self) wself = self;

    //fontSize
    self.font = ^AttributeTyper * (NSFont *font) {
        wself.attributes[NSFontAttributeName] = font;
        return wself;
    };
    //color
    self.color = ^AttributeTyper * (id color) {
        wself.attributes[NSForegroundColorAttributeName] = color;
        return wself;
    };
    //underline
    self.underline = ^AttributeTyper * (NSInteger underline) {
        wself.attributes[NSUnderlineStyleAttributeName] = [NSNumber numberWithInteger:underline];
        return wself;
    };
    self.strikethrough = ^AttributeTyper * (NSInteger value) {
        wself.attributes[NSStrikethroughStyleAttributeName] = [NSNumber numberWithInteger:value];
        return wself;
    };
}

- (NSAttributedString *)string {
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:self.text attributes:self.attributes];
    return attributeText;
}


@end

@implementation NSString (AttributeTyper)

- (AttributeTyper *)typer {
    AttributeTyper *attrTyper = [[AttributeTyper alloc] init];
    attrTyper.text = self;
    return attrTyper;
}

@end


@implementation NSAttributedString (AttributeTyper)

- (NSAttributedString *)append:(NSAttributedString *)text {
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] init];
    [content appendAttributedString:self];
    [content appendAttributedString:text];
    return content;
    
}

@end
