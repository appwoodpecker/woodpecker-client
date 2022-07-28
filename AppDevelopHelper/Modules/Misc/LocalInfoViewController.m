//
//  LocalInfoViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/2/6.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "LocalInfoViewController.h"
#import "MacOrganizer.h"
#import "DeviceUtil.h"

@interface LocalInfoViewController ()

@property (weak) IBOutlet NSTextField *hostnameTextfield;
@property (weak) IBOutlet NSTextField *addressTextfield;
@property (weak) IBOutlet NSView *lineView;
@property (weak) IBOutlet NSTextField *portTextfield;

@end

@implementation LocalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Client Info";
    self.lineView.wantsLayer = YES;
    self.lineView.layer.backgroundColor = [Appearance controlSeperatorColor].CGColor;
    [self loadContent];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    NSWindowStyleMask style = self.view.window.styleMask;
    style = (style & ~(NSWindowStyleMaskResizable));
    self.view.window.styleMask = style;
}

- (void)loadContent {
    NSString * deviceName = [DeviceUtil deviceName];
    self.hostnameTextfield.stringValue = deviceName;
    [self updatePortUI];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MacConnector * connector = [[MacOrganizer organizer] connector];
        NSString * host = [DeviceUtil localIP];
        NSString * port = [connector localPort];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableString *text = [NSMutableString string];
            if(host.length > 0) {
                [text appendString:host];
                if(port > 0) {
                    [text appendFormat:@":%@",port];
                }
            }
            self.addressTextfield.stringValue = text;
        });
    });
}

- (void)updatePortUI {
    int port = [Preference preferedPort];
    if(port <= 0) {
        self.portTextfield.stringValue = @"";
    }else {
        self.portTextfield.stringValue = [NSString stringWithFormat:@"%d",port];
    }
}

- (IBAction)hostnameButtonPressed:(id)sender {
    NSString * text = self.hostnameTextfield.stringValue;
    [DeviceUtil pasteText:text];
}

- (IBAction)ipButtonPressed:(id)sender {
    NSString * text = self.addressTextfield.stringValue;
    [DeviceUtil pasteText:text];
}

- (IBAction)preferedPortSaveButtonClicked:(id)sender {
    int port = [self.portTextfield.stringValue intValue];
    if(port < 0) {
        port = 0;
    }
    if(port > 65535) {
        port = 65535;
    }
    [Preference savePreferedPort:(uint16_t)port];
    [self.portTextfield resignFirstResponder];
    [self updatePortUI];
    [ADHAlert alertWithMessage:@"Port save sucessfully" infoText:@"Woodpecker will use this port on next launch,please restart to test your setting" comfirmBlock:^{
        
    }];
}

@end
