//
//  StackTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2019/3/9.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "StackTestViewController.h"

@interface StackTestViewController ()

@end

@implementation StackTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *values = @{
                      @"UIStackViewAlignmentFill" : [NSNumber numberWithInteger:UIStackViewAlignmentFill],
                      @"UIStackViewAlignmentLeading" : [NSNumber numberWithInteger:UIStackViewAlignmentLeading],
                      @"UIStackViewAlignmentTop" : [NSNumber numberWithInteger:UIStackViewAlignmentTop],
                      @"UIStackViewAlignmentFirstBaseline" : [NSNumber numberWithInteger:UIStackViewAlignmentFirstBaseline],
                      @"UIStackViewAlignmentCenter" : [NSNumber numberWithInteger:UIStackViewAlignmentCenter],
                      @"UIStackViewAlignmentTrailing" : [NSNumber numberWithInteger:UIStackViewAlignmentTrailing],
                      @"UIStackViewAlignmentBottom" : [NSNumber numberWithInteger:UIStackViewAlignmentBottom],
                      @"UIStackViewAlignmentLastBaseline" : [NSNumber numberWithInteger:UIStackViewAlignmentLastBaseline],
                      };
//    NSLog(@"%@",values);
    /*
     UIStackViewAlignmentFill = 0;
     UIStackViewAlignmentLeading = 1;
     UIStackViewAlignmentTop = 1;
     UIStackViewAlignmentFirstBaseline = 2;
     UIStackViewAlignmentCenter = 3;
     UIStackViewAlignmentTrailing = 4;
     UIStackViewAlignmentBottom = 4;
     UIStackViewAlignmentLastBaseline = 5;
     */
    
                      
};

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
