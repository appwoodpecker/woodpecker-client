//
//  AttributeTyper.h
//  Niuyouguo
//
//  Created by 张小刚 on 2018/10/22.
//  Copyright © 2018 kuajie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class AttributeTyper;
typedef AttributeTyper *(^AttributeTyperFloatBlock)(float);
typedef AttributeTyper *(^AttributeTyperIntegerBlock)(NSInteger);
typedef AttributeTyper *(^AttributeTyperObjectBlock)(id object);

@interface AttributeTyper : NSObject

@property (nonatomic,strong,readonly) AttributeTyperObjectBlock font;
@property (nonatomic,strong,readonly) AttributeTyperObjectBlock color;
@property (nonatomic,strong,readonly) AttributeTyperIntegerBlock underline;
@property (nonatomic,strong,readonly) AttributeTyperIntegerBlock strikethrough;

- (NSAttributedString *)string;

@end


@interface NSString (AttributeTyper)

- (AttributeTyper *)typer;

@end

@interface NSAttributedString (AttributeTyper)

- (NSAttributedString *)append:(NSAttributedString *)text;

@end

NS_ASSUME_NONNULL_END
