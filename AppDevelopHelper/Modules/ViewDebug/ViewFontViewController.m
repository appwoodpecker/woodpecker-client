//
//  FontViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/3/11.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewFontViewController.h"

@interface ViewFontViewController ()

@property (weak) IBOutlet NSPopUpButton *familyPopup;
@property (weak) IBOutlet NSPopUpButton *fontsPopup;
@property (weak) IBOutlet NSTextField *sizeTextfield;
@property (weak) IBOutlet NSStepper *sizeStepper;

@property (nonatomic, strong) NSArray<NSString *> *familyNames;
@property (nonatomic, strong) NSString *curtFamilyName;
@property (nonatomic, strong) NSArray<NSString *> *fontNames;
@property (nonatomic, strong) NSString *initialFontName;



@end

@implementation ViewFontViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValue];
    [self initUI];
    [self loadData];
}

- (void)initValue {
    if(self.fontSize == 0){
        self.fontSize = 13;
    }
}

- (void)initUI {
    [self.familyPopup removeAllItems];
    [self.fontsPopup removeAllItems];
    if(self.fontName) {
        [self.familyPopup addItemWithTitle:@"Current"];
        [self.fontsPopup addItemWithTitle:self.fontName];
    }
    if(self.fontSize > 0) {
        self.sizeTextfield.stringValue = [NSString stringWithFormat:@"%zd",self.fontSize];
        self.sizeStepper.integerValue = self.fontSize;
    }
}

- (void)loadData {
    if(self.context.app.appInfo) {
        [self loadContent];
    }else {
        __weak typeof(self) wself = self;
        [self.apiClient requestWithService:@"adh.appinfo" action:@"info" onSuccess:^(NSDictionary *body, NSData *payload) {
            wself.context.app.appInfo = body;
            [wself loadContent];
        } onFailed:^(NSError *error) {
            
        }];
    }
}

- (void)loadContent {
    [self prepareData];
    [self updateFamilyUI];
    [self updateFontNameUI];
}

- (void)prepareData {
    NSDictionary *data = self.context.app.appInfo;
    NSDictionary *fontData = data[@"font"];
    NSMutableArray *familyNames = [NSMutableArray array];
    if(fontData[@"System"]) {
        [familyNames addObject:@"System"];
    }
    NSDictionary *fonts = fontData[@"fonts"];
    NSArray *names = [fonts allKeys];
    if(names.count > 0) {
        names = [names sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
            return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
        }];
        [familyNames addObjectsFromArray:names];
    }
    self.familyNames = familyNames;
    if(self.familyNames.count > 0) {
        if(self.fontName) {
            //反向找到familyName
            NSString *targetFamily = nil;
            for (NSString *family in self.familyNames) {
                NSArray *fontNames = [self getFontNames:family];
                if([fontNames containsObject:self.fontName]) {
                    targetFamily = family;
                    break;
                }
            }
            if(targetFamily) {
                self.curtFamilyName = targetFamily;
                self.initialFontName = self.fontName;
            }
        }
        if(!self.curtFamilyName) {
            self.curtFamilyName = self.familyNames[0];
        }
        [self loadCurtFontNames];
    }
}

- (void)updateFamilyUI {
    [self.familyPopup removeAllItems];
    for (NSString *name in self.familyNames) {
        [self.familyPopup addItemWithTitle:name];
    }
    if(self.curtFamilyName) {
        [self.familyPopup selectItemWithTitle:self.curtFamilyName];
    }
}

- (void)updateFontNameUI {
    [self.fontsPopup removeAllItems];
    for (NSString *name in self.fontNames) {
        [self.fontsPopup addItemWithTitle:name];
    }
    if(self.initialFontName) {
        [self.fontsPopup selectItemWithTitle:self.initialFontName];
    }
}

- (IBAction)familyPopValueChanged:(id)sender {
    NSString *familyName = [self.familyPopup titleOfSelectedItem];
    if([self.curtFamilyName isEqualToString:familyName]) {
        return;
    }
    self.curtFamilyName = familyName;
    self.initialFontName = nil;
    [self loadCurtFontNames];
    [self updateFontNameUI];
}

- (void)loadCurtFontNames {
    self.fontNames = [self getFontNames:self.curtFamilyName];
}

- (NSArray *)getFontNames: (NSString *)familyName {
    NSDictionary *data = self.context.app.appInfo;
    NSDictionary *fontData = data[@"font"];
    NSArray *fontNames = fontData[familyName];
    if(fontNames.count == 0) {
        NSDictionary *fonts = fontData[@"fonts"];
        fontNames = fonts[familyName];
    }
    return fontNames;
}


- (IBAction)fontPopVaueChanged:(id)sender {

}

- (IBAction)sizeStepperValueChange:(id)sender {
    self.sizeTextfield.stringValue = [NSString stringWithFormat:@"%zd",self.sizeStepper.integerValue];
}

- (IBAction)doneButtonPressed:(id)sender {
    NSString *fontName = [self.fontsPopup titleOfSelectedItem];
    NSInteger size = [self.sizeTextfield integerValue];
    if(fontName.length > 0 && size > 0) {
        if(self.completionBlock) {
            self.completionBlock(fontName, size);
        }
    }
}

@end
