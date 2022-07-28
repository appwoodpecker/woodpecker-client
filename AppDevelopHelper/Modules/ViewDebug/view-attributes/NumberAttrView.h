//
//  NumberAttrView.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHView.h"
#import "ViewDebugNode.h"

@protocol NumberAttrViewDelegate;
@interface NumberAttrView : ADHView

+ (NumberAttrView *)make;
@property (nonatomic, weak) id<NumberAttrViewDelegate> delegate;

- (void)setName: (NSString *)name;
- (void)setValue: (float)value;
- (float)value;
- (void)setMin: (float)min max: (float)max;

@end

@protocol NumberAttrViewDelegate <NSObject>

- (void)numberAttrValueUpdate: (NumberAttrView *)numView value: (double)value;

@end
