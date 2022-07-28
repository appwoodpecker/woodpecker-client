//
//  CloudContainerViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/10/13.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "CloudContainerViewController.h"
#import "EntitlementUtil.h"
#import "SandboxContainerCell.h"

static NSString *const kCloudDefaultContainerId = @"Default";
static NSString *const kPreferenceContainerListKey = @"containerList";

@interface CloudContainerViewController ()<SandboxContainerCellDelegate>

@property (strong) IBOutlet NSView *addLayout;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *customTextfield;
@property (weak) IBOutlet NSButton *addButton;

@property (nonatomic, strong) NSArray *containerList;
@property (nonatomic, strong) NSMutableArray *customList;

@property (nonatomic, strong) NSArray *viewList;

@end

@implementation CloudContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self initValue];
    [self initUI];
    [self loadContainerInfo];
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
}

- (void)initValue {
    self.customList = [NSMutableArray array];
    NSArray *customList = [Preference defaultValueForKey:kPreferenceContainerListKey inDomain:kToolModuleiCloud];
    if([customList isKindOfClass:[NSArray class]]) {
        [self.customList addObjectsFromArray:customList];
    }
    [self cookList];
    if(self.currentContainerId.length == 0) {
        self.currentContainerId = kCloudDefaultContainerId;
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
                NSArray *groupList = entitleData[@"com.apple.developer.icloud-container-identifiers"];
                if([groupList isKindOfClass:[NSArray class]] && groupList.count > 0) {
                    self.containerList = groupList;
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
    //default
    [viewList addObject:@{
                          @"title" : kCloudDefaultContainerId,
                          @"fix" : @1,
                          }];
    //suite list
    for (NSString *containerName in self.containerList) {
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
    NSString *containerId = self.customTextfield.stringValue;
    if(containerId.length == 0) {
        [self.customTextfield becomeFirstResponder];
        return;
    }
    BOOL exists = NO;
    for (NSString *name in self.containerList) {
        if([name isEqualToString:containerId]) {
            exists = YES;
            break;
        }
    }
    if(!exists) {
        for (NSString *name in self.customList) {
            if([name isEqualToString:containerId]) {
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
                           @"containerId" : adhvf_safestringfy(containerId),
                           };
    [self.apiClient requestWithService:@"adh.icloud" action:@"ubiquityIdCheck" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
        [wself.addButton hideHud];
        BOOL success = [body[@"success"] boolValue];
        if(success) {
            [self.customList addObject:containerId];
            [self cookList];
            [self.tableView reloadData];
            self.customTextfield.stringValue = adhvf_const_emptystr();
            [Preference setDefaultValue:self.customList forKey:kPreferenceContainerListKey inDomain:kToolModuleiCloud];
        }else {
            NSString *msg = body[@"msg"];
            [wself showErrorWithText:msg];
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
        self.currentContainerId = containerName;
        [self.tableView reloadData];
        if(self.completionBlock) {
            NSString *resultName = self.currentContainerId;
            if([resultName isEqualToString:kCloudDefaultContainerId]) {
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
        [Preference setDefaultValue:self.customList forKey:kPreferenceContainerListKey inDomain:kToolModuleiCloud];
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
        BOOL selected = [containerName isEqualToString:self.currentContainerId];
        [cell setSelected:selected];
        cell.delegate = self;
        cellView = cell;
    }else {
        cellView = self.addLayout;
    }
    return cellView;
}


@end
