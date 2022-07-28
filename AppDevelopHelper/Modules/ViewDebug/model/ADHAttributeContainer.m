//
//  ADHAttribute+Container.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/9.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHAttributeContainer.h"
#import "ADHViewDebugUtil.h"

@implementation ADHScrollViewAttribute

- (NSDictionary *)getPropertyData {
    ADHScrollViewAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"delegate"] = adhvf_safestringfy(attr.delegate);
    data[@"contentOffset"] = adhvf_safestringfy([ADHViewDebugUtil stringWithCGPoint: attr.contentOffset]);
    data[@"contentSize"] = adhvf_safestringfy([ADHViewDebugUtil stringWithCGSize:attr.contentSize]);
    data[@"contentInset"] = [ADHViewDebugUtil stringWithAdhInsets:attr.contentInset];
    data[@"adjustedContentInset"] = [ADHViewDebugUtil stringWithAdhInsets:attr.adjustedContentInset];
    data[@"contentInsetAdjustmentBehavior"] = [ADHViewDebugUtil numberWithAdhInt:attr.contentInsetAdjustmentBehavior];
    data[@"directionalLockEnabled"] = [NSNumber numberWithBool:attr.directionalLockEnabled];
    data[@"bounces"] = [NSNumber numberWithBool:attr.bounces];
    data[@"alwaysBounceVertical"] = [NSNumber numberWithBool:attr.alwaysBounceVertical];
    data[@"alwaysBounceHorizontal"] = [NSNumber numberWithBool:attr.alwaysBounceHorizontal];
    data[@"pagingEnabled"] = [NSNumber numberWithBool:attr.pagingEnabled];
    data[@"scrollEnabled"] = [NSNumber numberWithBool:attr.scrollEnabled];
    data[@"showsHorizontalScrollIndicator"] = [NSNumber numberWithBool:attr.showsHorizontalScrollIndicator];
    data[@"showsVerticalScrollIndicator"] = [NSNumber numberWithBool:attr.showsVerticalScrollIndicator];
    data[@"scrollIndicatorInsets"] = [ADHViewDebugUtil stringWithAdhInsets:attr.scrollIndicatorInsets];
    data[@"indicatorStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.indicatorStyle];
    data[@"decelerationRate"] = [ADHViewDebugUtil numberWithAdhInt:attr.decelerationRate];
    data[@"minimumZoomScale"] = [NSNumber numberWithBool:attr.minimumZoomScale];
    data[@"maximumZoomScale"] = [NSNumber numberWithBool:attr.maximumZoomScale];
    data[@"zoomScale"] = [NSNumber numberWithBool:attr.zoomScale];
    data[@"scrollsToTop"] = [NSNumber numberWithBool:attr.scrollsToTop];
    data[@"keyboardDismissMode"] = [ADHViewDebugUtil numberWithAdhInt:attr.keyboardDismissMode];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHScrollViewAttribute *attr = self;
    attr.delegate = data[@"delegate"];
    attr.contentOffset = [ADHViewDebugUtil pointWithString:data[@"contentOffset"]];
    attr.contentSize = [ADHViewDebugUtil sizeWithString:data[@"contentSize"]];
    attr.contentInset = [ADHViewDebugUtil insetsWithString:data[@"contentInset"]];
    attr.adjustedContentInset = [ADHViewDebugUtil insetsWithString:data[@"adjustedContentInset"]];
    attr.contentInsetAdjustmentBehavior = [ADHViewDebugUtil adhIntWithValue:data[@"contentInsetAdjustmentBehavior"]];
    attr.directionalLockEnabled = [data[@"directionalLockEnabled"] boolValue];
    attr.bounces = [data[@"bounces"] boolValue];
    attr.alwaysBounceVertical = [data[@"alwaysBounceVertical"] boolValue];
    attr.alwaysBounceHorizontal = [data[@"alwaysBounceHorizontal"] boolValue];
    attr.pagingEnabled = [data[@"pagingEnabled"] boolValue];
    attr.scrollEnabled = [data[@"scrollEnabled"] boolValue];
    attr.showsHorizontalScrollIndicator = [data[@"showsHorizontalScrollIndicator"] boolValue];
    attr.showsVerticalScrollIndicator = [data[@"showsVerticalScrollIndicator"] boolValue];
    attr.scrollIndicatorInsets = [ADHViewDebugUtil insetsWithString:data[@"scrollIndicatorInsets"]];
    attr.indicatorStyle = [ADHViewDebugUtil adhIntWithValue:data[@"indicatorStyle"]];
    attr.decelerationRate = [ADHViewDebugUtil adhIntWithValue:data[@"decelerationRate"]];
    attr.minimumZoomScale = [data[@"minimumZoomScale"] floatValue];
    attr.maximumZoomScale = [data[@"maximumZoomScale"] floatValue];
    attr.zoomScale = [data[@"zoomScale"] floatValue];
    attr.scrollsToTop = [data[@"scrollsToTop"] boolValue];
    attr.keyboardDismissMode = [ADHViewDebugUtil adhIntWithValue:data[@"keyboardDismissMode"]];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"delegate",@"Delegate",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"contentOffset",@"Content Offset",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"contentSize",@"Content Size",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"contentInset",@"Content Inset",ADHAttrTypeText)];
    if(ATTR_iOS11) {
        [list addObject:ADH_ATTR(@"adjustedContentInset",@"Adjusted Content Inset",ADHAttrTypeText)];
        [list addObject:ADH_ATTR(@"contentInsetAdjustmentBehavior",@"Adjustment Behavior",ADHAttrTypeSelect)];
    }
    [list addObject:ADH_ATTR(@"directionalLockEnabled",@"Directional Lock Enabled",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"bounces",@"Bounces",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"alwaysBounceVertical",@"Bounce Vertical",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"alwaysBounceHorizontal",@"Bounce Horizontal",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"pagingEnabled",@"Paging Enabled",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"scrollEnabled",@"Scroll Enabled",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"showsHorizontalScrollIndicator",@"Horizontal Scroll Indicator",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"showsVerticalScrollIndicator",@"Vertical Scroll Indicator",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"scrollIndicatorInsets",@"Scroll Indicator Insets",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"indicatorStyle",@"Indicator Style",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"decelerationRate",@"Deceleration Rate",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"minimumZoomScale",@"Min Zoom Scale",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"maximumZoomScale",@"Max Zoom Scale",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"zoomScale",@"Zoom Scale",ADHAttrTypeValue)];
    [list addObject:ADH_ATTR(@"scrollsToTop",@"ScrollsToTop",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"keyboardDismissMode",@"Keyboard Dismiss Mode",ADHAttrTypeSelect)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHScrollViewAttribute *attr = self;
    if([key isEqualToString:@"contentOffset"]) {
        attrValue = [ADHViewDebugUtil presentStringWithCGPoint:attr.contentOffset];
    }else if([key isEqualToString:@"contentSize"]) {
        attrValue = [ADHViewDebugUtil presentStringWithCGSize:attr.contentSize];
    }else if([key isEqualToString:@"contentInset"]) {
        attrValue = [ADHViewDebugUtil presentStringWithAdhInsets:attr.contentInset];
    }else if([key isEqualToString:@"adjustedContentInset"]) {
        attrValue = [ADHViewDebugUtil presentStringWithAdhInsets:attr.adjustedContentInset];
    }else if([key isEqualToString:@"contentInsetAdjustmentBehavior"]) {
        /*
        UIScrollViewContentInsetAdjustmentAutomatic,
        UIScrollViewContentInsetAdjustmentScrollableAxes,
        UIScrollViewContentInsetAdjustmentNever,
        UIScrollViewContentInsetAdjustmentAlways,
        */
        NSArray *list = @[
                          ADH_POPUP(@"Automatic", 0),
                          ADH_POPUP(@"ScrollableAxes", 1),
                          ADH_POPUP(@"Never", 2),
                          ADH_POPUP(@"Always", 3),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.contentInsetAdjustmentBehavior],
                      };
    }else if([key isEqualToString:@"directionalLockEnabled"]) {
        attrValue = [NSNumber numberWithBool:attr.directionalLockEnabled];
    }else if([key isEqualToString:@"bounces"]) {
        attrValue = [NSNumber numberWithBool:attr.bounces];
    }else if([key isEqualToString:@"alwaysBounceVertical"]) {
        attrValue = [NSNumber numberWithBool:attr.alwaysBounceVertical];
    }else if([key isEqualToString:@"alwaysBounceHorizontal"]) {
        attrValue = [NSNumber numberWithBool:attr.alwaysBounceHorizontal];
    }else if([key isEqualToString:@"pagingEnabled"]) {
        attrValue = [NSNumber numberWithBool:attr.pagingEnabled];
    }else if([key isEqualToString:@"scrollEnabled"]) {
        attrValue = [NSNumber numberWithBool:attr.scrollEnabled];
    }else if([key isEqualToString:@"showsHorizontalScrollIndicator"]) {
        attrValue = [NSNumber numberWithBool:attr.showsHorizontalScrollIndicator];
    }else if([key isEqualToString:@"showsVerticalScrollIndicator"]) {
        attrValue = [NSNumber numberWithBool:attr.showsVerticalScrollIndicator];
    }else if([key isEqualToString:@"scrollIndicatorInsets"]) {
        attrValue = [ADHViewDebugUtil presentStringWithAdhInsets:attr.scrollIndicatorInsets];
    }else if([key isEqualToString:@"indicatorStyle"]) {
        /*
        UIScrollViewIndicatorStyleDefault,
        UIScrollViewIndicatorStyleBlack,
        UIScrollViewIndicatorStyleWhite
         */
        NSArray *list = @[
                          ADH_POPUP(@"Default", 0),
                          ADH_POPUP(@"Black", 1),
                          ADH_POPUP(@"White", 2),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.indicatorStyle],
                      };
    }else if([key isEqualToString:@"decelerationRate"]) {
        NSArray *list = @[
                          ADH_POPUP(@"Normal", 0),
                          ADH_POPUP(@"Fast", 1),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.decelerationRate],
                      };
    }else if([key isEqualToString:@"minimumZoomScale"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.minimumZoomScale];
    }else if([key isEqualToString:@"maximumZoomScale"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.maximumZoomScale];
    }else if([key isEqualToString:@"zoomScale"]) {
        
        /**
         * value
         * format : ADHAttrValueFormat
         * stepper : @(YES)
         * step : 0.1
         * min : 0
         * max : 1
         */
        attrValue = @{
                      @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                      @"stepper" : @(YES),
                      @"step" : @(0.1),
                      @"min" : [NSNumber numberWithFloat:attr.minimumZoomScale],
                      @"max" : [NSNumber numberWithFloat:attr.maximumZoomScale],
                      @"value" : [NSNumber numberWithFloat:attr.zoomScale],
                      };
    }else if([key isEqualToString:@"scrollsToTop"]) {
        attrValue = [NSNumber numberWithBool:attr.scrollsToTop];
    }else if([key isEqualToString:@"keyboardDismissMode"]) {
        /*
         UIScrollViewKeyboardDismissModeNone,
         UIScrollViewKeyboardDismissModeOnDrag,
         UIScrollViewKeyboardDismissModeInteractive,
         */
        NSArray *list = @[
                          ADH_POPUP(@"None", 0),
                          ADH_POPUP(@"OnDrag", 1),
                          ADH_POPUP(@"Interactive", 2),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" :[ADHViewDebugUtil numberWithAdhInt:attr.keyboardDismissMode],
                      };
    }else if([key isEqualToString:@"delegate"]) {
        attrValue = attr.delegate;
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    ADHScrollViewAttribute *attr = self;
    if([key isEqualToString:@"contentInsetAdjustmentBehavior"]) {
        if (@available(iOS 11.0, *)) {
            attr.contentInsetAdjustmentBehavior = [ADHViewDebugUtil adhIntWithValue:value];
        }
    }else if([key isEqualToString:@"directionalLockEnabled"]) {
        attr.directionalLockEnabled = [value boolValue];
    }else if([key isEqualToString:@"bounces"]) {
        attr.bounces = [value boolValue];
    }else if([key isEqualToString:@"alwaysBounceVertical"]) {
        attr.alwaysBounceVertical = [value boolValue];
    }else if([key isEqualToString:@"alwaysBounceHorizontal"]) {
        attr.alwaysBounceHorizontal = [value boolValue];
    }else if([key isEqualToString:@"pagingEnabled"]) {
        attr.pagingEnabled = [value boolValue];
    }else if([key isEqualToString:@"scrollEnabled"]) {
        attr.scrollEnabled = [value boolValue];
    }else if([key isEqualToString:@"showsHorizontalScrollIndicator"]) {
        attr.showsHorizontalScrollIndicator = [value boolValue];
    }else if([key isEqualToString:@"showsVerticalScrollIndicator"]) {
        attr.showsVerticalScrollIndicator = [value boolValue];
    }else if([key isEqualToString:@"indicatorStyle"]) {
        attr.indicatorStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"decelerationRate"]) {
        attr.decelerationRate = [value floatValue];
    }else if([key isEqualToString:@"zoomScale"]) {
        attr.zoomScale = [value floatValue];
    }else if([key isEqualToString:@"scrollsToTop"]) {
        attr.scrollsToTop = [value boolValue];
    }else if([key isEqualToString:@"keyboardDismissMode"]) {
        attr.keyboardDismissMode = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_scrollview";
}


@end

@implementation ADHTableViewAttribute

- (NSDictionary *)getPropertyData {
    ADHTableViewAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"delegate"] = adhvf_safestringfy(attr.delegate);
    data[@"dataSource"] = adhvf_safestringfy(attr.dataSource);
    data[@"style"] = [ADHViewDebugUtil stringWithAdhInt:attr.style];
    data[@"rowHeight"] = [NSNumber numberWithFloat:attr.rowHeight];
    data[@"sectionHeaderHeight"] = [NSNumber numberWithFloat:attr.sectionHeaderHeight];
    data[@"sectionFooterHeight"] = [NSNumber numberWithFloat:attr.sectionFooterHeight];
    data[@"estimatedRowHeight"] = [NSNumber numberWithFloat:attr.estimatedRowHeight];
    data[@"estimatedSectionHeaderHeight"] = [NSNumber numberWithFloat:attr.estimatedSectionHeaderHeight];
    data[@"estimatedSectionFooterHeight"] = [NSNumber numberWithFloat:attr.estimatedSectionFooterHeight];
    data[@"separatorStyle"] = [ADHViewDebugUtil stringWithAdhInt:attr.separatorStyle];
    data[@"separatorInset"] = [ADHViewDebugUtil stringWithAdhInsets:attr.separatorInset];
    data[@"separatorColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.separatorColor];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHTableViewAttribute *attr = self;
    attr.delegate = data[@"delegate"];
    attr.dataSource = data[@"dataSource"];
    attr.style = [ADHViewDebugUtil adhIntWithValue:data[@"style"]];
    attr.rowHeight = [data[@"rowHeight"] floatValue];
    attr.sectionHeaderHeight = [data[@"sectionHeaderHeight"] floatValue];
    attr.sectionFooterHeight = [data[@"sectionFooterHeight"] floatValue];
    attr.estimatedRowHeight = [data[@"estimatedRowHeight"] floatValue];
    attr.estimatedSectionHeaderHeight = [data[@"estimatedSectionHeaderHeight"] floatValue];
    attr.estimatedSectionFooterHeight = [data[@"estimatedSectionFooterHeight"] floatValue];
    attr.separatorStyle = [ADHViewDebugUtil adhIntWithValue:data[@"separatorStyle"]];
    attr.separatorInset = [ADHViewDebugUtil insetsWithString:data[@"separatorInset"]];
    attr.separatorColor = [ADHViewDebugUtil colorWithString:data[@"separatorColor"]];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"delegate",@"Delegate",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"dataSource",@"DataSource",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"style",@"Style",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"rowHeight",@"Row Height",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"sectionHeaderHeight",@"Section Header Height",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"sectionFooterHeight",@"Section Footer Height",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"estimatedRowHeight",@"Estimated Row Height",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"estimatedSectionHeaderHeight",@"Estimated Header Height",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"estimatedSectionFooterHeight",@"Estimated Footer Height",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"separatorStyle",@"Separator Style",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"separatorInset",@"Separator Inset",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"separatorColor",@"Separator Color",ADHAttrTypeColor)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHTableViewAttribute *attr = self;
    if([key isEqualToString:@"delegate"]) {
        attrValue = attr.delegate;
    }else if([key isEqualToString:@"dataSource"]) {
        attrValue = attr.dataSource;
    }else if([key isEqualToString:@"style"]) {
        /*
         UITableViewStylePlain,
         UITableViewStyleGrouped
         */
        NSString *text = nil;
        switch (attr.style) {
            case 0:
                text = @"Plain";
                break;
            case 1:
                text = @"Grouped";
                break;
            default:
                break;
        }
        attrValue = text;
    }else if([key isEqualToString:@"rowHeight"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.rowHeight];
    }else if([key isEqualToString:@"sectionHeaderHeight"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.sectionHeaderHeight];
    }else if([key isEqualToString:@"sectionFooterHeight"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.sectionFooterHeight];
    }else if([key isEqualToString:@"estimatedRowHeight"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.estimatedRowHeight];
    }else if([key isEqualToString:@"estimatedSectionHeaderHeight"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.estimatedSectionHeaderHeight];
    }else if([key isEqualToString:@"estimatedSectionFooterHeight"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.estimatedSectionFooterHeight];
    }else if([key isEqualToString:@"separatorStyle"]) {
        /*
        UITableViewCellSeparatorStyleNone,
        UITableViewCellSeparatorStyleSingleLine,
         */
        NSArray *list = @[
                          ADH_POPUP(@"None", 0),
                          ADH_POPUP(@"Single Line", 1),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.separatorStyle],
                      };
    }else if([key isEqualToString:@"separatorInset"]) {
        attrValue = [ADHViewDebugUtil presentStringWithAdhInsets:attr.separatorInset];
    }else if([key isEqualToString:@"separatorColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.separatorColor];
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    if([key isEqualToString:@"separatorColor"]) {
        self.separatorColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"separatorStyle"]) {
        self.separatorStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_tableview";
}

@end

@implementation ADHTableCellAttribute

- (NSDictionary *)getPropertyData {
    ADHTableCellAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"reuseIdentifier"] = adhvf_safestringfy(attr.reuseIdentifier);
    data[@"selectionStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.selectionStyle];
    data[@"selected"] = [NSNumber numberWithBool:attr.selected];
    data[@"highlighted"] = [NSNumber numberWithBool:attr.highlighted];
    data[@"editingStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.editingStyle];
    data[@"accessoryType"] = [ADHViewDebugUtil numberWithAdhInt:attr.accessoryType];
    data[@"editingAccessoryType"] = [ADHViewDebugUtil numberWithAdhInt:attr.editingAccessoryType];
    data[@"indentationLevel"] = [ADHViewDebugUtil numberWithAdhInt:attr.indentationLevel];
    data[@"indentationWidth"] = [NSNumber numberWithFloat:attr.indentationWidth];
    data[@"separatorInset"] = [ADHViewDebugUtil stringWithAdhInsets:attr.separatorInset];
    data[@"focusStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.focusStyle];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHTableCellAttribute *attr = self;
    attr.reuseIdentifier = data[@"reuseIdentifier"];
    attr.selectionStyle = [ADHViewDebugUtil adhIntWithValue:data[@"selectionStyle"]];
    attr.selected = [data[@"selected"] boolValue];
    attr.highlighted = [data[@"highlighted"] boolValue];
    attr.editingStyle = [ADHViewDebugUtil adhIntWithValue:data[@"editingStyle"]];
    attr.accessoryType = [ADHViewDebugUtil adhIntWithValue:data[@"accessoryType"]];
    attr.editingAccessoryType = [ADHViewDebugUtil adhIntWithValue:data[@"editingAccessoryType"]];
    attr.indentationLevel = [ADHViewDebugUtil adhIntWithValue:data[@"indentationLevel"]];
    attr.indentationWidth = [data[@"indentationWidth"] floatValue];
    attr.separatorInset = [ADHViewDebugUtil insetsWithString:data[@"separatorInset"]];
    attr.focusStyle = [ADHViewDebugUtil adhIntWithValue:data[@"focusStyle"]];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"reuseIdentifier",@"ReuseIdentifier",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"selectionStyle",@"Selection Style",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"selected",@"Selected",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"highlighted",@"Highlighted",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"editingStyle",@"Editing Style",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"accessoryType",@"Accessory Type",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"editingAccessoryType",@"Editing Accessory Type",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"indentationLevel",@"Indentation Level",ADHAttrTypeValue)];
    [list addObject:ADH_ATTR(@"indentationWidth",@"Indentation Width",ADHAttrTypeValue)];
    [list addObject:ADH_ATTR(@"separatorInset",@"Separator Inset",ADHAttrTypeText)];
    if(ATTR_iOS9) {
        [list addObject:ADH_ATTR(@"focusStyle",@"Focus Style",ADHAttrTypeSelect)];
    }
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHTableCellAttribute *attr = self;
    if([key isEqualToString:@"reuseIdentifier"]) {
        attrValue = attr.reuseIdentifier;
    }else if([key isEqualToString:@"selectionStyle"]) {
        /*
         UITableViewCellSelectionStyleNone,
         UITableViewCellSelectionStyleBlue,
         UITableViewCellSelectionStyleGray,
         UITableViewCellSelectionStyleDefault NS_ENUM_AVAILABLE_IOS(7_0)
         */
        NSArray *list = @[
                          ADH_POPUP(@"None", 0),
                          ADH_POPUP(@"Blue", 1),
                          ADH_POPUP(@"Gray", 2),
                          ADH_POPUP(@"Default", 3),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.selectionStyle],
                      };
    }else if([key isEqualToString:@"selected"]) {
        attrValue = [NSNumber numberWithBool:attr.selected];
    }else if([key isEqualToString:@"highlighted"]) {
        attrValue = [NSNumber numberWithBool:attr.highlighted];
    }else if([key isEqualToString:@"editingStyle"]) {
        /*
        UITableViewCellEditingStyleNone,
        UITableViewCellEditingStyleDelete,
        UITableViewCellEditingStyleInsert
        */
        NSString *text = nil;
        switch (attr.editingStyle) {
            case 0:
                text = @"None";
                break;
            case 1:
                text = @"Delete";
                break;
            case 2:
                text = @"Insert";
                break;
            default:
                break;
        }
        attrValue = text;
    }else if([key isEqualToString:@"accessoryType"]) {
        NSArray *list = [self accessoryTypes];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.accessoryType],
                      };
    }else if([key isEqualToString:@"editingAccessoryType"]) {
        NSArray *list = [self accessoryTypes];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.editingAccessoryType],
                      };
    }else if([key isEqualToString:@"indentationLevel"]) {
        attrValue = @{
                      @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                      @"stepper" : @(YES),
                      @"step" : @(1),
                      @"min" : @(0),
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.indentationLevel],
                      };
    }else if([key isEqualToString:@"indentationWidth"]) {
        /**
         * value
         * format : ADHAttrValueFormat
         * stepper : @(YES)
         * step : 0.1
         * min : 0
         * max : 1
         */
        attrValue = @{
                      @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                      @"stepper" : @(YES),
                      @"step" : @(0.1),
                      @"min" : @(0),
                      @"value" : [NSNumber numberWithFloat:attr.indentationWidth],
                      };
    }else if([key isEqualToString:@"separatorInset"]) {
        attrValue = [ADHViewDebugUtil presentStringWithAdhInsets:attr.separatorInset];
    }else if([key isEqualToString:@"focusStyle"]) {
        /*
        UITableViewCellFocusStyleDefault,
        UITableViewCellFocusStyleCustom
         */
        NSArray *list = @[
                          ADH_POPUP(@"Default", 0),
                          ADH_POPUP(@"Custom", 1),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.focusStyle],
                      };
    }
    return attrValue;
}

- (NSArray<ADHPopupItem *> *)accessoryTypes {
    NSArray *list = @[
                      ADH_POPUP(@"None", 0),
                      ADH_POPUP(@"Disclosure Indicator", 1),
                      ADH_POPUP(@"Detail Disclosure Button", 2),
                      ADH_POPUP(@"Checkmark", 3),
                      ADH_POPUP(@"Detail Button", 4),
                      ];
    return list;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    ADHTableCellAttribute *attr = self;
    if([key isEqualToString:@"selectionStyle"]) {
        attr.selectionStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"selected"]) {
        attr.selected = [value boolValue];
    }else if([key isEqualToString:@"highlighted"]) {
        attr.highlighted = [value boolValue];
    }else if([key isEqualToString:@"accessoryType"]) {
        attr.accessoryType = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"editingAccessoryType"]) {
        attr.editingAccessoryType = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"indentationLevel"]) {
        attr.indentationLevel = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"indentationWidth"]) {
        attr.indentationWidth = [value floatValue];
    }else if([key isEqualToString:@"focusStyle"]) {
        attr.focusStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_tablecell";
}

@end


@implementation ADHCollectionAttribute

- (NSDictionary *)getPropertyData {
    ADHCollectionAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"collectionViewLayout"] = adhvf_safestringfy(attr.collectionViewLayout);
    data[@"delegate"] = adhvf_safestringfy(attr.delegate);
    data[@"dataSource"] = adhvf_safestringfy(attr.dataSource);
    data[@"allowsSelection"] = [NSNumber numberWithBool:attr.allowsSelection];
    data[@"allowsMultipleSelection"] = [NSNumber numberWithBool:attr.allowsMultipleSelection];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHCollectionAttribute *attr = self;
    attr.collectionViewLayout = data[@"collectionViewLayout"];
    attr.delegate = data[@"delegate"];
    attr.dataSource = data[@"dataSource"];
    attr.allowsSelection = [data[@"allowsSelection"] boolValue];
    attr.allowsMultipleSelection = [data[@"allowsMultipleSelection"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"delegate",@"Delegate",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"dataSource",@"DataSource",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"allowsSelection",@"Allow Selection",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"allowsMultipleSelection",@"Multiple Selection",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"collectionViewLayout",@"Layout Class",ADHAttrTypeText)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHCollectionAttribute *attr = self;
    if([key isEqualToString:@"collectionViewLayout"]) {
        attrValue = attr.collectionViewLayout;
    }else if([key isEqualToString:@"delegate"]) {
        attrValue = attr.delegate;
    }else if([key isEqualToString:@"dataSource"]) {
        attrValue = attr.dataSource;
    }else if([key isEqualToString:@"allowsSelection"]) {
        attrValue = [NSNumber numberWithBool:attr.allowsSelection];
    }else if([key isEqualToString:@"allowsMultipleSelection"]) {
        attrValue = [NSNumber numberWithBool:attr.allowsMultipleSelection];
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    ADHCollectionAttribute *attr = self;
    if([key isEqualToString:@"allowsSelection"]) {
        attr.allowsSelection = [value boolValue];
    }else if([key isEqualToString:@"allowsMultipleSelection"]) {
        attr.allowsMultipleSelection = [value boolValue];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_collectionview";
}


@end

@implementation ADHCollectReusableAttribute

- (NSDictionary *)getPropertyData {
    ADHCollectReusableAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"reuseIdentifier"] = adhvf_safestringfy(attr.reuseIdentifier);
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHCollectReusableAttribute *attr = self;
    attr.reuseIdentifier = data[@"reuseIdentifier"];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"reuseIdentifier",@"ReuseIdentifier",ADHAttrTypeText)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHCollectReusableAttribute *attr = self;
    if([key isEqualToString:@"reuseIdentifier"]) {
        attrValue = attr.reuseIdentifier;
    }
    return attrValue;
}

- (NSString *)classTypeIcon {
    return @"vd_collectioncell";
}

@end


@implementation ADHCollectCellAttribute

- (NSDictionary *)getPropertyData {
    ADHCollectCellAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"selected"] = [NSNumber numberWithBool:attr.selected];
    data[@"highlighted"] = [NSNumber numberWithBool:attr.selected];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHCollectCellAttribute *attr = self;
    attr.selected = [data[@"selected"] boolValue];
    attr.highlighted = [data[@"highlighted"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"selected",@"Selected",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"highlighted",@"Highlighted",ADHAttrTypeBoolean)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHCollectCellAttribute *attr = self;
    if([key isEqualToString:@"selected"]) {
        attrValue = [NSNumber numberWithBool:attr.selected];
    }else if([key isEqualToString:@"highlighted"]) {
        attrValue = [NSNumber numberWithBool:attr.highlighted];
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    ADHCollectCellAttribute *attr = self;
    if([key isEqualToString:@"selected"]) {
        attr.selected = [value boolValue];
    }else if([key isEqualToString:@"highlighted"]) {
        attr.highlighted = [value boolValue];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_collectioncell";
}

@end

@implementation ADHStackAttribute

- (NSDictionary *)getPropertyData {
    ADHStackAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"axis"] = [ADHViewDebugUtil numberWithAdhInt:attr.axis];
    data[@"distribution"] = [ADHViewDebugUtil numberWithAdhInt:attr.distribution];
    data[@"alignment"] = [ADHViewDebugUtil numberWithAdhInt:attr.alignment];
    data[@"spacing"] = [NSNumber numberWithFloat:attr.spacing];
    data[@"baselineRelativeArrangement"] = [NSNumber numberWithBool:attr.baselineRelativeArrangement];
    data[@"layoutMarginsRelativeArrangement"] = [NSNumber numberWithBool:attr.layoutMarginsRelativeArrangement];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHStackAttribute *attr = self;
    attr.axis = [ADHViewDebugUtil adhIntWithValue:data[@"axis"]];
    attr.distribution = [ADHViewDebugUtil adhIntWithValue:data[@"distribution"]];
    attr.alignment = [ADHViewDebugUtil adhIntWithValue:data[@"alignment"]];
    attr.spacing = [data[@"spacing"] floatValue];
    attr.baselineRelativeArrangement = [data[@"baselineRelativeArrangement"] boolValue];
    attr.layoutMarginsRelativeArrangement = [data[@"layoutMarginsRelativeArrangement"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"axis",@"Axis",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"distribution",@"Distribution",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"alignment",@"Alignment",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"spacing",@"Spacing",ADHAttrTypeValue)];
    [list addObject:ADH_ATTR(@"baselineRelativeArrangement",@"Baseline Relative",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"layoutMarginsRelativeArrangement",@"Layout Margins Relative",ADHAttrTypeBoolean)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHStackAttribute *attr = self;
    if([key isEqualToString:@"axis"]) {
        /*
         UILayoutConstraintAxisHorizontal = 0,
         UILayoutConstraintAxisVertical = 1
         */
        NSArray *list = @[
                          ADH_POPUP(@"Horizontal", 0),
                          ADH_POPUP(@"Vertical", 1),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.axis],
                      };
    }else if([key isEqualToString:@"distribution"]) {
        /*
        UIStackViewDistributionFill = 0,
        UIStackViewDistributionFillEqually,
        UIStackViewDistributionFillProportionally,
        UIStackViewDistributionEqualSpacing,
        UIStackViewDistributionEqualCentering,
         */
        NSArray *list = @[
                          ADH_POPUP(@"Fill", 0),
                          ADH_POPUP(@"Fill Equally", 1),
                          ADH_POPUP(@"Fill Proportionally", 2),
                          ADH_POPUP(@"Equal Spacing", 3),
                          ADH_POPUP(@"Equal Centering", 4),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.distribution],
                      };
    }else if([key isEqualToString:@"alignment"]) {
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
        NSArray *list = @[
                          ADH_POPUP(@"Fill", 0),
                          ADH_POPUP(@"Leading (Top)", 1),
                          ADH_POPUP(@"First Baseline", 2),
                          ADH_POPUP(@"Center", 3),
                          ADH_POPUP(@"Trailing (Bottom)", 4),
                          ADH_POPUP(@"Last Baseline", 5),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.alignment],
                      };
    }else if([key isEqualToString:@"spacing"]) {
        attrValue = @{
                      @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                      @"stepper" : @(YES),
                      @"step" : @(1),
                      @"value" : [NSNumber numberWithFloat:attr.spacing],
                      };
    }else if([key isEqualToString:@"baselineRelativeArrangement"]) {
        attrValue = [NSNumber numberWithBool:attr.baselineRelativeArrangement];
    }else if([key isEqualToString:@"layoutMarginsRelativeArrangement"]) {
        attrValue = [NSNumber numberWithBool:attr.layoutMarginsRelativeArrangement];
    }
    return attrValue;
}

/*
 * axis
 * distribution
 * alignment
 * spacing
 * baselineRelativeArrangement
 * layoutMarginsRelativeArrangement
 */
- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    ADHStackAttribute *attr = self;
    if([key isEqualToString:@"axis"]) {
        attr.axis = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"distribution"]) {
        attr.distribution = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"alignment"]) {
        attr.alignment = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"spacing"]) {
        attr.spacing = [value floatValue];
    }else if([key isEqualToString:@"baselineRelativeArrangement"]) {
        attr.baselineRelativeArrangement = [value boolValue];
    }else if([key isEqualToString:@"layoutMarginsRelativeArrangement"]) {
        attr.layoutMarginsRelativeArrangement = [value boolValue];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_stackview";
}

@end

@implementation ADHNaviBarAttribute

- (NSDictionary *)getPropertyData {
    ADHNaviBarAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"barStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.barStyle];
    data[@"translucent"] = [NSNumber numberWithBool:attr.translucent];
    data[@"prefersLargeTitles"] = [NSNumber numberWithBool:attr.prefersLargeTitles];
    data[@"tintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.tintColor];
    data[@"barTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.barTintColor];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHNaviBarAttribute *attr = self;
    attr.barStyle = [ADHViewDebugUtil adhIntWithValue:data[@"barStyle"]];
    attr.translucent = [data[@"translucent"] boolValue];
    attr.prefersLargeTitles = [data[@"prefersLargeTitles"] boolValue];
    attr.tintColor = [ADHViewDebugUtil colorWithString:data[@"tintColor"]];
    attr.barTintColor = [ADHViewDebugUtil colorWithString:data[@"barTintColor"]];
    attr.backgroundImage = data[@"backgroundImage"];
    attr.shadowImage = data[@"shadowImage"];
    attr.backIndicatorImage = data[@"backIndicatorImage"];
    attr.backIndicatorTransitionMaskImage = data[@"backIndicatorTransitionMaskImage"];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"barStyle",@"Bar Style",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"translucent",@"Translucent",ADHAttrTypeBoolean)];
    if(ATTR_iOS11) {
        [list addObject:ADH_ATTR(@"prefersLargeTitles",@"PrefersLargeTitles",ADHAttrTypeBoolean)];
    }
    [list addObject:ADH_ATTR(@"tintColor",@"Tint Color",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"barTintColor",@"Bar Tint Color",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"backgroundImage",@"Background Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"shadowImage",@"Shadow Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"backIndicatorImage",@"Back Indicator Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"backIndicatorTransitionMaskImage",@"Back Indicator Mask Image",ADHAttrTypeImage)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHNaviBarAttribute *attr = self;
    if([key isEqualToString:@"barStyle"]) {
        /*
        UIBarStyleDefault          = 0,
        UIBarStyleBlack            = 1,
        */
        NSArray *list = @[
                          ADH_POPUP(@"Default", 0),
                          ADH_POPUP(@"Black", 1),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.barStyle],
                      };
    }else if([key isEqualToString:@"translucent"]) {
        attrValue = [NSNumber numberWithBool:attr.translucent];
    }else if([key isEqualToString:@"prefersLargeTitles"]) {
        attrValue = [NSNumber numberWithBool:attr.prefersLargeTitles];
    }else if([key isEqualToString:@"tintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.tintColor];
    }else if([key isEqualToString:@"barTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.barTintColor];
    }else if([key isEqualToString:@"backgroundImage"]) {
        attrValue = attr.backgroundImage;
    }else if([key isEqualToString:@"shadowImage"]) {
        attrValue = attr.shadowImage;
    }else if([key isEqualToString:@"backIndicatorImage"]) {
        attrValue = attr.backIndicatorImage;
    }else if([key isEqualToString:@"backIndicatorTransitionMaskImage"]) {
        attrValue = attr.backIndicatorTransitionMaskImage;
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    ADHNaviBarAttribute *attr = self;
    if([key isEqualToString:@"barStyle"]) {
        attr.barStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"translucent"]) {
        attr.translucent = [value boolValue];
    }else if([key isEqualToString:@"prefersLargeTitles"]) {
        attr.prefersLargeTitles = [value boolValue];
    }else if([key isEqualToString:@"tintColor"]) {
        attr.tintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"barTintColor"]) {
        attr.barTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"backgroundImage"]) {
        attr.backgroundImage = value;
    }else if([key isEqualToString:@"shadowImage"]) {
        attr.shadowImage = value;
    }else if([key isEqualToString:@"backIndicatorImage"]) {
        attr.backIndicatorImage = value;
    }else if([key isEqualToString:@"backIndicatorTransitionMaskImage"]) {
        attr.backIndicatorTransitionMaskImage = value;
    }
}

- (NSString *)classTypeIcon {
    return @"vd_navibationbar";
}

@end

@implementation ADHTabBarAttribute

- (NSDictionary *)getPropertyData {
    ADHTabBarAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"tintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.tintColor];
    data[@"barTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.barTintColor];
    data[@"unselectedItemTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.unselectedItemTintColor];
    data[@"itemPositioning"] = [ADHViewDebugUtil numberWithAdhInt:attr.itemPositioning];
    data[@"itemWidth"] = [NSNumber numberWithFloat:attr.itemWidth];
    data[@"itemSpacing"] = [NSNumber numberWithFloat:attr.itemSpacing];
    data[@"barStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.barStyle];
    data[@"translucent"] = [NSNumber numberWithBool:attr.translucent];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHTabBarAttribute *attr = self;
    attr.tintColor = [ADHViewDebugUtil colorWithString:data[@"tintColor"]];
    attr.barTintColor = [ADHViewDebugUtil colorWithString:data[@"barTintColor"]];
    attr.unselectedItemTintColor = [ADHViewDebugUtil colorWithString:data[@"unselectedItemTintColor"]];
    attr.itemPositioning = [ADHViewDebugUtil adhIntWithValue:data[@"itemPositioning"]];
    attr.itemWidth = [data[@"itemWidth"] floatValue];
    attr.itemSpacing = [data[@"itemSpacing"] floatValue];
    attr.barStyle = [ADHViewDebugUtil adhIntWithValue:data[@"barStyle"]];
    attr.translucent = [data[@"translucent"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"barStyle",@"Bar Style",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"translucent",@"Translucent",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"tintColor",@"Tint Color",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"barTintColor",@"Bar Tint Color",ADHAttrTypeColor)];
    if(ATTR_iOS10) {
        [list addObject:ADH_ATTR(@"unselectedItemTintColor",@"Unselected Tint Color",ADHAttrTypeColor)];
    }
    [list addObject:ADH_ATTR(@"backgroundImage",@"Background Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"selectionIndicatorImage",@"Selection Indicator Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"shadowImage",@"Shadow Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"itemPositioning",@"Item Positioning",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"itemWidth",@"Item Width",ADHAttrTypeValue)];
    [list addObject:ADH_ATTR(@"itemSpacing",@"Item Spacing",ADHAttrTypeValue)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHTabBarAttribute *attr = self;
    if([key isEqualToString:@"tintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.tintColor];
    }else if([key isEqualToString:@"barTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.barTintColor];
    }else if([key isEqualToString:@"unselectedItemTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.unselectedItemTintColor];
    }else if([key isEqualToString:@"backgroundImage"]) {
        attrValue = attr.backgroundImage;
    }else if([key isEqualToString:@"selectionIndicatorImage"]) {
        attrValue = attr.selectionIndicatorImage;
    }else if([key isEqualToString:@"shadowImage"]) {
        attrValue = attr.shadowImage;
    }else if([key isEqualToString:@"itemPositioning"]) {
        /*
        UITabBarItemPositioningAutomatic,
        UITabBarItemPositioningFill,
        UITabBarItemPositioningCentered,
        */
        NSArray *list = @[
                          ADH_POPUP(@"Automatic", 0),
                          ADH_POPUP(@"Fill", 1),
                          ADH_POPUP(@"Centered", 2),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.itemPositioning],
                      };
    }else if([key isEqualToString:@"itemWidth"]) {
        attrValue = @{
                      @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                      @"stepper" : @(YES),
                      @"step" : @(1),
                      @"min" : @(0),
                      @"value" : [NSNumber numberWithFloat:attr.itemWidth],
                      };
    }else if([key isEqualToString:@"itemSpacing"]) {
        attrValue = @{
                      @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                      @"stepper" : @(YES),
                      @"step" : @(1),
                      @"min" : @(0),
                      @"value" : [NSNumber numberWithFloat:attr.itemSpacing],
                      };
    }else if([key isEqualToString:@"barStyle"]) {
        /*
        UIBarStyleDefault          = 0,
        UIBarStyleBlack            = 1,
         */
        NSArray *list = @[
                          ADH_POPUP(@"Default", 0),
                          ADH_POPUP(@"Black", 1),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.barStyle],
                      };
    }else if([key isEqualToString:@"translucent"]) {
        attrValue = [NSNumber numberWithBool:attr.translucent];
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    ADHTabBarAttribute *attr = self;
    if([key isEqualToString:@"tintColor"]) {
        attr.tintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"barTintColor"]) {
        attr.barTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"unselectedItemTintColor"]) {
        attr.unselectedItemTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"backgroundImage"]) {
        attr.backgroundImage = value;
    }else if([key isEqualToString:@"selectionIndicatorImage"]) {
        attr.selectionIndicatorImage = value;
    }else if([key isEqualToString:@"shadowImage"]) {
        attr.shadowImage = value;
    }else if([key isEqualToString:@"translucent"]) {
        attr.translucent = [value boolValue];
    }else if([key isEqualToString:@"itemPositioning"]) {
        attr.itemPositioning = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"itemWidth"]) {
        attr.itemWidth = [value floatValue];
    }else if([key isEqualToString:@"itemSpacing"]) {
        attr.itemSpacing = [value floatValue];
    }else if([key isEqualToString:@"barStyle"]) {
        attr.barStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_tabbar";
}

@end

@implementation ADHToolBarAttribute

- (NSDictionary *)getPropertyData {
    ADHToolBarAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"barStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.barStyle];
    data[@"translucent"] = [NSNumber numberWithBool:attr.translucent];
    data[@"barTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.barTintColor];
    data[@"tintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.tintColor];
    return data;
}


- (void)setPropertyWithData: (NSDictionary *)data {
    ADHToolBarAttribute *attr = self;
    attr.barStyle = [ADHViewDebugUtil adhIntWithValue:data[@"barStyle"]];
    attr.translucent = [data[@"translucent"] boolValue];
    attr.tintColor = [ADHViewDebugUtil colorWithString:data[@"tintColor"]];
    attr.barTintColor = [ADHViewDebugUtil colorWithString:data[@"barTintColor"]];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"barStyle",@"Bar Style",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"translucent",@"Translucent",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"barTintColor",@"Bar Tint Color",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"tintColor",@"Tint Color",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"backgroundImage",@"Background Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"shadowImage",@"Shadow Image",ADHAttrTypeImage)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHToolBarAttribute *attr = self;
    if([key isEqualToString:@"barStyle"]) {
        /*
         UIBarStyleDefault          = 0,
         UIBarStyleBlack            = 1,
         */
        NSArray *list = @[
                          ADH_POPUP(@"Default", 0),
                          ADH_POPUP(@"Black", 1),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.barStyle],
                      };
    }else if([key isEqualToString:@"translucent"]) {
        attrValue = [NSNumber numberWithBool:attr.translucent];
    }else if([key isEqualToString:@"tintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.tintColor];
    }else if([key isEqualToString:@"barTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.barTintColor];
    }else if([key isEqualToString:@"backgroundImage"]) {
        attrValue = attr.backgroundImage;
    }else if([key isEqualToString:@"shadowImage"]) {
        attrValue = attr.shadowImage;
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    ADHToolBarAttribute *attr = self;
    if([key isEqualToString:@"barStyle"]) {
        attr.barStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"translucent"]) {
        attr.translucent = [value boolValue];
    }else if([key isEqualToString:@"tintColor"]) {
        attr.tintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"barTintColor"]) {
        attr.barTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"backgroundImage"]) {
        attr.backgroundImage = value;
    }else if([key isEqualToString:@"shadowImage"]) {
        attr.shadowImage = value;
    }
}

- (NSString *)classTypeIcon {
    return @"vd_toolbar";
}

@end
