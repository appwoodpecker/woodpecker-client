//
//  UserDefaultSuiteViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/10.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "UserDefaultSuiteViewController.h"
#import "UDSuiteCell.h"
#import "EntitlementUtil.h"

NSString *const kUserDefaultStandardSuiteName = @"standard";
static NSString *const kPreferenceSuiteListKey = @"suitelist";

@interface UserDefaultSuiteViewController ()<UDSuiteCellDelegate>

@property (strong) IBOutlet NSView *addLayout;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *customTextfield;
@property (weak) IBOutlet NSButton *addButton;

@property (nonatomic, strong) NSArray *suiteList;
@property (nonatomic, strong) NSMutableArray *customList;
@property (nonatomic, strong) NSArray *viewList;


@end

@implementation UserDefaultSuiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self initValue];
    [self initUI];
    [self loadSuitInfo];
    [self addNotification];
}

- (void)setupAfterXib {
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([UDSuiteCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([UDSuiteCell class])];
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
    NSArray *customList = [Preference defaultValueForKey:kPreferenceSuiteListKey inDomain:kToolModuleUserDefaults];
    if([customList isKindOfClass:[NSArray class]]) {
        [self.customList addObjectsFromArray:customList];
    }
    [self cookList];
    if(self.currentSuiteName.length == 0) {
        self.currentSuiteName = kUserDefaultStandardSuiteName;
    }
}

- (void)initUI {
    [self.tableView reloadData];
}

- (void)loadSuitInfo {
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.appinfo" action:@"entitlement" onSuccess:^(NSDictionary *body, NSData *payload) {
        if(payload) {
            NSDictionary *data = [EntitlementUtil parseEntitlementData:payload];
            NSDictionary *entitleData = data[@"Entitlements"];
            if([entitleData isKindOfClass:[NSDictionary class]]) {
                NSArray *groupList = entitleData[@"com.apple.security.application-groups"];
                if([groupList isKindOfClass:[NSArray class]] && groupList.count > 0) {
                    self.suiteList = groupList;
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
                          @"title" : kUserDefaultStandardSuiteName,
                          @"fix" : @1,
                          }];
    //suite list
    for (NSString *suiteName in self.suiteList) {
        [viewList addObject:@{
                              @"title" : adhvf_safestringfy(suiteName),
                              @"fix" : @1,
                              }];
    }
    //custom list
    for (NSString *suiteName in self.customList) {
        [viewList addObject:@{
                              @"title" : adhvf_safestringfy(suiteName),
                              }];
    }
    self.viewList = viewList;
}

- (IBAction)addButtonPressed:(id)sender {
    NSString *suiteName = self.customTextfield.stringValue;
    if(suiteName.length == 0) {
        [self.customTextfield becomeFirstResponder];
        return;
    }
    BOOL exists = NO;
    for (NSString *name in self.suiteList) {
        if([name isEqualToString:suiteName]) {
            exists = YES;
            break;
        }
    }
    if(!exists) {
        for (NSString *name in self.customList) {
            if([name isEqualToString:suiteName]) {
                exists = YES;
                break;
            }
        }
    }
    if(exists) {
        [self.customTextfield becomeFirstResponder];
        return;
    }
    [self.customList addObject:suiteName];
    [self cookList];
    [self.tableView reloadData];
    self.customTextfield.stringValue = adhvf_const_emptystr();
    [self.customTextfield resignFirstResponder];
    [Preference setDefaultValue:self.customList forKey:kPreferenceSuiteListKey inDomain:kToolModuleUserDefaults];
}

#pragma mark -----------------   cell delegate   ----------------

- (void)cellClicked: (ADHBaseCell *)cell {
    if(self.viewList.count == 0) {
        return;
    }
    NSInteger row = [self.tableView rowForView:cell];
    if(row != NSNotFound) {
        NSDictionary *data = self.viewList[row];
        NSString *suiteName = data[@"title"];
        self.currentSuiteName = suiteName;
        [self.tableView reloadData];
        if(self.completionBlock) {
            NSString *resultName = self.currentSuiteName;
            if([resultName isEqualToString:kUserDefaultStandardSuiteName]) {
                resultName = nil;
            }
            self.completionBlock(resultName);
        }
    }
}

- (void)suiteCellDeleteRequest: (UDSuiteCell *)cell {
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
        [Preference setDefaultValue:self.customList forKey:kPreferenceSuiteListKey inDomain:kToolModuleUserDefaults];
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
        UDSuiteCell *cell = [tableView makeViewWithIdentifier:NSStringFromClass([UDSuiteCell class]) owner:nil];
        NSDictionary *data = self.viewList[row];
        [cell setData:data];
        NSString *suiteName = data[@"title"];
        BOOL selected = [suiteName isEqualToString:self.currentSuiteName];
        [cell setSelected:selected];
        cell.delegate = self;
        cellView = cell;
    }else {
        cellView = self.addLayout;
    }
    return cellView;
}

@end
