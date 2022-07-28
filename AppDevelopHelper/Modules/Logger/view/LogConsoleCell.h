//
//  LogConsoleCell.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/5/18.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LogConsoleCell : ADHBaseCell

- (void)setData: (id)data contentWidth: (CGFloat)contentWidth;
+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth;

@end

NS_ASSUME_NONNULL_END
