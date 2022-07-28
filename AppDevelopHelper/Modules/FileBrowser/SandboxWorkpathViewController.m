//
//  SandboxWorkpathViewController.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/6/1.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "SandboxWorkpathViewController.h"
#import "SandboxWorkpathCell.h"

@interface SandboxWorkpathViewController ()<SandboxWorkpathCellDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSArray *customList;
@property (nonatomic, strong) NSMutableArray *viewList;

@end

@implementation SandboxWorkpathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initValue];
    [self initUI];
}

- (void)setupUI {
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([SandboxWorkpathCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([SandboxWorkpathCell class])];
    self.tableView.rowHeight = 40.0;
    self.view.wantsLayer = YES;
}

- (void)initValue {
    self.customList = [self.service loadCustomWorkpathItems];
    [self cookList];
}

- (void)cookList {
    NSMutableArray *viewList = [NSMutableArray array];
    SandboxWorkpathItem *thisItem = nil;
    if(self.customList) {
        for (SandboxWorkpathItem *item in self.customList) {
            if([item.bundleId isEqualToString:self.context.bundleId]) {
                thisItem = item;
                continue;
            }
            [viewList addObject:item];
        }
    }
    if(!thisItem) {
        thisItem = [[SandboxWorkpathItem alloc] init];
        thisItem.bundleId = self.context.bundleId;
        thisItem.path = nil;
    }
    [viewList addObject:thisItem];
    self.viewList = viewList;
}

- (void)initUI {
    [self.tableView reloadData];
}


#pragma mark -----------------   tableview datasource & delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.viewList.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    SandboxWorkpathCell *cell = [tableView makeViewWithIdentifier:NSStringFromClass([SandboxWorkpathCell class]) owner:nil];
    SandboxWorkpathItem *item = self.viewList[row];
    [cell setData:item];
    cell.delegate = self;
    return cell;
}

#pragma mark -----------------   cell delegate   ----------------

- (void)workpathCellPathSetup: (SandboxWorkpathCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    SandboxWorkpathItem *item = self.viewList[row];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    NSURL * directoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
    panel.directoryURL = directoryURL;
    __weak typeof(self) wself = self;
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) {
            NSURL * fileURL = [panel URL];
            NSString * filePath = [fileURL path];
            item.path = filePath;
            [wself.service saveCustomWorkpaths:wself.viewList];
            if(wself.completionBlock) {
                wself.completionBlock(filePath);
            }
        }
    }];
}

- (void)workpathCellDelete: (SandboxWorkpathCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    SandboxWorkpathItem *item = self.viewList[row];
    if([item.bundleId isEqualToString:self.context.bundleId]) {
        item.path = nil;
        [cell setData:item];
        if(self.updationBlock) {
            self.updationBlock(nil);
        }
    }else {
        [self.viewList removeObject:item];
        [self.tableView reloadData];
    }
    [self.service saveCustomWorkpaths:self.viewList];
}



@end
