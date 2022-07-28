//
//  FSItemView.h
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADHBaseCell.h"
#import "ADHFilePreviewItem.h"

@interface FSItemView : ADHBaseCell

- (void)setData: (ADHFilePreviewItem *)previewItem;

@end
