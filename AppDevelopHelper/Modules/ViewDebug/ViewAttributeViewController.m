//
//  ViewAttributeViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/17.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewAttributeViewController.h"
#import "ViewAttributeHeader.h"
#import "ViewAttributeCell.h"
#import "ViewAttributeNameCell.h"
#import "ViewTextAttributeCell.h"
#import "ViewFrameAttributeCell.h"
#import "ViewColorAttributeCell.h"
#import "ViewAutoresizeAttributeCell.h"
#import "ViewEditableTextAttrCell.h"
#import "ViewImageViewAttrCell.h"
#import "ViewPopupAttributeCell.h"
#import "ViewSliderAttributeCell.h"
#import "ViewStepperAttributeCell.h"
#import "ViewBooleanAttributeCell.h"
#import "ViewSelectAttributeCell.h"
#import "ViewValueAttributeCell.h"
#import "ViewFontAttributeCell.h"
#import "ViewAttriWebNaviCell.h"
#import "ViewGestureCell.h"
#import "ViewGestureRecognizerViewController.h"
#import "WebDebugViewController.h"
#import "ViewInsetsAttributeCell.h"

@interface ViewAttributeViewController ()<NSTableViewDataSource, NSTableViewDelegate,ViewAttributeCellDelegate>

@property (weak) IBOutlet NSScrollView *scrollView;

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *nameColumn;
@property (weak) IBOutlet NSTableColumn *contentColumn;

@property (nonatomic, strong) ADHViewNode *node;
@property (nonatomic, strong) NSArray *rowList;

@property (nonatomic, strong) ViewGestureRecognizerViewController *gestureController;
@property (nonatomic, strong) WebDebugViewController *webVC;

@end

@implementation ViewAttributeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNodeSelectStateUpdate:) name:kViewDebugNodeSelectStateNotification object:nil];
}

- (void)setupAfterXib {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    NSArray *cells = @[
                       [ViewAttributeHeader class],
                       [ViewAttributeNameCell class],
                       [ViewTextAttributeCell class],
                       [ViewEditableTextAttrCell class],
                       [ViewFrameAttributeCell class],
                       [ViewColorAttributeCell class],
                       [ViewAutoresizeAttributeCell class],
                       [ViewImageViewAttrCell class],
                       [ViewPopupAttributeCell class],
                       [ViewSelectAttributeCell class],
                       [ViewSliderAttributeCell class],
                       [ViewStepperAttributeCell class],
                       [ViewBooleanAttributeCell class],
                       [ViewValueAttributeCell class],
                       [ViewFontAttributeCell class],
                       [ViewAttriWebNaviCell class],
                       [ViewGestureCell class],
                       [ViewInsetsAttributeCell class],
                       ];
    for (Class clazz in cells) {
        NSNib * nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass(clazz) bundle:nil];
        [self.tableView registerNib:nib forIdentifier:NSStringFromClass(clazz)];
    }
    self.tableView.usesAlternatingRowBackgroundColors = YES;
    self.tableView.rowHeight = 32.0f;
    self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    self.scrollView.automaticallyAdjustsContentInsets = NO;
    self.scrollView.contentInsets = NSEdgeInsetsMake(0, 0, 30.0f, 0);
}

- (void)cookData {
    NSMutableArray *rowList = [NSMutableArray array];
    NSArray *attributes = self.node.attributes;
    for (ADHAttribute *attr in attributes) {
        attr.appContext = self.context;
        NSArray<ADHAttrItem *> * itemList = [attr itemList];
        if(itemList.count > 0) {
            [rowList addObject:attr];
            [rowList addObjectsFromArray:itemList];
        }
    }
    self.rowList = rowList;
}

#pragma mark -----------------   notification   ----------------

- (void)onNodeSelectStateUpdate: (NSNotification *)noti {
    if(noti.object == self) {
        return;
    }
    ADHViewNode *node = noti.userInfo[@"node"];
    self.node = node;
    [self cookData];
    [self.tableView reloadData];
}

#pragma mark -----------------   cell delegate   ----------------

//数据更新
- (void)valueUpdateRequest: (ViewAttributeCell *)cell value: (id)value info: (NSDictionary *)info {
    NSInteger row = [self.tableView rowForView:cell];
    if(row == NSNotFound || row <0 || row >self.rowList.count-1) {
        return;
    }
    if(value) {
        id rowData = self.rowList[row];
        if([rowData isKindOfClass:[ADHAttrItem class]]) {
            ADHAttrItem *item = rowData;
            ADHAttribute *attribute = item.attribute;
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            data[@"instaddr"] = adhvf_safestringfy(self.node.weakViewAddr);
            data[@"attrClass"] = adhvf_safestringfy(NSStringFromClass([attribute class]));
            data[@"key"] = adhvf_safestringfy(item.key);
            NSData *payload = nil;
            if([value isKindOfClass:[NSData class]]) {
                data[@"payloadValue"] = @(1);
                payload = value;
            }else {
                data[@"value"] = value;
            }
            NSMutableDictionary *payloadInfo = [NSMutableDictionary dictionary];
            if(info) {
                [payloadInfo addEntriesFromDictionary:info];
            }
            NSDictionary *extraInfo = [attribute getInfoBeforeSetValueRequest:item];
            if(extraInfo) {
                [payloadInfo addEntriesFromDictionary:extraInfo];
            }
            if(payloadInfo.count > 0) {
                data[@"info"] = payloadInfo;
            }
            if(self.domain.serviceAddr) {
                data[@"serviceAddr"] = adhvf_safestringfy(self.domain.serviceAddr);
            }
            [cell showHud];
            [self.apiClient requestWithService:@"adh.viewdebug" action:@"setValue" body:data payload:payload progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
                [cell hideHud];
                BOOL succeed = [body[@"success"] boolValue];
                if(succeed) {
                    //1.更新本地值
                    id retValue = value;
                    if(body[@"value"]) {
                        retValue = body[@"value"];
                    }
                    NSDictionary *retInfo = body[@"info"];
                    [attribute updateAttrValue:item value:retValue info:retInfo localInfo:info];
                    if(payload) {
                        //update node snapshot
                        [self.domain updateNodeSnapshot:self.node snapshot:payload];
                    }
                    //2.更新3d node状态
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    if(item.key) {
                        userInfo[@"key"] = item.key;
                    }
                    userInfo[@"node"] = self.node;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kViewDebugNodeAttributeUpdateNotification object:self userInfo:userInfo];
                    //更新attribute view
                    NSIndexSet *rowIndex = [NSIndexSet indexSetWithIndex:row];
                    NSMutableIndexSet *columnIndex = [NSMutableIndexSet indexSet];
                    [columnIndex addIndex:0];
                    [columnIndex addIndex:1];
                    ADHAttrItemAffect affect = [attribute getAffectWithItem:item];
                    if(affect == ADHAttrItemAffectHeight) {
                        [self.tableView noteHeightOfRowsWithIndexesChanged:rowIndex];
                        [self.tableView reloadDataForRowIndexes:rowIndex columnIndexes:columnIndex];
                    }else if(affect == ADHAttrItemAffectLarge) {
                        [self.tableView reloadData];
                    }else {
                        [self.tableView reloadDataForRowIndexes:rowIndex columnIndexes:columnIndex];
                    }
                }else {
                    //attribute view还原
                    /*
                    id value = [attribute getAttrValue:item];
                    [cell setData:value contentWidth:self.contentColumn.width];
                     */
                    [cell hideHud];
                    [self showErrorWithText:@"update failed"];
                }
            } onFailed:^(NSError *error) {
                [cell hideHud];
                [self showErrorWithText:@"update failed"];
            }];
        }
    }
}

//请求数据
- (void)valueRequest: (ViewAttributeCell *)cell info:(NSDictionary *)info {
    NSInteger row = [self.tableView rowForView:cell];
    if(row == NSNotFound || row <0 || row >self.rowList.count-1) {
        return;
    }
    id rowData = self.rowList[row];
    if([rowData isKindOfClass:[ADHAttrItem class]]) {
        ADHAttrItem *item = rowData;
        ADHAttribute *attribute = item.attribute;
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"instaddr"] = adhvf_safestringfy(self.node.weakViewAddr);
        data[@"attrClass"] = adhvf_safestringfy(NSStringFromClass([attribute class]));
        data[@"key"] = adhvf_safestringfy(item.key);
        NSMutableDictionary *payloadInfo = [NSMutableDictionary dictionary];
        if(info) {
            [payloadInfo addEntriesFromDictionary:info];
        }
        NSDictionary *extraInfo = [attribute getInfoBeforeGetValueRequest:item];
        if(extraInfo) {
            [payloadInfo addEntriesFromDictionary:extraInfo];
        }
        if(payloadInfo.count > 0) {
            data[@"info"] = payloadInfo;
        }
        if(self.domain.serviceAddr) {
            data[@"serviceAddr"] = adhvf_safestringfy(self.domain.serviceAddr);
        }
        [cell showHud];
        [self.apiClient requestWithService:@"adh.viewdebug" action:@"getValue" body:data onSuccess:^(NSDictionary *body, NSData *payload) {
            [cell hideHud];
            BOOL succeed = [body[@"success"] boolValue];
            if(succeed) {
                //1.更新本地值
                id retValue = payload;
                if(body[@"value"]) {
                    retValue = body[@"value"];
                }
                NSDictionary *retInfo = body[@"info"];
                [attribute updateAttrValue:item value:retValue info:retInfo localInfo:info];
                //更新attribute view
                NSIndexSet *rowIndex = [NSIndexSet indexSetWithIndex:row];
                NSMutableIndexSet *columnIndex = [NSMutableIndexSet indexSet];
                [columnIndex addIndex:0];
                [columnIndex addIndex:1];
                ADHAttrItemAffect affect = [attribute getAffectWithItem:item];
                if(affect == ADHAttrItemAffectHeight) {
                    [self.tableView noteHeightOfRowsWithIndexesChanged:rowIndex];
                    [self.tableView reloadDataForRowIndexes:rowIndex columnIndexes:columnIndex];
                }else if(affect == ADHAttrItemAffectLarge) {
                    [self.tableView reloadData];
                }else {
                    [self.tableView reloadDataForRowIndexes:rowIndex columnIndexes:columnIndex];
                }
            }else {
                [self showErrorWithText:@"get failed"];
            }
        } onFailed:^(NSError *error) {
            [cell hideHud];
            [self showErrorWithText:@"get failed"];
        }];
    }
}

/**
 * 状态更新请求，一般为popup cell
 */
- (void)stateUpdateRequest: (ViewAttributeCell *)cell value: (id)value info: (nullable NSDictionary *)info {
    NSInteger row = [self.tableView rowForView:cell];
    if(row == NSNotFound || row <0 || row >self.rowList.count-1) {
        return;
    }
    id rowData = self.rowList[row];
    if([rowData isKindOfClass:[ADHAttrItem class]]) {
        ADHAttrItem *item = rowData;
        ADHAttribute *attribute = item.attribute;
        [attribute updateStateValue:item value:value info:info];
        //更新attribute view
        [self.tableView reloadData];
    }
}

- (void)actionRequest:(ViewAttributeCell *)cell {
    NSInteger row = [self.tableView rowForView:cell];
    if(row == NSNotFound || row <0 || row >self.rowList.count-1) {
        return;
    }
    id rowData = self.rowList[row];
    if([rowData isKindOfClass:[ADHAttrItem class]]) {
        ADHAttrItem *item = (ADHAttrItem *)rowData;
        NSString *key = item.key;
        if([key isEqualToString:@"gestureRecognizers"]) {
            ADHViewAttribute *viewAttribute = (ADHViewAttribute *)item.attribute;
            NSInteger index = [item.subKey integerValue];
            ViewGestureRecognizerViewController *vc = [[ViewGestureRecognizerViewController alloc] init];
            vc.viewAttribute = viewAttribute;
            vc.index = index;
            NSDictionary *gestureData = viewAttribute.gestureRecognizers[index];
            NSString *shortName = gestureData[@"shortname"];
            NSString *addr = gestureData[@"instaddr"];
            NSString *title = nil;
            if(shortName) {
                title = [NSString stringWithFormat:@"%@ %@",shortName,addr];
            }else {
                title = addr;
            }
            vc.name = title;
            __weak typeof(self) wself = self;
            vc.updationBlock = ^(NSString * _Nonnull gestureKey, id  _Nonnull gestureValue, NSDictionary * _Nonnull gestureInfo) {
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                if(gestureInfo) {
                    [info addEntriesFromDictionary:gestureInfo];
                }
                info[@"gesture-index"] = [NSNumber numberWithInteger:index];
                info[@"gesture-key"] = adhvf_safestringfy(gestureKey);
                info[@"gesture-class"] = adhvf_safestringfy(gestureData[@"class"]);
                [wself valueUpdateRequest:cell value:gestureValue info:info];
            };
            [self presentViewController:vc asPopoverRelativeToRect:cell.bounds ofView:cell preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorSemitransient];
            self.gestureController= vc;
        }
        if(item.type == ADHAttrTypeWebNavi) {
            if([key isEqualToString:@"action"]) {
                WebDebugViewController *webVC = [[WebDebugViewController alloc] initWithNibName:@"WebDebugViewController" bundle:nil];
                ADHViewNode *viewNode = item.attribute.viewNode;
                webVC.webNode = viewNode;
                webVC.context = self.context;
                NSWindow * window = self.view.window;
                CGSize windowSize = window.screen.frame.size;
                CGSize viewSize = [Appearance getModalWindowSize:windowSize];
                webVC.view.size = viewSize;
                [self presentViewControllerAsModalWindow:webVC];
                self.webVC = webVC;
            }
        }
    }
}




#pragma mark -----------------   table view   ----------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.rowList.count;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    id rowData = self.rowList[row];
    return [rowData isKindOfClass:[ADHAttribute class]];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGFloat height = 0;
    id rowData = self.rowList[row];
    if([rowData isKindOfClass:[ADHAttribute class]]) {
        height = [ViewAttributeHeader heightForData:rowData contentWidth:tableView.width];
    }else {
        ADHAttrItem *item = rowData;
        CGFloat keyHeight = [ViewAttributeNameCell heightForData:item.name contentWidth:self.nameColumn.width];
        ADHAttribute *attribute = item.attribute;
        id value = [attribute getAttrValue:item];
        Class clazz = [self attributeCellForType:item.type];
        CGFloat valueHeight = [clazz heightForData:value contentWidth:self.contentColumn.width];
        height = MAX(keyHeight, valueHeight);
        
    }
    return height;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView * view = nil;
    id rowData = self.rowList[row];
    if([rowData isKindOfClass:[ADHAttribute class]]) {
        ADHAttribute *attr = rowData;
        ViewAttributeHeader *header = [tableView makeViewWithIdentifier:NSStringFromClass([ViewAttributeHeader class]) owner:nil];
        [header setData:attr contentWidth:tableView.width];
        header.contextVC = self;
        view = header;
    }else {
        ADHAttrItem *item = rowData;
        if(tableColumn == self.nameColumn) {
            ViewAttributeNameCell *nameCell = [tableView makeViewWithIdentifier:NSStringFromClass([ViewAttributeNameCell class]) owner:nil];
            [nameCell setData:item.name contentWidth:tableColumn.width];
            nameCell.contextVC = self;
            view = nameCell;
        }else if(tableColumn == self.contentColumn) {
            ADHAttribute *attribute = item.attribute;
            id value = [attribute getAttrValue:item];
            Class clazz = [self attributeCellForType:item.type];
            ViewAttributeCell *valueCell = [tableView makeViewWithIdentifier:NSStringFromClass(clazz) owner:nil];
            valueCell.item = item;
            valueCell.attribute = attribute;
            [valueCell setData:value contentWidth:tableColumn.width];
            valueCell.delegate = self;
            valueCell.contextVC = self;
            view = valueCell;
        }
    }
    return view;
}

#pragma mark -----------------   attribute   ----------------

- (Class)attributeCellForType: (ADHAttrType)type {
    Class clazz = nil;
    switch (type) {
        case ADHAttrTypeText:
            clazz = [ViewTextAttributeCell class];
            break;
        case ADHAttrTypeEditText:
            clazz = [ViewEditableTextAttrCell class];
            break;
        case ADHAttrTypeFrame:
            clazz = [ViewFrameAttributeCell class];
            break;
        case ADHAttrTypeColor:
            clazz = [ViewColorAttributeCell class];
            break;
        case ADHAttrTypeAutoresizing:
            clazz = [ViewAutoresizeAttributeCell class];
            break;
        case ADHAttrTypeImage:
            clazz = [ViewImageViewAttrCell class];
            break;
        case ADHAttrTypePopup:
            clazz = [ViewPopupAttributeCell class];
            break;
        case ADHAttrTypeSelect:
            clazz = [ViewSelectAttributeCell class];
            break;
        case ADHAttrTypeSlider:
            clazz = [ViewSliderAttributeCell class];
            break;
        case ADHAttrTypeStepper:
            clazz = [ViewStepperAttributeCell class];
            break;
        case ADHAttrTypeBoolean:
            clazz = [ViewBooleanAttributeCell class];
            break;
        case ADHAttrTypeValue:
            clazz = [ViewValueAttributeCell class];
            break;
        case ADHAttrTypeFont:
            clazz = [ViewFontAttributeCell class];
            break;
        case ADHAttrTypeWebNavi:
            clazz = [ViewAttriWebNaviCell class];
            break;
        case ADHAttrTypeGesture:
            clazz = [ViewGestureCell class];
            break;
        case ADHAttrTypeInsets:
            clazz = [ViewInsetsAttributeCell class];
            break;
        default:
            break;
    }
    return clazz;
}

@end
