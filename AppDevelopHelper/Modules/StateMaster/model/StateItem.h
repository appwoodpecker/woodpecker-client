//
//  StateItem.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/6/1.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StateItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *workPath;

//是否是共享
@property (nonatomic, assign, getter=isShared) BOOL shared;
//是否为add item
@property (nonatomic, assign, getter=isAdd) BOOL add;
//排序使用各个section排序独立
@property (nonatomic, assign) NSInteger sortIndex;

@end
