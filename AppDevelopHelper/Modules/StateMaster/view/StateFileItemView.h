//
//  StateFileItemView.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/29.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol StateFileItemViewDelegate;
@interface StateFileItemView : ADHBaseCell

- (void)setEditState: (BOOL)edit;

@end

@protocol StateFileItemViewDelegate <ADHBaseCellDelegate>

- (void)stateItemView: (StateFileItemView *)itemView contentUpdateRequest: (NSString *)newValue;

@end
