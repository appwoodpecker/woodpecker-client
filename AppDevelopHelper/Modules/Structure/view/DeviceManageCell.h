//
//  DeviceManageCell.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/23.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DeviceManageCellDelegate;
@interface DeviceManageCell : ADHBaseCell

@property (nonatomic, weak) id<DeviceManageCellDelegate> delegate;

@end

@protocol DeviceManageCellDelegate <ADHBaseCellDelegate>

- (void)deviceManageCellDeleteRequest: (DeviceManageCell *)cell;

@end
