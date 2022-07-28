//
//  DBTableCell.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DBTableCell.h"
#import "DBTable.h"

@interface DBTableCell()

@property (weak) IBOutlet NSTextField *titleLabel;


@end

@implementation DBTableCell


- (void)setData: (DBTable *)table
{
    self.titleLabel.stringValue = table.name;
}

+ (CGFloat)rowHeight
{
    return 35.0f;
}

@end















