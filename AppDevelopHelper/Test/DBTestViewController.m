//
//  DBTestViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/11.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "DBTestViewController.h"
#import "EGODatabase.h"
@import WebKit;

@interface DBTestViewController ()

@property (weak) IBOutlet WKWebView *webview;
@property (weak) IBOutlet NSTextField *sqlTextfield;
@property (nonatomic, strong) EGODatabase * database;

@end

@implementation DBTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * dbPath = @"/Users/zhangxiaogang/SourceTree/AppDevelopHelper/tmp/apps/test/Documents/test.sqlite";
    self.database = [[EGODatabase alloc] initWithPath:dbPath];
    [self.database open];
}

- (IBAction)queryButtonPressed:(id)sender {
    NSString * sql = self.sqlTextfield.stringValue;
    if(sql.length == 0) return;
    EGODatabaseResult * dbResult = [self.database executeQuery:sql];
    [self cookQueryResult:dbResult];
}

- (void)cookQueryResult : (EGODatabaseResult *)result
{
    NSArray * columnNames = result.columnNames;
    NSMutableArray * tableDatas = [NSMutableArray arrayWithCapacity:result.rows.count];
    for (int i=0; i<result.rows.count; i++) {
        NSMutableDictionary * aRow = [NSMutableDictionary dictionary];
        EGODatabaseRow * row = result.rows[i];
        for (NSString * columnName in columnNames) {
            NSString * strValue = [row stringForColumn:columnName];
            if(!strValue) strValue = @"";
            aRow[columnName] = strValue;
        }
        [tableDatas addObject:aRow];
    }
    //render
    NSString * html = [self renderHtmlWithSections:columnNames tableDatas:tableDatas];
    [self showQueryResult:html];
}

- (NSString *)renderHtmlWithSections: (NSArray *)sections tableDatas: (NSArray *)tableDatas
{
    NSMutableString * html = [NSMutableString string];
    [html appendString:@"<html>"];
    NSString * style =
    @"<head>\
    <style type='text/css'>\
    table\
    {\
    border-collapse:collapse;\
    }\
    table, td, th\
    {\
    border:1px solid black;\
    }\
    </style>\
    </head>";
    [html appendString:style];
    [html appendString:@"<body>"];
    [html appendString:@"<table style='border:1px solid black'; border-collapse:'collapse'>"];
    //table header
    [html appendString:@"<tr>"];
    for (int i=0; i<sections.count; i++) {
        NSString * section = sections[i];
        [html appendFormat:@"<th>%@</th>",section];
    }
    [html appendString:@"</tr>"];
    //table body
    for (int i=0; i<tableDatas.count; i++) {
        [html appendString:@"<tr>"];
        NSDictionary * aRow = tableDatas[i];
        for (int j=0; j<sections.count; j++) {
            NSString * section = sections[j];
            NSString * value = aRow[section];
            [html appendFormat:@"<td>%@</td>",value];
        }
        [html appendString:@"</tr>"];
    }
    [html appendString:@"</table>"];
    [html appendString:@"</body>"];
    [html appendString:@"</html>"];
    return html;
}

- (void)showQueryResult: (NSString *)html
{
    [self.webview loadHTMLString:html baseURL:nil];
}

@end












