//
//  ViewGestureCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewGestureCell.h"

@interface ViewGestureCell ()

@property (weak) IBOutlet NSTextField *nameTextfield;

@end

@implementation ViewGestureCell

- (void)setData:(NSDictionary *)data contentWidth:(CGFloat)contentWidth {
    NSString *shortName = data[@"shortname"];
    NSString *addr = data[@"instaddr"];
    if(shortName) {
        self.nameTextfield.stringValue = [NSString stringWithFormat:@"%@ %@",shortName,addr];
    }else {
        self.nameTextfield.stringValue = addr;
    }
}

- (IBAction)actionButtonPressed:(id)sender {
    [self.delegate actionRequest:self];
}

+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 32.0f;
}

@end
