//
//  ADHRemoteServiceCell.h
//  ADHClient
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ADHRemoteServiceCellDegate;
@interface ADHRemoteServiceCell : UITableViewCell

- (void)setData: (id)data;
+ (CGFloat)heightForData: (id)data;
@property (nonatomic, weak) id <ADHRemoteServiceCellDegate> delegate;

@end

@protocol ADHRemoteServiceCellDegate <NSObject>

- (void)adhRemoteServiceCellActionRequest: (ADHRemoteServiceCell *)cell;

@end
