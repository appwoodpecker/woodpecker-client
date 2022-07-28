//
//  ViewDebugTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2019/2/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewDebugTestViewController.h"
#import "ADHViewDebugService.h"
#import "CollectionViewTestViewController.h"
#import "StackTestViewController.h"
#import "TabbarTestViewController.h"

@import WebKit;

@interface ViewDebugTestViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *gifImageview;
@property (weak, nonatomic) IBOutlet UIView *paletteView;


@end

@implementation ViewDebugTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    /*
normal: 0.998000
fast: 0.990000
    */
//    NSLog(@"\nnormal: %f\nfast: %f",UIScrollViewDecelerationRateNormal,UIScrollViewDecelerationRateFast);
//    [self fonts];
}

- (void)setupUI {
    UIImage *image1 = [UIImage imageNamed:@"pro1024"];
    UIImage *image2 = [UIImage imageNamed:@"hi"];
    self.gifImageview.animationImages = @[image2,image1];
    self.gifImageview.animationDuration = 10.0f;
    self.gifImageview.animationRepeatCount = 0;
    [self.gifImageview startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    float red = (arc4random() % 255)/255.0f;
    float green = (arc4random() % 255)/255.0f;
    float blue = (arc4random() % 255)/255.0f;
    self.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
}

- (IBAction)captureButtonPressed:(id)sender {
    ADHViewDebugService *service = [ADHViewDebugService service];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    ADHViewNode *node = [service captureViewTree:window];
    NSDictionary *data = [node dicPresentation];
}

- (IBAction)collectionButtonPressed:(id)sender {
    CollectionViewTestViewController *vc = [[CollectionViewTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)stackButtonPressed:(id)sender {
    StackTestViewController *vc = [[StackTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)toolbarButtonPressed:(id)sender {
    TabbarTestViewController *vc = [[TabbarTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)uiview {
    UIView *view = nil;
}

- (void)label {
    UILabel *label = nil;
    
}

- (void)imageView {
    UIImageView *imageView = nil;
}

- (void)control {
    UIControl *control = nil;
}

- (void)button {
    UIButton *button = nil;
}

- (void)textfield {
    UITextField *textfield = nil;
    
}

- (void)testview {
    UITextView *textview = nil;
}

- (void)slider {
    UISlider *slider = nil;
}

- (void)stepper {
    UIStepper *stepper = nil;
}

- (void)progressview {
    UIProgressView *pv = nil;
}



- (void)activityView {
    UIActivityIndicatorView *activity = nil;
}

- (void)pageControl {
    UIPageControl *pageControl = nil;
}

- (void)window {
    UIWindow *window = nil;
}

- (void)segmentcontrol {
    UISegmentedControl *segment = nil;
}

- (void)pickerView {
    UIPickerView *pickerView = nil;
}

- (void)datePickerView {
    UIDatePicker *pickerView = nil;
}

- (void)wkwebView {
    WKWebView *webView = nil;
}

- (void)uiwebView {
    UIWebView *webView = nil;
}

- (void)scrollView {
    UIScrollView *scrollView = nil;
}

- (void)tableView {
    UITableView *tableView = nil;
}

- (void)tableCell {
    UITableViewCell *cell = nil;
}

- (void)collectonView {
    UICollectionView *collection = nil;
}

- (void)collectionCell {
    UICollectionViewCell *cell = nil;
}

- (void)stackView {
    UIStackView *stackView = nil;
}

- (void)navigationBar {
    UINavigationBar *bar = nil;
}

- (void)tabbar {
    UITabBar *bar = nil;
}

- (void)toolbar {
    UIToolbar *bar = nil;
    
}

- (void)fonts {
    NSMutableDictionary *fontData = [NSMutableDictionary dictionary];
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    //system default
    NSArray *defaultFontNames = @[
                           @".SFUIText-Light",
                           @".SFUIText",
                           @"SFUIText-Medium",
                           @".SFUIText-Semibold",
                           @".SFUIText-Bold",
                           @".SFUIText-Heavy"
      ];
    fontData[@"DefaultFonts"] = defaultFontNames;
    //custom
    NSArray *customFonts = infoDic[@"UIAppFonts"];
    if([customFonts isKindOfClass:[NSArray class]]) {
        fontData[@"UIAppFonts"] = customFonts;
    }
    //system fonts
    NSMutableDictionary *fonts = [NSMutableDictionary dictionary];
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *familyName in familyNames) {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        if([fontNames isKindOfClass:[NSArray class]]) {
            fonts[familyName] = fontNames;
        }
    }
    fontData[@"fonts"] = fonts;
}

- (void)gesture {
    UIGestureRecognizer *recognizer = nil;
    UITapGestureRecognizer *tap = nil;
    UILongPressGestureRecognizer * longpress = nil;
    UIPanGestureRecognizer *pan = nil;
    UISwipeGestureRecognizer *swipe = nil;
    UIPinchGestureRecognizer *pinch = nil;
    UIRotationGestureRecognizer *rotation = nil;
    UIScreenEdgePanGestureRecognizer *edge = nil;
}


- (IBAction)colorSpaceButtonPressed:(id)sender {
    UIColor *rgb = [UIColor colorWithRed:50/255.0f green:100/255.0f blue:50/255.0f alpha:1.0];
    [self logColorInfo:rgb];
    UIColor *gray = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self logColorInfo:gray];
    UIColor *p3 = [UIColor colorWithDisplayP3Red:1.0 green:0.5 blue:0.5 alpha:1.0f];
    [self logColorInfo:p3];
    UIColor *hsb = [UIColor colorWithHue:1.0 saturation:0.8 brightness:1.0 alpha:0.8];
    [self logColorInfo:hsb];
}

- (void)logColorInfo: (UIColor *)color {
    CGColorSpaceRef space = CGColorGetColorSpace(color.CGColor);
    NSString *name = (NSString *)CGColorSpaceGetName(space);
    NSLog(@"%@",name);
    CGFloat r,g,b,a = 0;
    [color getRed:&r green:&g blue:&b alpha:&a];
    NSLog(@"[%.2f,%.2f,%.2f,%.2f]",r,g,b,a);
}


@end
