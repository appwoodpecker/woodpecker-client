//
//  ADHGestureRecognizer.h
//  ADHClient
//
//  Created by 张小刚 on 2017/11/16.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 触发UI手势，两指长按
 
 注意：之前使用双指点击两次，webview不支持，所以更换为两指长按
 */
@interface ADHGestureRecognizer : UILongPressGestureRecognizer

@end
