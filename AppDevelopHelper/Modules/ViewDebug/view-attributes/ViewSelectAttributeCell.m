//
//  ViewSelectAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/7.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewSelectAttributeCell.h"

@interface ViewSelectAttributeCell ()

@property (weak) IBOutlet NSPopUpButton *popupButton;
@property (nonatomic, strong) NSArray<ADHPopupItem *> *itemList;

@end

@implementation ViewSelectAttributeCell

- (void)setData:(id)data contentWidth:(CGFloat)contentWidth {
    [self.popupButton removeAllItems];
    NSArray<ADHPopupItem *> *list = data[@"list"];
    self.itemList = list;
    ADH_INT value = [ADHViewDebugUtil adhIntWithValue:data[@"value"]];
    NSInteger targetIndex = NSNotFound;
    for (NSInteger i=0; i<self.itemList.count; i++) {
        ADHPopupItem *item = self.itemList[i];
        [self.popupButton addItemWithTitle:item.title];
        if(value == item.value) {
            targetIndex = i;
        }
    }
    if(targetIndex != NSNotFound) {
        [self.popupButton selectItemAtIndex:targetIndex];
    }
}

+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 32.0f;
}

- (IBAction)popupButtonValueChanged:(id)sender {
    NSInteger index = [self.popupButton indexOfSelectedItem];
    if(index != NSNotFound && index < self.itemList.count) {
        ADHPopupItem *item = self.itemList[index];
        NSNumber *value = [ADHViewDebugUtil numberWithAdhInt:item.value];
        [self.delegate valueUpdateRequest:self value:value info:nil];
    }
}

@end
