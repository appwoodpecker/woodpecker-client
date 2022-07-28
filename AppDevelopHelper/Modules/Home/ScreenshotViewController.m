//
//  ScreenshotViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/3/15.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ScreenshotViewController.h"
#import "MacOrganizer.h"
#import "DeviceUtil.h"

static CGFloat const kPaddingVTop = 56.0f;
static CGFloat const kPaddingVBottom = 56.0f;
static CGFloat const kPaddingH = 40.0f;

static CGFloat const kSkinEdgeUp = 75.0f;
static CGFloat const kSkinEdgeBottom = 90.0f;
static CGFloat const kSkinEdgeBorder = 20.0f;
static CGFloat const kHomeBaseSize = 48.0f;
static CGFloat const kHomeBaseBorder = 3.0f;
static CGFloat const kiPhoneBaseCorner = 36.0f;

static CGFloat const kMiniPhoneSize = 80.0f;
static CGFloat const kDefaultSSWidth = 320;
static CGFloat const kDefaultSSHeight = 568;


@interface ScreenshotViewController ()

@property (weak) IBOutlet NSView *screenshotLayout;
@property (weak) IBOutlet NSImageView *screenImageView;

@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSView *homeView;
@property (weak) IBOutlet NSButton *updateButton;
@property (weak) IBOutlet NSButton *downloadButton;
@property (weak) IBOutlet NSButton *cacheButton;

@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *stopButton;

@property (nonatomic, assign) NSInteger orientation;
@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, strong) NSDate * updateDate;

@property (nonatomic, strong) NSTimer * playTimer;
@property (nonatomic, assign) BOOL isLoadingScreenshot;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation ScreenshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initialState];
    [self addNotification];
}

- (void)setupAfterXib {
    NSClickGestureRecognizer * clickRecognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(screenshotClicked:)];
    [self.screenImageView addGestureRecognizer:clickRecognizer];
    self.screenImageView.wantsLayer = YES;
    self.screenImageView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.screenshotLayout.wantsLayer = YES;
    self.screenshotLayout.layer.backgroundColor = [Appearance colorWithHex:0x353535].CGColor;
    self.homeView.wantsLayer = YES;
    self.homeView.layer.borderColor = [[NSColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
    self.cacheButton.toolTip = @"Clear Caches\n\n- Main Cache(/Library/Caches)\n- Webkit Cache\n- Launch Screen Cache\n\nClick with option key to clear Sandbox and UserDefaults Caches\n";
    //action buttons
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkAppUpdate) name:kAppContextAppStatusUpdate object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.updateButton setTintColor:[Appearance actionImageColor]];
    [self.downloadButton setTintColor:[Appearance actionImageColor]];
    [self.cacheButton setTintColor:[Appearance actionImageColor]];
}

- (void)initialState
{
    self.isPlaying = NO;
    [self updatePlayState];
    [self loadScreenshot];
    [self refreshUpdateTimeUI];
}

- (void)loadScreenshot {
    if(!self.context.isConnected){
        return;
    }
    __weak typeof(self) wself = self;
    self.isLoadingScreenshot = YES;
    if(!self.isPlaying){
        [self.updateButton showHud];
    }
    [self.apiClient requestWithService:@"adh.device" action:@"screenshort" onSuccess:^(NSDictionary *body, NSData *payload) {
        wself.updateDate = [NSDate date];
        [wself updateScreenshot:body imageData:payload];
        wself.isLoadingScreenshot = NO;
        [wself.updateButton hideHud];
    } onFailed:^(NSError *error) {
        wself.isLoadingScreenshot = NO;
        [wself.updateButton hideHud];
    }];
}

- (void)updateScreenshot:(NSDictionary * )body imageData:(NSData *)imageData {
    if(!body || !imageData){
        return;
    }
    NSInteger orientation = [body[@"orientation"] integerValue];
    self.orientation = orientation;
    self.imageData = imageData;
    NSImage * image = [[NSImage alloc] initWithData:imageData];
    self.screenImageView.image = image;
    [self updateLayout];
    [self refreshUpdateTimeUI];
}

- (NSEdgeInsets)skinEdgeInsetWith: (NSInteger)orientation imagePixelSize: (CGSize)size {
    /*
     UIDeviceOrientationUnknown,
     UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
     UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
     UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
     UIDeviceOrientationLandscapeRight,
     */
    
    CGFloat skinEdgeUp = kSkinEdgeUp;
    if(ABS(size.width-size.height)==(2436-1125)){
        //iPhoneX
        skinEdgeUp = 30;
    }
    NSEdgeInsets skinEdge = NSEdgeInsetsZero;
    switch (orientation) {
            /*
             case 2:
             //potrait down
             skinEdge.left = kSkinEdgeBorder;
             skinEdge.right = kSkinEdgeBorder;
             skinEdge.top = kSkinEdgeBottom;
             skinEdge.bottom = kSkinEdgeUp;
             break;*/
        case 3:
            //left
            skinEdge.left = skinEdgeUp;
            skinEdge.right = kSkinEdgeBottom;
            skinEdge.top = kSkinEdgeBorder;
            skinEdge.bottom = kSkinEdgeBorder;
            break;
        case 4:
            //right
            skinEdge.left = kSkinEdgeBottom;
            skinEdge.right = skinEdgeUp;
            skinEdge.top = kSkinEdgeBorder;
            skinEdge.bottom = kSkinEdgeBorder;
            break;
        default:
            //其他情况正方向
            skinEdge.top = skinEdgeUp;
            skinEdge.bottom = kSkinEdgeBottom;
            skinEdge.left = kSkinEdgeBorder;
            skinEdge.right = kSkinEdgeBorder;
            break;
    }
    return skinEdge;
}

- (void)updateLayout {
    NSImage * image = self.screenImageView.image;
    NSInteger orientation = self.orientation;
    CGSize imagePixelSize = [self getImagePixelSize:image];
    NSEdgeInsets skinEdge = [self skinEdgeInsetWith:orientation imagePixelSize:imagePixelSize];
    NSRect bounds = self.view.bounds;
    CGFloat frameX = kPaddingH;
    CGFloat frameY = kPaddingVBottom;
    CGFloat frameWidth = bounds.size.width - kPaddingH * 2;
    CGFloat frameHeight = bounds.size.height - (kPaddingVTop + kPaddingVBottom);
    
    CGFloat frameWHFactor = (frameWidth / frameHeight);
    //根据frame size，计算最终frame
    CGFloat imageWidth = 0.0f;
    CGFloat imageHeight = 0.0f;
    if(image){
         imageWidth = image.size.width;
         imageHeight = image.size.height;
    }else{
        imageWidth = kDefaultSSWidth;
        imageHeight = kDefaultSSHeight;
    }
    CGFloat edgeWidth = skinEdge.left + skinEdge.right;
    CGFloat edgeHeight = skinEdge.top + skinEdge.bottom;
    CGFloat contentWidth = imageWidth + edgeWidth;
    CGFloat contentHeight = imageHeight + edgeHeight;
    CGFloat contentWHFactor = contentWidth / contentHeight;
    
    CGFloat displayWidth = 0;
    CGFloat displayHeight = 0;
    
    //fix width or height
    BOOL isWidthMode = NO;
    if(contentWHFactor > frameWHFactor){
        //宽图
        isWidthMode = YES;
    }else{
        //长图
    }
    if(isWidthMode){
        //固定宽度，计算长度
        displayWidth = frameWidth;
        displayHeight = (displayWidth/contentWHFactor);
    }else{
        displayHeight = frameHeight;
        displayWidth = (displayHeight * contentWHFactor);
    }
    if(displayWidth < kMiniPhoneSize || displayHeight < kMiniPhoneSize){
        //防止显示过小
        return;
    }
    CGFloat displayX = frameX + (frameWidth - displayWidth)/2.0;
    CGFloat displayY = frameY + (frameHeight - displayHeight)/2.0f;
    
    NSRect iphoneRect = NSZeroRect;
    iphoneRect.origin.x = displayX;
    iphoneRect.origin.y = displayY;
    iphoneRect.size.width = displayWidth;
    iphoneRect.size.height = displayHeight;
    self.screenshotLayout.frame = iphoneRect;
    //计算screenshot frame
    CGFloat sswidth = displayWidth * (imageWidth/contentWidth);
    CGFloat ssheight = displayHeight * (imageHeight/contentHeight);
    CGFloat ssx = (displayWidth - sswidth)*(skinEdge.left/edgeWidth);
    CGFloat ssy = (displayHeight - ssheight)*(skinEdge.bottom/edgeHeight);
    NSRect ssRect = NSZeroRect;
    ssRect.origin.x = ssx;
    ssRect.origin.y = ssy;
    ssRect.size.width = sswidth;
    ssRect.size.height = ssheight;
    self.screenImageView.frame = ssRect;
    
    CGFloat scale = (displayWidth/contentWidth);
    self.screenshotLayout.layer.cornerRadius = kiPhoneBaseCorner * scale;
    
    CGFloat homeSize = ceilf(kHomeBaseSize * scale);
    NSRect homeRect = NSZeroRect;
    //home button
    /*if(orientation == 2){
        //at top
        homeRect.origin.x = (iphoneRect.size.width - homeSize)/2.0f;
        homeRect.origin.y = CGRectGetMaxY(ssRect) + ((displayHeight-CGRectGetMaxY(ssRect)) - homeSize)/2.0f;
        homeRect.size.width = homeSize;
        homeRect.size.height = homeSize;
    }else */if(orientation == 3){
        //at right
        homeRect.origin.x = CGRectGetMaxX(ssRect) + ((displayWidth - CGRectGetMaxX(ssRect)) - homeSize)/2.0f;
        homeRect.origin.y = (displayHeight - homeSize)/2.0f;
        homeRect.size.width = homeSize;
        homeRect.size.height = homeSize;
    }else if(orientation == 4){
        //at left
        homeRect.origin.x = (ssx - homeSize)/2.0f;
        homeRect.origin.y = (displayHeight - homeSize)/2.0f;
        homeRect.size.width = homeSize;
        homeRect.size.height = homeSize;
    }else{
        //at bottom
        homeRect.origin.x = (iphoneRect.size.width - homeSize)/2.0f;
        homeRect.origin.y = (ssy - homeSize)/2.0f;
        homeRect.size.width = homeSize;
        homeRect.size.height = homeSize;
        
    }
    self.homeView.frame = homeRect;
    self.homeView.layer.cornerRadius = homeSize/2.0f;
    self.homeView.layer.borderWidth = kHomeBaseBorder * scale;
    
}

- (CGSize)getImagePixelSize: (NSImage *)image {
    CGSize size = CGSizeZero;
    if(image.representations.count > 0){
        NSImageRep * firstImg = image.representations[0];
        size.width = firstImg.pixelsWide;
        size.height = firstImg.pixelsHigh;
    }
    return size;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [self updateLayout];
}

- (void)refreshUpdateTimeUI {
    if(!self.updateDate){
        self.screenImageView.toolTip = nil;
    }else{
        NSString * dateText = [ADHDateUtil formatStringWithDate:self.updateDate dateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.screenImageView.toolTip = [NSString stringWithFormat:@"last update: %@",dateText];
    }
}

- (void)cleanPlayTimer {
    [self.playTimer invalidate];
    self.playTimer = nil;
}

- (IBAction)playButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    __weak typeof(self) wself = self;
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if(!wself.isLoadingScreenshot){
            [wself loadScreenshot];
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.playTimer = timer;
    self.isPlaying = YES;
    [self updatePlayState];
}

- (IBAction)stopButtonPressed:(id)sender {
    [self cleanPlayTimer];
    self.isPlaying = NO;
    [self updatePlayState];
}

- (void)onWorkAppUpdate {
    if(!self.screenImageView.image){
        [self loadScreenshot];
    }
}

- (void)updatePlayState {
    self.playButton.hidden = self.isPlaying;
    self.stopButton.hidden = !self.playButton.hidden;
}

- (NSString *)getDownloadPath {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
    NSString * path = paths[0];
    return path;
}

#pragma mark -----------------   按钮点击   ----------------

- (void)screenshotClicked: (NSClickGestureRecognizer *)recognizer {
    NSPoint point = [recognizer locationInView:self.screenImageView];
    point.y = self.screenImageView.height - point.y;
    CGFloat x = (point.x / self.screenImageView.width);
    CGFloat y = (point.y / self.screenImageView.height);
    point.x = x;
    point.y = y;
    NSString * pointDes = NSStringFromPoint(point);
    NSDictionary * body = @{@"point" : pointDes};
    [self.apiClient requestWithService:@"adh.device" action:@"onTouchEvent" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        
    } onFailed:^(NSError *error) {
        
    }];
}

#pragma mark -----------------   Tools   ----------------

- (IBAction)updateButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) return;
    [self loadScreenshot];
}

- (IBAction)saveButtonPressed:(id)sender {
    if(![self doCheckConnectionRoutine]) {
        return;
    }
    __weak typeof(self) wself = self;
    [self.downloadButton showHud];
    [self.apiClient requestWithService:@"adh.device" action:@"screenshort" onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.downloadButton hideHud];
        if(payload) {
            NSData *imageData = payload;
            NSString * desktopPath = [self getDownloadPath];
            NSString * dateText = [ADHDateUtil formatStringWithDate:[NSDate date] dateFormat:@"YYYY-MM-dd HH.mm.ss"];
            NSString * filename = [NSString stringWithFormat:@"Screen Shot %@.png",dateText];
            NSString * filePath = [desktopPath stringByAppendingPathComponent:filename];
            BOOL result = [imageData writeToFile:filePath atomically:NO];
            if(result){
                //copy to pasteboard
                [[NSPasteboard generalPasteboard] clearContents];
                [[NSPasteboard generalPasteboard] setData:imageData forType:NSPasteboardTypePNG];
                //open file
                NSURL * fileURL = [NSURL fileURLWithPath:filePath];
                [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
            }
        }else {
            [self showErrorWithText:@"Screenshot is not ready"];
        }
    } onFailed:^(NSError *error) {
        [wself.downloadButton hideHud];
    }];
}

/**
 1. copy from app
 2. sync to app
 3. clear app
 */
- (IBAction)pasteboardButtonPressed:(NSButton *)sender {
    if([DeviceUtil isOptionPressed]) {
        NSMenu * menu = [[NSMenu alloc] init];
        menu.autoenablesItems = NO;
        //copy from app
        NSMenuItem * copyMenu = [[NSMenuItem alloc] initWithTitle:@"Copy from app" action:@selector(doPbCopyFromApp) keyEquivalent:adhvf_const_emptystr()];
        copyMenu.target = self;
        [menu addItem:copyMenu];
        //paste to app
        NSMenuItem * pasteMenu = [[NSMenuItem alloc] initWithTitle:@"Paste to app" action:@selector(doPbPasteToApp) keyEquivalent:adhvf_const_emptystr()];
        pasteMenu.target = self;
        [menu addItem:pasteMenu];
        //clear app
        NSMenuItem * clearMenu = [[NSMenuItem alloc] initWithTitle:@"Clear app" action:@selector(doPbClearApp) keyEquivalent:adhvf_const_emptystr()];
        clearMenu.target = self;
        [menu addItem:clearMenu];
        [menu popUpMenuPositioningItem:nil atLocation:sender.center inView:sender];
    }else {
        [self doPbCopyFromApp];
    }
}

/**
 * copy from app
 * 1. text
 * 2. url
 * 3. image
 */
- (void)doPbCopyFromApp {
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.utility" action:@"pasteboard" onSuccess:^(NSDictionary *body, NSData *payload) {
        BOOL succeed = [body[@"success"] boolValue];
        if(succeed) {
            NSString *type = body[@"type"];
            if([type isEqualToString:@"text"]) {
                NSString *text = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
                [DeviceUtil pasteText:text];
            }else if([type isEqualToString:@"url"]) {
                NSString *text = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
                [DeviceUtil pasteText:text];
            }else if([type isEqualToString:@"image"]) {
                NSString * downloadPath = [DeviceUtil getDownloadPath];
                NSString * dateText = [ADHDateUtil formatStringWithDate:[NSDate date] dateFormat:@"YYYY-MM-dd HH.mm.ss"];
                NSString * filename = [NSString stringWithFormat:@"Pasteboard %@.png",dateText];
                NSString * filePath = [downloadPath stringByAppendingPathComponent:filename];
                BOOL result = [payload writeToFile:filePath atomically:NO];
                if(result){
                    //copy to pasteboard
                    [[NSPasteboard generalPasteboard] clearContents];
                    [[NSPasteboard generalPasteboard] setData:payload forType:NSPasteboardTypePNG];
                    //open file
                    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
                    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
                }
            }
            [wself showSuccessWithText:[NSString stringWithFormat:@"Copy %@ successfully",type]];
        }else {
            [wself showErrorWithText:@"App's pasteboard was empty"];
        }
    } onFailed:^(NSError *error) {
        
    }];
}

/**
 * paste to app
 * 1. text
 * 2. image
 */
- (void)doPbPasteToApp {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSData *pbData = nil;
    NSString *type = nil;
    [self doPbList];
    //url
    NSURL *url = [NSURL URLFromPasteboard:pb];
    //string
    NSString *text = [pb stringForType:NSPasteboardTypeString];
    //image
    NSData * imageData = nil;
    NSPasteboardType imgType = [pb availableTypeFromArray:@[NSPasteboardTypePNG,NSPasteboardTypeTIFF]];
    if(imgType) {
        NSLog(@"%@",imgType);
        imageData = [pb dataForType:imgType];
    }
    if(url) {
        NSString *text = [url absoluteString];
        pbData = [text dataUsingEncoding:NSUTF8StringEncoding];
        type = @"url";
    }else if(text) {
        pbData = [text dataUsingEncoding:NSUTF8StringEncoding];
        type = @"text";
    }else if(imageData) {
        //这里对图片支持的不是很好，所以放到最后
        pbData = imageData;
        type = @"image";
    }
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if(pbData) {
        data[@"type"] = type;
        [self.apiClient requestWithService:@"adh.utility" action:@"writePasteboard" body:data payload:pbData progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
            [self showSuccessWithText:@"Paste to app successfully"];
        } onFailed:^(NSError *error) {
            [self showError];
        }];
    }else {
        [self showErrorWithText:@"Local pasteboard was empty or format not supported"];
    }
}

- (void)doPbClearApp {
    [self.apiClient requestWithService:@"adh.utility" action:@"clearPasteboard" onSuccess:^(NSDictionary *body, NSData *payload) {
        [self showSuccessWithText:@"App pasteboard is cleared"];
    } onFailed:^(NSError *error) {
        [self showError];
    }];
}

- (void)doPbList {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *list = [pb pasteboardItems];
    for (NSPasteboardItem *item in list) {
        NSLog(@"%@",item.types);
    }
}

/**
 1. Caches(Include Webkit, Launch Screen, /Library/Caches, /tmp)
 /Library/Caches
 /Library/SplashBoard
 /Library/WebKit, /Library/Cookies
 /tmp
 
 2.Sandbox
 
 3.UserDefaults
 
 */
- (IBAction)cacheButtonPressed:(NSButton *)sender {
    if([DeviceUtil isOptionPressed]) {
        NSMenu * menu = [[NSMenu alloc] init];
        menu.autoenablesItems = NO;
        //copy from app
        NSMenuItem * copyMenu = [[NSMenuItem alloc] initWithTitle:@"Clear Caches" action:@selector(doRemoveCaches) keyEquivalent:adhvf_const_emptystr()];
        copyMenu.target = self;
        //Caches
        copyMenu.toolTip = @"- Main Cache(/Library/Caches)\n- Webkit Cache\n- Launch Screen Cache\n";
        [menu addItem:copyMenu];
        //paste to app
        NSMenuItem * pasteMenu = [[NSMenuItem alloc] initWithTitle:@"Clear Sandbox Files" action:@selector(doRemoveSandbox) keyEquivalent:adhvf_const_emptystr()];
        pasteMenu.target = self;
        [menu addItem:pasteMenu];
        //clear app
        NSMenuItem * clearMenu = [[NSMenuItem alloc] initWithTitle:@"Clear UserDefaults" action:@selector(doRemoveUserDefaults) keyEquivalent:adhvf_const_emptystr()];
        clearMenu.target = self;
        [menu addItem:clearMenu];
        [menu popUpMenuPositioningItem:nil atLocation:CGPointMake(sender.width, sender.height*0.7) inView:sender];
    }else {
        [self doRemoveCaches];
    }
}

- (void)doRemoveCacheWithType: (NSInteger)type {
    NSDictionary *body = @{
        @"type" : [NSNumber numberWithInteger:type],
    };
    [self.apiClient requestWithService:@"adh.utility" action:@"removeCache" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        [self showSuccessWithText:@"Cache Cleared"];
    } onFailed:^(NSError *error) {
        [self showSuccessWithText:error.localizedDescription];
    }];
}

- (void)doRemoveCaches {
    [self doRemoveCacheWithType:0];
}

- (void)doRemoveSandbox {
    [self doRemoveCacheWithType:1];
}

- (void)doRemoveUserDefaults {
    [self doRemoveCacheWithType:2];
}

@end














