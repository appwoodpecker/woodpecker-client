//
//  ADHAttributeUtil.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/20.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHAttributeUtil.h"
#import "ADHAttributeContainer.h"
@import WebKit;

@implementation ADHAttributeUtil

+ (ADHAttribute *)attributeWithClass: (Class)clazz {
    ADHAttribute *attr = nil;
    if(clazz == [UILabel class]) {
        attr = [ADHLabelAttribute attribute];
    }else if(clazz == [UIView class]){
        attr = [ADHViewAttribute attribute];
    }else if(clazz == [UIImageView class]) {
        attr =  [ADHImageViewAttribute attribute];
    }else if(clazz == [UIControl class]) {
        attr = [ADHControlAttribute attribute];
    }else if(clazz == [UIButton class]) {
        attr = [ADHButtonAttribute attribute];
    }else if(clazz == [UITextField class]) {
        attr = [ADHTextFieldAttribute attribute];
    }else if(clazz == [UITextView class]) {
        attr = [ADHTextViewAttribute attribute];
    }else if(clazz == [UISlider class]) {
        attr = [ADHSliderAttribute attribute];
    }else if(clazz == [UIStepper class]) {
        attr = [ADHStepperAttribute attribute];
    }else if(clazz == [UIProgressView class]) {
        attr = [ADHProgressAttribute attribute];
    }else if(clazz == [UIPageControl class]) {
        attr = [ADHPageControlAttribute attribute];
    }else if(clazz == [UIActivityIndicatorView class]) {
        attr = [ADHActivityAttribute attribute];
    }else if(clazz == [UIWindow class]) {
        attr = [ADHWindowAttribute attribute];
    }else if(clazz == [UISegmentedControl class]) {
        attr = [ADHSegmentAttribute attribute];
    }else if(clazz == [UIPickerView class]) {
        attr = [ADHPickerViewAttribute attribute];
    }else if(clazz == [UIDatePicker class]) {
        attr = [ADHDatePickerAttribute attribute];
    }else if(clazz == [WKWebView class]) {
        attr = [ADHWKWebAttribute attribute];
    }else if(clazz == [UIScrollView class]) {
        attr = [ADHScrollViewAttribute attribute];
    }else if(clazz == [UITableView class]) {
        attr = [ADHTableViewAttribute attribute];
    }else if(clazz == [UITableViewCell class]) {
        attr = [ADHTableCellAttribute attribute];
    }else if(clazz == [UICollectionView class]) {
        attr = [ADHCollectionAttribute attribute];
    }else if(clazz == [UICollectionReusableView class]) {
        attr = [ADHCollectReusableAttribute attribute];
    }else if(clazz == [UICollectionViewCell class]) {
        attr = [ADHCollectCellAttribute attribute];
    }else if(clazz == [UINavigationBar class]) {
        attr = [ADHNaviBarAttribute attribute];
    }else if(clazz == [UITabBar class]) {
        attr = [ADHTabBarAttribute attribute];
    }else if(clazz == [UIToolbar class]) {
        attr = [ADHToolBarAttribute attribute];
    }
    else {
        if (@available(iOS 9.0, *)) {
            if(clazz == [UIStackView class]) {
                attr = [ADHStackAttribute attribute];
            }
        }
    }
    if(attr) {
        attr.className = NSStringFromClass(clazz);
    }
    return attr;
}

@end
