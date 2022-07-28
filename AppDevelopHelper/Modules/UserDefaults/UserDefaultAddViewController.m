//
//  UserDefaultAddViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/12/6.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "UserDefaultAddViewController.h"

@interface UserDefaultAddViewController ()

@property (weak) IBOutlet NSTextField *keyTextfield;
@property (unsafe_unretained) IBOutlet NSTextView *valueTextfield;


@end

@implementation UserDefaultAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
}

- (void)setupAfterXib {
    
    self.valueTextfield.font = [NSFont systemFontOfSize:[NSFont systemFontSize] + 2];
}

- (IBAction)cancelButtonPressed:(id)sender {
    if(self.cancelBlock) {
        self.cancelBlock();
    }
}

- (BOOL)validateInputValues {
    BOOL result = NO;
    NSString *key = self.keyTextfield.stringValue;
    do {
        if(key.length == 0) {
            [self.keyTextfield becomeFirstResponder];
            break;
        }
        result = YES;
    } while (0);
    return result;
}

- (IBAction)addButtonPressed:(NSButton *)button {
    if(!doProCheckRoutine()) {
        return;
    }
    if(![self validateInputValues]) {
        return;
    }
    NSString *key = self.keyTextfield.stringValue;
    NSString *value = adhvf_safestringfy(self.valueTextfield.string);
    if(self.valueBlock) {
        self.valueBlock(key, value);
    }else {
        //request
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        NSString *serviceName = nil;
        NSString *actionName = nil;
        if(self.iCloud) {
            serviceName = @"adh.icloud";
            actionName = @"addUserDefaults";
        }else {
            serviceName = @"adh.userdefaults";
            actionName = @"add";
            if(self.suiteName.length > 0) {
                data[@"suitename"] = adhvf_safestringfy(self.suiteName);
            }
        }
        data[@"key"] = adhvf_safestringfy(key);
        data[@"value"] = value;
        __weak typeof(self) wself = self;
        [self.apiClient requestWithService:serviceName action:actionName body:data onSuccess:^(NSDictionary *body, NSData *payload) {
            [button hideHud];
            if(wself.completionBlock) {
                wself.completionBlock(key);
            }
        } onFailed:^(NSError *error) {
            [button hideHud];
            [wself showError];
        }];
        [button showHud];
    }
}

@end
