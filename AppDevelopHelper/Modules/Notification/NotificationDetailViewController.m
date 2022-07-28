//
//  NotificationDetailViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2018/2/27.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "NotificationDetailViewController.h"
#import "NotificationItemCell.h"
#import "NotificationItemKeyCell.h"

@interface NotificationDetailViewController ()<NSTableViewDelegate, NSTableViewDataSource,ADHBaseCellDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *keyColumn;
@property (weak) IBOutlet NSTableColumn *valueColumn;
@property (nonatomic, strong) ADHNotificationItem * notifictionItem;
@property (nonatomic, strong) NSArray * keyList;
@property (nonatomic, strong) NSArray * valueList;

@end

@implementation NotificationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
}

- (void)setupAfterXib
{
    NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([NotificationItemCell class]) bundle:nil];
    [self.tableView registerNib:nib forIdentifier:NSStringFromClass([NotificationItemCell class])];
    
    NSNib * keyNib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([NotificationItemKeyCell class]) bundle:nil];
    [self.tableView registerNib:keyNib forIdentifier:NSStringFromClass([NotificationItemKeyCell class])];
    self.tableView.gridStyleMask = NSTableViewSolidVerticalGridLineMask;
    self.tableView.usesAlternatingRowBackgroundColors = YES;
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    NSWindowStyleMask style = self.view.window.styleMask;
    style = (style & ~(NSWindowStyleMaskResizable));
    self.view.window.styleMask = style;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [self updateContentUI];
}

- (void)setData: (ADHNotificationItem *)item
{
    self.notifictionItem = item;
    [self cookList];
}

- (void)updateContentUI {
    [self.tableView reloadData];
}

- (void)cookList
{
    NSMutableArray * keyList = [NSMutableArray array];
    NSMutableArray * valueList = [NSMutableArray array];
    ADHNotificationItem * item = self.notifictionItem;
    
    [keyList addObject:@"Title"];
    [valueList addObject:adhvf_safestringfy(item.title)];
    
    [keyList addObject:@"Subtitle"];
    [valueList addObject:adhvf_safestringfy(item.subtitle)];
    
    [keyList addObject:@"Body"];
    [valueList addObject:adhvf_safestringfy(item.body)];
    
    if(item.fireTimeinterval > 0){
        [keyList addObject:@"Date"];
        NSString * dateText = [ADHDateUtil formatStringWithTimeInterval:item.fireTimeinterval dateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [valueList addObject:dateText];
    }
    
    //trigger type
    [keyList addObject:@"Trigger"];
    [valueList addObject:[ADHNotificationItem readbleTriggerType:item.triggerType]];
    
    if(item.triggerType != ADHNotificationTriggerTypePush) {
        //trigger condition
        [keyList addObject:@"Trigger Detail"];
        [valueList addObject:adhvf_safestringfy(item.triggerDetail)];
        //next trigger date
        if(item.nextTriggerTimeinterval > 0) {
            if(item.triggerType != ADHNotificationTriggerTypeLegacyCalendar) {
                [keyList addObject:@"Next Fire Date"];
            }else {
                [keyList addObject:@"Scheduled Fire Date"];
            }
            NSString * dateText = [ADHDateUtil formatStringWithTimeInterval:item.nextTriggerTimeinterval dateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [valueList addObject:dateText];
        }
        //trigger repeat
        [keyList addObject:@"Trigger Repeat"];
        [valueList addObject:item.triggerRepeat ? @"YES" : @"NO"];
    }
    
    [keyList addObject:@"User Info"];
    if(item.userInfo) {
        [valueList addObject:[NSString stringWithFormat:@"%@",item.userInfo]];
    }else {
        [valueList addObject: @""];
    }
    
    [keyList addObject:@"Badge"];
    [valueList addObject:adhvf_safestringfy(item.badge)];
    
    [keyList addObject:@"Sound"];
    [valueList addObject:adhvf_safestringfy(item.sound)];
    
    [keyList addObject:@"LaunchImage Name"];
    [valueList addObject:adhvf_safestringfy(item.launchImageName)];
    
    [keyList addObject:@"Attachments"];
    if(item.attachments) {
        [valueList addObject:[NSString stringWithFormat:@"%@",item.attachments]];
    }else {
        [valueList addObject:@""];
    }
    
    [keyList addObject:@"CategoryIdentifier"];
    [valueList addObject:adhvf_safestringfy(item.categoryIdentifier)];
    
    if(item.actionIdentifier.length > 0){
        [keyList addObject:@"ActionIdentifier"];
        [valueList addObject:adhvf_safestringfy(item.actionIdentifier)];
    }
    
    if(item.identifier.length > 0) {
        [keyList addObject:@"Identifier"];
        [valueList addObject:adhvf_safestringfy(item.identifier)];
    }
    if(item.source.length > 0) {
        [keyList addObject:@"Source"];
        [valueList addObject:adhvf_safestringfy(item.source)];
    }
    
    self.keyList = keyList;
    self.valueList = valueList;
}


#pragma mark -----------------   tableview datasource & delegate   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.keyList.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    NSString * value = self.valueList[row];
    CGFloat contentWidth = self.valueColumn.width;
    height = [NotificationItemCell heightForData:value contentWidth:contentWidth];
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    ADHBaseCell * cell = nil;
    NSString * value = nil;
    if(tableColumn == self.keyColumn){
        value = self.keyList[row];
        NotificationItemKeyCell * keyCell = [tableView makeViewWithIdentifier:NSStringFromClass([NotificationItemKeyCell class]) owner:nil];
        [keyCell setData:value];
        cell = keyCell;
    }else if(tableColumn == self.valueColumn){
        value = self.valueList[row];
        NotificationItemCell * valueCell = [tableView makeViewWithIdentifier:NSStringFromClass([NotificationItemCell class]) owner:nil];
        CGFloat contentWidth = self.valueColumn.width;
        [valueCell setData:value contentWidth:contentWidth];
        cell = valueCell;
    }
    [cell setDelegate:self];
    return cell;
}

- (void)cellRightClicked: (ADHBaseCell *)cell point: (NSPoint)point
{
    NSInteger row = [self.tableView rowForView:cell];
    if(row < 0) return;
    NSMenu * menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    //copy key
    NSMenuItem * keyItem = [[NSMenuItem alloc] initWithTitle:@"Copy Key" action:@selector(copyKeyMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    keyItem.target = self;
    keyItem.representedObject = [NSNumber numberWithInteger:row];
    [menu addItem:keyItem];
    
    //copy value
    NSMenuItem * valueItem = [[NSMenuItem alloc] initWithTitle:@"Copy Value" action:@selector(copyValueMenuSelected:) keyEquivalent:adhvf_const_emptystr()];
    valueItem.target = self;
    valueItem.representedObject = [NSNumber numberWithInteger:row];
    [menu addItem:valueItem];
    
    [menu popUpMenuPositioningItem:nil atLocation:point inView:cell];
}

- (void)copyValueMenuSelected: (NSMenuItem *)menu
{
    NSInteger row = [menu.representedObject integerValue];
    NSString * value = self.valueList[row];
    if(value.length > 0){
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:value forType:NSPasteboardTypeString];
    }
}

- (void)copyKeyMenuSelected: (NSMenuItem *)menu
{
    NSInteger row = [menu.representedObject integerValue];
    NSString * value = self.keyList[row];
    if(value.length > 0){
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:value forType:NSPasteboardTypeString];
    }
}


@end




















