//
//  ADHAttribute.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/20.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHAttribute.h"
#import "ADHViewDebugUtil.h"
#import "AppContext.h"
#import "ADHViewNode.h"

@implementation ADHPopupItem

+ (ADHPopupItem *)itemWithTitle: (NSString *)title value: (ADH_INT)value {
    ADHPopupItem *item = [[ADHPopupItem alloc] init];
    item.title = title;
    item.value = value;
    return item;
}

@end

@implementation ADHAttrItem

+ (ADHAttrItem *)itemWithKey: (NSString *)key name: (NSString *)name type: (ADHAttrType)type {
    ADHAttrItem *item = [[ADHAttrItem alloc] init];
    item.key = key;
    item.name = name;
    item.type = type;
    return item;
}

@end

@implementation ADHAttribute

+ (instancetype)attribute {
    ADHAttribute *instance = [[self alloc] init];
    return instance;
}

- (ADHAttrItem *)addAttrItem: (NSString *)key name: (NSString *)name type: (ADHAttrType)type {
    ADHAttrItem *item = [ADHAttrItem itemWithKey:key name:name type:type];
    item.attribute = self;
    return item;
}

- (ADHAttrItem *)addAttrItem: (NSString *)key subKey: (NSString *)subKey name: (NSString *)name type: (ADHAttrType)type {
    ADHAttrItem *item = [self addAttrItem:key name:name type:type];
    item.subKey = subKey;
    return item;
}

- (void)setPropertyWithView: (id)view {
    
}

- (NSDictionary *)dicPresentation {
    ADHAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"class"] = adhvf_safestringfy(attr.className);
    data[@"attrClass"] = NSStringFromClass([self class]);
    NSDictionary *propertyData = [self getPropertyData];
    if([propertyData isKindOfClass:[NSDictionary class]]) {
        [data addEntriesFromDictionary:propertyData];
    }
    return data;
}

- (NSDictionary *)getPropertyData {
    return nil;
}

+ (ADHAttribute *)attributeWithData: (NSDictionary *)data {
    NSString *attrClassName = data[@"attrClass"];
    Class clazz = NSClassFromString(attrClassName);
    ADHAttribute *attr = [[clazz alloc] init];
    //common
    attr.className = adhvf_safestringfy(data[@"class"]);
    [attr setPropertyWithData:data];
    return attr;
}

//subclass override
- (void)setPropertyWithData: (NSDictionary *)data {
    
}

- (NSArray<ADHAttrItem *> *)itemList {
    return @[];
}

- (id)getAttrValue: (ADHAttrItem *)item {
    return nil;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    
}

- (void)updateStateValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info {
    
}

//向App设置属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeSetValueRequest: (ADHAttrItem *)item {
    return nil;
}

//从App获取属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeGetValueRequest: (ADHAttrItem *)item {
    return nil;
}

//set value
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    return value;
}

+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    return nil;
}

- (ADHAttrItemAffect)getAffectWithItem: (ADHAttrItem *)item {
    ADHAttrItemAffect value = ADHAttrItemAffectDefault;
    switch (item.type) {
        case ADHAttrTypeEditText:
        case ADHAttrTypeText:
            value = ADHAttrItemAffectHeight;
            break;
        case ADHAttrTypePopup:
        case ADHAttrTypeWebNavi:
            value = ADHAttrItemAffectLarge;
        default:
            break;
    }
    return value;
}

#pragma mark -----------------   extra   ----------------

- (NSString *)classTypeIcon {
    return @"vd_view";
}

#pragma mark -----------------   util   ----------------

- (BOOL)isVersionEqualOrGreaterThan: (NSInteger)ver  {
    return [self isVersionEqualOrGreaterThan:ver minVersion:0];
}

- (BOOL)isVersionEqualOrGreaterThan: (NSInteger)majorVer minVersion: (NSInteger)minVer {
    BOOL ret = NO;
    if (@available(macOS 10.12, *)) {
        AppContext *context = self.appContext;
        NSInteger appMajorVer = [context.app majorVersion];
        NSInteger appMinVer = [context.app minorVersion];
        if(appMajorVer > majorVer) {
            ret = YES;
        }else if(appMajorVer == majorVer && appMinVer >= minVer) {
            ret = YES;
        }
    }
    return ret;
}

@end

@implementation ADHViewAttribute

- (NSDictionary *)getPropertyData {
    ADHViewAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"frame"] = [ADHViewDebugUtil stringWithAdhFrame:attr.frame];
    data[@"frameInWindow"] = [ADHViewDebugUtil stringWithAdhFrame:attr.frameInWindow];
    data[@"color"] = [ADHViewDebugUtil stringWithAdhColor:attr.backgroundColor];
    data[@"alpha"] = [NSNumber numberWithFloat:attr.alpha];
    data[@"tag"] = [NSString stringWithFormat:@"%lld",attr.tag];
    data[@"contentMode"] = [NSString stringWithFormat:@"%lld",attr.contentMode];
    data[@"tintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.tintColor];
    data[@"userInteractionEnabled"] = [NSNumber numberWithBool:attr.userInteractionEnabled];
    data[@"opaque"] = [NSNumber numberWithBool:attr.opaque];
    data[@"clipsToBounds"] = [NSNumber numberWithBool:attr.clipsToBounds];
    data[@"cornerRadius"] = [NSNumber numberWithFloat:attr.cornerRadius];
    data[@"autoresizingMask"] = [NSString stringWithFormat:@"%lld",attr.autoresizingMask];
    if(attr.gestureRecognizers) {
        data[@"gestureRecognizers"] = attr.gestureRecognizers;
    }
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHViewAttribute *attr = self;
    attr.frame = [ADHViewDebugUtil frameWithString:data[@"frame"]];
    attr.frameInWindow = [ADHViewDebugUtil frameWithString:data[@"frameInWindow"]];
    attr.backgroundColor = [ADHViewDebugUtil colorWithString:data[@"color"]];
    attr.alpha = [data[@"alpha"] floatValue];
    attr.tag = [data[@"tag"] longLongValue];
    attr.contentMode = [data[@"contentMode"] longLongValue];
    attr.tintColor = [ADHViewDebugUtil colorWithString:data[@"tintColor"]];
    attr.userInteractionEnabled = [data[@"userInteractionEnabled"] boolValue];
    attr.opaque = [data[@"opaque"] boolValue];
    attr.clipsToBounds = [data[@"clipsToBounds"] boolValue];
    attr.cornerRadius = [data[@"cornerRadius"] floatValue];
    attr.autoresizingMask = [data[@"autoresizingMask"] longLongValue];
    //mutable 方便后期修改
    NSArray *list = data[@"gestureRecognizers"];
    NSMutableArray *gestureList = [NSMutableArray array];
    for (NSDictionary *data in list) {
        NSMutableDictionary *gestureData = [data mutableCopy];
        [gestureList addObject:gestureData];
    }
    attr.gestureRecognizers = gestureList;
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"frame",@"Frame",ADHAttrTypeFrame)];
    [list addObject:ADH_ATTR(@"backgroundColor",@"Color", ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"alpha",@"Alpha",ADHAttrTypeValue)];
    [list addObject:ADH_ATTR(@"tag",@"Tag", ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"tintColor",@"Tint Color", ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"contentMode",@"Content Mode", ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"userInteractionEnabled",@"Interaction Enable", ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"opaque",@"Opaque", ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"clipsToBounds",@"ClipsToBounds", ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"cornerRadius",@"Corner Radius",ADHAttrTypeValue)];
    [list addObject:ADH_ATTR(@"autoresizingMask",@"Autoresizing", ADHAttrTypeAutoresizing)];
    for (NSInteger i=0; i<self.gestureRecognizers.count; i++) {
        NSString *name = nil;
        if(i == 0) {
            name = @"Gesture";
        }
        NSString *indexKey = [NSString stringWithFormat:@"%zd",i];
        [list addObject:ADH_ATTR_SUB(@"gestureRecognizers",indexKey,name,ADHAttrTypeGesture)];
    }
    [list addObject:ADH_ATTR(@"hierarchy",@"Hierarchy", ADHAttrTypeText)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    if([key isEqualToString:@"frame"]) {
        NSString *value = [ADHViewDebugUtil stringWithAdhFrame:self.frame];
        attrValue = value;
    }else if([key isEqualToString:@"backgroundColor"]) {
        NSString *value = [ADHViewDebugUtil stringWithAdhColor:self.backgroundColor];
        attrValue = value;
    }else if([key isEqualToString:@"alpha"]) {
        attrValue = @{
                      @"value" :  [NSNumber numberWithFloat:self.alpha],
                      @"step" : [NSNumber numberWithFloat:0.1],
                      @"min" : @(0),
                      @"max" : @(1),
                      };
    }else if([key isEqualToString:@"tag"]) {
        attrValue = [NSString stringWithFormat:@"%lld",self.tag];
    }else if([key isEqualToString:@"tintColor"]) {
        NSString *value = [ADHViewDebugUtil stringWithAdhColor:self.tintColor];
        attrValue = value;
    }else if([key isEqualToString:@"contentMode"]) {
        /*
         UIViewContentModeScaleToFill = 0,
         UIViewContentModeScaleAspectFit,
         UIViewContentModeScaleAspectFill,
         UIViewContentModeRedraw,
         UIViewContentModeCenter,
         UIViewContentModeTop,
         UIViewContentModeBottom,
         UIViewContentModeLeft,
         UIViewContentModeRight,
         UIViewContentModeTopLeft,
         UIViewContentModeTopRight,
         UIViewContentModeBottomLeft,
         UIViewContentModeBottomRight,
         */
        NSArray *list = @[
                          ADH_POPUP(@"ScaleToFill", 0),
                          ADH_POPUP(@"ScaleAspectFit", 1),
                          ADH_POPUP(@"ScaleAspectFill", 2),
                          ADH_POPUP(@"Redraw", 3),
                          ADH_POPUP(@"Center", 4),
                          ADH_POPUP(@"Top", 5),
                          ADH_POPUP(@"Bottom", 6),
                          ADH_POPUP(@"Left", 7),
                          ADH_POPUP(@"Right", 8),
                          ADH_POPUP(@"TopLeft", 9),
                          ADH_POPUP(@"TopRight", 10),
                          ADH_POPUP(@"BottomLeft", 11),
                          ADH_POPUP(@"BottomRight", 12),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:self.contentMode],
                      };
    }else if([key isEqualToString:@"userInteractionEnabled"]) {
        attrValue = [NSNumber numberWithBool:self.userInteractionEnabled];
    }else if([key isEqualToString:@"opaque"]) {
        attrValue = [NSNumber numberWithBool:self.opaque];
    }else if([key isEqualToString:@"clipsToBounds"]) {
        attrValue = [NSNumber numberWithBool:self.clipsToBounds];
    }else if([key isEqualToString:@"cornerRadius"]) {
        CGFloat width = self.frame.width;
        CGFloat height = self.frame.height;
        CGFloat max = (MIN(width, height))/2.0f;
        attrValue = @{
                      @"value" : [NSNumber numberWithFloat:self.cornerRadius],
                      @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                      @"stepper" : @(YES),
                      @"step" : @(1),
                      @"min" : @(0),
                      @"max" : [NSNumber numberWithFloat:max],
                      };
    }else if([key isEqualToString:@"autoresizingMask"]) {
        attrValue = [ADHViewDebugUtil numberWithAdhInt:self.autoresizingMask];
    }else if([key isEqualToString:@"gestureRecognizers"]) {
        NSInteger index = [item.subKey integerValue];
        if(index < self.gestureRecognizers.count) {
            NSDictionary *data = self.gestureRecognizers[index];
            attrValue = data;
        }
    }else if([key isEqualToString:@"hierarchy"]) {
        NSString *text = nil;
        ADHViewNode *node = self.viewNode;
        if(node.classList) {
            text = [node.classList componentsJoinedByString:@"\n"];
        }
        attrValue = text;
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHViewAttribute *attr = self;
    if([key isEqualToString:@"backgroundColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        attr.backgroundColor = color;
    }else if([key isEqualToString:@"frame"]) {
        ADH_FRAME frame = [ADHViewDebugUtil frameWithString:value];
        attr.frame = frame;
    }else if([key isEqualToString:@"tintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        attr.tintColor = color;
    }else if([key isEqualToString:@"alpha"]) {
        attr.alpha = [value floatValue];
    }else if([key isEqualToString:@"contentMode"]) {
        attr.contentMode = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"userInteractionEnabled"]) {
        attr.userInteractionEnabled = [value boolValue];
    }else if([key isEqualToString:@"opaque"]) {
        attr.opaque = [value boolValue];
    }else if([key isEqualToString:@"clipsToBounds"]) {
        attr.clipsToBounds = [value boolValue];
    }else if([key isEqualToString:@"cornerRadius"]) {
        attr.cornerRadius = [value floatValue];
    }else if([key isEqualToString:@"gestureRecognizers"]) {
        NSInteger index = [info[@"gesture-index"] integerValue];
        NSString *gestureKey = info[@"gesture-key"];
        NSString *class = info[@"gesture-class"];
        if(index < attr.gestureRecognizers.count) {
            NSMutableDictionary *data = attr.gestureRecognizers[index];
            [self updateGestureRecognizerAttr:data key:gestureKey value:value class:class];
        }
    }
}

#pragma mark -----------------   gesture recognizer   ----------------

- (NSArray<ADHAttrItem *> *)getGestureRecognizerItemList: (NSInteger)index {
    if(index >= self.gestureRecognizers.count) {
        return nil;
    }
    NSDictionary *data = self.gestureRecognizers[index];
    NSMutableArray *list = [NSMutableArray array];
    NSString *class = data[@"class"];
    //common
    [list addObject:ADH_ATTR(@"class", @"Class", ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"delegate", @"Delegate", ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"view", @"View", ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"enabled", @"Enabled", ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"state", @"State", ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"cancelsTouchesInView", @"CancelsTouchesInView", ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"delaysTouchesBegan", @"DelaysTouchesBegan", ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"delaysTouchesEnded", @"DelaysTouchesEnded", ADHAttrTypeBoolean)];
    if(ATTR_iOS(9, 2)) {
        [list addObject:ADH_ATTR(@"requiresExclusiveTouchType", @"RequiresExclusiveTouchType", ADHAttrTypeBoolean)];
    }
    [list addObject:ADH_ATTR(@"numberOfTouches", @"NumberOfTouches", ADHAttrTypeText)];
    if([class isEqualToString:@"UITapGestureRecognizer"]) {
        [list addObject:ADH_ATTR(@"numberOfTapsRequired", @"NumberOfTapsRequired", ADHAttrTypeValue)];
        [list addObject:ADH_ATTR(@"numberOfTouchesRequired", @"NumberOfTouchesRequired", ADHAttrTypeValue)];
    }else if([class isEqualToString:@"UILongPressGestureRecognizer"]) {
        [list addObject:ADH_ATTR(@"numberOfTapsRequired", @"NumberOfTapsRequired", ADHAttrTypeValue)];
        [list addObject:ADH_ATTR(@"numberOfTouchesRequired", @"NumberOfTouchesRequired", ADHAttrTypeValue)];
        [list addObject:ADH_ATTR(@"minimumPressDuration", @"MinimumPressDuration", ADHAttrTypeValue)];
        [list addObject:ADH_ATTR(@"allowableMovement", @"AllowableMovement", ADHAttrTypeValue)];
    }else if([class isEqualToString:@"UIPanGestureRecognizer"]) {
        [list addObject:ADH_ATTR(@"minimumNumberOfTouches", @"MinimumNumberOfTouches", ADHAttrTypeValue)];
        [list addObject:ADH_ATTR(@"maximumNumberOfTouches", @"MaximumNumberOfTouches", ADHAttrTypeValue)];
    }else if([class isEqualToString:@"UISwipeGestureRecognizer"]) {
        [list addObject:ADH_ATTR(@"numberOfTouchesRequired", @"NumberOfTouchesRequired", ADHAttrTypeValue)];
        [list addObject:ADH_ATTR(@"direction", @"Direction", ADHAttrTypeSelect)];
    }else if([class isEqualToString:@"UIPinchGestureRecognizer"]) {
        [list addObject:ADH_ATTR(@"scale", @"Scale", ADHAttrTypeValue)];
        [list addObject:ADH_ATTR(@"velocity", @"Velocity", ADHAttrTypeText)];
    }else if([class isEqualToString:@"UIRotationGestureRecognizer"]) {
        [list addObject:ADH_ATTR(@"rotation", @"Rotation", ADHAttrTypeValue)];
        [list addObject:ADH_ATTR(@"velocity", @"Velocity", ADHAttrTypeText)];
    }else if([class isEqualToString:@"UIScreenEdgePanGestureRecognizer"]) {
        [list addObject:ADH_ATTR(@"edges", @"Edges", ADHAttrTypeText)];
        [list addObject:ADH_ATTR(@"minimumNumberOfTouches", @"MinimumNumberOfTouches", ADHAttrTypeValue)];
        [list addObject:ADH_ATTR(@"maximumNumberOfTouches", @"MaximumNumberOfTouches", ADHAttrTypeValue)];
    }
    return list;
}

- (id)getGestureRecognzierAttrValue: (ADHAttrItem *)item index: (NSInteger)index {
    if(index >= self.gestureRecognizers.count) {
        return nil;
    }
    NSDictionary *data = self.gestureRecognizers[index];
    id attrValue = nil;
    NSString *key = item.key;
    NSString *class = data[@"class"];
    if([class isEqualToString:@"UITapGestureRecognizer"]) {
        if([key isEqualToString:@"numberOfTapsRequired"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(1),
                          @"value" : [NSNumber numberWithInteger:[data[@"numberOfTapsRequired"] integerValue]],
                          };
        }else if([key isEqualToString:@"numberOfTouchesRequired"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(1),
                          @"value" : [NSNumber numberWithInteger:[data[@"numberOfTouchesRequired"] integerValue]],
                          };
        }
    }else if([class isEqualToString:@"UILongPressGestureRecognizer"]) {
        if([key isEqualToString:@"numberOfTapsRequired"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(0),
                          @"value" : [NSNumber numberWithInteger:[data[@"numberOfTapsRequired"] integerValue]],
                          };
        }else if([key isEqualToString:@"numberOfTouchesRequired"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(1),
                          @"value" : [NSNumber numberWithInteger:[data[@"numberOfTouchesRequired"] integerValue]],
                          };
        }else if([key isEqualToString:@"minimumPressDuration"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                          @"stepper" : @(YES),
                          @"step" : @(0.1),
                          @"min" : @(0),
                          @"value" : [NSNumber numberWithFloat:[data[@"minimumPressDuration"] floatValue]],
                          };
        }else if([key isEqualToString:@"allowableMovement"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(0),
                          @"value" : [NSNumber numberWithFloat:[data[@"allowableMovement"] floatValue]],
                          };
        }
    }else if([class isEqualToString:@"UIPanGestureRecognizer"]) {
        if([key isEqualToString:@"minimumNumberOfTouches"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(1),
                          @"value" : [NSNumber numberWithInteger:[data[@"minimumNumberOfTouches"] integerValue]],
                          };
        }else if([key isEqualToString:@"maximumNumberOfTouches"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(1),
                          @"value" : [NSNumber numberWithInteger:[data[@"maximumNumberOfTouches"] integerValue]],
                          };
        }
    }else if([class isEqualToString:@"UISwipeGestureRecognizer"]) {
        if([key isEqualToString:@"numberOfTouchesRequired"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(1),
                          @"value" : [NSNumber numberWithInteger:[data[@"numberOfTouchesRequired"] integerValue]],
                          };
        }else if([key isEqualToString:@"direction"]) {
            /*
            UISwipeGestureRecognizerDirectionRight = 1 << 0,
            UISwipeGestureRecognizerDirectionLeft  = 1 << 1,
            UISwipeGestureRecognizerDirectionUp    = 1 << 2,
            UISwipeGestureRecognizerDirectionDown  = 1 << 3
            */
            NSArray *list = @[
                              ADH_POPUP(@"Right", 1<<0),
                              ADH_POPUP(@"Left", 1<<1),
                              ADH_POPUP(@"Up", 1<<2),
                              ADH_POPUP(@"Down", 1<<3),
                              ];
            attrValue = @{
                          @"list" : list,
                          @"value" : [NSNumber numberWithInteger:[data[@"direction"] integerValue]],
                          };
        }
    }else if([class isEqualToString:@"UIPinchGestureRecognizer"]) {
        if([key isEqualToString:@"scale"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                          @"stepper" : @(YES),
                          @"step" : @(0.1),
                          @"min" : @(0),
                          @"value" : [NSNumber numberWithFloat:[data[@"scale"] floatValue]],
                          };
        }else if([key isEqualToString:@"velocity"]) {
            attrValue = [NSString stringWithFormat:@"%.1f scale/s",[data[@"velocity"] floatValue]];
        }
    }else if([class isEqualToString:@"UIRotationGestureRecognizer"]) {
        if([key isEqualToString:@"rotation"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(0),
                          @"value" : [NSNumber numberWithFloat:[data[@"rotation"] floatValue]],
                          };
        }else if([key isEqualToString:@"velocity"]) {
            attrValue = [NSString stringWithFormat:@"%.1f radians/s",[data[@"velocity"] floatValue]];
        }
    }else if([class isEqualToString:@"UIScreenEdgePanGestureRecognizer"]) {
        if([key isEqualToString:@"edges"]) {
            attrValue = data[@"edges"];
        }else if([key isEqualToString:@"minimumNumberOfTouches"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(1),
                          @"value" : [NSNumber numberWithInteger:[data[@"minimumNumberOfTouches"] integerValue]],
                          };
        }else if([key isEqualToString:@"maximumNumberOfTouches"]) {
            attrValue = @{
                          @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                          @"stepper" : @(YES),
                          @"step" : @(1),
                          @"min" : @(1),
                          @"value" : [NSNumber numberWithInteger:[data[@"maximumNumberOfTouches"] integerValue]],
                          };
        }
    }
    if(!attrValue) {
        if([key isEqualToString:@"class"]) {
            attrValue = class;
        }else if([key isEqualToString:@"delegate"]) {
            attrValue = data[@"delegate"];
        }else if([key isEqualToString:@"view"]) {
            attrValue = data[@"view"];
        }else if([key isEqualToString:@"enabled"]) {
            attrValue = data[@"enabled"];
        }else if([key isEqualToString:@"state"]) {
            /*
            UIGestureRecognizerStatePossible = 0,
            UIGestureRecognizerStateBegan,
            UIGestureRecognizerStateChanged,
            UIGestureRecognizerStateEnded,
            UIGestureRecognizerStateCancelled,
            UIGestureRecognizerStateFailed,
            UIGestureRecognizerStateRecognized = UIGestureRecognizerStateEnded
            */
            NSString *text = nil;
            NSInteger state = [data[@"state"] integerValue];
            switch (state) {
                case 0:
                    text = @"Possible";
                    break;
                case 1:
                    text = @"Began";
                    break;
                case 2:
                    text = @"Changed";
                    break;
                case 3:
                    text = @"Ended/Recognized";
                    break;
                case 4:
                    text = @"Cancelled";
                    break;
                case 5:
                    text = @"Failed";
                    break;
                default:
                    break;
            }
            attrValue = text;
        }else if([key isEqualToString:@"cancelsTouchesInView"]) {
            attrValue = data[@"cancelsTouchesInView"];
        }else if([key isEqualToString:@"delaysTouchesBegan"]) {
            attrValue = data[@"delaysTouchesBegan"];
        }else if([key isEqualToString:@"delaysTouchesEnded"]) {
            attrValue = data[@"delaysTouchesEnded"];
        }else if([key isEqualToString:@"requiresExclusiveTouchType"]) {
            attrValue = data[@"requiresExclusiveTouchType"];
        }else if([key isEqualToString:@"numberOfTouches"]) {
            attrValue = [NSString stringWithFormat:@"%@",data[@"numberOfTouches"]];
        }
    }
    return attrValue;
}

- (void)updateGestureRecognizerAttr: (NSMutableDictionary *)data key: (NSString *)key value: (id)value class: (NSString *)class {
    if(key && value) {
        data[key] = value;
    }
}

- (NSString *)classTypeIcon {
    return @"vd_view";
}

@end

@implementation ADHLabelAttribute

- (NSDictionary *)getPropertyData {
    ADHLabelAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if(attr.text) {
        data[@"text"] = adhvf_safestringfy(attr.text);
    }
    data[@"textColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.textColor];
    data[@"font"] = adhvf_safestringfy([attr.font stringValue]);
    data[@"alignment"] = [ADHViewDebugUtil numberWithAdhInt:attr.alignment];
    data[@"numberOfLines"] = [ADHViewDebugUtil numberWithAdhInt:attr.numberOfLines];
    data[@"linebreakMode"] = [ADHViewDebugUtil numberWithAdhInt:attr.linebreakMode];
    data[@"adjustsFontSizeToFitWidth"] = [NSNumber numberWithBool:attr.adjustsFontSizeToFitWidth];
    data[@"minimumScaleFactor"] = [NSNumber numberWithFloat:attr.minimumScaleFactor];
    data[@"preferredMaxLayoutWidth"] = [NSNumber numberWithFloat:attr.preferredMaxLayoutWidth];
    data[@"baselineAdjustment"] = [ADHViewDebugUtil numberWithAdhInt:attr.baselineAdjustment];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHLabelAttribute *attr = self;
    attr.text = data[@"text"];
    attr.textColor = [ADHViewDebugUtil colorWithString:data[@"textColor"]];
    attr.font = [ADHFont fontWithString:data[@"font"]];
    attr.alignment = [data[@"alignment"] longLongValue];
    attr.numberOfLines = [ADHViewDebugUtil adhIntWithValue:data[@"numberOfLines"]];
    attr.linebreakMode = [ADHViewDebugUtil adhIntWithValue:data[@"linebreakMode"]];
    attr.adjustsFontSizeToFitWidth = [data[@"adjustsFontSizeToFitWidth"] boolValue];
    attr.minimumScaleFactor = [data[@"minimumScaleFactor"] floatValue];
    attr.preferredMaxLayoutWidth = [data[@"preferredMaxLayoutWidth"] floatValue];
    attr.baselineAdjustment = [ADHViewDebugUtil adhIntWithValue:data[@"baselineAdjustment"]];
                          
}

- (NSArray<ADHAttrItem *> *)itemList {
    return @[
             ADH_ATTR(@"text",@"Text", ADHAttrTypeEditText),
             ADH_ATTR(@"textColor",@"Text Color", ADHAttrTypeColor),
             ADH_ATTR(@"font",@"Font", ADHAttrTypeFont),
             ADH_ATTR(@"alignment",@"Alignment", ADHAttrTypeSelect),
             ADH_ATTR(@"numberOfLines",@"NumberOfLines", ADHAttrTypeValue),
             ADH_ATTR(@"linebreakMode",@"LinebreakMode", ADHAttrTypeSelect),
             ADH_ATTR(@"adjustsFontSizeToFitWidth",@"AdjustsFontSizeToFitWidth", ADHAttrTypeBoolean),
             ADH_ATTR(@"minimumScaleFactor",@"MinimumScaleFactor", ADHAttrTypeValue),
             ADH_ATTR(@"preferredMaxLayoutWidth",@"PreferredMaxLayoutWidth", ADHAttrTypeValue),
             ADH_ATTR(@"baselineAdjustment",@"BaselineAdjustment", ADHAttrTypeSelect),
             ];
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    if([key isEqualToString:@"text"]) {
        attrValue = self.text;
    }else if([key isEqualToString:@"textColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:self.textColor];
    }else if([key isEqualToString:@"font"]) {
        attrValue = self.font;
    }else if([key isEqualToString:@"alignment"]) {
        NSArray *list = [ADHViewDebugUtil textAlignmentItemList];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:self.alignment],
                      };
    }else if([key isEqualToString:@"numberOfLines"]) {
        attrValue = @{
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:self.numberOfLines],
                      @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatInt],
                      @"stepper" : @(YES),
                      @"step" : @(1),
                      @"min" : @(0),
                      };
    }else if([key isEqualToString:@"linebreakMode"]) {
        /*
        NSLineBreakByWordWrapping = 0,
        NSLineBreakByCharWrapping,
        NSLineBreakByClipping,
        NSLineBreakByTruncatingHead,
        NSLineBreakByTruncatingTail,
        NSLineBreakByTruncatingMiddle
        */
        NSArray *list = @[
                          ADH_POPUP(@"WordWrapping", 0),
                          ADH_POPUP(@"CharWrapping", 1),
                          ADH_POPUP(@"Clipping", 2),
                          ADH_POPUP(@"TruncatingHead", 3),
                          ADH_POPUP(@"TruncatingTail", 4),
                          ADH_POPUP(@"TruncatingMiddle", 5),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:self.linebreakMode],
                      };
    }else if([key isEqualToString:@"adjustsFontSizeToFitWidth"]) {
        attrValue = [NSNumber numberWithBool:self.adjustsFontSizeToFitWidth];
    }else if([key isEqualToString:@"minimumScaleFactor"]) {
        attrValue = @{
                      @"value" : [NSNumber numberWithFloat:self.minimumScaleFactor],
                      @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                      @"stepper" : @(YES),
                      @"step" : @(0.1),
                      @"min" : @(0.1),
                      @"max" : @(1.0),
                      };
    }else if([key isEqualToString:@"preferredMaxLayoutWidth"]) {
        attrValue =  @{
                       @"value" : [NSNumber numberWithFloat:self.preferredMaxLayoutWidth],
                       @"format" : [NSNumber numberWithInteger:ADHAttrValueFormatFloat],
                       @"stepper" : @(YES),
                       @"step" : @(1),
                       @"min" : @(0),
                    };
    }else if([key isEqualToString:@"baselineAdjustment"]) {
        NSArray *list = @[
                          ADH_POPUP(@"Baselines", 0),
                          ADH_POPUP(@"Centers", 1),
                          ADH_POPUP(@"None", 2),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:self.baselineAdjustment],
                      };
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHLabelAttribute *attr = self;
    if([key isEqualToString:@"text"]) {
        attr.text = value;
    }else if([key isEqualToString:@"textColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        attr.textColor = color;
    }else if([key isEqualToString:@"alignment"]) {
        attr.alignment = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"numberOfLines"]) {
        attr.numberOfLines = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"linebreakMode"]) {
        attr.linebreakMode = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"adjustsFontSizeToFitWidth"]) {
        attr.adjustsFontSizeToFitWidth = [value boolValue];
    }else if([key isEqualToString:@"minimumScaleFactor"]) {
        attr.minimumScaleFactor = [value floatValue];
    }else if([key isEqualToString:@"preferredMaxLayoutWidth"]) {
        attr.preferredMaxLayoutWidth = [value floatValue];
    }else if([key isEqualToString:@"baselineAdjustment"]) {
        attr.baselineAdjustment = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"font"]) {
        attr.font = [ADHFont fontWithString:value];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_label";
}

@end

@implementation ADHImageViewAttribute

- (NSDictionary *)getPropertyData {
    ADHImageViewAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"highlighted"] = [NSNumber numberWithBool:attr.highlighted];
    data[@"animating"] = [NSNumber numberWithBool:attr.animating];
    data[@"animationDuration"] = [NSNumber numberWithDouble:attr.animationDuration];
    data[@"animationRepeatCount"] = [NSNumber numberWithLongLong:attr.animationRepeatCount];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHImageViewAttribute *attr = self;
    attr.highlighted = [data[@"highlighted"] boolValue];
    attr.animationDuration = [data[@"animationDuration"] doubleValue];
    attr.animationRepeatCount = [data[@"animationRepeatCount"] longLongValue];
    attr.animating = [data[@"animating"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"image",@"Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"highlightedImage",@"Highlighted",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"highlighted",@"Highlighted",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"animating",@"Animating",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"animationDuration",@"Animation Duration",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"animationRepeatCount",@"Repeat Count",ADHAttrTypeText)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    if([key isEqualToString:@"image"]) {
        attrValue = self.image;
    }else if([key isEqualToString:@"highlightedImage"]) {
        attrValue = self.highlightedImage;
    }else if([key isEqualToString:@"animating"]) {
        attrValue = [NSNumber numberWithBool:self.animating];
    }else if([key isEqualToString:@"highlighted"]) {
        attrValue = [NSNumber numberWithBool:self.highlighted];
    }else if([key isEqualToString:@"animationDuration"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",self.animationDuration];
    }else if([key isEqualToString:@"animationRepeatCount"]) {
        attrValue = [NSString stringWithFormat:@"%lld",self.animationRepeatCount];
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHImageViewAttribute *attr = self;
    if([key isEqualToString:@"image"]) {
        attr.imageAnimated = [info[@"imageAnimated"] boolValue];
        attr.image = value;
    }else if([key isEqualToString:@"highlightedImage"]) {
        attr.highlightedImageAnimated = [info[@"highlightedImage"] boolValue];
        attr.highlightedImage = value;
    }else if([key isEqualToString:@"highlighted"]) {
        attr.highlighted = [value boolValue];
    }else if([key isEqualToString:@"animating"]) {
        attr.animating = [value boolValue];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_imageview";
}

@end

@implementation ADHControlAttribute

- (NSDictionary *)getPropertyData {
    ADHControlAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"enabled"] = [NSNumber numberWithBool:attr.enabled];
    data[@"selected"] = [NSNumber numberWithBool:attr.selected];
    data[@"highlighted"] = [NSNumber numberWithBool:attr.highlighted];
    data[@"horizontalAlignment"] = [ADHViewDebugUtil numberWithAdhInt:attr.horizontalAlignment];
    data[@"verticalAlignment"] = [ADHViewDebugUtil numberWithAdhInt:attr.verticalAlignment];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHControlAttribute *attr = self;
    attr.enabled = [data[@"enabled"] boolValue];
    attr.selected = [data[@"selected"] boolValue];
    attr.highlighted = [data[@"highlighted"] boolValue];
    attr.horizontalAlignment = [ADHViewDebugUtil adhIntWithValue:data[@"horizontalAlignment"]];
    attr.verticalAlignment = [ADHViewDebugUtil adhIntWithValue:data[@"verticalAlignment"]];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"enabled",@"Enabled",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"selected",@"Selected",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"highlighted",@"Highlighted",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"horizontalAlignment",@"Horizontal Alignment",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"verticalAlignment",@"Vertical Alignment",ADHAttrTypeSelect)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    if([key isEqualToString:@"enabled"]) {
        attrValue = [NSNumber numberWithBool:self.enabled];
    }else if([key isEqualToString:@"selected"]) {
        attrValue = [NSNumber numberWithBool:self.selected];
    }else if([key isEqualToString:@"highlighted"]) {
        attrValue = [NSNumber numberWithBool:self.highlighted];
    }else if([key isEqualToString:@"horizontalAlignment"]) {
        /*
        UIControlContentHorizontalAlignmentCenter = 0,
        UIControlContentHorizontalAlignmentLeft   = 1,
        UIControlContentHorizontalAlignmentRight  = 2,
        UIControlContentHorizontalAlignmentFill   = 3,
        UIControlContentHorizontalAlignmentLeading  API_AVAILABLE(ios(11.0), tvos(11.0)) = 4,
        UIControlContentHorizontalAlignmentTrailing API_AVAILABLE(ios(11.0), tvos(11.0)) = 5,
         */
        NSArray *list = @[
                          ADH_POPUP(@"Center", 0),
                          ADH_POPUP(@"Left", 1),
                          ADH_POPUP(@"Right", 2),
                          ADH_POPUP(@"Fill", 3),
                          ADH_POPUP(@"Leading", 4),
                          ADH_POPUP(@"Trailing", 5),
                          ];
        return @{
                 @"list" : list,
                 @"value" : [ADHViewDebugUtil numberWithAdhInt:self.horizontalAlignment],
                 };
    }else if([key isEqualToString:@"verticalAlignment"]) {
        /*
        UIControlContentVerticalAlignmentCenter  = 0,
        UIControlContentVerticalAlignmentTop     = 1,
        UIControlContentVerticalAlignmentBottom  = 2,
        UIControlContentVerticalAlignmentFill    = 3,
        */
        NSArray *list = @[
                          ADH_POPUP(@"Center", 0),
                          ADH_POPUP(@"Top", 1),
                          ADH_POPUP(@"Bottom", 2),
                          ADH_POPUP(@"Fill", 3),
                          ];
        return @{
                 @"list" : list,
                 @"value" : [ADHViewDebugUtil numberWithAdhInt:self.verticalAlignment],
                 };
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHControlAttribute *attr = self;
    if([key isEqualToString:@"enabled"]) {
        attr.enabled = [value boolValue];
    }else if([key isEqualToString:@"selected"]) {
        attr.selected = [value boolValue];
    }else if([key isEqualToString:@"highlighted"]) {
        attr.highlighted = [value boolValue];
    }else if([key isEqualToString:@"horizontalAlignment"]){
        attr.horizontalAlignment = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"verticalAlignment"]){
        attr.verticalAlignment = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

@end

@implementation ADHButtonAttribute

- (NSDictionary *)getPropertyData {
    ADHButtonAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"state"] = [ADHViewDebugUtil numberWithAdhInt:attr.state];
    data[@"contentEdgeInsets"] = [ADHViewDebugUtil stringWithAdhInsets:attr.contentEdgeInsets];
    data[@"titleEdgeInsets"] = [ADHViewDebugUtil stringWithAdhInsets:attr.titleEdgeInsets];
    data[@"imageEdgeInsets"] = [ADHViewDebugUtil stringWithAdhInsets:attr.imageEdgeInsets];
    data[@"buttonType"] = [ADHViewDebugUtil numberWithAdhInt:attr.buttonType];
    data[@"stateValues"] = attr.stateValues;
    data[@"reversesTitleShadowWhenHighlighted"] = [NSNumber numberWithBool:attr.reversesTitleShadowWhenHighlighted];
    data[@"adjustsImageWhenHighlighted"] = [NSNumber numberWithBool:attr.adjustsImageWhenHighlighted];
    data[@"adjustsImageWhenDisabled"] = [NSNumber numberWithBool:attr.adjustsImageWhenDisabled];
    data[@"showsTouchWhenHighlighted"] = [NSNumber numberWithBool:attr.showsTouchWhenHighlighted];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHButtonAttribute *attr = self;
    attr.state = [ADHViewDebugUtil adhIntWithValue:data[@"state"]];
    attr.contentEdgeInsets = [ADHViewDebugUtil insetsWithString:data[@"contentEdgeInsets"]];
    attr.titleEdgeInsets = [ADHViewDebugUtil insetsWithString:data[@"titleEdgeInsets"]];
    attr.imageEdgeInsets = [ADHViewDebugUtil insetsWithString:data[@"imageEdgeInsets"]];
    attr.buttonType = [ADHViewDebugUtil adhIntWithValue:data[@"buttonType"]];
    NSDictionary *values = data[@"stateValues"];
    //mutable方便后面修改
    NSMutableDictionary *stateValues = [NSMutableDictionary dictionary];
    [values enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *itemData, BOOL * _Nonnull stop) {
        NSMutableDictionary *mutableData = [itemData mutableCopy];
        stateValues[key] = mutableData;
    }];
    attr.stateValues = stateValues;
    attr.reversesTitleShadowWhenHighlighted = [data[@"reversesTitleShadowWhenHighlighted"] boolValue];
    attr.adjustsImageWhenHighlighted = [data[@"adjustsImageWhenHighlighted"] boolValue];
    attr.adjustsImageWhenDisabled = [data[@"adjustsImageWhenDisabled"] boolValue];
    attr.showsTouchWhenHighlighted = [data[@"showsTouchWhenHighlighted"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"state",@"State",ADHAttrTypePopup)];
    [list addObject:ADH_ATTR(@"title",@"Title",ADHAttrTypeEditText)];
    [list addObject:ADH_ATTR(@"titleColor",@"Title Color",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"image",@"Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"backgroundImage",@"Background",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"buttonType",@"Type",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"contentEdgeInsets",@"Content Insets",ADHAttrTypeInsets)];
    [list addObject:ADH_ATTR(@"titleEdgeInsets",@"Title Insets",ADHAttrTypeInsets)];
    [list addObject:ADH_ATTR(@"imageEdgeInsets",@"Image Insets",ADHAttrTypeInsets)];
    [list addObject:ADH_ATTR(@"reversesTitleShadowWhenHighlighted",@"Reverses Title Shadow When Highlighted",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"adjustsImageWhenHighlighted",@"Adjusts Image When Highlighted",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"adjustsImageWhenDisabled",@"Adjusts Image When Disabled",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"showsTouchWhenHighlighted",@"Shows Touch When Highlighted",ADHAttrTypeBoolean)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    if([key isEqualToString:@"state"]) {
        NSArray *list = @[
                            ADH_POPUP(@"Normal",0),
                            ADH_POPUP(@"Highlighted",1 << 0),
                            ADH_POPUP(@"Disabled",1 << 1),
                            ADH_POPUP(@"Selected",1 << 2),
                            ];
        NSDictionary *data = @{
                                @"list" : list,
                                @"value" : [ADHViewDebugUtil numberWithAdhInt:self.state],
                                };
        attrValue = data;
    }else if([key isEqualToString:@"title"]) {
        NSString *title = [self getItemValueWithState:self.state key:@"title"];
        attrValue = title;
    }else if([key isEqualToString:@"titleColor"]) {
        NSString *colorValue = [self getItemValueWithState:self.state key:@"titleColor"];
        attrValue = colorValue;
    }else if([key isEqualToString:@"image"]) {
        NSData *image = [self getItemValueWithState:self.state key:@"image"];
        attrValue = image;
    }else if([key isEqualToString:@"backgroundImage"]) {
        NSData *image = [self getItemValueWithState:self.state key:@"backgroundImage"];
        attrValue = image;
    }else if([key isEqualToString:@"contentEdgeInsets"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhInsets:self.contentEdgeInsets];
    }else if([key isEqualToString:@"titleEdgeInsets"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhInsets:self.titleEdgeInsets];
    }else if([key isEqualToString:@"imageEdgeInsets"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhInsets:self.imageEdgeInsets];
    }else if([key isEqualToString:@"buttonType"]) {
        /*
         UIButtonTypeCustom = 0,                         // no button type
         UIButtonTypeSystem  // standard system button
         UIButtonTypeDetailDisclosure,
         UIButtonTypeInfoLight,
         UIButtonTypeInfoDark,
         UIButtonTypeContactAdd,
         */
        NSString *title = nil;
        switch (self.buttonType) {
            case 0:
                title = @"Custom";
                break;
            case 1:
                title = @"System";
                break;
            case 2:
                title = @"DetailDisclosure";
                break;
            case 3:
                title = @"InfoLight";
                break;
            case 4:
                title = @"InfoDark";
                break;
            case 5:
                title = @"ContactAdd";
                break;
            default:
                break;
        }
        attrValue = title;
    }else if([key isEqualToString:@"reversesTitleShadowWhenHighlighted"]) {
        attrValue = [NSNumber numberWithBool:self.reversesTitleShadowWhenHighlighted];
    }else if([key isEqualToString:@"adjustsImageWhenHighlighted"]) {
        attrValue = [NSNumber numberWithBool:self.adjustsImageWhenHighlighted];
    }else if([key isEqualToString:@"adjustsImageWhenDisabled"]) {
        attrValue = [NSNumber numberWithBool:self.adjustsImageWhenDisabled];
    }else if([key isEqualToString:@"showsTouchWhenHighlighted"]) {
        attrValue = [NSNumber numberWithBool:self.showsTouchWhenHighlighted];
    }
    return attrValue;
}

- (id)getItemValueWithState: (ADH_INT)state key: (NSString *)key {
    NSString *stateKey = [ADHViewDebugUtil stringWithAdhInt:state];
    NSDictionary *data = self.stateValues[stateKey];
    return data[key];
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    NSString *stateKey = [ADHViewDebugUtil stringWithAdhInt:self.state];
    NSMutableDictionary *stateData = self.stateValues[stateKey];
    ADHButtonAttribute *attr = self;
    if([key isEqualToString:@"image"]) {
        stateData[@"image"] = value;
    }else if([key isEqualToString:@"backgroundImage"]) {
        stateData[@"backgroundImage"] = value;
    }else if([key isEqualToString:@"titleColor"]) {
        stateData[@"titleColor"] = value;
    }else if([key isEqualToString:@"title"]) {
        stateData[@"title"] = adhvf_safestringfy(value);
    }else if([key isEqualToString:@"reversesTitleShadowWhenHighlighted"]) {
        attr.reversesTitleShadowWhenHighlighted = [value boolValue];
    }else if([key isEqualToString:@"adjustsImageWhenHighlighted"]) {
        attr.adjustsImageWhenHighlighted = [value boolValue];
    }else if([key isEqualToString:@"adjustsImageWhenDisabled"]) {
        attr.adjustsImageWhenDisabled = [value boolValue];
    }else if([key isEqualToString:@"showsTouchWhenHighlighted"]) {
        attr.showsTouchWhenHighlighted = [value boolValue];
    }else if([key isEqualToString:@"contentEdgeInsets"]) {
        ADH_INSETS insets = [ADHViewDebugUtil insetsWithString:value];
        attr.contentEdgeInsets = insets;
    }else if([key isEqualToString:@"titleEdgeInsets"]) {
        ADH_INSETS insets = [ADHViewDebugUtil insetsWithString:value];
        attr.titleEdgeInsets = insets;
    }else if([key isEqualToString:@"imageEdgeInsets"]) {
        ADH_INSETS insets = [ADHViewDebugUtil insetsWithString:value];
        attr.imageEdgeInsets = insets;
    }
}

- (void)updateStateValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info {
    NSString *key = item.key;
    if([key isEqualToString:@"state"]) {
        self.state = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

//从App获取属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeGetValueRequest: (ADHAttrItem *)item {
    return @{
             @"state" : [ADHViewDebugUtil numberWithAdhInt:self.state],
             };
}

//向App设置属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeSetValueRequest: (ADHAttrItem *)item {
    return @{
             @"state" : [ADHViewDebugUtil numberWithAdhInt:self.state],
             };
}

- (NSString *)classTypeIcon {
    return @"vd_button";
}

@end


@implementation ADHTextFieldAttribute

- (NSDictionary *)getPropertyData {
    ADHTextFieldAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"text"] = adhvf_safestringfy(attr.text);
    data[@"placeholder"] = adhvf_safestringfy(attr.placeholder);
    data[@"textColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.textColor];
    data[@"font"] = adhvf_safestringfy([attr.font stringValue]);
    data[@"textAlignment"] = [ADHViewDebugUtil numberWithAdhInt:attr.textAlignment];
    data[@"borderStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.borderStyle];
    data[@"adjustsFontSizeToFitWidth"] = [NSNumber numberWithBool:attr.adjustsFontSizeToFitWidth];
    data[@"minimumFontSize"] = [NSNumber numberWithFloat:attr.minimumFontSize];
    data[@"leftViewMode"] = [ADHViewDebugUtil numberWithAdhInt:attr.leftViewMode];
    data[@"rightViewMode"] = [ADHViewDebugUtil numberWithAdhInt:attr.rightViewMode];
    data[@"clearButtonMode"] = [ADHViewDebugUtil numberWithAdhInt:attr.clearButtonMode];
    data[@"clearsOnBeginEditing"] = [NSNumber numberWithBool:attr.clearsOnBeginEditing];
    data[@"clearsOnInsertion"] = [NSNumber numberWithBool:attr.clearsOnInsertion];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHTextFieldAttribute *attr = self;
    attr.text = adhvf_safestringfy(data[@"text"]);
    attr.placeholder = adhvf_safestringfy(data[@"placeholder"]);
    attr.textColor = [ADHViewDebugUtil colorWithString:data[@"textColor"]];
    attr.font = [ADHFont fontWithString:data[@"font"]];
    attr.textAlignment = [ADHViewDebugUtil adhIntWithValue:data[@"textAlignment"]];
    attr.borderStyle = [ADHViewDebugUtil adhIntWithValue:data[@"borderStyle"]];
    attr.adjustsFontSizeToFitWidth = [data[@"adjustsFontSizeToFitWidth"] boolValue];
    attr.minimumFontSize = [data[@"minimumFontSize"] floatValue];
    attr.leftViewMode = [ADHViewDebugUtil adhIntWithValue:data[@"leftViewMode"]];
    attr.rightViewMode = [ADHViewDebugUtil adhIntWithValue:data[@"rightViewMode"]];
    attr.clearButtonMode = [ADHViewDebugUtil adhIntWithValue:data[@"clearButtonMode"]];
    attr.clearsOnBeginEditing = [data[@"clearsOnBeginEditing"] boolValue];
    attr.clearsOnInsertion = [data[@"clearsOnInsertion"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    return @[
             ADH_ATTR(@"text",@"Text",ADHAttrTypeEditText),
             ADH_ATTR(@"placeholder",@"Placeholder",ADHAttrTypeEditText),
             ADH_ATTR(@"textColor",@"Text Color",ADHAttrTypeColor),
             ADH_ATTR(@"font",@"Font",ADHAttrTypeFont),
             ADH_ATTR(@"textAlignment",@"Text Alignment",ADHAttrTypeSelect),
             ADH_ATTR(@"borderStyle",@"Border Style",ADHAttrTypeSelect),
             ADH_ATTR(@"adjustsFontSizeToFitWidth",@"AdjustsFontSizeToFitWidth",ADHAttrTypeBoolean),
             ADH_ATTR(@"minimumFontSize",@"MinimumFontSize",ADHAttrTypeValue),
             ADH_ATTR(@"background",@"Background",ADHAttrTypeImage),
             ADH_ATTR(@"disabledBackground",@"DisabledBackground",ADHAttrTypeImage),
             ADH_ATTR(@"leftViewMode",@"LeftViewMode",ADHAttrTypeSelect),
             ADH_ATTR(@"rightViewMode",@"RightViewMode",ADHAttrTypeSelect),
             ADH_ATTR(@"clearButtonMode",@"ClearButtonMode",ADHAttrTypeSelect),
             ADH_ATTR(@"clearsOnBeginEditing",@"ClearsOnBeginEditing",ADHAttrTypeBoolean),
             ADH_ATTR(@"clearsOnInsertion",@"ClearsOnInsertion",ADHAttrTypeBoolean),
             ];
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHTextFieldAttribute *attr = self;
    if([key isEqualToString:@"text"]) {
        attrValue = attr.text;
    }else if([key isEqualToString:@"placeholder"]) {
        attrValue = attr.placeholder;
    }else if([key isEqualToString:@"textColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.textColor];
    }else if([key isEqualToString:@"font"]) {
        attrValue = attr.font;
    }else if([key isEqualToString:@"textAlignment"]) {
        attrValue = @{
                      @"list" : [ADHViewDebugUtil textAlignmentItemList],
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.textAlignment],
                      };
    }else if([key isEqualToString:@"borderStyle"]) {
        /*
         UITextBorderStyleNone = 0,
         UITextBorderStyleLine,
         UITextBorderStyleBezel,
         UITextBorderStyleRoundedRect
         */
        NSArray *list = @[
                          ADH_POPUP(@"None", 0),
                          ADH_POPUP(@"Line", 1),
                          ADH_POPUP(@"Bezel", 2),
                          ADH_POPUP(@"RoundedRect", 3),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.borderStyle],
                      };
    }else if([key isEqualToString:@"adjustsFontSizeToFitWidth"]) {
        attrValue = [NSNumber numberWithBool:attr.adjustsFontSizeToFitWidth];
    }else if([key isEqualToString:@"minimumFontSize"]) {
        /**
         * value
         * format : ADHAttrValueFormat
         * stepper : @(YES)
         * step : 0.1
         * min : 0
         * max : 1
         */
        attrValue = @{
                      @"value" : [NSNumber numberWithFloat:attr.minimumFontSize],
                      @"stepper" : @(YES),
                      @"step" : @(1),
                      @"min" : @(0),
                      };
    }else if([key isEqualToString:@"background"]) {
        attrValue = attr.background;
    }else if([key isEqualToString:@"disabledBackground"]) {
        attrValue = attr.disabledBackground;
    }else if([key isEqualToString:@"leftViewMode"]) {
        attrValue = @{
                      @"list" : [self getTextFieldModeList],
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.leftViewMode],
                      };
    }else if([key isEqualToString:@"rightViewMode"]) {
        attrValue = @{
                      @"list" : [self getTextFieldModeList],
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.rightViewMode],
                      };
    }else if([key isEqualToString:@"clearButtonMode"]) {
        attrValue = @{
                      @"list" : [self getTextFieldModeList],
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.clearButtonMode],
                      };
    }else if([key isEqualToString:@"clearsOnBeginEditing"]) {
        attrValue = [NSNumber numberWithBool:attr.clearsOnBeginEditing];
    }else if([key isEqualToString:@"clearsOnInsertion"]) {
        attrValue = [NSNumber numberWithBool:attr.clearsOnInsertion];
    }
    return attrValue;
}

- (NSArray *)getTextFieldModeList {
    /*
     UITextFieldViewModeNever,
     UITextFieldViewModeWhileEditing,
     UITextFieldViewModeUnlessEditing,
     UITextFieldViewModeAlways
     */
    NSArray *list = @[
                      ADH_POPUP(@"Never", 0),
                      ADH_POPUP(@"WhileEditing", 1),
                      ADH_POPUP(@"UnlessEditing", 2),
                      ADH_POPUP(@"Always", 3),
                      ];
    return list;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHTextFieldAttribute *attr = self;
    if([key isEqualToString:@"text"]) {
        attr.text = adhvf_safestringfy(value);
    }else if([key isEqualToString:@"placeholder"]) {
        attr.placeholder = adhvf_safestringfy(value);
    }else if([key isEqualToString:@"textColor"]) {
        attr.textColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"font"]) {
        attr.font = [ADHFont fontWithString:value];
    }else if([key isEqualToString:@"textAlignment"]) {
        attr.textAlignment = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"borderStyle"]) {
        attr.borderStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"adjustsFontSizeToFitWidth"]) {
        attr.adjustsFontSizeToFitWidth = [value boolValue];
    }else if([key isEqualToString:@"minimumFontSize"]) {
        attr.minimumFontSize = [value floatValue];
    }else if([key isEqualToString:@"background"]) {
        attr.background = value;
    }else if([key isEqualToString:@"disabledBackground"]) {
        attr.disabledBackground = value;
    }else if([key isEqualToString:@"leftViewMode"]) {
        attr.leftViewMode = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"rightViewMode"]) {
        attr.rightViewMode = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"clearButtonMode"]) {
        attr.clearButtonMode = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"clearsOnBeginEditing"]) {
        attr.clearsOnBeginEditing = [value boolValue];
    }else if([key isEqualToString:@"clearsOnInsertion"]) {
        attr.clearsOnInsertion = [value boolValue];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_textfield";
}

@end


@implementation ADHTextViewAttribute

- (NSDictionary *)getPropertyData {
    ADHTextViewAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"text"] = adhvf_safestringfy(attr.text);
    data[@"font"] = adhvf_safestringfy([attr.font stringValue]);
    data[@"textColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.textColor];
    data[@"textAlignment"] = [ADHViewDebugUtil numberWithAdhInt:attr.textAlignment];
    data[@"selectedRange"] = [ADHViewDebugUtil stringWithRange:attr.selectedRange];
    data[@"dataDetectorTypes"] = [ADHViewDebugUtil numberWithAdhInt:attr.dataDetectorTypes];
    data[@"editable"] = [NSNumber numberWithBool:attr.editable];
    data[@"selectable"] = [NSNumber numberWithBool:attr.selectable];
    data[@"allowsEditingTextAttributes"] = [NSNumber numberWithBool:attr.allowsEditingTextAttributes];
    data[@"clearsOnInsertion"] = [NSNumber numberWithBool:attr.clearsOnInsertion];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHTextViewAttribute *attr = self;
    attr.text = adhvf_safestringfy(data[@"text"]);
    attr.font = [ADHFont fontWithString:data[@"font"]];
    attr.textColor = [ADHViewDebugUtil colorWithString:data[@"textColor"]];
    attr.textAlignment = [ADHViewDebugUtil adhIntWithValue:data[@"textAlignment"]];
    attr.selectedRange = [ADHViewDebugUtil rangeWithString:data[@"selectedRange"]];
    attr.dataDetectorTypes = [ADHViewDebugUtil adhIntWithValue:data[@"dataDetectorTypes"]];
    attr.editable = [data[@"editable"] boolValue];
    attr.selectable = [data[@"selectable"] boolValue];
    attr.allowsEditingTextAttributes = [data[@"allowsEditingTextAttributes"] boolValue];
    attr.clearsOnInsertion = [data[@"clearsOnInsertion"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    return @[
             ADH_ATTR(@"text",@"Text",ADHAttrTypeEditText),
             ADH_ATTR(@"font",@"Font",ADHAttrTypeFont),
             ADH_ATTR(@"textColor",@"Text Color",ADHAttrTypeColor),
             ADH_ATTR(@"textAlignment",@"Text Alignment",ADHAttrTypeSelect),
             ADH_ATTR(@"selectedRange",@"SelectedRange",ADHAttrTypeText),
             ADH_ATTR(@"dataDetectorTypes",@"DataDetectorTypes",ADHAttrTypeText),
             ADH_ATTR(@"editable",@"Editable",ADHAttrTypeBoolean),
             ADH_ATTR(@"selectable",@"Selectable",ADHAttrTypeBoolean),
             ADH_ATTR(@"allowsEditingTextAttributes",@"AllowsEditingTextAttributes",ADHAttrTypeBoolean),
             ADH_ATTR(@"clearsOnInsertion",@"ClearsOnInsertion",ADHAttrTypeBoolean),
             ];
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHTextViewAttribute *attr = self;
    if([key isEqualToString:@"text"]) {
        attrValue = attr.text;
    }else if([key isEqualToString:@"font"]) {
        attrValue = attr.font;
    }else if([key isEqualToString:@"textColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.textColor];
    }else if([key isEqualToString:@"textAlignment"]) {
        NSArray *list = [ADHViewDebugUtil textAlignmentItemList];
        attrValue = @{
                      @"list": list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.textAlignment],
                      };
    }else if([key isEqualToString:@"selectedRange"]) {
        attrValue = [ADHViewDebugUtil presentStringWithRange:attr.selectedRange];
    }else if([key isEqualToString:@"dataDetectorTypes"]) {
        attrValue = [ADHViewDebugUtil stringWithDataDetectorType:attr.dataDetectorTypes];
    }else if([key isEqualToString:@"editable"]) {
        attrValue = [NSNumber numberWithBool:attr.editable];
    }else if([key isEqualToString:@"selectable"]) {
        attrValue = [NSNumber numberWithBool:attr.selectable];
    }else if([key isEqualToString:@"allowsEditingTextAttributes"]) {
        attrValue = [NSNumber numberWithBool:attr.allowsEditingTextAttributes];
    }else if([key isEqualToString:@"clearsOnInsertion"]) {
        attrValue = [NSNumber numberWithBool:attr.clearsOnInsertion];
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHTextViewAttribute *attr = self;
    if([key isEqualToString:@"text"]) {
        attr.text = adhvf_safestringfy(value);
    }else if([key isEqualToString:@"font"]) {
        attr.font = [ADHFont fontWithString:value];
    }else if([key isEqualToString:@"textColor"]) {
        attr.textColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"textAlignment"]) {
        attr.textAlignment = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"editable"]) {
        attr.editable = [value boolValue];
    }else if([key isEqualToString:@"selectable"]) {
        attr.selectable = [value boolValue];
    }else if([key isEqualToString:@"allowsEditingTextAttributes"]) {
        attr.allowsEditingTextAttributes = [value boolValue];
    }else if([key isEqualToString:@"clearsOnInsertion"]) {
        attr.clearsOnInsertion = [value boolValue];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_textview";
}

@end


@implementation ADHSliderAttribute

- (NSDictionary *)getPropertyData {
    ADHSliderAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"value"] = [NSNumber numberWithFloat:attr.value];
    data[@"minimumValue"] = [NSNumber numberWithFloat:attr.minimumValue];
    data[@"maximumValue"] = [NSNumber numberWithFloat:attr.maximumValue];
    data[@"continuous"] = [NSNumber numberWithBool:attr.continuous];
    data[@"minimumTrackTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.minimumTrackTintColor];
    data[@"maximumTrackTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.maximumTrackTintColor];
    data[@"thumbTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.thumbTintColor];
    data[@"state"] = [ADHViewDebugUtil numberWithAdhInt:attr.state];
    data[@"stateValues"] = attr.stateValues;
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHSliderAttribute *attr = self;
    attr.value = [data[@"value"] floatValue];
    attr.minimumValue = [data[@"minimumValue"] floatValue];
    attr.maximumValue = [data[@"maximumValue"] floatValue];
    attr.continuous = [data[@"continuous"] boolValue];
    attr.minimumTrackTintColor = [ADHViewDebugUtil colorWithString:data[@"minimumTrackTintColor"]];
    attr.maximumTrackTintColor = [ADHViewDebugUtil colorWithString:data[@"maximumTrackTintColor"]];
    attr.thumbTintColor = [ADHViewDebugUtil colorWithString:data[@"thumbTintColor"]];
    NSDictionary *values = data[@"stateValues"];
    //mutable方便后面修改
    NSMutableDictionary *stateValues = [NSMutableDictionary dictionary];
    [values enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *itemData, BOOL * _Nonnull stop) {
        NSMutableDictionary *mutableData = [itemData mutableCopy];
        stateValues[key] = mutableData;
    }];
    attr.stateValues = stateValues;
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"value",@"Value",ADHAttrTypeSlider)];
    [list addObject:ADH_ATTR(@"minimumValue",@"Min",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"maximumValue",@"Max",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"continuous",@"Continuous",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"minimumTrackTintColor",@"MinimumTrackTintColor",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"maximumTrackTintColor",@"MaximumTrackTintColor",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"thumbTintColor",@"ThumbTintColor",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"minimumValueImage",@"MinimumValueImage",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"maximumValueImage",@"MaximumValueImage",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"state",@"State",ADHAttrTypePopup)];
    [list addObject:ADH_ATTR(@"thumbImage",@"ThumbImage",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"minimumTrackImage",@"MinimumTrackImage",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"maximumTrackImage",@"MaximumTrackImage",ADHAttrTypeImage)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHSliderAttribute *attr = self;
    if([key isEqualToString:@"value"]) {
        NSDictionary *data = @{
                               @"min" : [NSNumber numberWithFloat:attr.minimumValue],
                               @"max" : [NSNumber numberWithFloat:attr.maximumValue],
                               @"value" : [NSNumber numberWithFloat:attr.value],
                               };
        attrValue = data;
    }else if([key isEqualToString:@"minimumValue"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.minimumValue];
    }else if([key isEqualToString:@"maximumValue"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.maximumValue];
    }else if([key isEqualToString:@"continuous"]) {
        attrValue = [NSNumber numberWithBool:attr.continuous];
    }else if([key isEqualToString:@"minimumTrackTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.minimumTrackTintColor];
    }else if([key isEqualToString:@"maximumTrackTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.maximumTrackTintColor];
    }else if([key isEqualToString:@"thumbTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.thumbTintColor];
    }else if([key isEqualToString:@"minimumValueImage"]) {
        attrValue = attr.minimumValueImage;
    }else if([key isEqualToString:@"maximumValueImage"]) {
        attrValue = attr.maximumValueImage;
    }else if([key isEqualToString:@"state"]) {
        NSArray *list = @[
                          ADH_POPUP(@"Normal",0),
                          ADH_POPUP(@"Highlighted",1 << 0),
                          ADH_POPUP(@"Disabled",1 << 1),
                          ADH_POPUP(@"Selected",1 << 2),
                          ];
        NSDictionary *data = @{
                               @"list" : list,
                               @"value" : [ADHViewDebugUtil numberWithAdhInt:self.state],
                               };
        attrValue = data;
    }else if([key isEqualToString:@"thumbImage"]) {
        attrValue = [self getItemValueWithState:self.state key:@"thumbImage"];
    }else if([key isEqualToString:@"minimumTrackImage"]) {
        attrValue = [self getItemValueWithState:self.state key:@"minimumTrackImage"];
    }else if([key isEqualToString:@"maximumTrackImage"]) {
        attrValue = [self getItemValueWithState:self.state key:@"maximumTrackImage"];
    }
    return attrValue;
}

- (id)getItemValueWithState: (ADH_INT)state key: (NSString *)key {
    NSString *stateKey = [ADHViewDebugUtil stringWithAdhInt:state];
    NSDictionary *data = self.stateValues[stateKey];
    return data[key];
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHSliderAttribute *attr = self;
    NSString *stateKey = [ADHViewDebugUtil stringWithAdhInt:self.state];
    NSMutableDictionary *stateData = self.stateValues[stateKey];
    if([key isEqualToString:@"value"]) {
        attr.value = [value floatValue];
    }else if([key isEqualToString:@"continuous"]) {
        attr.continuous = [value boolValue];
    }else if([key isEqualToString:@"minimumTrackTintColor"]) {
        attr.minimumTrackTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"maximumTrackTintColor"]) {
        attr.maximumTrackTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"thumbTintColor"]) {
        attr.thumbTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"minimumValueImage"]) {
        attr.minimumValueImage = value;
    }else if([key isEqualToString:@"maximumValueImage"]) {
        attr.maximumValueImage = value;
    }else if([key isEqualToString:@"thumbImage"]) {
        if(value) {
            stateData[@"thumbImage"] = value;
        }else {
            [stateData removeObjectForKey:@"thumbImage"];
        }
    }else if([key isEqualToString:@"minimumTrackImage"]) {
        if(value) {
            stateData[@"minimumTrackImage"] = value;
        }else {
            [stateData removeObjectForKey:@"minimumTrackImage"];
        }
    }else if([key isEqualToString:@"maximumTrackImage"]) {
        if(value) {
            stateData[@"maximumTrackImage"] = value;
        }else {
            [stateData removeObjectForKey:@"maximumTrackImage"];
        }
    }
}

- (void)updateStateValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info {
    NSString *key = item.key;
    if([key isEqualToString:@"state"]) {
        self.state = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

//从App获取属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeGetValueRequest: (ADHAttrItem *)item {
    return @{
             @"state" : [ADHViewDebugUtil numberWithAdhInt:self.state],
             };
}

//向App设置属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeSetValueRequest: (ADHAttrItem *)item {
    return @{
             @"state" : [ADHViewDebugUtil numberWithAdhInt:self.state],
             };
}

- (NSString *)classTypeIcon {
    return @"vd_slider";
}

@end

@implementation ADHStepperAttribute

- (NSDictionary *)getPropertyData {
    ADHStepperAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"value"] = [NSNumber numberWithDouble:attr.value];
    data[@"minimumValue"] = [NSNumber numberWithDouble:attr.minimumValue];
    data[@"maximumValue"] = [NSNumber numberWithDouble:attr.maximumValue];
    data[@"stepValue"] = [NSNumber numberWithDouble:attr.stepValue];
    data[@"continuous"] = [NSNumber numberWithBool:attr.continuous];
    data[@"autorepeat"] = [NSNumber numberWithBool:attr.autorepeat];
    data[@"wraps"] = [NSNumber numberWithBool:attr.wraps];
    data[@"state"] = [ADHViewDebugUtil numberWithAdhInt:attr.state];
    data[@"stateValues"] = attr.stateValues;
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHStepperAttribute *attr = self;
    attr.value = [data[@"value"] doubleValue];
    attr.minimumValue = [data[@"minimumValue"] doubleValue];
    attr.maximumValue = [data[@"maximumValue"] doubleValue];
    attr.stepValue = [data[@"stepValue"] doubleValue];
    attr.continuous = [data[@"continuous"] boolValue];
    attr.autorepeat = [data[@"autorepeat"] boolValue];
    attr.wraps = [data[@"wraps"] boolValue];
    NSDictionary *values = data[@"stateValues"];
    //mutable方便后面修改
    NSMutableDictionary *stateValues = [NSMutableDictionary dictionary];
    [values enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *itemData, BOOL * _Nonnull stop) {
        NSMutableDictionary *mutableData = [itemData mutableCopy];
        stateValues[key] = mutableData;
    }];
    attr.stateValues = stateValues;
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"value",@"Value",ADHAttrTypeStepper)];
    [list addObject:ADH_ATTR(@"minimumValue",@"Min",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"maximumValue",@"Max",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"stepValue",@"Step Value",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"continuous",@"Continuous",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"autorepeat",@"Autorepeat",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"wraps",@"Wraps",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"state",@"State",ADHAttrTypePopup)];
    [list addObject:ADH_ATTR(@"backgroundImage",@"Background Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"dividerImage",@"Divider Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"decrementImage",@"Decrement Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"incrementImage",@"Increment Image",ADHAttrTypeImage)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHStepperAttribute *attr = self;
    if([key isEqualToString:@"value"]) {
        NSDictionary *data = @{
                               @"min" : [NSNumber numberWithDouble:attr.minimumValue],
                               @"max" : [NSNumber numberWithDouble:attr.maximumValue],
                               @"step" : [NSNumber numberWithDouble:attr.stepValue],
                               @"value" : [NSNumber numberWithDouble:attr.value],
                               };
        attrValue = data;
    }else if([key isEqualToString:@"minimumValue"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.minimumValue];
    }else if([key isEqualToString:@"maximumValue"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.maximumValue];
    }else if([key isEqualToString:@"stepValue"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.stepValue];
    }else if([key isEqualToString:@"continuous"]) {
        attrValue = [NSNumber numberWithBool:attr.continuous];
    }else if([key isEqualToString:@"autorepeat"]) {
        attrValue = [NSNumber numberWithBool:attr.autorepeat];
    }else if([key isEqualToString:@"wraps"]) {
        attrValue = [NSNumber numberWithBool:attr.wraps];
    }else if([key isEqualToString:@"state"]) {
        NSArray *list = @[
                          ADH_POPUP(@"Normal",0),
                          ADH_POPUP(@"Highlighted",1 << 0),
                          ADH_POPUP(@"Disabled",1 << 1),
                          ADH_POPUP(@"Selected",1 << 2),
                          ];
        NSDictionary *data = @{
                               @"list" : list,
                               @"value" : [ADHViewDebugUtil numberWithAdhInt:self.state],
                               };
        attrValue = data;
    }else if([key isEqualToString:@"backgroundImage"]) {
        attrValue = [self getItemValueWithState:self.state key:@"backgroundImage"];
    }else if([key isEqualToString:@"dividerImage"]) {
        attrValue = [self getItemValueWithState:self.state key:@"dividerImage"];
    }else if([key isEqualToString:@"incrementImage"]) {
        attrValue = [self getItemValueWithState:self.state key:@"incrementImage"];
    }else if([key isEqualToString:@"decrementImage"]) {
        attrValue = [self getItemValueWithState:self.state key:@"decrementImage"];
    }
    return attrValue;
}

- (id)getItemValueWithState: (ADH_INT)state key: (NSString *)key {
    NSString *stateKey = [ADHViewDebugUtil stringWithAdhInt:state];
    NSDictionary *data = self.stateValues[stateKey];
    return data[key];
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHStepperAttribute *attr = self;
    NSString *stateKey = [ADHViewDebugUtil stringWithAdhInt:self.state];
    NSMutableDictionary *stateData = self.stateValues[stateKey];
    if([key isEqualToString:@"value"]) {
        attr.value = [value floatValue];
    }else if([key isEqualToString:@"backgroundImage"]) {
        if(value) {
            stateData[@"backgroundImage"] = value;
        }else {
            [stateData removeObjectForKey:@"backgroundImage"];
        }
    }else if([key isEqualToString:@"dividerImage"]) {
        if(value) {
            stateData[@"dividerImage"] = value;
        }else {
            [stateData removeObjectForKey:@"dividerImage"];
        }
    }else if([key isEqualToString:@"incrementImage"]) {
        if(value) {
            stateData[@"incrementImage"] = value;
        }else {
            [stateData removeObjectForKey:@"incrementImage"];
        }
    }else if([key isEqualToString:@"decrementImage"]) {
        if(value) {
            stateData[@"decrementImage"] = value;
        }else {
            [stateData removeObjectForKey:@"decrementImage"];
        }
    }else if([key isEqualToString:@"continuous"]) {
        attr.continuous = [value boolValue];
    }else if([key isEqualToString:@"autorepeat"]) {
        attr.autorepeat = [value boolValue];
    }else if([key isEqualToString:@"wraps"]) {
        attr.wraps = [value boolValue];
    }
}

- (void)updateStateValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info {
    NSString *key = item.key;
    if([key isEqualToString:@"state"]) {
        self.state = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

//从App获取属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeGetValueRequest: (ADHAttrItem *)item {
    return @{
             @"state" : [ADHViewDebugUtil numberWithAdhInt:self.state],
             };
}

//向App设置属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeSetValueRequest: (ADHAttrItem *)item {
    return @{
             @"state" : [ADHViewDebugUtil numberWithAdhInt:self.state],
             };
}

- (NSString *)classTypeIcon {
    return @"vd_stepper";
}

@end


@implementation ADHProgressAttribute


- (NSDictionary *)getPropertyData {
    ADHProgressAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"progress"] = [NSNumber numberWithFloat:attr.progress];
    data[@"progressViewStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.progressViewStyle];
    data[@"progressTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.progressTintColor];
    data[@"trackTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.trackTintColor];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHProgressAttribute *attr = self;
    attr.progress = [data[@"progress"] floatValue];
    attr.progressViewStyle = [ADHViewDebugUtil adhIntWithValue:data[@"progressViewStyle"]];
    attr.progressTintColor = [ADHViewDebugUtil colorWithString:data[@"progressTintColor"]];
    attr.trackTintColor = [ADHViewDebugUtil colorWithString:data[@"trackTintColor"]];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"progress",@"Progress",ADHAttrTypeSlider)];
    [list addObject:ADH_ATTR(@"progressViewStyle",@"Style",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"progressTintColor",@"Progress TintColor",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"trackTintColor",@"Rrack TintColor",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"progressImage",@"Progress Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"trackImage",@"Track Image",ADHAttrTypeImage)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHProgressAttribute *attr = self;
    if([key isEqualToString:@"progress"]) {
        NSDictionary *data = @{
                               @"min" : [NSNumber numberWithFloat:0],
                               @"max" : [NSNumber numberWithFloat:1],
                               @"value" : [NSNumber numberWithFloat:attr.progress],
                               };
        attrValue = data;
    }else if([key isEqualToString:@"progressViewStyle"]) {
        /*
         UIProgressViewStyleDefault,     // normal progress bar
         UIProgressViewStyleBar __TVOS_PROHIBITED,     // for use in a toolbar
         */
        NSArray *list = @[
                          ADH_POPUP(@"Default", 0),
                          ADH_POPUP(@"Bar", 1),
                          ];
        attrValue = @{
                      @"list":list,
                      @"value":[ADHViewDebugUtil numberWithAdhInt:attr.progressViewStyle],
                      };
    }else if([key isEqualToString:@"progressTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.progressTintColor];
    }else if([key isEqualToString:@"trackTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.trackTintColor];
    }else if([key isEqualToString:@"progressImage"]) {
        attrValue = attr.progressImage;
    }else if([key isEqualToString:@"trackImage"]) {
        attrValue = attr.trackImage;
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHProgressAttribute *attr = self;
    if([key isEqualToString:@"progress"]) {
        attr.progress = [value floatValue];
    }else if([key isEqualToString:@"progressTintColor"]) {
        attr.progressTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"trackTintColor"]) {
        attr.trackTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"progressImage"]) {
        attr.progressImage = value;
    }else if([key isEqualToString:@"trackImage"]) {
        attr.trackImage = value;
    }else if([key isEqualToString:@"progressViewStyle"]) {
        attr.progressViewStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_progress";
}

@end

@implementation ADHActivityAttribute

/*
* activityIndicatorViewStyle
* color
* hidesWhenStopped
* animating
*/
- (NSDictionary *)getPropertyData {
    ADHActivityAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"activityIndicatorViewStyle"] = [ADHViewDebugUtil numberWithAdhInt:attr.activityIndicatorViewStyle];
    data[@"color"] = [ADHViewDebugUtil stringWithAdhColor:attr.color];
    data[@"hidesWhenStopped"] = [NSNumber numberWithBool:attr.hidesWhenStopped];
    data[@"animating"] = [NSNumber numberWithBool:attr.animating];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHActivityAttribute *attr = self;
    attr.activityIndicatorViewStyle = [ADHViewDebugUtil adhIntWithValue:data[@"activityIndicatorViewStyle"]];
    attr.color = [ADHViewDebugUtil colorWithString:data[@"color"]];
    attr.hidesWhenStopped = [data[@"hidesWhenStopped"] boolValue];
    attr.animating = [data[@"animating"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"activityIndicatorViewStyle",@"Style",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"color",@"Color",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"hidesWhenStopped",@"HidesWhenStopped",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"animating",@"animating",ADHAttrTypeBoolean)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHActivityAttribute *attr = self;
    if([key isEqualToString:@"activityIndicatorViewStyle"]) {
        /*
         UIActivityIndicatorViewStyleWhiteLarge,
         UIActivityIndicatorViewStyleWhite,
         UIActivityIndicatorViewStyleGray __TVOS_PROHIBITED,
         */
        NSArray *list = @[
                          ADH_POPUP(@"White Large", 0),
                          ADH_POPUP(@"White", 1),
                          ADH_POPUP(@"Gray", 2),
                          ];
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.activityIndicatorViewStyle],
                      };
    }else if([key isEqualToString:@"color"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.color];
    }else if([key isEqualToString:@"hidesWhenStopped"]) {
        attrValue = [NSNumber numberWithBool:attr.hidesWhenStopped];
    }else if([key isEqualToString:@"animating"]) {
        attrValue = [NSNumber numberWithBool:attr.animating];
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHActivityAttribute *attr = self;
    if([key isEqualToString:@"color"]) {
        attr.color = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"animating"]) {
        attr.animating = [value boolValue];
    }else if([key isEqualToString:@"hidesWhenStopped"]) {
        attr.hidesWhenStopped = [value boolValue];
    }else if([key isEqualToString:@"activityIndicatorViewStyle"]) {
        attr.activityIndicatorViewStyle = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_activityindicator";
}

@end

@implementation ADHPageControlAttribute

- (NSDictionary *)getPropertyData {
    ADHPageControlAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"numberOfPages"] = [ADHViewDebugUtil numberWithAdhInt:attr.numberOfPages];
    data[@"currentPage"] = [ADHViewDebugUtil numberWithAdhInt:attr.currentPage];
    data[@"pageIndicatorTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.pageIndicatorTintColor];
    data[@"currentPageIndicatorTintColor"] = [ADHViewDebugUtil stringWithAdhColor:attr.currentPageIndicatorTintColor];
    data[@"hidesForSinglePage"] = [NSNumber numberWithBool:attr.hidesForSinglePage];
    data[@"defersCurrentPageDisplay"] = [NSNumber numberWithBool:attr.defersCurrentPageDisplay];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHPageControlAttribute *attr = self;
    attr.numberOfPages = [ADHViewDebugUtil adhIntWithValue:data[@"numberOfPages"]];
    attr.currentPage = [ADHViewDebugUtil adhIntWithValue:data[@"currentPage"]];
    attr.pageIndicatorTintColor = [ADHViewDebugUtil colorWithString:data[@"pageIndicatorTintColor"]];
    attr.currentPageIndicatorTintColor = [ADHViewDebugUtil colorWithString:data[@"currentPageIndicatorTintColor"]];
    attr.hidesForSinglePage = [data[@"hidesForSinglePage"] boolValue];
    attr.defersCurrentPageDisplay = [data[@"defersCurrentPageDisplay"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"numberOfPages",@"Number Of Pages",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"currentPage",@"Current Page",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"pageIndicatorTintColor",@"PageIndicatorTintColor",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"currentPageIndicatorTintColor",@"CurrentPageIndicatorTintColor",ADHAttrTypeColor)];
    [list addObject:ADH_ATTR(@"hidesForSinglePage",@"hidesForSinglePage",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"defersCurrentPageDisplay",@"DefersCurrentPageDisplay",ADHAttrTypeBoolean)];
    return list;
}

/*
 * numberOfPages
 * currentPage
 * pageIndicatorTintColor
 * currentPageIndicatorTintColor
 * hidesForSinglePage
 * defersCurrentPageDisplay
 */
- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHPageControlAttribute *attr = self;
    if([key isEqualToString:@"numberOfPages"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhInt:attr.numberOfPages];
    }else if([key isEqualToString:@"currentPage"]) {
        NSMutableArray *list = [NSMutableArray array];
        for (NSInteger i=0; i<attr.numberOfPages; i++) {
            NSString *indexText = [NSString stringWithFormat:@"Page %zd",i];
            [list addObject:ADH_POPUP(indexText, i)];
        }
        attrValue = @{
                      @"list" : list,
                      @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.currentPage],
                      };
    }else if([key isEqualToString:@"pageIndicatorTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.pageIndicatorTintColor];
    }else if([key isEqualToString:@"currentPageIndicatorTintColor"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhColor:attr.currentPageIndicatorTintColor];
    }else if([key isEqualToString:@"hidesForSinglePage"]) {
        attrValue = [NSNumber numberWithBool:attr.hidesForSinglePage];
    }else if([key isEqualToString:@"defersCurrentPageDisplay"]) {
        attrValue = [NSNumber numberWithBool:attr.defersCurrentPageDisplay];
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHPageControlAttribute *attr = self;
    if([key isEqualToString:@"pageIndicatorTintColor"]) {
        attr.pageIndicatorTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"currentPageIndicatorTintColor"]) {
        attr.currentPageIndicatorTintColor = [ADHViewDebugUtil colorWithString:value];
    }else if([key isEqualToString:@"currentPage"]) {
        attr.currentPage = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"hidesForSinglePage"]) {
        attr.hidesForSinglePage = [value boolValue];
    }else if([key isEqualToString:@"defersCurrentPageDisplay"]) {
        attr.defersCurrentPageDisplay = [value boolValue];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_pagecontrol";
}


@end

@implementation ADHWindowAttribute

- (NSDictionary *)getPropertyData {
    ADHWindowAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"windowLevel"] = [ADHViewDebugUtil numberWithAdhInt:attr.windowLevel];
    data[@"keyWindow"] = [NSNumber numberWithBool:attr.keyWindow];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHWindowAttribute *attr = self;
    attr.windowLevel = [ADHViewDebugUtil adhIntWithValue:data[@"windowLevel"]];
    attr.keyWindow = [data[@"keyWindow"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"windowLevel",@"Window Level",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"keyWindow",@"Key Window",ADHAttrTypeText)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHWindowAttribute *attr = self;
    if([key isEqualToString:@"windowLevel"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhInt:attr.windowLevel];
    }else if([key isEqualToString:@"keyWindow"]) {
        attrValue = [ADHViewDebugUtil stringWithBool:attr.keyWindow];
    }
    return attrValue;
}

- (NSString *)classTypeIcon {
    return @"vd_window";
}

@end

@implementation ADHSegmentAttribute

- (NSDictionary *)getPropertyData {
    ADHSegmentAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"numberOfSegments"] = [ADHViewDebugUtil numberWithAdhInt:attr.numberOfSegments];
    data[@"momentary"] = [NSNumber numberWithBool:attr.momentary];
    data[@"selectedSegmentIndex"] = [ADHViewDebugUtil numberWithAdhInt:attr.selectedSegmentIndex];
    data[@"segmentValues"] = attr.segmentValues;
    data[@"state"] = [ADHViewDebugUtil numberWithAdhInt:attr.state];
    data[@"stateValues"] = attr.stateValues;
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHSegmentAttribute *attr = self;
    attr.numberOfSegments = [ADHViewDebugUtil adhIntWithValue:data[@"numberOfSegments"]];
    attr.momentary = [data[@"momentary"] boolValue];
    attr.selectedSegmentIndex = [ADHViewDebugUtil adhIntWithValue:data[@"selectedSegmentIndex"]];
    {
        NSDictionary *values = data[@"segmentValues"];
        //mutable方便后面修改
        NSMutableDictionary *segmentValues = [NSMutableDictionary dictionary];
        [values enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *itemData, BOOL * _Nonnull stop) {
            NSMutableDictionary *mutableData = [itemData mutableCopy];
            segmentValues[key] = mutableData;
        }];
        attr.segmentValues = segmentValues;
    }
    attr.state = [ADHViewDebugUtil adhIntWithValue:data[@"state"]];
    {
        NSDictionary *values = data[@"stateValues"];
        //mutable方便后面修改
        NSMutableDictionary *stateValues = [NSMutableDictionary dictionary];
        [values enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *itemData, BOOL * _Nonnull stop) {
            NSMutableDictionary *mutableData = [itemData mutableCopy];
            stateValues[key] = mutableData;
        }];
        attr.stateValues = stateValues;
    }
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"numberOfSegments",@"NumberOfSegments",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"selectedSegmentIndex",@"Index",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"title",@"Title",ADHAttrTypeEditText)];
    [list addObject:ADH_ATTR(@"image",@"Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"state",@"State",ADHAttrTypePopup)];
    [list addObject:ADH_ATTR(@"backgroundImage",@"Background Image",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"dividerImage",@"DividerImage",ADHAttrTypeImage)];
    [list addObject:ADH_ATTR(@"momentary",@"Momentary",ADHAttrTypeBoolean)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHSegmentAttribute *attr = self;
    if([key isEqualToString:@"momentary"]) {
        attrValue = [NSNumber numberWithBool:attr.momentary];
    }else if([key isEqualToString:@"numberOfSegments"]) {
        attrValue = [ADHViewDebugUtil stringWithAdhInt:attr.numberOfSegments];
    }else if([key isEqualToString:@"selectedSegmentIndex"]) {
        NSMutableArray *list = [NSMutableArray array];
        for (ADH_INT i=0; i<attr.numberOfSegments; i++) {
            NSString *text = [NSString stringWithFormat:@"Segment %d",(int)i];
            [list addObject:ADH_POPUP(text, i)];
        }
        NSDictionary *data = @{
                               @"list" : list,
                               @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.selectedSegmentIndex],
                               };
        attrValue = data;
    }else if([key isEqualToString:@"title"]) {
        NSString *text = [self getItemValueWithIndex:attr.selectedSegmentIndex key:@"title"];
        attrValue = text;
    }else if([key isEqualToString:@"image"]) {
        attrValue = [self getItemValueWithIndex:attr.selectedSegmentIndex key:@"image"];
    }else if([key isEqualToString:@"state"]) {
        NSArray *list = @[
                          ADH_POPUP(@"Normal",0),
                          ADH_POPUP(@"Highlighted",1 << 0),
                          ADH_POPUP(@"Disabled",1 << 1),
                          ADH_POPUP(@"Selected",1 << 2),
                          ];
        NSDictionary *data = @{
                               @"list" : list,
                               @"value" : [ADHViewDebugUtil numberWithAdhInt:self.state],
                               };
        attrValue = data;
    }else if([key isEqualToString:@"backgroundImage"]) {
        attrValue = [self getItemValueWithState:attr.state key:@"backgroundImage"];
    }else if([key isEqualToString:@"dividerImage"]) {
        attrValue = [self getItemValueWithState:attr.state key:@"dividerImage"];
    }
    return attrValue;
}

- (id)getItemValueWithIndex: (ADH_INT)index key:(NSString *)key {
    NSString *indexKey = [ADHViewDebugUtil stringWithAdhInt:index];
    NSDictionary *segmentData = self.segmentValues[indexKey];
    return segmentData[key];
}

- (id)getItemValueWithState: (ADH_INT)state key: (NSString *)key {
    NSString *stateKey = [ADHViewDebugUtil stringWithAdhInt:state];
    NSDictionary *data = self.stateValues[stateKey];
    return data[key];
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    NSString *indexKey = [ADHViewDebugUtil stringWithAdhInt:self.selectedSegmentIndex];
    NSMutableDictionary *segmentData = self.segmentValues[indexKey];
    NSString *stateKey = [ADHViewDebugUtil stringWithAdhInt:self.state];
    NSMutableDictionary *stateData = self.stateValues[stateKey];
    ADHSegmentAttribute *attr = self;
    if([key isEqualToString:@"selectedSegmentIndex"]) {
        attr.selectedSegmentIndex = [ADHViewDebugUtil adhIntWithValue:value];
    }else if([key isEqualToString:@"title"]) {
        segmentData[@"title"] = adhvf_safestringfy(value);
    }else if([key isEqualToString:@"image"]) {
        if(value) {
            segmentData[@"image"] = value;
        }else {
            [segmentData removeObjectForKey:@"image"];
        }
    }else if([key isEqualToString:@"backgroundImage"]) {
        if(value) {
            stateData[@"backgroundImage"] = value;
        }else {
            [stateData removeObjectForKey:@"backgroundImage"];
        }
    }else if([key isEqualToString:@"dividerImage"]) {
        if(value) {
            stateData[@"dividerImage"] = value;
        }else {
            [stateData removeObjectForKey:@"dividerImage"];
        }
    }else if([key isEqualToString:@"momentary"]) {
        attr.momentary = [value boolValue];
    }
}

- (void)updateStateValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info {
    NSString *key = item.key;
    if([key isEqualToString:@"state"]) {
        self.state = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

//从App获取属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeGetValueRequest: (ADHAttrItem *)item {
    return @{
             @"state" : [ADHViewDebugUtil numberWithAdhInt:self.state],
             @"selectedSegmentIndex" : [ADHViewDebugUtil numberWithAdhInt:self.selectedSegmentIndex],
             };
}

//向App设置属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeSetValueRequest: (ADHAttrItem *)item {
    return @{
             @"state" : [ADHViewDebugUtil numberWithAdhInt:self.state],
             @"selectedSegmentIndex" : [ADHViewDebugUtil numberWithAdhInt:self.selectedSegmentIndex],
             };
}

- (ADHAttrItemAffect)getAffectWithItem: (ADHAttrItem *)item {
    ADHAttrItemAffect value = ADHAttrItemAffectDefault;
    if([item.key isEqualToString:@"selectedSegmentIndex"]) {
        value = ADHAttrItemAffectLarge;
    }else {
        value = [super getAffectWithItem:item];
    }
    return value;
}

- (NSString *)classTypeIcon {
    return @"vd_segmentcontrol";
}

@end


@implementation ADHPickerViewAttribute

- (NSDictionary *)getPropertyData {
    ADHPickerViewAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"showsSelectionIndicator"] = [NSNumber numberWithBool:attr.showsSelectionIndicator];
    data[@"dataSource"] = adhvf_safestringfy(attr.dataSource);
    data[@"delegate"] = adhvf_safestringfy(attr.delegate);
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHPickerViewAttribute *attr = self;
    attr.showsSelectionIndicator = [data[@"showsSelectionIndicator"] boolValue];
    attr.dataSource = data[@"dataSource"];
    attr.delegate = data[@"delegate"];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"showsSelectionIndicator",@"Selection Indicator",ADHAttrTypeBoolean)];
    [list addObject:ADH_ATTR(@"dataSource",@"DataSource",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"delegate",@"Delegate",ADHAttrTypeText)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHPickerViewAttribute *attr = self;
    if([key isEqualToString:@"showsSelectionIndicator"]) {
        attrValue = [NSNumber numberWithBool:attr.showsSelectionIndicator];
    }else if([key isEqualToString:@"dataSource"]) {
        attrValue = attr.dataSource;
    }else if([key isEqualToString:@"delegate"]) {
        attrValue = attr.delegate;
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    if([key isEqualToString:@"showsSelectionIndicator"]) {
        self.showsSelectionIndicator = [value boolValue];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_pickerview";
}

@end


@implementation ADHDatePickerAttribute

- (NSDictionary *)getPropertyData {
    ADHDatePickerAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"datePickerMode"] = [ADHViewDebugUtil numberWithAdhInt:attr.datePickerMode];
    data[@"locale"] = adhvf_safestringfy(attr.locale);
    data[@"calendar"] = adhvf_safestringfy(attr.calendar);
    data[@"timeZone"] = adhvf_safestringfy(attr.timeZone);
    data[@"date"] = [NSNumber numberWithDouble:attr.date];
    data[@"minimumDate"] = [NSNumber numberWithDouble:attr.minimumDate];
    data[@"maximumDate"] = [NSNumber numberWithDouble:attr.maximumDate];
    data[@"countDownDuration"] = [NSNumber numberWithDouble:attr.countDownDuration];
    data[@"minuteInterval"] = [ADHViewDebugUtil numberWithAdhInt:attr.minuteInterval];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHDatePickerAttribute *attr = self;
    attr.datePickerMode = [ADHViewDebugUtil adhIntWithValue:data[@"datePickerMode"]];
    attr.locale = data[@"locale"];
    attr.calendar = data[@"calendar"];
    attr.timeZone = data[@"timeZone"];
    attr.date = [data[@"date"] doubleValue];
    attr.minimumDate = [data[@"minimumDate"] doubleValue];
    attr.maximumDate = [data[@"maximumDate"] doubleValue];
    attr.countDownDuration = [data[@"countDownDuration"] doubleValue];
    attr.minuteInterval = [ADHViewDebugUtil adhIntWithValue:data[@"minuteInterval"]];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"datePickerMode",@"Mode",ADHAttrTypeSelect)];
    [list addObject:ADH_ATTR(@"locale",@"Locale",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"calendar",@"Calendar",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"timeZone",@"Timezone",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"date",@"Date",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"minimumDate",@"Min Date",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"maximumDate",@"Max Date",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"countDownDuration",@"Countdown",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"minuteInterval",@"Minute Interval",ADHAttrTypeText)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHDatePickerAttribute *attr = self;
    if([key isEqualToString:@"datePickerMode"]) {
        NSArray *list = @[
                          ADH_POPUP(@"Time",0),
                          ADH_POPUP(@"Date",1),
                          ADH_POPUP(@"Date And Time",2),
                          ADH_POPUP(@"CountDown Timer",3),
                          ];
        NSDictionary *data = @{
                               @"list" : list,
                               @"value" : [ADHViewDebugUtil numberWithAdhInt:attr.datePickerMode],
                               };
        attrValue = data;
    }else if([key isEqualToString:@"locale"]) {
        attrValue = attr.locale;
    }else if([key isEqualToString:@"calendar"]) {
        attrValue = attr.calendar;
    }else if([key isEqualToString:@"timeZone"]) {
        attrValue = attr.timeZone;
    }else if([key isEqualToString:@"date"]) {
        attrValue = [self formatTextWithDateInterval:attr.date];
    }else if([key isEqualToString:@"minimumDate"]) {
        attrValue = [self formatTextWithDateInterval:attr.minimumDate];
    }else if([key isEqualToString:@"maximumDate"]) {
        attrValue = [self formatTextWithDateInterval:attr.maximumDate];
    }else if([key isEqualToString:@"countDownDuration"]) {
        attrValue = [self formatTextWithDateInterval:attr.countDownDuration];
    }else if([key isEqualToString:@"minuteInterval"]) {
        NSInteger hour = (NSInteger)(attr.minuteInterval / (60*60));
        NSInteger minute = (NSInteger)((attr.minuteInterval % (60*60)) / 60);
        attrValue = [NSString stringWithFormat:@"%.2zd:%.2zd",hour,minute];
    }
    return attrValue;
}

- (NSString *)formatTextWithDateInterval: (NSTimeInterval)interval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSString *text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
    return text;
}

- (void)updateAttrValue:(ADHAttrItem *)item value:(id)value info:(NSDictionary *)info localInfo:(NSDictionary *)localInfo {
    NSString *key = item.key;
    ADHDatePickerAttribute *attr = self;
    if([key isEqualToString:@"datePickerMode"]) {
        attr.datePickerMode = [ADHViewDebugUtil adhIntWithValue:value];
    }
}

- (NSString *)classTypeIcon {
    return @"vd_pickerview";
}

@end


@implementation ADHWKWebAttribute

- (NSDictionary *)getPropertyData {
    ADHWKWebAttribute *attr = self;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"title"] = adhvf_safestringfy(attr.title);
    data[@"url"] = adhvf_safestringfy(attr.url);
    data[@"navigationDelegate"] = adhvf_safestringfy(attr.navigationDelegate);
    data[@"UIDelegate"] = adhvf_safestringfy(attr.UIDelegate);
    data[@"estimatedProgress"] = [NSNumber numberWithFloat:attr.estimatedProgress];
    data[@"hasOnlySecureContent"] = [NSNumber numberWithBool:attr.hasOnlySecureContent];
    data[@"loading"] = [NSNumber numberWithBool:attr.loading];
    data[@"canGoBack"] = [NSNumber numberWithBool:attr.canGoBack];
    data[@"canGoForward"] = [NSNumber numberWithBool:attr.canGoForward];
    return data;
}

- (void)setPropertyWithData: (NSDictionary *)data {
    ADHWKWebAttribute *attr = self;
    attr.title = data[@"title"];
    attr.url = data[@"url"];
    attr.navigationDelegate = data[@"navigationDelegate"];
    attr.UIDelegate = data[@"UIDelegate"];
    attr.estimatedProgress = [data[@"estimatedProgress"] floatValue];
    attr.hasOnlySecureContent = [data[@"hasOnlySecureContent"] boolValue];
    attr.loading = [data[@"loading"] boolValue];
    attr.canGoBack = [data[@"canGoBack"] boolValue];
    attr.canGoForward = [data[@"canGoForward"] boolValue];
}

- (NSArray<ADHAttrItem *> *)itemList {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:ADH_ATTR(@"title",@"Title",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"url",@"URL",ADHAttrTypeEditText)];
    [list addObject:ADH_ATTR(@"navigationDelegate",@"Navigation Delegate",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"UIDelegate",@"UIDelegate",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"estimatedProgress",@"Estimated Progress",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"hasOnlySecureContent",@"Secure Only",ADHAttrTypeText)];
    [list addObject:ADH_ATTR(@"action",@"Console",ADHAttrTypeWebNavi)];
    return list;
}

- (id)getAttrValue: (ADHAttrItem *)item {
    id attrValue = nil;
    NSString *key = item.key;
    ADHWKWebAttribute *attr = self;
    if([key isEqualToString:@"title"]) {
        attrValue = attr.title;
    }else if([key isEqualToString:@"url"]) {
        attrValue = attr.url;
    }else if([key isEqualToString:@"navigationDelegate"]) {
        attrValue = attr.navigationDelegate;
    }else if([key isEqualToString:@"UIDelegate"]) {
        attrValue = attr.UIDelegate;
    }else if([key isEqualToString:@"estimatedProgress"]) {
        attrValue = [NSString stringWithFormat:@"%.1f",attr.estimatedProgress];
    }else if([key isEqualToString:@"hasOnlySecureContent"]) {
        attrValue = [ADHViewDebugUtil stringWithBool:attr.hasOnlySecureContent];
    }else if([key isEqualToString:@"action"]) {
        NSDictionary *data = @{
                               @"canGoBack" : [NSNumber numberWithBool:attr.canGoBack],
                               @"canGoForward" : [NSNumber numberWithBool:attr.canGoForward],
                               @"loading" : [NSNumber numberWithBool:attr.loading],
                               };
        attrValue = data;
    }
    return attrValue;
}

- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo {
    if(!value) return;
    NSString *key = item.key;
    ADHWKWebAttribute *attr = self;
    if([key isEqualToString:@"url"]) {
        attr.url = value;
    }else if([key isEqualToString:@"action"]) {
        if([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *data = value;
            attr.title = data[@"title"];
            attr.url = data[@"url"];
            attr.estimatedProgress = [data[@"estimatedProgress"] floatValue];
            attr.hasOnlySecureContent = [data[@"hasOnlySecureContent"] boolValue];
            attr.loading = [data[@"loading"] boolValue];
            attr.canGoBack = [data[@"canGoBack"] boolValue];
            attr.canGoForward = [data[@"canGoForward"] boolValue];
        }
    }
}

- (NSString *)classTypeIcon {
    return @"vd_webview";
}

@end
