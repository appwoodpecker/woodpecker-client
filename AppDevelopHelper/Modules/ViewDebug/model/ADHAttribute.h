//
//  ADHAttribute.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/20.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef ADH_HELP
#define ADH_HELP

#define ADH_ATTR(keyValue,nameValue,typeValue) ([self addAttrItem:keyValue name:nameValue type:typeValue])
#define ADH_ATTR_SUB(keyValue,subKeyValue,nameValue,typeValue) ([self addAttrItem:keyValue subKey:subKeyValue name:nameValue type:typeValue])
#define ADH_POPUP(titleValue,theValue) ([ADHPopupItem itemWithTitle:titleValue value:theValue])
#define ATTR_iOS9 ([self isVersionEqualOrGreaterThan:9])
#define ATTR_iOS10 ([self isVersionEqualOrGreaterThan:10])
#define ATTR_iOS11 ([self isVersionEqualOrGreaterThan:11])
#define ATTR_iOS12 ([self isVersionEqualOrGreaterThan:12])
#define ATTR_iOS(major,minor) ([self isVersionEqualOrGreaterThan:major minVersion:minor])

#endif

/**
 * Render
 */
typedef NS_ENUM(NSUInteger, ADHAttrType) {
    ADHAttrTypeText = 0,    //read only text
    ADHAttrTypeColor,       //color
    ADHAttrTypeFrame,       //frame
    ADHAttrTypeEditText,    //editable text
    ADHAttrTypeAutoresizing, //autoresizing
    ADHAttrTypeImage,       //image
    ADHAttrTypePopup,       //popup
    ADHAttrTypeSelect,      //select(edit popup)
    ADHAttrTypeSlider,      //slider
    ADHAttrTypeStepper,     //stepper
    ADHAttrTypeBoolean,     //boolean
    ADHAttrTypeValue,       //value
    ADHAttrTypeFont,        //font
    ADHAttrTypeWebNavi,     //webview navigation
    ADHAttrTypeGesture,     //gesture
    ADHAttrTypeInsets,      //insets
};

typedef NS_ENUM(NSUInteger, ADHAttrValueFormat) {
    ADHAttrValueFormatFloat = 0,  //float 0.1
    ADHAttrValueFormatFloat2,     //float 0.01
    ADHAttrValueFormatInt,        //int
};

//attr某一key修改后影响范围
typedef NS_ENUM(NSUInteger, ADHAttrItemAffect) {
    ADHAttrItemAffectDefault = 0,   //只影响自己
    ADHAttrItemAffectHeight,        //影响高度，其他cell需要布局
    ADHAttrItemAffectLarge,         //影响其他item值，需要reload
};


@interface ADHPopupItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) ADH_INT value;
+ (ADHPopupItem *)itemWithTitle: (NSString *)title value: (ADH_INT)value;

@end

@class ADHAttribute;
@interface ADHAttrItem : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *subKey;
@property (nonatomic, assign) ADHAttrType type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) ADHAttribute *attribute;

@end

//abstract
@class ADHViewNode;
@interface ADHAttribute : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, weak) ADHViewNode *viewNode;

+ (instancetype)attribute;

- (ADHAttrItem *)addAttrItem: (NSString *)key name: (NSString *)name type: (ADHAttrType)type;
- (ADHAttrItem *)addAttrItem: (NSString *)key subKey: (NSString *)subKey name: (NSString *)name type: (ADHAttrType)type;
- (NSDictionary *)dicPresentation;

@property (nonatomic, weak) id appContext;

//subclass override
- (void)setPropertyWithView: (id)view;
+ (ADHAttribute *)attributeWithData: (NSDictionary *)data;
- (void)setPropertyWithData: (NSDictionary *)data;
- (NSDictionary *)getPropertyData;
- (NSArray<ADHAttrItem *> *)itemList;
- (id)getAttrValue: (ADHAttrItem *)item;

//从App获取属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeGetValueRequest: (ADHAttrItem *)item;
//向App设置属性请求从本地获取额外信息
- (NSDictionary *)getInfoBeforeSetValueRequest: (ADHAttrItem *)item;
//从App端获取属性后，更新本地值
- (void)updateAttrValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info localInfo: (NSDictionary *)localInfo;
//Mac本地属性状态
- (void)updateStateValue: (ADHAttrItem *)item value: (id)value info:(NSDictionary *)info;

//设置App端view属性
+ (id)updateValueWithInstance: (id)instance key: (NSString *)key value: (id)value info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo;
//从App端获取View属性
+ (id)getValueWithInstance: (id)instance key: (NSString *)key info: (NSDictionary *)info retInfo: (NSDictionary **)retInfo;

//tree视图类型icon
- (NSString *)classTypeIcon;

- (ADHAttrItemAffect)getAffectWithItem: (ADHAttrItem *)item;
- (BOOL)isVersionEqualOrGreaterThan: (NSInteger)ver;


@end

@interface ADHViewAttribute : ADHAttribute

@property (nonatomic, assign) ADH_FRAME frame;
//相对窗口frame
@property (nonatomic, assign) ADH_FRAME frameInWindow;
@property (nonatomic, assign) struct ADH_COLOR backgroundColor;
//alpha
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) ADH_INT tag;
@property (nonatomic, assign) ADH_INT contentMode;
@property (nonatomic, assign) ADH_COLOR tintColor;
@property (nonatomic, assign) BOOL userInteractionEnabled;
@property (nonatomic, assign) BOOL opaque;
@property (nonatomic, assign) BOOL clipsToBounds;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) ADH_INT autoresizingMask;
@property (nonatomic, strong) NSArray *gestureRecognizers;

///gesture
- (NSArray<ADHAttrItem *> *)getGestureRecognizerItemList: (NSInteger)index;
- (id)getGestureRecognzierAttrValue: (ADHAttrItem *)item index: (NSInteger)index;

@end


@interface ADHLabelAttribute : ADHAttribute

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) ADH_COLOR textColor;
@property (nonatomic, strong) ADHFont *font;
@property (nonatomic, assign) ADH_INT alignment;
@property (nonatomic, assign) ADH_INT numberOfLines;
@property (nonatomic, assign) ADH_INT linebreakMode;
@property (nonatomic, assign) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic, assign) CGFloat minimumScaleFactor;
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;
@property (nonatomic, assign) ADH_INT baselineAdjustment;

@end

@interface ADHImageViewAttribute : ADHAttribute

//图片需要下载
@property (nonatomic, strong) NSData *image;
@property (nonatomic, assign) BOOL imageAnimated;
@property (nonatomic, strong) NSData *highlightedImage;
@property (nonatomic, assign) BOOL highlightedImageAnimated;

@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) double animationDuration;
@property (nonatomic, assign) ADH_INT animationRepeatCount;

@end

@interface ADHControlAttribute : ADHAttribute

@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic, assign) BOOL highlighted;
@property(nonatomic, assign) ADH_INT verticalAlignment;
@property(nonatomic, assign) ADH_INT horizontalAlignment;

@end

@interface ADHButtonAttribute : ADHAttribute

@property (nonatomic, assign) ADH_INT state;
@property (nonatomic, assign) ADH_INT buttonType;
@property (nonatomic, assign) ADH_INSETS contentEdgeInsets;
@property (nonatomic, assign) ADH_INSETS titleEdgeInsets;
@property (nonatomic, assign) ADH_INSETS imageEdgeInsets;
@property (nonatomic, strong) NSDictionary *stateValues;
@property (nonatomic, assign) BOOL reversesTitleShadowWhenHighlighted;
@property (nonatomic, assign) BOOL adjustsImageWhenHighlighted;
@property (nonatomic, assign) BOOL adjustsImageWhenDisabled;
@property (nonatomic, assign) BOOL showsTouchWhenHighlighted;

@end


@interface ADHTextFieldAttribute : ADHAttribute

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) ADH_COLOR textColor;
@property (nonatomic, strong) ADHFont *font;
@property (nonatomic, assign) ADH_INT textAlignment;
@property (nonatomic, assign) ADH_INT borderStyle;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign) BOOL clearsOnBeginEditing;
@property (nonatomic, assign) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic, assign) CGFloat minimumFontSize;
@property (nonatomic, strong) NSData * background;
@property (nonatomic, strong) NSData * disabledBackground;
@property (nonatomic, assign) ADH_INT clearButtonMode;
@property (nonatomic, assign) ADH_INT leftViewMode;
@property (nonatomic, assign) ADH_INT rightViewMode;
@property (nonatomic, assign) BOOL clearsOnInsertion;

@end

@interface ADHTextViewAttribute : ADHAttribute

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) ADHFont *font;
@property (nonatomic, assign) ADH_COLOR textColor;
@property (nonatomic, assign) ADH_INT textAlignment;
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, assign) ADH_INT dataDetectorTypes;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL selectable;
@property (nonatomic, assign) BOOL allowsEditingTextAttributes;
@property (nonatomic, assign) BOOL clearsOnInsertion;

@end

@interface ADHSliderAttribute : ADHAttribute

@property (nonatomic, assign) float value;
@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;
@property (nonatomic, strong) NSData *minimumValueImage;
@property (nonatomic, strong) NSData *maximumValueImage;
@property (nonatomic, assign) BOOL continuous;
@property (nonatomic, assign) ADH_COLOR minimumTrackTintColor;
@property (nonatomic, assign) ADH_COLOR maximumTrackTintColor;
@property (nonatomic, assign) ADH_COLOR thumbTintColor;
@property (nonatomic, assign) ADH_INT state;
@property (nonatomic, strong) NSDictionary *stateValues;

@end


@interface ADHStepperAttribute : ADHAttribute

@property (nonatomic, assign) double value;
@property (nonatomic, assign) double minimumValue;
@property (nonatomic, assign) double maximumValue;
@property (nonatomic, assign) double stepValue;
@property (nonatomic, assign) BOOL continuous;
@property (nonatomic, assign) BOOL autorepeat;
@property (nonatomic, assign) BOOL wraps;
@property (nonatomic, assign) ADH_INT state;
@property (nonatomic, strong) NSDictionary *stateValues;

@end


//UIProgressView
@interface ADHProgressAttribute : ADHAttribute

@property (nonatomic, assign) float progress;
@property (nonatomic, assign) ADH_INT progressViewStyle;
@property (nonatomic, assign) ADH_COLOR progressTintColor;
@property (nonatomic, assign) ADH_COLOR trackTintColor;
@property (nonatomic, strong) NSData *progressImage;
@property (nonatomic, strong) NSData *trackImage;

@end

@interface ADHActivityAttribute : ADHAttribute

@property (nonatomic, assign) ADH_INT activityIndicatorViewStyle;
@property (nonatomic, assign) ADH_COLOR color;
@property (nonatomic, assign) BOOL hidesWhenStopped;
@property (nonatomic, assign) BOOL animating;

@end

@interface ADHPageControlAttribute : ADHAttribute

@property (nonatomic, assign) ADH_INT numberOfPages;
@property (nonatomic, assign) ADH_INT currentPage;
@property (nonatomic, assign) ADH_COLOR pageIndicatorTintColor;
@property (nonatomic, assign) ADH_COLOR currentPageIndicatorTintColor;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic, assign) BOOL defersCurrentPageDisplay;

@end

@interface ADHWindowAttribute : ADHAttribute

@property (nonatomic, assign) ADH_INT windowLevel;
@property (nonatomic, assign) BOOL keyWindow;

@end

@interface ADHSegmentAttribute : ADHAttribute

@property (nonatomic, assign) ADH_INT numberOfSegments;
@property (nonatomic, assign) ADH_INT selectedSegmentIndex;
@property (nonatomic, assign) BOOL momentary;
@property (nonatomic, strong) NSDictionary *segmentValues;
@property (nonatomic, assign) ADH_INT state;
@property (nonatomic, strong) NSDictionary *stateValues;

@end


@interface ADHPickerViewAttribute : ADHAttribute

@property (nonatomic, assign) BOOL showsSelectionIndicator;
@property (nonatomic, strong) NSString *dataSource;
@property (nonatomic, strong) NSString *delegate;

@end

@interface ADHDatePickerAttribute : ADHAttribute

@property (nonatomic, assign) ADH_INT datePickerMode;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSString *calendar;
@property (nonatomic, strong) NSString *timeZone;
@property (nonatomic, assign) NSTimeInterval date;
@property (nonatomic, assign) NSTimeInterval minimumDate;
@property (nonatomic, assign) NSTimeInterval maximumDate;
@property (nonatomic, assign) NSTimeInterval countDownDuration;
@property (nonatomic, assign) ADH_INT minuteInterval;

@end


@interface ADHWKWebAttribute : ADHAttribute

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *navigationDelegate;
@property (nonatomic, strong) NSString *UIDelegate;
@property (nonatomic, assign) CGFloat estimatedProgress;
@property (nonatomic, assign) BOOL hasOnlySecureContent;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL canGoBack;
@property (nonatomic, assign) BOOL canGoForward;

@end
