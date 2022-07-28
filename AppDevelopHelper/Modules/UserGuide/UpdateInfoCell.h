//
//  UpdateInfoCell.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/4/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface UpdateInfoCell : ADHBaseCell

- (void)setData: (id)data contentWidth: (CGFloat)contentWidth;
+ (CGFloat)heightForData: (NSDictionary *)data contentWidth: (CGFloat)contentWidth;

@end

NS_ASSUME_NONNULL_END
