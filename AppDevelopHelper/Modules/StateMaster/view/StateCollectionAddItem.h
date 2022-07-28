//
//  StateCollectionAddItem.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/6/1.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol StateCollectionAddItemDelegate;

@interface StateCollectionAddItem : NSCollectionViewItem

- (void)setData: (NSDictionary *)data;
@property (nonatomic, weak) id<StateCollectionAddItemDelegate> delegate;

@end

@protocol StateCollectionAddItemDelegate <NSObject>

- (void)stateCollectionAddRequest: (StateCollectionAddItem *)item;

@end
