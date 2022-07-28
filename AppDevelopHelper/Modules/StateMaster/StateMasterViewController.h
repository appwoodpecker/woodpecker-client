//
//  StateMasterViewController.h
//  Woodpecker
//
//  Created by 张小刚 on 2020/5/24.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StateItem.h"

@interface StateMasterViewController : NSViewController

@property (nonatomic, strong) StateItem *stateItem;
@property (nonatomic, assign) NSInteger tabIndex;

@end
