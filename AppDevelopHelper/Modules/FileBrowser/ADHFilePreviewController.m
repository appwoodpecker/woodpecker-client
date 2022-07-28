//
//  ADHFilePreviewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/27.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHFilePreviewController.h"
#import "FSWebViewController.h"
#import "DatabaseViewController.h"
#import "PlainTextViewController.h"
#import "FileTypeUtil.h"

@interface ADHFilePreviewController ()

@property (weak) IBOutlet NSTabView *contentTabView;

@end

@implementation ADHFilePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContentView];
}

- (void)setupContentView
{
    self.contentTabView.tabPosition = NSTabPositionNone;
    //PlainText
    NSTabViewItem * plainTextItem = [[NSTabViewItem alloc] init];
    PlainTextViewController * plainTextVC = [[PlainTextViewController alloc] init];
    plainTextVC.formatBeautify = self.formatBeautify;
    plainTextItem.viewController = plainTextVC;
    [self.contentTabView addTabViewItem:plainTextItem];
    //Database
    NSTabViewItem * databaseItem = [[NSTabViewItem alloc] init];
    DatabaseViewController * databaseVC = [[DatabaseViewController alloc] init];
    databaseVC.editable = self.editable;
    databaseItem.viewController = databaseVC;
    [self.contentTabView addTabViewItem:databaseItem];
    //webview
    NSTabViewItem * webviewItem = [[NSTabViewItem alloc] init];
    FSWebViewController * webVC = [[FSWebViewController alloc] init];
    webviewItem.viewController = webVC;
    [self.contentTabView addTabViewItem:webviewItem];
}

- (void)reload
{
    [self previewContent];
}

- (void)previewContent
{
    NSString * filePath = self.filePath;
    ADHFilePreviewItem * fileItem = self.fileItem;
    NSTabView * contentTabView = self.contentTabView;
    NSString * fileExt = [filePath pathExtension];
    BOOL isPlainText = [FileTypeUtil isPlainFileByMimeType:self.mimeType fileExt:fileExt];
    if(isPlainText){
        //plain file
        NSTabViewItem * plainTextItem = contentTabView.tabViewItems[0];
        [contentTabView selectTabViewItem:plainTextItem];
        PlainTextViewController * plainTextVC = (PlainTextViewController *)plainTextItem.viewController;
        plainTextVC.filePath = filePath;
        plainTextVC.fileItem = fileItem;
        [plainTextVC reload];
    }else if([FileTypeUtil isDBFileByExt:[fileItem fileExtension]] || [FileTypeUtil isDBFileByMetaData:filePath]){
        //database
        NSTabViewItem * dbItem = contentTabView.tabViewItems[1];
        [contentTabView selectTabViewItem:dbItem];
        DatabaseViewController * dbVC = (DatabaseViewController *)dbItem.viewController;
        dbVC.filePath = filePath;
        dbVC.fileItem = fileItem;
        [dbVC reload];
    }else{
        //webview
        NSTabViewItem * webItem = contentTabView.tabViewItems[2];
        [contentTabView selectTabViewItem:webItem];
        FSWebViewController * webVC = (FSWebViewController *)webItem.viewController;
        webVC.filePath = filePath;
        webVC.fileItem = fileItem;
        [webVC reload];
    }
}


@end












