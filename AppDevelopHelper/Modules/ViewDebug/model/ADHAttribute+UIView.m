//
//  ADHAttribute+UIView.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/20.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHAttribute+UIView.h"
#import "ADHViewDebugUtil.h"

@import WebKit;

@implementation ADHAttribute (UIView)

@end

@implementation  ADHViewAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    ADHViewAttribute *attr = self;
    attr.frame = adhFrameFromFrame(view.frame);
    if (view.window) {
        CGRect frameInWindow = [view convertRect:view.bounds toView:view.window];
        attr.frameInWindow = adhFrameFromFrame(frameInWindow);
    } else {
        attr.frameInWindow = adhFrameMake(0, 0, 0, 0);
    }
    attr.backgroundColor = adhColorFromUIColor(view.backgroundColor);
    attr.alpha = view.alpha;
    attr.tag = (ADH_INT)view.tag;
    attr.tintColor = adhColorFromUIColor(view.tintColor);
    attr.userInteractionEnabled = view.userInteractionEnabled;
    attr.opaque = view.isOpaque;
    attr.clipsToBounds = view.clipsToBounds;
    attr.cornerRadius = view.layer.cornerRadius;
    attr.autoresizingMask = view.autoresizingMask;
    NSArray *gestures = view.gestureRecognizers;
    NSMutableArray *gestureList = [NSMutableArray array];
    for (UIGestureRecognizer *recognizer in gestures) {
        NSDictionary *data = [self getGestureRecognizerData:recognizer];
        if(data) {
            [gestureList addObject:data];
        }
    }
    if(gestureList.count > 0) {
        attr.gestureRecognizers = gestureList;
    }
}

//set value
+ (id)updateValueWithInstance: (id)instance key:(NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIView class]]) {
        return retValue;
    }
    UIView *view = (UIView *)instance;
    if([key isEqualToString:@"alpha"]) {
        CGFloat alpha = [value floatValue];
        view.alpha = alpha;
    }else if([key isEqualToString:@"frame"]) {
        ADH_FRAME frame = [ADHViewDebugUtil frameWithString:value];
        view.frame = frameFromAdhFrame(frame);
    }else if([key isEqualToString:@"backgroundColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        view.backgroundColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"tintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        view.tintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"contentMode"]) {
        view.contentMode = [value integerValue];
    }else if([key isEqualToString:@"userInteractionEnabled"]) {
        view.userInteractionEnabled = [value boolValue];
    }else if([key isEqualToString:@"opaque"]) {
        view.opaque = [value boolValue];
    }else if([key isEqualToString:@"clipsToBounds"]) {
        view.clipsToBounds = [value boolValue];
    }else if([key isEqualToString:@"gestureRecognizers"]) {
        NSArray *gestureRecognizers = view.gestureRecognizers;
        NSInteger index = [info[@"gesture-index"] integerValue];
        NSString *gestureKey = info[@"gesture-key"];
        NSString *class = info[@"gesture-class"];
        if(index < gestureRecognizers.count) {
            UIGestureRecognizer *recognizer = gestureRecognizers[index];
            [ADHViewAttribute updateGestureRecognizer:recognizer key:gestureKey value:value class:class];
        }
        *retInfo = info;
    }else if([key isEqualToString:@"cornerRadius"]) {
        CGFloat cornerRadius = [value floatValue];
        view.layer.cornerRadius = cornerRadius;
    }
    return retValue;
}

#pragma mark -----------------   gesture recognizer   ----------------

- (NSDictionary *)getGestureRecognizerData: (UIGestureRecognizer *)recognizer {
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    //common
    if([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)recognizer;
        data[@"numberOfTapsRequired"] = [NSNumber numberWithInteger:tap.numberOfTapsRequired];
        data[@"numberOfTouchesRequired"] = [NSNumber numberWithInteger:tap.numberOfTouchesRequired];
        data[@"shortname"] = @"Tap";
    }else if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)recognizer;
        data[@"numberOfTapsRequired"] = [NSNumber numberWithInteger:press.numberOfTapsRequired];
        data[@"numberOfTouchesRequired"] = [NSNumber numberWithInteger:press.numberOfTouchesRequired];
        data[@"minimumPressDuration"] = [NSNumber numberWithDouble:press.minimumPressDuration];
        data[@"allowableMovement"] = [NSNumber numberWithFloat:press.allowableMovement];
        data[@"shortname"] = @"Long Press";
    }else if([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        UIScreenEdgePanGestureRecognizer *edge = (UIScreenEdgePanGestureRecognizer *)recognizer;
        /*
         UIRectEdgeNone   = 0,
         UIRectEdgeTop    = 1 << 0,
         UIRectEdgeLeft   = 1 << 1,
         UIRectEdgeBottom = 1 << 2,
         UIRectEdgeRight  = 1 << 3,
         UIRectEdgeAll    = UIRectEdgeTop | UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight
         */
        NSInteger value = edge.edges;
        NSMutableArray *texts = [NSMutableArray array];
        if(value == 0) {
            [texts addObject:@"None"];
        }
        if(value & 1 << 0) {
            [texts addObject:@"Top"];
        }else if(value & 1 << 1) {
            [texts addObject:@"Left"];
        }else if(value & 1 << 2) {
            [texts addObject:@"Bottom"];
        }else if(value & 1 << 3) {
            [texts addObject:@"Right"];
        }
        NSString *text = [texts componentsJoinedByString:@"\n"];
        data[@"edges"] = adhvf_safestringfy(text);
        data[@"minimumNumberOfTouches"] = [NSNumber numberWithInteger:edge.minimumNumberOfTouches];
        data[@"maximumNumberOfTouches"] = [NSNumber numberWithInteger:edge.maximumNumberOfTouches];
        data[@"shortname"] = @"Screen Edge";
    }else if([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)recognizer;
        data[@"minimumNumberOfTouches"] = [NSNumber numberWithInteger:pan.minimumNumberOfTouches];
        data[@"maximumNumberOfTouches"] = [NSNumber numberWithInteger:pan.maximumNumberOfTouches];
        data[@"shortname"] = @"Pan";
    }else if([recognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer *)recognizer;
        data[@"numberOfTouchesRequired"] = [NSNumber numberWithInteger:swipe.numberOfTouchesRequired];
        data[@"direction"] = [NSNumber numberWithInteger:swipe.direction];
        data[@"shortname"] = @"Swipe";
    }else if([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)recognizer;
        data[@"scale"] = [NSNumber numberWithFloat:pinch.scale];
        data[@"velocity"] = [NSNumber numberWithFloat:pinch.velocity];
        data[@"shortname"] = @"Pinch";
    }else if([recognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
        UIRotationGestureRecognizer *rotation = (UIRotationGestureRecognizer *)recognizer;
        data[@"rotation"] = [NSNumber numberWithFloat:rotation.rotation];
        data[@"velocity"] = [NSNumber numberWithFloat:rotation.velocity];
        data[@"shortname"] = @"Rotation";
    }
    /*
     * delegate
     * view
     * enabled E
     * state (read only)
     * cancelsTouchesInView E
     * delaysTouchesBegan E
     * delaysTouchesEnded E
     * requiresExclusiveTouchType (9_2) E
     * numberOfTouches (read only)
     */
    data[@"class"] = adhvf_safestringfy(NSStringFromClass([recognizer class]));
    data[@"delegate"] = adhvf_safestringfy([ADHViewDebugUtil stringWithInstance:recognizer.delegate]);
    data[@"view"] = adhvf_safestringfy([ADHViewDebugUtil stringWithInstance:recognizer.view]);
    data[@"enabled"] = [NSNumber numberWithBool:recognizer.enabled];
    data[@"state"] = [NSNumber numberWithInteger:recognizer.state];
    data[@"cancelsTouchesInView"] = [NSNumber numberWithBool:recognizer.cancelsTouchesInView];
    data[@"delaysTouchesBegan"] = [NSNumber numberWithBool:recognizer.delaysTouchesBegan];
    data[@"delaysTouchesEnded"] = [NSNumber numberWithBool:recognizer.delaysTouchesEnded];
    if (@available(iOS 9.2, *)) {
        data[@"requiresExclusiveTouchType"] = [NSNumber numberWithBool:recognizer.requiresExclusiveTouchType];
    }
    data[@"numberOfTouches"] = [NSNumber numberWithInteger:recognizer.numberOfTouches];
    data[@"instaddr"] = adhvf_safestringfy([ADHViewDebugUtil stringWithInstance2:recognizer]);
    return data;
}

+ (void)updateGestureRecognizer: (UIGestureRecognizer *)recognizer key: (NSString *)key value: (id)value class: (NSString *)class {
    if([class isEqualToString:@"UITapGestureRecognizer"]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)recognizer;
        if([key isEqualToString:@"numberOfTapsRequired"]) {
            tap.numberOfTapsRequired = [value integerValue];
        }else if([key isEqualToString:@"numberOfTouchesRequired"]) {
            tap.numberOfTouchesRequired = [value integerValue];
        }
    }else if([class isEqualToString:@"UILongPressGestureRecognizer"]) {
        UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)recognizer;
        if([key isEqualToString:@"numberOfTapsRequired"]) {
            press.numberOfTapsRequired = [value integerValue];
        }else if([key isEqualToString:@"numberOfTouchesRequired"]) {
            press.numberOfTouchesRequired = [value integerValue];
        }else if([key isEqualToString:@"minimumPressDuration"]) {
            press.minimumPressDuration = [value doubleValue];
        }else if([key isEqualToString:@"allowableMovement"]) {
            press.allowableMovement = [value floatValue];
        }
    }else if([class isEqualToString:@"UIPanGestureRecognizer"] || [class isEqualToString:@"UIScreenEdgePanGestureRecognizer"]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)recognizer;
        if([key isEqualToString:@"minimumNumberOfTouches"]) {
            pan.minimumNumberOfTouches = [value integerValue];
        }else if([key isEqualToString:@"maximumNumberOfTouches"]) {
            pan.maximumNumberOfTouches = [value integerValue];
        }
    }else if([class isEqualToString:@"UISwipeGestureRecognizer"]) {
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer *)recognizer;
        if([key isEqualToString:@"numberOfTouchesRequired"]) {
            swipe.numberOfTouchesRequired = [value integerValue];
        }else if([key isEqualToString:@"direction"]) {
            swipe.direction = [value integerValue];
        }
    }else if([class isEqualToString:@"UIPinchGestureRecognizer"]) {
        UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)recognizer;
        if([key isEqualToString:@"scale"]) {
            pinch.scale = [value floatValue];
        }
    }else if([class isEqualToString:@"UIRotationGestureRecognizer"]) {
        UIRotationGestureRecognizer *rotation = (UIRotationGestureRecognizer *)recognizer;
        if([key isEqualToString:@"rotation"]) {
            rotation.rotation = [value floatValue];
        }
    }
    if([key isEqualToString:@"enabled"]) {
        recognizer.enabled = [value boolValue];
    }else if([key isEqualToString:@"cancelsTouchesInView"]) {
        recognizer.cancelsTouchesInView = [value boolValue];
    }else if([key isEqualToString:@"delaysTouchesBegan"]) {
        recognizer.delaysTouchesBegan = [value boolValue];
    }else if([key isEqualToString:@"delaysTouchesEnded"]) {
        recognizer.delaysTouchesEnded = [value boolValue];
    }
}

@end

@implementation ADHLabelAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UILabel *label = (UILabel *)view;
    ADHLabelAttribute *attr = self;
    attr.text = label.text;
    attr.textColor = adhColorFromUIColor(label.textColor);
    attr.font = adhFontFromUIFont(label.font);
    attr.alignment = label.textAlignment;
    attr.numberOfLines = label.numberOfLines;
    attr.linebreakMode = label.lineBreakMode;
    attr.adjustsFontSizeToFitWidth = label.adjustsFontSizeToFitWidth;
    attr.minimumScaleFactor = label.minimumScaleFactor;
    attr.preferredMaxLayoutWidth = label.preferredMaxLayoutWidth;
    attr.baselineAdjustment = label.baselineAdjustment;
}

+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UILabel class]]) {
        return retValue;
    }
    UILabel *label = (UILabel *)instance;
    if([key isEqualToString:@"text"]) {
        label.text = value;
    }else if([key isEqualToString:@"textColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        label.textColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"alignment"]) {
        label.textAlignment = [value integerValue];
    }else if([key isEqualToString:@"numberOfLines"]) {
        label.numberOfLines = [value integerValue];
    }else if([key isEqualToString:@"linebreakMode"]) {
        label.lineBreakMode = [value integerValue];
    }else if([key isEqualToString:@"adjustsFontSizeToFitWidth"]) {
        label.adjustsFontSizeToFitWidth = [value boolValue];
    }else if([key isEqualToString:@"minimumScaleFactor"]) {
        label.minimumScaleFactor = [value floatValue];
    }else if([key isEqualToString:@"preferredMaxLayoutWidth"]) {
        label.preferredMaxLayoutWidth = [value floatValue];
    }else if([key isEqualToString:@"baselineAdjustment"]) {
        label.baselineAdjustment = [value integerValue];
    }else if([key isEqualToString:@"font"]) {
        ADHFont *font = [ADHFont fontWithString:value];
        label.font = uifontFromAdhFont(font);
    }
    return retValue;
}

@end

@implementation ADHImageViewAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UIImageView *imv = (UIImageView *)view;
    ADHImageViewAttribute *attr = self;
    attr.highlighted = imv.highlighted;
    attr.animating = imv.animating;
    attr.animationDuration = imv.animationDuration;
    attr.animationRepeatCount = imv.animationRepeatCount;
}

+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UIImageView class]]) {
        return nil;
    }
    id retValue = nil;
    NSMutableDictionary *resultInfo = [NSMutableDictionary dictionary];
    UIImageView *imv = (UIImageView *)instance;
    if([key isEqualToString:@"image"]) {
        if(imv.animationImages.count > 0) {
            NSData *data = UIImagePNGRepresentation(imv.animationImages[0]);
            retValue = data;
            resultInfo[@"imageAnimated"] = @(1);
        }else if(imv.image) {
            NSData *data = UIImagePNGRepresentation(imv.image);
            retValue = data;
        }
    }else if([key isEqualToString:@"highlightedImage"]) {
        if(imv.highlightedAnimationImages) {
            NSData *data = UIImagePNGRepresentation(imv.highlightedAnimationImages[0]);
            retValue = data;
            resultInfo[@"highlightedImageAnimated"] = @(1);
        }else if(imv.highlightedImage) {
            NSData *data = UIImagePNGRepresentation(imv.highlightedImage);
            retValue = data;
        }
    }
    *retInfo = resultInfo;
    return retValue;
}

+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIImageView class]]) {
        return retValue;
    }
    UIImageView *imv = (UIImageView *)instance;
    if([key isEqualToString:@"image"]) {
        NSData *data = value;
        UIImage *image = [[UIImage alloc] initWithData:data];
        if(image) {
            imv.image = image;
        }
    }else if([key isEqualToString:@"highlightedImage"]) {
        NSData *data = value;
        UIImage *image = [[UIImage alloc] initWithData:data];
        if(image) {
            imv.highlightedImage = image;
        }
    }else if([key isEqualToString:@"highlighted"]) {
        imv.highlighted = [value boolValue];
    }else if([key isEqualToString:@"animating"]) {
        BOOL animating = [value boolValue];
        if(animating) {
            [imv startAnimating];
        }else {
            [imv stopAnimating];
        }
    }
    return retValue;
}


@end

@implementation ADHControlAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UIControl *control = (UIControl *)view;
    ADHControlAttribute *attr = self;
    attr.enabled = control.enabled;
    attr.selected = control.selected;
    attr.highlighted = control.highlighted;
    attr.horizontalAlignment = control.contentHorizontalAlignment;
    attr.verticalAlignment = control.contentVerticalAlignment;
}

+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIControl class]]) {
        return retValue;
    }
    UIControl *control = (UIControl *)instance;
    if([key isEqualToString:@"enabled"]) {
        control.enabled = [value boolValue];
    }else if([key isEqualToString:@"selected"]) {
        control.selected = [value boolValue];
    }else if([key isEqualToString:@"highlighted"]) {
        control.highlighted = [value boolValue];
    }else if([key isEqualToString:@"horizontalAlignment"]){
        control.contentHorizontalAlignment = [value integerValue];
    }else if([key isEqualToString:@"verticalAlignment"]){
        control.contentVerticalAlignment = [value integerValue];
    }
    return retValue;
}

@end

@implementation ADHButtonAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UIButton *button = (UIButton *)view;
    ADHButtonAttribute *attr = self;
    attr.state = button.state;
    attr.buttonType = button.buttonType;
    attr.contentEdgeInsets = adhInsetsFromInsets(button.contentEdgeInsets);
    attr.titleEdgeInsets = adhInsetsFromInsets(button.titleEdgeInsets);
    attr.imageEdgeInsets = adhInsetsFromInsets(button.imageEdgeInsets);
    //title
    //titleColor
    //image
    //backgroundImage
    //attributedTitle
    NSMutableDictionary *stateValues = [NSMutableDictionary dictionary];
    NSArray *states = @[
                        [NSNumber numberWithInt:UIControlStateNormal],
                        [NSNumber numberWithInt:UIControlStateHighlighted],
                        [NSNumber numberWithInt:UIControlStateDisabled],
                        [NSNumber numberWithInt:UIControlStateSelected],
                        ];
    for (NSNumber *stateValue in states) {
        UIControlState state = [stateValue integerValue];
        NSString *title = [button titleForState:state];
        UIColor *titleColor = [button titleColorForState:state];
        NSMutableDictionary *itemData = [NSMutableDictionary dictionary];
        itemData[@"title"] = adhvf_safestringfy(title);
        if(titleColor) {
            ADH_COLOR color = adhColorFromUIColor(titleColor);
            itemData[@"titleColor"] = [ADHViewDebugUtil stringWithAdhColor:color];
        }
        NSString *key = [NSString stringWithFormat:@"%zd",state];
        stateValues[key] = itemData;
    }
    attr.stateValues = stateValues;
    /*
     UIControlStateNormal       = 0,
     UIControlStateHighlighted  = 1 << 0,
     UIControlStateDisabled     = 1 << 1,
     UIControlStateSelected     = 1 << 2,
     */
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIButton class]]) {
        return retValue;
    }
    UIButton *button = (UIButton *)instance;
    if([key isEqualToString:@"image"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [button setImage:image forState:state];
    }else if([key isEqualToString:@"backgroundImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [button setBackgroundImage:image forState:state];
    }else if([key isEqualToString:@"titleColor"]) {
        NSInteger state = [info[@"state"] integerValue];
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        UIColor *titleColor = uicolorFromAdhColor(color);
        [button setTitleColor:titleColor forState:state];
    }else if([key isEqualToString:@"title"]) {
        NSInteger state = [info[@"state"] integerValue];
        [button setTitle:adhvf_safestringfy(value) forState:state];
    }else if([key isEqualToString:@"reversesTitleShadowWhenHighlighted"]) {
        button.reversesTitleShadowWhenHighlighted = [value boolValue];
    }else if([key isEqualToString:@"adjustsImageWhenHighlighted"]) {
        button.adjustsImageWhenHighlighted = [value boolValue];
    }else if([key isEqualToString:@"adjustsImageWhenDisabled"]) {
        button.adjustsImageWhenDisabled = [value boolValue];
    }else if([key isEqualToString:@"showsTouchWhenHighlighted"]) {
        button.showsTouchWhenHighlighted = [value boolValue];
    }else if([key isEqualToString:@"contentEdgeInsets"]) {
        ADH_INSETS insets = [ADHViewDebugUtil insetsWithString:value];
        button.contentEdgeInsets = uiinsetsFromAdhInsets(insets);
    }else if([key isEqualToString:@"titleEdgeInsets"]) {
        ADH_INSETS insets = [ADHViewDebugUtil insetsWithString:value];
        button.titleEdgeInsets = uiinsetsFromAdhInsets(insets);
    }else if([key isEqualToString:@"imageEdgeInsets"]) {
        ADH_INSETS insets = [ADHViewDebugUtil insetsWithString:value];
        button.imageEdgeInsets = uiinsetsFromAdhInsets(insets);
    }
    return retValue;
}

//从App端获取View属性
+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UIButton class]]) {
        return nil;
    }
    id retValue = nil;
    UIButton *button = (UIButton *)instance;
    if([key isEqualToString:@"image"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [button imageForState:state];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"backgroundImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [button backgroundImageForState:state];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }
    return retValue;
}

@end


@implementation ADHTextFieldAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UITextField *textfield = (UITextField *)view;
    ADHTextFieldAttribute *attr = self;
    attr.text = textfield.text;
    attr.placeholder = textfield.placeholder;
    attr.font = adhFontFromUIFont(textfield.font);
    attr.textColor = adhColorFromUIColor(textfield.textColor);
    attr.textAlignment = textfield.textAlignment;
    attr.borderStyle = textfield.borderStyle;
    attr.adjustsFontSizeToFitWidth = textfield.adjustsFontSizeToFitWidth;
    attr.minimumFontSize = textfield.minimumFontSize;
    attr.leftViewMode = textfield.leftViewMode;
    attr.rightViewMode = textfield.rightViewMode;
    attr.clearButtonMode = textfield.clearButtonMode;
    attr.clearsOnBeginEditing = textfield.clearsOnBeginEditing;
    attr.clearsOnInsertion = textfield.clearsOnInsertion;
    /*
     * text
     * placeholder
     * textColor
     * font
     * textAlignment
     * borderStyle
     * adjustsFontSizeToFitWidth
     * minimumFontSize
     * background
     * disabledBackground
     * leftViewMode
     * rightViewMode
     * clearButtonMode
     * clearsOnBeginEditing
     * clearsOnInsertion
     */
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UITextField class]]) {
        return retValue;
    }
    UITextField *textfield = (UITextField *)instance;
    if([key isEqualToString:@"text"]) {
        textfield.text = value;
    }else if([key isEqualToString:@"placeholder"]) {
        textfield.placeholder = value;
    }else if([key isEqualToString:@"textColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        textfield.textColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"font"]) {
        ADHFont *font = [ADHFont fontWithString:value];
        textfield.font = uifontFromAdhFont(font);
    }else if([key isEqualToString:@"textAlignment"]) {
        textfield.textAlignment = [value integerValue];
    }else if([key isEqualToString:@"borderStyle"]) {
        textfield.borderStyle = [value integerValue];
    }else if([key isEqualToString:@"adjustsFontSizeToFitWidth"]) {
        textfield.adjustsFontSizeToFitWidth = [value boolValue];
    }else if([key isEqualToString:@"minimumFontSize"]) {
        textfield.minimumFontSize = [value floatValue];
    }else if([key isEqualToString:@"background"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        textfield.background = image;
    }else if([key isEqualToString:@"disabledBackground"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        textfield.disabledBackground = image;
    }else if([key isEqualToString:@"leftViewMode"]) {
        textfield.leftViewMode = [value integerValue];
    }else if([key isEqualToString:@"rightViewMode"]) {
        textfield.rightViewMode = [value integerValue];
    }else if([key isEqualToString:@"clearButtonMode"]) {
        textfield.clearButtonMode = [value integerValue];
    }else if([key isEqualToString:@"clearsOnBeginEditing"]) {
        textfield.clearsOnBeginEditing = [value boolValue];
    }else if([key isEqualToString:@"clearsOnInsertion"]) {
        textfield.clearsOnInsertion = [value boolValue];
    }
    return retValue;
}

//从App端获取View属性
+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UITextField class]]) {
        return nil;
    }
    id retValue = nil;
    UITextField *textfield = (UITextField *)instance;
    if([key isEqualToString:@"background"]) {
        UIImage *image = textfield.background;
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"disabledBackground"]) {
        UIImage *image = textfield.disabledBackground;
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }
    return retValue;
}

@end

@implementation ADHTextViewAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UITextView *textview = (UITextView *)view;
    ADHTextViewAttribute *attr = self;
    attr.text = textview.text;
    attr.font = adhFontFromUIFont(textview.font);
    attr.textColor = adhColorFromUIColor(textview.textColor);
    attr.textAlignment = textview.textAlignment;
    attr.selectedRange = textview.selectedRange;
    attr.dataDetectorTypes = textview.dataDetectorTypes;
    attr.editable = textview.editable;
    attr.selectable = textview.selectable;
    attr.allowsEditingTextAttributes = textview.allowsEditingTextAttributes;
    attr.clearsOnInsertion = textview.clearsOnInsertion;
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UITextView class]]) {
        return retValue;
    }
    UITextView *textview = (UITextView *)instance;
    if([key isEqualToString:@"text"]) {
        textview.text = value;
    }else if([key isEqualToString:@"font"]) {
        ADHFont *font = [ADHFont fontWithString:value];
        textview.font = uifontFromAdhFont(font);
    }else if([key isEqualToString:@"textColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        textview.textColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"textAlignment"]) {
        textview.textAlignment = [value integerValue];
    }else if([key isEqualToString:@"editable"]) {
        textview.editable = [value boolValue];
    }else if([key isEqualToString:@"selectable"]) {
        textview.selectable = [value boolValue];
    }else if([key isEqualToString:@"allowsEditingTextAttributes"]) {
        textview.allowsEditingTextAttributes = [value boolValue];
    }else if([key isEqualToString:@"clearsOnInsertion"]) {
        textview.clearsOnInsertion = [value boolValue];
    }
    return retValue;
}

@end

@implementation ADHSliderAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UISlider *slider = (UISlider *)view;
    ADHSliderAttribute *attr = self;
    attr.value = slider.value;
    attr.minimumValue = slider.minimumValue;
    attr.maximumValue = slider.maximumValue;
    attr.continuous = slider.continuous;
    attr.minimumTrackTintColor = adhColorFromUIColor(slider.minimumTrackTintColor);
    attr.maximumTrackTintColor = adhColorFromUIColor(slider.maximumTrackTintColor);
    attr.thumbTintColor = adhColorFromUIColor(slider.thumbTintColor);
    attr.state = slider.state;
    NSMutableDictionary *stateValues = [NSMutableDictionary dictionary];
    NSArray *states = @[
                        [NSNumber numberWithInt:UIControlStateNormal],
                        [NSNumber numberWithInt:UIControlStateHighlighted],
                        [NSNumber numberWithInt:UIControlStateDisabled],
                        [NSNumber numberWithInt:UIControlStateSelected],
                        ];
    for (NSNumber *stateValue in states) {
        UIControlState state = [stateValue integerValue];
        NSMutableDictionary *itemData = [NSMutableDictionary dictionary];
        NSString *key = [NSString stringWithFormat:@"%zd",state];
        stateValues[key] = itemData;
    }
    attr.stateValues = stateValues;
    /*
     * value
     * minimumValue
     * maximumValue
     * minimumValueImage
     * maximumValueImage
     * continuous
     * minimumTrackTintColor
     * maximumTrackTintColor
     * thumbTintColor
     * thumbImage
     * minimumTrackImage
     * maximumTrackImage
     */
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UISlider class]]) {
        return retValue;
    }
    UISlider *slider = (UISlider *)instance;
    if([key isEqualToString:@"value"]) {
        slider.value = [value floatValue];
    }else if([key isEqualToString:@"continuous"]) {
        slider.continuous = [value boolValue];
    }else if([key isEqualToString:@"minimumTrackTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        slider.minimumTrackTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"maximumTrackTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        slider.maximumTrackTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"thumbTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        slider.thumbTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"minimumValueImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        slider.minimumValueImage = image;
    }else if([key isEqualToString:@"maximumValueImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        slider.maximumValueImage = image;
    }else if([key isEqualToString:@"thumbImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [slider setThumbImage:image forState:state];
    }else if([key isEqualToString:@"minimumTrackImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [slider setMinimumTrackImage:image forState:state];
    }else if([key isEqualToString:@"maximumTrackImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [slider setMaximumTrackImage:image forState:state];
    }
    return retValue;
}

//从App端获取View属性
+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UISlider class]]) {
        return nil;
    }
    id retValue = nil;
    UISlider *slider = (UISlider *)instance;
    if([key isEqualToString:@"minimumValueImage"]) {
        NSData *data = UIImagePNGRepresentation(slider.minimumValueImage);
        if(data) {
            retValue = data;
        }
    }else if([key isEqualToString:@"maximumValueImage"]) {
        NSData *data = UIImagePNGRepresentation(slider.maximumValueImage);
        if(data) {
            retValue = data;
        }
    }else if([key isEqualToString:@"thumbImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [slider thumbImageForState:state];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"minimumTrackImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [slider minimumTrackImageForState:state];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"maximumTrackImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [slider maximumTrackImageForState:state];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }
    return retValue;
}


@end


@implementation ADHStepperAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UIStepper *stepper = (UIStepper *)view;
    ADHStepperAttribute *attr = (ADHStepperAttribute *)self;
    attr.value = stepper.value;
    attr.minimumValue = stepper.minimumValue;
    attr.maximumValue = stepper.maximumValue;
    attr.stepValue = stepper.stepValue;
    attr.continuous = stepper.continuous;
    attr.autorepeat = stepper.autorepeat;
    attr.wraps = stepper.wraps;
    attr.state = stepper.state;
    NSMutableDictionary *stateValues = [NSMutableDictionary dictionary];
    NSArray *states = @[
                        [NSNumber numberWithInt:UIControlStateNormal],
                        [NSNumber numberWithInt:UIControlStateHighlighted],
                        [NSNumber numberWithInt:UIControlStateDisabled],
                        [NSNumber numberWithInt:UIControlStateSelected],
                        ];
    for (NSNumber *stateValue in states) {
        UIControlState state = [stateValue integerValue];
        NSMutableDictionary *itemData = [NSMutableDictionary dictionary];
        NSString *key = [NSString stringWithFormat:@"%zd",state];
        stateValues[key] = itemData;
    }
    attr.stateValues = stateValues;
    /*
     * value
     * minimumValue
     * maximumValue
     * stepValue
     * continuous
     * autorepeat
     * wraps
     * tintColor
     * state
     * backgroundImage
     * dividerImage
     * incrementImage
     * decrementImage
     */
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIStepper class]]) {
        return retValue;
    }
    UIStepper *stepper = (UIStepper *)instance;
    if([key isEqualToString:@"value"]) {
        stepper.value = [value floatValue];
    }else if([key isEqualToString:@"backgroundImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [stepper setBackgroundImage:image forState:state];
    }else if([key isEqualToString:@"dividerImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [stepper setDividerImage:image forLeftSegmentState:state rightSegmentState:state];
    }else if([key isEqualToString:@"incrementImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [stepper setIncrementImage:image forState:state];
    }else if([key isEqualToString:@"decrementImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [stepper setDecrementImage:image forState:state];
    }else if([key isEqualToString:@"continuous"]) {
        stepper.continuous = [value boolValue];
    }else if([key isEqualToString:@"autorepeat"]) {
        stepper.autorepeat = [value boolValue];
    }else if([key isEqualToString:@"wraps"]) {
        stepper.wraps = [value boolValue];
    }
    return retValue;
}

//从App端获取View属性
+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UIStepper class]]) {
        return nil;
    }
    id retValue = nil;
    UIStepper *stepper = (UIStepper *)instance;
    if([key isEqualToString:@"backgroundImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [stepper backgroundImageForState:state];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"dividerImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [stepper dividerImageForLeftSegmentState:state rightSegmentState:state];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"incrementImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [stepper incrementImageForState:state];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"decrementImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [stepper decrementImageForState:state];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }
    return retValue;
}

@end

@implementation ADHProgressAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UIProgressView *pv = (UIProgressView *)view;
    ADHProgressAttribute *attr = (ADHProgressAttribute *)self;
    attr.progress = pv.progress;
    attr.progressViewStyle = pv.progressViewStyle;
    attr.progressTintColor = adhColorFromUIColor(pv.progressTintColor);
    attr.trackTintColor = adhColorFromUIColor(pv.trackTintColor);
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIProgressView class]]) {
        return retValue;
    }
    /*
     * progress
     * progressViewStyle
     * progressTintColor
     * trackTintColor
     * progressImage
     * trackImage
     */
    UIProgressView *pv = (UIProgressView *)instance;
    if([key isEqualToString:@"progress"]) {
        pv.progress = [value floatValue];
    }else if([key isEqualToString:@"progressTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        pv.progressTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"trackTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        pv.trackTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"progressImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [pv setProgressImage:image];
    }else if([key isEqualToString:@"trackImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [pv setTrackImage:image];
    }else if([key isEqualToString:@"progressViewStyle"]) {
        pv.progressViewStyle = [value integerValue];
    }
    return retValue;
}

//从App端获取View属性
+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UIProgressView class]]) {
        return nil;
    }
    id retValue = nil;
    UIProgressView *pv = (UIProgressView *)instance;
    if([key isEqualToString:@"progressImage"]) {
        if(pv.progressImage) {
            NSData *data = UIImagePNGRepresentation(pv.progressImage);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"trackImage"]) {
        if(pv.progressImage) {
            NSData *data = UIImagePNGRepresentation(pv.trackImage);
            if(data) {
                retValue = data;
            }
        }
    }
    return retValue;
}

@end


@implementation ADHActivityAttribute (UIView)


- (void)setPropertyWithView: (UIView *)view {
    UIActivityIndicatorView *aiv = (UIActivityIndicatorView *)view;
    ADHActivityAttribute *attr = (ADHActivityAttribute *)self;
    attr.activityIndicatorViewStyle = aiv.activityIndicatorViewStyle;
    attr.color = adhColorFromUIColor(aiv.color);
    attr.hidesWhenStopped = aiv.hidesWhenStopped;
    attr.animating = aiv.animating;
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIActivityIndicatorView class]]) {
        return retValue;
    }
    UIActivityIndicatorView *aiv = (UIActivityIndicatorView *)instance;
    if([key isEqualToString:@"color"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        aiv.color = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"animating"]) {
        BOOL animate = [value boolValue];
        if(animate) {
            [aiv startAnimating];
        }else {
            [aiv stopAnimating];
        }
    }else if([key isEqualToString:@"hidesWhenStopped"]) {
        aiv.hidesWhenStopped = [value boolValue];
    }else if([key isEqualToString:@"activityIndicatorViewStyle"]) {
        aiv.activityIndicatorViewStyle = [value integerValue];
    }
    return retValue;
}

@end

@implementation ADHPageControlAttribute (UIView)

- (void)setPropertyWithView: (UIView *)view {
    UIPageControl *pc = (UIPageControl *)view;
    ADHPageControlAttribute *attr = (ADHPageControlAttribute *)self;
    attr.numberOfPages = pc.numberOfPages;
    attr.currentPage = pc.currentPage;
    attr.pageIndicatorTintColor = adhColorFromUIColor(pc.pageIndicatorTintColor);
    attr.currentPageIndicatorTintColor = adhColorFromUIColor(pc.currentPageIndicatorTintColor);
    attr.hidesForSinglePage = pc.hidesForSinglePage;
    attr.defersCurrentPageDisplay = pc.defersCurrentPageDisplay;
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIPageControl class]]) {
        return retValue;
    }
    UIPageControl *pc = (UIPageControl *)instance;
    if([key isEqualToString:@"pageIndicatorTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        pc.pageIndicatorTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"currentPageIndicatorTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        pc.currentPageIndicatorTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"currentPage"]) {
        pc.currentPage = [value integerValue];
    }else if([key isEqualToString:@"hidesForSinglePage"]) {
        pc.hidesForSinglePage = [value boolValue];
    }else if([key isEqualToString:@"defersCurrentPageDisplay"]) {
        pc.defersCurrentPageDisplay = [value boolValue];
    }
    return retValue;
}

@end

@implementation ADHWindowAttribute (UIView)

/*
 * windowLevel
 * keyWindow
 */
- (void)setPropertyWithView: (UIView *)view {
    UIWindow *window = (UIWindow *)view;
    ADHWindowAttribute *attr = (ADHWindowAttribute *)self;
    attr.windowLevel = window.windowLevel;
    attr.keyWindow = window.keyWindow;
}

@end

@implementation ADHSegmentAttribute (UIView)

- (void)setPropertyWithView:(id)view {
    UISegmentedControl *segment = (UISegmentedControl *)view;
    ADHSegmentAttribute *attr = self;
    attr.numberOfSegments = segment.numberOfSegments;
    attr.momentary = segment.momentary;
    attr.selectedSegmentIndex = segment.selectedSegmentIndex;
    //index values
    NSMutableDictionary *segmentValues = [NSMutableDictionary dictionary];
    for (NSInteger i=0; i<segment.numberOfSegments; i++) {
        NSString *key = [NSString stringWithFormat:@"%zd",i];
        NSString *title = [segment titleForSegmentAtIndex:i];
        NSMutableDictionary *segmentData = [NSMutableDictionary dictionary];
        segmentData[@"title"] = adhvf_safestringfy(title);
        segmentValues[key] = segmentData;
    }
    attr.segmentValues = segmentValues;
    //state values
    NSMutableDictionary *stateValues = [NSMutableDictionary dictionary];
    NSArray *states = @[
                        [NSNumber numberWithInt:UIControlStateNormal],
                        [NSNumber numberWithInt:UIControlStateHighlighted],
                        [NSNumber numberWithInt:UIControlStateDisabled],
                        [NSNumber numberWithInt:UIControlStateSelected],
                        ];
    for (NSNumber *stateValue in states) {
        UIControlState state = [stateValue integerValue];
        NSMutableDictionary *itemData = [NSMutableDictionary dictionary];
        NSString *key = [NSString stringWithFormat:@"%zd",state];
        stateValues[key] = itemData;
    }
    attr.stateValues = stateValues;
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UISegmentedControl class]]) {
        return retValue;
    }
    UISegmentedControl *segment = (UISegmentedControl *)instance;
    if([key isEqualToString:@"selectedSegmentIndex"]) {
        [segment setSelectedSegmentIndex:[value integerValue]];
    }else if([key isEqualToString:@"title"]) {
        NSInteger index = [info[@"selectedSegmentIndex"] integerValue];
        NSString *text = adhvf_safestringfy(value);
        [segment setTitle:text forSegmentAtIndex:index];
    }else if([key isEqualToString:@"image"]) {
        NSInteger index = [info[@"selectedSegmentIndex"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [segment setImage:image forSegmentAtIndex:index];
    }else if([key isEqualToString:@"backgroundImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [segment setBackgroundImage:image forState:state barMetrics:UIBarMetricsDefault];
    }else if([key isEqualToString:@"dividerImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [[UIImage alloc] initWithData:value];
        [segment setDividerImage:image forLeftSegmentState:state rightSegmentState:state barMetrics:UIBarMetricsDefault];;
    }else if([key isEqualToString:@"momentary"]) {
        segment.momentary = [value boolValue];
    }
    return retValue;
}

/*
 * segmentedControlStyle
 * momentary
 * numberOfSegments
 * selectedSegmentIndex
 * title (index)
 * image (index)
 * state
 * backgroundImage
 * dividerImage
 */
//从App端获取View属性
+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UISegmentedControl class]]) {
        return nil;
    }
    id retValue = nil;
    UISegmentedControl *segment = (UISegmentedControl *)instance;
    if([key isEqualToString:@"image"]) {
        NSInteger index = [info[@"selectedSegmentIndex"] integerValue];
        UIImage *image = [segment imageForSegmentAtIndex:index];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"backgroundImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [segment backgroundImageForState:state barMetrics:UIBarMetricsDefault];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }else if([key isEqualToString:@"dividerImage"]) {
        NSInteger state = [info[@"state"] integerValue];
        UIImage *image = [segment dividerImageForLeftSegmentState:state rightSegmentState:state barMetrics:UIBarMetricsDefault];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            if(data) {
                retValue = data;
            }
        }
    }
    return retValue;
}

@end

@implementation ADHPickerViewAttribute (UIView)

- (void)setPropertyWithView:(id)view {
    UIPickerView *pickerView = (UIPickerView *)view;
    ADHPickerViewAttribute *attr = self;
    attr.showsSelectionIndicator = pickerView.showsSelectionIndicator;
    attr.dataSource = [ADHViewDebugUtil stringWithInstance:pickerView.dataSource];
    attr.delegate = [ADHViewDebugUtil stringWithInstance:pickerView.delegate];
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIPickerView class]]) {
        return retValue;
    }
    UIPickerView *pickerView = (UIPickerView *)instance;
    if([key isEqualToString:@"showsSelectionIndicator"]) {
        pickerView.showsSelectionIndicator = [value boolValue];
    }
    return retValue;
}

@end

@implementation ADHDatePickerAttribute (UIView)

/*
 * datePickerMode
 * locale
 * calendar
 * timeZone
 * date
 * minimumDate
 * maximumDate
 * countDownDuration
 * minuteInterval
 */
- (void)setPropertyWithView:(id)view {
    UIDatePicker *pickerView = (UIDatePicker *)view;
    ADHDatePickerAttribute *attr = self;
    attr.datePickerMode = pickerView.datePickerMode;
    attr.locale = [NSString stringWithFormat:@"%@",pickerView.locale.localeIdentifier];
    attr.calendar = [NSString stringWithFormat:@"%@",pickerView.calendar.calendarIdentifier];
    if(pickerView.timeZone) {
        attr.timeZone = [NSString stringWithFormat:@"%@",pickerView.timeZone.name];
    }else {
        attr.timeZone = adhvf_const_emptystr();
    }
    attr.date = [pickerView.date timeIntervalSince1970];
    attr.minimumDate = [pickerView.minimumDate timeIntervalSince1970];
    attr.maximumDate = [pickerView.maximumDate timeIntervalSince1970];
    attr.countDownDuration = pickerView.countDownDuration;
    attr.minuteInterval = pickerView.minuteInterval;
}

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIDatePicker class]]) {
        return retValue;
    }
    UIDatePicker *pickerView = (UIDatePicker *)instance;
    if([key isEqualToString:@"datePickerMode"]) {
        pickerView.datePickerMode = [value integerValue];
    }
    return retValue;
}



@end


@implementation ADHWKWebAttribute (UIView)

/*
 * title
 * url
 * navigationDelegate
 * UIDelegate
 * estimatedProgress
 * hasOnlySecureContent
 * loading
 * canGoBack
 * canGoForward
 */
- (void)setPropertyWithView:(id)view {
    WKWebView *webView = (WKWebView *)view;
    ADHWKWebAttribute *attr = self;
    attr.title = webView.title;
    attr.url = [webView.URL absoluteString];
    attr.navigationDelegate = [ADHViewDebugUtil stringWithInstance: webView.navigationDelegate];
    attr.UIDelegate = [ADHViewDebugUtil stringWithInstance: webView.UIDelegate];
    attr.estimatedProgress = webView.estimatedProgress;
    attr.hasOnlySecureContent = webView.hasOnlySecureContent;
    attr.loading = webView.loading;
    attr.canGoBack = webView.canGoBack;
    attr.canGoForward = webView.canGoBack;
}

//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[WKWebView class]]) {
        return retValue;
    }
    WKWebView *webView = (WKWebView *)instance;
    if([key isEqualToString:@"url"]) {
        NSURL *requestURL = [NSURL URLWithString:value];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
        [webView loadRequest:request];
    }else if([key isEqualToString:@"action"]) {
        NSString *action = value;
        if([action isEqualToString:@"back"]) {
            if([webView canGoBack]) {
                [webView goBack];
            }
        }else if([action isEqualToString:@"forward"]) {
            if([webView canGoForward]) {
                [webView goForward];
            }
        }else if([action isEqualToString:@"stop"]) {
            if([webView isLoading]) {
                [webView stopLoading];
            }
        }else if([action isEqualToString:@"refresh"]) {
            [webView reload];
        }
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"title"] = adhvf_safestringfy(webView.title);
        data[@"url"] = adhvf_safestringfy(webView.URL.absoluteString);
        data[@"estimatedProgress"] = [NSNumber numberWithFloat:webView.estimatedProgress];
        data[@"hasOnlySecureContent"] = [NSNumber numberWithBool:webView.hasOnlySecureContent];
        data[@"loading"] = [NSNumber numberWithBool:webView.isLoading];
        data[@"canGoBack"] = [NSNumber numberWithBool:webView.canGoBack];
        data[@"canGoForward"] = [NSNumber numberWithBool:webView.canGoForward];
        retValue = data;
    }
    return retValue;
}

@end

@implementation ADHScrollViewAttribute (UIView)

- (void)setPropertyWithView:(id)view {
    UIScrollView *scrollView = (UIScrollView *)view;
    ADHScrollViewAttribute *attr = self;
    attr.contentOffset = scrollView.contentOffset;
    attr.contentSize = scrollView.contentSize;
    attr.contentInset = adhInsetsFromInsets(scrollView.contentInset);
    if (@available(iOS 11.0, *)) {
        attr.adjustedContentInset = adhInsetsFromInsets(scrollView.adjustedContentInset);
        attr.contentInsetAdjustmentBehavior = scrollView.contentInsetAdjustmentBehavior;
    } else {
        attr.adjustedContentInset = adhInsetsFromInsets(UIEdgeInsetsZero);
        attr.contentInsetAdjustmentBehavior = 0;
    }
    attr.directionalLockEnabled = scrollView.directionalLockEnabled;
    attr.bounces = scrollView.bounces;
    attr.alwaysBounceVertical = scrollView.alwaysBounceVertical;
    attr.alwaysBounceHorizontal = scrollView.alwaysBounceHorizontal;
    attr.pagingEnabled = scrollView.pagingEnabled;
    attr.scrollEnabled = scrollView.scrollEnabled;
    attr.showsHorizontalScrollIndicator = scrollView.showsHorizontalScrollIndicator;
    attr.showsVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator;
    attr.scrollIndicatorInsets = adhInsetsFromInsets(scrollView.scrollIndicatorInsets);
    attr.indicatorStyle = scrollView.indicatorStyle;
    if(scrollView.decelerationRate == UIScrollViewDecelerationRateFast) {
        attr.decelerationRate = 1;
    }else {
        attr.decelerationRate = 0;
    }
    attr.minimumZoomScale = scrollView.minimumZoomScale;
    attr.maximumZoomScale = scrollView.maximumZoomScale;
    attr.zoomScale = scrollView.zoomScale;
    attr.scrollsToTop = scrollView.scrollsToTop;
    attr.keyboardDismissMode = scrollView.keyboardDismissMode;
    attr.delegate = [ADHViewDebugUtil stringWithInstance:scrollView.delegate];
}

/*
 * contentOffset
 * contentSize
 * contentInset
 * adjustedContentInset
 * contentInsetAdjustmentBehavior
 * directionalLockEnabled
 * bounces
 * alwaysBounceVertical
 * alwaysBounceHorizontal
 * pagingEnabled
 * scrollEnabled
 * showsHorizontalScrollIndicator
 * showsVerticalScrollIndicator
 * scrollIndicatorInsets
 * indicatorStyle (UIScrollViewIndicatorStyle)
 * decelerationRate (UIScrollViewDecelerationRate)
 * indexDisplayMode (UIScrollViewIndexDisplayMode)
 * minimumZoomScale
 * maximumZoomScale
 * zoomScale
 * scrollsToTop
 * keyboardDismissMode (UIScrollViewKeyboardDismissMode)
 * delegate
 */
//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIScrollView class]]) {
        return retValue;
    }
    UIScrollView *scrollView = (UIScrollView *)instance;
    if([key isEqualToString:@"contentInsetAdjustmentBehavior"]) {
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = [value integerValue];
        }
    }else if([key isEqualToString:@"directionalLockEnabled"]) {
        scrollView.directionalLockEnabled = [value boolValue];
    }else if([key isEqualToString:@"bounces"]) {
        scrollView.bounces = [value boolValue];
    }else if([key isEqualToString:@"alwaysBounceVertical"]) {
        scrollView.alwaysBounceVertical = [value boolValue];
    }else if([key isEqualToString:@"alwaysBounceHorizontal"]) {
        scrollView.alwaysBounceHorizontal = [value boolValue];
    }else if([key isEqualToString:@"pagingEnabled"]) {
        scrollView.pagingEnabled = [value boolValue];
    }else if([key isEqualToString:@"scrollEnabled"]) {
        scrollView.scrollEnabled = [value boolValue];
    }else if([key isEqualToString:@"showsHorizontalScrollIndicator"]) {
        scrollView.showsHorizontalScrollIndicator = [value boolValue];
    }else if([key isEqualToString:@"showsVerticalScrollIndicator"]) {
        scrollView.showsVerticalScrollIndicator = [value boolValue];
    }else if([key isEqualToString:@"indicatorStyle"]) {
        scrollView.indicatorStyle = [value integerValue];
    }else if([key isEqualToString:@"decelerationRate"]) {
        NSInteger intValue = [value integerValue];
        if(intValue == 1) {
            scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        }else {
            scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        }
    }else if([key isEqualToString:@"zoomScale"]) {
        scrollView.zoomScale = [value floatValue];
    }else if([key isEqualToString:@"scrollsToTop"]) {
        scrollView.scrollsToTop = [value boolValue];
    }else if([key isEqualToString:@"keyboardDismissMode"]) {
        scrollView.keyboardDismissMode = [value integerValue];
    }
    return retValue;
}

@end

@implementation ADHTableViewAttribute (UIView)

/*
 * delegate
 * dataSource
 * style
 * rowHeight
 * sectionHeaderHeight
 * sectionFooterHeight
 * estimatedRowHeight
 * estimatedSectionHeaderHeight
 * estimatedSectionFooterHeight
 * separatorStyle
 * separatorInset
 * separatorColor
 */
- (void)setPropertyWithView:(id)view {
    UITableView *tableView = (UITableView *)view;
    ADHTableViewAttribute *attr = self;
    attr.delegate = [ADHViewDebugUtil stringWithInstance:tableView.delegate];
    attr.dataSource = [ADHViewDebugUtil stringWithInstance:tableView.dataSource];
    attr.style = tableView.style;
    attr.rowHeight = tableView.rowHeight;
    attr.sectionHeaderHeight = tableView.sectionHeaderHeight;
    attr.sectionFooterHeight = tableView.sectionFooterHeight;
    attr.estimatedRowHeight = tableView.estimatedRowHeight;
    attr.estimatedSectionHeaderHeight = tableView.estimatedSectionHeaderHeight;
    attr.estimatedSectionFooterHeight = tableView.estimatedSectionFooterHeight;
    attr.separatorStyle = tableView.separatorStyle;
    attr.separatorInset = adhInsetsFromInsets(tableView.separatorInset);
    attr.separatorColor = adhColorFromUIColor(tableView.separatorColor);
}

//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UITableView class]]) {
        return retValue;
    }
    UITableView *tableView = (UITableView *)instance;
    if([key isEqualToString:@"separatorColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        tableView.separatorColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"separatorStyle"]) {
        tableView.separatorStyle = [value integerValue];
    }
    return retValue;
}

@end

@implementation ADHTableCellAttribute (UIView)

/*
 * reuseIdentifier
 * selectionStyle
 * selected
 * highlighted
 * editingStyle
 * accessoryType
 * editingAccessoryType
 * indentationLevel
 * indentationWidth
 * separatorInset
 * focusStyle (iOS 9)
 */
- (void)setPropertyWithView:(id)view {
    UITableViewCell *cell = (UITableViewCell *)view;
    ADHTableCellAttribute *attr = self;
    attr.reuseIdentifier = cell.reuseIdentifier;
    attr.selectionStyle = cell.selectionStyle;
    attr.selected = cell.selected;
    attr.highlighted = cell.highlighted;
    attr.editingStyle = cell.editingStyle;
    attr.accessoryType = cell.accessoryType;
    attr.editingAccessoryType = cell.editingAccessoryType;
    attr.indentationWidth = cell.indentationWidth;
    attr.separatorInset = adhInsetsFromInsets(cell.separatorInset);
    if (@available(iOS 9.0, *)) {
        attr.focusStyle = cell.focusStyle;
    } else {
        attr.focusStyle = 0;
    }
}

//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UITableViewCell class]]) {
        return retValue;
    }
    UITableViewCell *cell = (UITableViewCell *)instance;
    if([key isEqualToString:@"selectionStyle"]) {
        cell.selectionStyle = [value integerValue];
    }else if([key isEqualToString:@"selected"]) {
        cell.selected = [value boolValue];
    }else if([key isEqualToString:@"highlighted"]) {
        cell.highlighted = [value boolValue];
    }else if([key isEqualToString:@"accessoryType"]) {
        cell.accessoryType = [value integerValue];
    }else if([key isEqualToString:@"editingAccessoryType"]) {
        cell.editingAccessoryType = [value integerValue];
    }else if([key isEqualToString:@"indentationLevel"]) {
        cell.indentationLevel = [value integerValue];
    }else if([key isEqualToString:@"indentationWidth"]) {
        cell.indentationWidth = [value floatValue];
    }else if([key isEqualToString:@"focusStyle"]) {
        if (@available(iOS 9.0, *)) {
            cell.focusStyle = [value integerValue];
        }
    }
    return retValue;
}

@end

@implementation ADHCollectionAttribute (UIView)

/*
 * collectionViewLayout （ClassName）
 * delegate
 * dataSource
 * allowsSelection
 * allowsMultipleSelection
 */
- (void)setPropertyWithView:(id)view {
    UICollectionView *collectionView = (UICollectionView *)view;
    ADHCollectionAttribute *attr = self;
    attr.collectionViewLayout = [self getCollectionLayoutText:collectionView.collectionViewLayout];
    attr.delegate = [ADHViewDebugUtil stringWithInstance:collectionView.delegate];
    attr.dataSource = [ADHViewDebugUtil stringWithInstance:collectionView.dataSource];
    attr.allowsSelection = collectionView.allowsSelection;
    attr.allowsMultipleSelection = collectionView.allowsMultipleSelection;
}

- (NSString *)getCollectionLayoutText: (UICollectionViewLayout *)viewLayout {
    NSString *text = nil;
    if(viewLayout) {
        if([viewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)viewLayout;
            NSMutableArray *items = [NSMutableArray array];
            [items addObject:[NSString stringWithFormat:@"Class : %@\n",[ADHViewDebugUtil stringWithInstance:layout]]];
            [items addObject:[NSString stringWithFormat:@"Min Line Spacing : %.1f",layout.minimumLineSpacing]];
            [items addObject:[NSString stringWithFormat:@"Min Interitem Spacing : %.1f",layout.minimumInteritemSpacing]];
            [items addObject:[NSString stringWithFormat:@"Item Size : %@",[ADHViewDebugUtil presentStringWithCGSize:layout.itemSize]]];
            [items addObject:[NSString stringWithFormat:@"Estimated Item Size : %@",[ADHViewDebugUtil presentStringWithCGSize:layout.estimatedItemSize]]];
            NSString *direction = nil;
            if(layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                direction = @"Horizontal";
            }else if(layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
                direction = @"Vertical";
            }
            [items addObject:[NSString stringWithFormat:@"Section Header Size : %@",[ADHViewDebugUtil presentStringWithCGSize:layout.headerReferenceSize]]];
            [items addObject:[NSString stringWithFormat:@"Section Footer Size : %@",[ADHViewDebugUtil presentStringWithCGSize:layout.footerReferenceSize]]];
            ADH_INSETS insets = adhInsetsFromInsets(layout.sectionInset);
            [items addObject:[NSString stringWithFormat:@"Section Inset : %@",[ADHViewDebugUtil presentStringWithAdhInsets:insets]]];
            if (@available(iOS 9.0, *)) {
                [items addObject:[NSString stringWithFormat:@"Section Header Pin : %@",[ADHViewDebugUtil stringWithBool:layout.sectionFootersPinToVisibleBounds]]];
                [items addObject:[NSString stringWithFormat:@"Section Footer Pin : %@",[ADHViewDebugUtil stringWithBool:layout.sectionFootersPinToVisibleBounds]]];
            }
            text = [items componentsJoinedByString:@"\n"];
        }else {
            text = [ADHViewDebugUtil stringWithInstance:viewLayout];
        }
    }else {
        text = adhvf_const_emptystr();
    }
    return text;
}

//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UICollectionView class]]) {
        return retValue;
    }
    UICollectionView *collectionView = (UICollectionView *)instance;
    if([key isEqualToString:@"allowsSelection"]) {
        collectionView.allowsSelection = [value boolValue];
    }else if([key isEqualToString:@"allowsMultipleSelection"]) {
        collectionView.allowsMultipleSelection = [value boolValue];
    }
    return retValue;
}

@end

@implementation ADHCollectReusableAttribute (UIView)

/*
reuseIdentifier
*/
- (void)setPropertyWithView:(id)view {
    UICollectionReusableView *reuseView = (UICollectionReusableView *)view;
    ADHCollectReusableAttribute *attr = self;
    attr.reuseIdentifier = reuseView.reuseIdentifier;
}

@end

@implementation ADHCollectCellAttribute (UIView)

/*
 * selected
 * highlighted
 */
- (void)setPropertyWithView:(id)view {
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
    ADHCollectCellAttribute *attr = self;
    attr.selected = cell.selected;
    attr.highlighted = cell.highlighted;
}

//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UICollectionViewCell class]]) {
        return retValue;
    }
    UICollectionViewCell *cell = (UICollectionViewCell *)instance;
    if([key isEqualToString:@"selected"]) {
        cell.selected = [value boolValue];
    }else if([key isEqualToString:@"highlighted"]) {
        cell.highlighted = [value boolValue];
    }
    return retValue;
}

@end

@implementation ADHStackAttribute (UIView)

/*
 * axis
 * distribution
 * alignment
 * spacing
 * baselineRelativeArrangement
 * layoutMarginsRelativeArrangement
 */
- (void)setPropertyWithView:(id)view {
    if (@available(iOS 9.0, *)) {
        UIStackView *stackView = (UIStackView *)view;
        ADHStackAttribute *attr = self;
        attr.axis = stackView.axis;
        attr.distribution = stackView.distribution;
        attr.alignment = stackView.alignment;
        attr.spacing = stackView.spacing;
        attr.baselineRelativeArrangement = stackView.baselineRelativeArrangement;
        attr.layoutMarginsRelativeArrangement = stackView.layoutMarginsRelativeArrangement;
    }
}

//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if (@available(iOS 9.0, *)) {
        if(![instance isKindOfClass:[UIStackView class]]) {
            return retValue;
        }
        UIStackView *stackView = (UIStackView *)instance;
        if([key isEqualToString:@"axis"]) {
            stackView.axis = [value integerValue];
        }else if([key isEqualToString:@"distribution"]) {
            stackView.distribution = [value integerValue];
        }else if([key isEqualToString:@"alignment"]) {
            stackView.alignment = [value integerValue];
        }else if([key isEqualToString:@"spacing"]) {
            stackView.spacing = [value floatValue];
        }else if([key isEqualToString:@"baselineRelativeArrangement"]) {
            stackView.baselineRelativeArrangement = [value boolValue];
        }else if([key isEqualToString:@"layoutMarginsRelativeArrangement"]) {
            stackView.layoutMarginsRelativeArrangement = [value boolValue];
        }
    }
    return retValue;
}

@end

@implementation ADHNaviBarAttribute (UIView)

- (void)setPropertyWithView:(id)view {
    UINavigationBar *naviBar = (UINavigationBar *)view;
    ADHNaviBarAttribute *attr = self;
    attr.barStyle = naviBar.barStyle;
    attr.translucent = naviBar.translucent;
    if (@available(iOS 11.0, *)) {
        attr.prefersLargeTitles = naviBar.prefersLargeTitles;
    } else {
        attr.prefersLargeTitles = NO;
    }
    attr.tintColor = adhColorFromUIColor(naviBar.tintColor);
    attr.barTintColor = adhColorFromUIColor(naviBar.barTintColor);
}

/*
 * barStyle
 * translucent
 * prefersLargeTitles (11)
 * tintColor
 * barTintColor
 * backgroundImage
 * shadowImage
 * backIndicatorImage
 * backIndicatorTransitionMaskImage
 */
//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UINavigationBar class]]) {
        return retValue;
    }
    UINavigationBar *naviBar = (UINavigationBar *)instance;
    if([key isEqualToString:@"barStyle"]) {
        naviBar.barStyle = [value integerValue];
    }else if([key isEqualToString:@"translucent"]) {
        naviBar.translucent = [value boolValue];
    }else if([key isEqualToString:@"prefersLargeTitles"]) {
        if (@available(iOS 11.0, *)) {
            naviBar.prefersLargeTitles = [value boolValue];
        }
    }else if([key isEqualToString:@"tintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        naviBar.tintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"barTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        naviBar.barTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"backgroundImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [naviBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }else if([key isEqualToString:@"shadowImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [naviBar setShadowImage:image];
    }else if([key isEqualToString:@"backIndicatorImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [naviBar setBackIndicatorImage:image];
    }else if([key isEqualToString:@"backIndicatorTransitionMaskImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [naviBar setBackIndicatorTransitionMaskImage:image];
    }
    return retValue;
}

+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UINavigationBar class]]) {
        return nil;
    }
    id retValue = nil;
    UINavigationBar *naviBar = (UINavigationBar *)instance;
    if([key isEqualToString:@"backgroundImage"]) {
        UIImage *image = [naviBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            retValue = data;
        }
    }else if([key isEqualToString:@"shadowImage"]) {
        UIImage *image = [naviBar shadowImage];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            retValue = data;
        }
    }else if([key isEqualToString:@"backIndicatorImage"]) {
        UIImage *image = [naviBar backIndicatorImage];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            retValue = data;
        }
    }else if([key isEqualToString:@"backIndicatorTransitionMaskImage"]) {
        UIImage *image = [naviBar backIndicatorTransitionMaskImage];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            retValue = data;
        }
    }
    return retValue;
}

@end

@implementation ADHTabBarAttribute (UIView)

- (void)setPropertyWithView:(id)view {
    UITabBar *tabBar = (UITabBar *)view;
    ADHTabBarAttribute *attr = self;
    attr.tintColor = adhColorFromUIColor(tabBar.tintColor);
    attr.barTintColor = adhColorFromUIColor(tabBar.barTintColor);
    if (@available(iOS 10.0, *)) {
        attr.unselectedItemTintColor = adhColorFromUIColor(tabBar.unselectedItemTintColor);
    }else {
        attr.unselectedItemTintColor = adhColorZero();
    }
    attr.itemPositioning = tabBar.itemPositioning;
    attr.itemWidth = tabBar.itemWidth;
    attr.itemSpacing = tabBar.itemSpacing;
    attr.barStyle = tabBar.barStyle;
    attr.translucent = tabBar.translucent;
}

//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UITabBar class]]) {
        return retValue;
    }
    UITabBar *tabBar = (UITabBar *)instance;
    if([key isEqualToString:@"tintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        tabBar.tintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"barTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        tabBar.barTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"unselectedItemTintColor"]) {
        if (@available(iOS 10.0, *)) {
            ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
            tabBar.unselectedItemTintColor = uicolorFromAdhColor(color);
        }
    }else if([key isEqualToString:@"backgroundImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [tabBar setBackgroundImage:image];
    }else if([key isEqualToString:@"selectionIndicatorImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [tabBar setSelectionIndicatorImage:image];
    }else if([key isEqualToString:@"shadowImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [tabBar setShadowImage:image];
    }else if([key isEqualToString:@"translucent"]) {
        tabBar.translucent = [value boolValue];
    }else if([key isEqualToString:@"itemPositioning"]) {
        tabBar.itemPositioning = [value integerValue];
    }else if([key isEqualToString:@"itemWidth"]) {
        tabBar.itemWidth = [value floatValue];
    }else if([key isEqualToString:@"itemSpacing"]) {
        tabBar.itemSpacing = [value floatValue];
    }else if([key isEqualToString:@"barStyle"]) {
        tabBar.barStyle = [value integerValue];
    }
    return retValue;
}

/*
 * tintColor
 * barTintColor
 * unselectedItemTintColor  (ios 10)
 * backgroundImage
 * selectionIndicatorImage
 * shadowImage
 * itemPositioning
 * itemWidth
 * itemSpacing
 * barStyle
 * translucent
 */
+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UITabBar class]]) {
        return nil;
    }
    id retValue = nil;
    UITabBar *tabBar = (UITabBar *)instance;
    if([key isEqualToString:@"backgroundImage"]) {
        UIImage *image = [tabBar backgroundImage];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            retValue = data;
        }
    }else if([key isEqualToString:@"selectionIndicatorImage"]) {
        UIImage *image = [tabBar selectionIndicatorImage];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            retValue = data;
        }
    }else if([key isEqualToString:@"shadowImage"]) {
        UIImage *image = [tabBar shadowImage];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            retValue = data;
        }
    }
    return retValue;
}

@end

@implementation ADHToolBarAttribute (UIView)

- (void)setPropertyWithView:(id)view {
    UIToolbar *toolBar = (UIToolbar *)view;
    ADHToolBarAttribute *attr = self;
    attr.barStyle = toolBar.barStyle;
    attr.translucent = toolBar.translucent;
    attr.tintColor = adhColorFromUIColor(toolBar.tintColor);
    attr.barTintColor = adhColorFromUIColor(toolBar.barTintColor);
}

/*
 * barStyle
 * translucent
 * tintColor
 * barTintColor
 * backgroundImage
 * shadowImage
 */
//App端设置view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    id retValue = value;
    if(![instance isKindOfClass:[UIToolbar class]]) {
        return retValue;
    }
    UIToolbar *toolBar = (UIToolbar *)instance;
    if([key isEqualToString:@"barStyle"]) {
        toolBar.barStyle = [value integerValue];
    }else if([key isEqualToString:@"translucent"]) {
        toolBar.translucent = [value boolValue];
    }else if([key isEqualToString:@"barTintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        toolBar.barTintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"tintColor"]) {
        ADH_COLOR color = [ADHViewDebugUtil colorWithString:value];
        toolBar.tintColor = uicolorFromAdhColor(color);
    }else if([key isEqualToString:@"backgroundImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [toolBar setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }else if([key isEqualToString:@"shadowImage"]) {
        UIImage *image = [[UIImage alloc] initWithData:value];
        [toolBar setShadowImage:image forToolbarPosition:UIBarPositionAny];
    }
    return retValue;
}

+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo {
    if(![instance isKindOfClass:[UIToolbar class]]) {
        return nil;
    }
    id retValue = nil;
    UIToolbar *toolBar = (UIToolbar *)instance;
    if([key isEqualToString:@"backgroundImage"]) {
        UIImage *image = [toolBar backgroundImageForToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            retValue = data;
        }
    }else if([key isEqualToString:@"shadowImage"]) {
        UIImage *image = [toolBar shadowImageForToolbarPosition:UIBarPositionAny];
        if(image) {
            NSData *data = UIImagePNGRepresentation(image);
            retValue = data;
        }
    }
    return retValue;
}

@end
