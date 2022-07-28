//
//  StateCollectionViewItem.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/31.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StateItem.h"

@protocol StateCollectionViewItemDelegate;
@interface StateCollectionViewItem : NSCollectionViewItem

@property (nonatomic, weak) id<StateCollectionViewItemDelegate> delegate;
- (void)setData: (StateItem *)item;

- (void)setSyncState: (BOOL)syncing;
- (void)setProgress: (float)progress;

@end

@protocol StateCollectionViewItemDelegate <NSObject>

- (void)stateCollectionViewItem: (StateCollectionViewItem *)viewItem titleUpdate: (NSString *)title;
- (void)stateCollectionViewItemMore: (StateCollectionViewItem *)viewItem atPosition:(NSPoint)pos;
- (void)stateCollectionViewItemSyncRequest: (StateCollectionViewItem *)viewItem;
- (void)stateCollectionViewItemPauseRequest: (StateCollectionViewItem *)viewItem;


@end
