//
//  ADHAttribute+Container.h
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/9.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHAttribute.h"

@interface ADHScrollViewAttribute : ADHAttribute

@property (nonatomic, strong) NSString *delegate;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) ADH_INSETS contentInset;
@property (nonatomic, assign) ADH_INSETS adjustedContentInset;
@property (nonatomic, assign) ADH_INT contentInsetAdjustmentBehavior;
@property (nonatomic, assign) BOOL directionalLockEnabled;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) BOOL alwaysBounceVertical;
@property (nonatomic, assign) BOOL alwaysBounceHorizontal;
@property (nonatomic, assign) BOOL pagingEnabled;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL showsHorizontalScrollIndicator;
@property (nonatomic, assign) BOOL showsVerticalScrollIndicator;
@property (nonatomic, assign) ADH_INSETS scrollIndicatorInsets;
@property (nonatomic, assign) ADH_INT indicatorStyle;
@property (nonatomic, assign) ADH_INT decelerationRate;
@property (nonatomic, assign) CGFloat minimumZoomScale;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) BOOL scrollsToTop;
@property (nonatomic, assign) ADH_INT keyboardDismissMode;

@end

@interface ADHTableViewAttribute : ADHAttribute

@property (nonatomic, strong) NSString *delegate;
@property (nonatomic, strong) NSString *dataSource;
@property (nonatomic, assign) ADH_INT style;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) CGFloat sectionHeaderHeight;
@property (nonatomic, assign) CGFloat sectionFooterHeight;
@property (nonatomic, assign) CGFloat estimatedRowHeight;
@property (nonatomic, assign) CGFloat estimatedSectionHeaderHeight;
@property (nonatomic, assign) CGFloat estimatedSectionFooterHeight;
@property (nonatomic, assign) ADH_INT separatorStyle;
@property (nonatomic, assign) ADH_INSETS separatorInset;
@property (nonatomic, assign) ADH_COLOR separatorColor;

@end

@interface ADHTableCellAttribute : ADHAttribute

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, assign) ADH_INT selectionStyle;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) ADH_INT editingStyle;
@property (nonatomic, assign) ADH_INT accessoryType;
@property (nonatomic, assign) ADH_INT editingAccessoryType;
@property (nonatomic, assign) ADH_INT indentationLevel;
@property (nonatomic, assign) CGFloat indentationWidth;
@property (nonatomic, assign) ADH_INSETS separatorInset;
@property (nonatomic, assign) ADH_INT focusStyle;

@end

@interface ADHCollectionAttribute : ADHAttribute

@property (nonatomic, strong) NSString *collectionViewLayout;
@property (nonatomic, strong) NSString *delegate;
@property (nonatomic, strong) NSString *dataSource;
@property (nonatomic, assign) BOOL allowsSelection;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end


@interface ADHCollectReusableAttribute : ADHAttribute

@property (nonatomic, strong) NSString *reuseIdentifier;

@end

@interface ADHCollectCellAttribute : ADHAttribute

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL highlighted;

@end


@interface ADHStackAttribute : ADHAttribute

@property (nonatomic, assign) ADH_INT axis;
@property (nonatomic, assign) ADH_INT distribution;
@property (nonatomic, assign) ADH_INT alignment;
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) BOOL baselineRelativeArrangement;
@property (nonatomic, assign) BOOL layoutMarginsRelativeArrangement;

@end


@interface ADHNaviBarAttribute : ADHAttribute

@property (nonatomic, assign) ADH_INT barStyle;
@property (nonatomic, assign) BOOL translucent;
//ios11
@property (nonatomic, assign) BOOL prefersLargeTitles;
@property (nonatomic, assign) ADH_COLOR tintColor;
@property (nonatomic, assign) ADH_COLOR barTintColor;
@property (nonatomic, strong) NSData *backgroundImage;
@property (nonatomic, strong) NSData *shadowImage;
@property (nonatomic, strong) NSData *backIndicatorImage;
@property (nonatomic, strong) NSData *backIndicatorTransitionMaskImage;

@end

@interface ADHTabBarAttribute : ADHAttribute

@property (nonatomic, assign) ADH_COLOR tintColor;
@property (nonatomic, assign) ADH_COLOR barTintColor;
@property (nonatomic, assign) ADH_COLOR unselectedItemTintColor;
@property (nonatomic, strong) NSData *backgroundImage;
@property (nonatomic, strong) NSData *selectionIndicatorImage;
@property (nonatomic, strong) NSData *shadowImage;
@property (nonatomic, assign) ADH_INT itemPositioning;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) ADH_INT barStyle;
@property (nonatomic, assign) BOOL translucent;

@end


@interface ADHToolBarAttribute : ADHAttribute

@property (nonatomic, assign) ADH_INT barStyle;
@property (nonatomic, assign) BOOL translucent;
@property (nonatomic, assign) ADH_COLOR tintColor;
@property (nonatomic, assign) ADH_COLOR barTintColor;
@property (nonatomic, strong) NSData *backgroundImage;
@property (nonatomic, strong) NSData *shadowImage;

@end
