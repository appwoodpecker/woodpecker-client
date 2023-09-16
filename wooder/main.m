//
//  main.m
//  wdpk
//
//  Created by 张小刚 on 2023/9/4.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPCCaller.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *text = [[IPCCaller new] call];
        if (text == nil) {
            text = @"something wrong";
        }
        NSLog(@"%@",text);
    }
    return 0;
}
