//
//  FSItemView.m
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "FSItemView.h"

@interface FSItemView ()

@property (weak) IBOutlet NSImageView *typeIcon;
@property (weak) IBOutlet NSImageView * statusIcon;
@property (weak) IBOutlet NSTextField *titleTextfield;
@property (weak) ADHFilePreviewItem *previewItem;

@end

@implementation FSItemView

- (NSImage *)uploadIcon {
    NSString *name = @"icon_upload";
    NSBackgroundStyle backgroundStyle = self.backgroundStyle;
    if(backgroundStyle == NSBackgroundStyleEmphasized) {
        name = @"icon_upload_white";
    }
    return [NSImage imageNamed:name];
}

- (NSImage *)downloadIcon {
    NSString *name = @"icon_download";
    NSBackgroundStyle backgroundStyle = self.backgroundStyle;
    if(backgroundStyle == NSBackgroundStyleEmphasized) {
        name = @"icon_download_white";
    }
    return [NSImage imageNamed:name];
}

- (NSImage *)fileIcon {
    NSString *name = @"icon_file";
    NSBackgroundStyle backgroundStyle = self.backgroundStyle;
    if(backgroundStyle == NSBackgroundStyleEmphasized) {
        name = @"icon_file_white";
    }
    return [NSImage imageNamed:name];
}

- (void)setData: (ADHFilePreviewItem *)previewItem {
    self.previewItem = previewItem;
    [self updateContentData:previewItem];
    CGFloat contentWidth = self.frame.size.width;
    CGFloat baseLeft = 4.0f;
    if(!self.statusIcon.hidden){
        baseLeft = 18.0f;
    }
    CGRect typeRect = self.typeIcon.frame;
    typeRect.origin.x = baseLeft;
    self.typeIcon.frame = typeRect;
    baseLeft += (39.0f - 18.0f);
    CGRect titleRect = self.titleTextfield.frame;
    titleRect.origin.x = baseLeft;
    titleRect.size.width = (contentWidth - baseLeft - 10.0f);
    self.titleTextfield.frame = titleRect;
}

- (void)updateContentData: (ADHFilePreviewItem *)previewItem {
    ADHFileItem * fileItem = previewItem.viewFileItem;
    NSString *fileName = fileItem.name;
    if([fileName isKindOfClass:[NSString class]]) {
        self.titleTextfield.stringValue = fileName;
    }
    NSColor *statusTintColor = nil;
    if(![previewItem bothExists]){
        //文件不存在
        self.titleTextfield.textColor = [NSColor secondaryLabelColor];
        self.statusIcon.hidden = NO;
        if([previewItem remoteExists]){
            self.statusIcon.image = [self downloadIcon];
        }else{
            self.statusIcon.image = [self uploadIcon];
        }
        statusTintColor = [NSColor secondaryLabelColor];
    }else{
        self.titleTextfield.textColor = [NSColor labelColor];
        if([previewItem needSync]){
            self.statusIcon.hidden = NO;
            if([previewItem localNeedSync]){
                self.statusIcon.image = [self downloadIcon];
            }else{
                self.statusIcon.image = [self uploadIcon];
            }
            
        }else{
            self.statusIcon.hidden = YES;
        }
        statusTintColor = [NSColor labelColor];
    }
    [self.statusIcon setTintColor:statusTintColor];
    if(previewItem.isDir){
        self.typeIcon.image = [NSImage imageNamed:NSImageNameFolder];
    }else{
        self.typeIcon.image = [self fileIcon];
        [self.typeIcon setTintColor:statusTintColor];
    }
}

- (NSColor *)actionImageColor {
    if([Appearance isDark]) {
        return [Appearance colorWithHex:0xBBBBBB];
    }else {
        return nil;
    }
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    [super setBackgroundStyle:backgroundStyle];
    [self updateContentData:self.previewItem];
}

@end


















