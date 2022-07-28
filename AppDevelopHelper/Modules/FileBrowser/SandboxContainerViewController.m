//
//  UserDefaultSuiteViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/10.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "SandboxContainerViewController.h"
#import "EntitlementUtil.h"
#import "SandboxContainerCell.h"

static NSString *const kSandboxDefaultContaienr = @"sandbox";
static NSString *const kPreferenceContainerListKey = @"containerList";

@interface SandboxContainerViewController ()<SandboxContainerCellDelegate>

@property (strong) IBOutlet NSView *addLayout;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *customTextfield;
@property (weak) IBOutlet NSButton *addButton;

@property (nonatomic, strong) NSArray *containeriList;
@property (nonatomic, strong) NSMutableArray *customList;

@property (nonatomic, strong) NSArray *viewList;

@end

@implementation SandboxContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initValue];
    [self initUI];
    [self loadContainerInfo];
    [self addNotification];
}

- (void)setupAfterXib {
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([SandboxContainerCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([SandboxContainerCell class])];
    self.tableView.rowHeight = self.addLayout.height;
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.addButton setTintColor:[Appearance actionImageColor]];
    [self.tableView reloadData];
}

- (void)initValue {
    self.customList = [NSMutableArray array];
    NSArray *customList = [Preference defaultValueForKey:kPreferenceContainerListKey inDomain:kToolModuleSandbox];
    if([customList isKindOfClass:[NSArray class]]) {
        [self.customList addObjectsFromArray:customList];
    }
    [self cookList];
    if(self.currentContainerName.length == 0) {
        self.currentContainerName = kSandboxDefaultContaienr;
    }
}

- (void)initUI {
    [self.tableView reloadData];
}

- (void)loadContainerInfo {
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.appinfo" action:@"entitlement" onSuccess:^(NSDictionary *body, NSData *payload) {
        if(payload) {
            NSDictionary *data = [EntitlementUtil parseEntitlementData:payload];
            NSDictionary *entitleData = data[@"Entitlements"];
            if([entitleData isKindOfClass:[NSDictionary class]]) {
                NSArray *groupList = entitleData[@"com.apple.security.application-groups"];
                if([groupList isKindOfClass:[NSArray class]] && groupList.count > 0) {
                    self.containeriList = groupList;
                    [wself cookList];
                    [wself.tableView reloadData];
                }
            }
        }
    } onFailed:^(NSError *error) {
        
    }];
}

- (void)cookList {
    NSMutableArray *viewList = [NSMutableArray array];
    //standard
    [viewList addObject:@{
                          @"title" : kSandboxDefaultContaienr,
                          @"fix" : @1,
                          }];
    //suite list
    for (NSString *containerName in self.containeriList) {
        [viewList addObject:@{
                              @"title" : adhvf_safestringfy(containerName),
                              @"fix" : @1,
                              }];
    }
    //custom list
    for (NSString *containerName in self.customList) {
        [viewList addObject:@{
                              @"title" : adhvf_safestringfy(containerName),
                              }];
    }
    self.viewList = viewList;
}

- (IBAction)addButtonPressed:(id)sender {
    NSString *containerName = self.customTextfield.stringValue;
    if(containerName.length == 0) {
        [self.customTextfield becomeFirstResponder];
        return;
    }
    BOOL exists = NO;
    for (NSString *name in self.containeriList) {
        if([name isEqualToString:containerName]) {
            exists = YES;
            break;
        }
    }
    if(!exists) {
        for (NSString *name in self.customList) {
            if([name isEqualToString:containerName]) {
                exists = YES;
                break;
            }
        }
    }
    if(exists) {
        [self.customTextfield becomeFirstResponder];
        return;
    }
    [self.customTextfield resignFirstResponder];
    __weak typeof(self) wself = self;
    [self.addButton showHud];
    NSDictionary *data = @{
                           @"container" : adhvf_safestringfy(containerName),
                           };
    [self.apiClient requestWithService:@"adh.sandbox" action:@"groupContainerCheck" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.addButton hideHud];
        BOOL success = [body[@"success"] boolValue];
        if(success) {
            [self.customList addObject:containerName];
            [self cookList];
            [self.tableView reloadData];
            self.customTextfield.stringValue = adhvf_const_emptystr();
            [Preference setDefaultValue:self.customList forKey:kPreferenceContainerListKey inDomain:kToolModuleSandbox];
        }else {
            [wself showErrorWithText:@"bad group container"];
            [wself.customTextfield becomeFirstResponder];
        }
    } onFailed:^(NSError *error) {
        [wself.addButton hideHud];
    }];
}

#pragma mark -----------------   cell delegate   ----------------

- (void)cellClicked: (ADHBaseCell *)cell {
    if(self.viewList.count == 0) {
        return;
    }
    NSInteger row = [self.tableView rowForView:cell];
    if(row != NSNotFound) {
        NSDictionary *data = self.viewList[row];
        NSString *containerName = data[@"title"];
        self.currentContainerName = containerName;
        [self.tableView reloadData];
        if(self.completionBlock) {
            NSString *resultName = self.currentContainerName;
            if([resultName isEqualToString:kSandboxDefaultContaienr]) {
                resultName = nil;
            }
            self.completionBlock(resultName);
        }
    }
}

- (void)sandboxCellDeleteRequest: (SandboxContainerCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    NSDictionary *data = self.viewList[row];
    NSString *suiteName = data[@"title"];
    NSInteger customIndex = NSNotFound;
    for (NSInteger i=0;i<self.customList.count;i++) {
        NSString *name = self.customList[i];
        if([name isEqualToString:suiteName]) {
            customIndex = i;
            break;
        }
    }
    if(customIndex != NSNotFound) {
        [self.customList removeObjectAtIndex:customIndex];
        [self cookList];
        [self.tableView reloadData];
        [Preference setDefaultValue:self.customList forKey:kPreferenceContainerListKey inDomain:kToolModuleSandbox];
    }
}

#pragma mark -----------------   tableview datasource & delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.viewList.count + 1;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat height = 0.0f;
    if(row < self.viewList.count) {
        height = 32.0f;
    }else {
        height = self.addLayout.height;
    }
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView *cellView = nil;
    if(row < self.viewList.count) {
        SandboxContainerCell *cell = [tableView makeViewWithIdentifier:NSStringFromClass([SandboxContainerCell class]) owner:nil];
        NSDictionary *data = self.viewList[row];
        [cell setData:data];
        NSString *containerName = data[@"title"];
        BOOL selected = [containerName isEqualToString:self.currentContainerName];
        [cell setSelected:selected];
        cell.delegate = self;
        cellView = cell;
    }else {
        cellView = self.addLayout;
    }
    return cellView;
}

@end
