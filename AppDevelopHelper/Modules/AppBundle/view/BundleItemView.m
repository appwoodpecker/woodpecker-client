//
//  BundleItemView.m
//  ADHClient
//
//  Created by 张小刚 on 2019/1/20.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "BundleItemView.h"
#import "ADHFilePreviewItem.h"

@interface BundleItemView ()

@property (weak) IBOutlet NSImageView *fileIcon;
@property (weak) IBOutlet NSTextField *nameTextfield;
@property (nonatomic, weak) ADHFilePreviewItem *previewItem;

@end

@implementation BundleItemView

- (void)setData:(id)data {
    ADHFilePreviewItem *previewItem = data;
    self.previewItem = previewItem;
    [self updateContentData:previewItem];
}

- (void)updateContentData: (ADHFilePreviewItem *)previewItem {
    if(previewItem.isDir){
        NSString *fileExt = [previewItem.viewFileItem.name pathExtension];
        NSImage *icon = nil;
        if(fileExt.length > 0) {
            icon = [[NSWorkspace sharedWorkspace] iconForFileType:fileExt];
        }
        if(!icon) {
            icon = [NSImage imageNamed:NSImageNameFolder];
        }
        self.fileIcon.image = icon;
    }else {
        NSString *fileExt = [previewItem.viewFileItem.name pathExtension];
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:fileExt];
        if(icon) {
            self.fileIcon.image = icon;
        }else {
            self.fileIcon.image = [NSImage imageNamed:@"icon_file"];
            if([Appearance isDark]) {
                [self.fileIcon setTintColor:[Appearance actionImageColor]];
            }
        }
    }
    ADHFileItem * fileItem = previewItem.viewFileItem;
    NSString *fileName = fileItem.name;
    if([fileName isKindOfClass:[NSString class]]) {
        self.nameTextfield.stringValue = previewItem.viewFileItem.name;
    }
    if([previewItem localExists]) {
        self.nameTextfield.textColor = [NSColor labelColor];
    }else {
        self.nameTextfield.textColor = [NSColor secondaryLabelColor];
    }
    NSBackgroundStyle backgroundStyle = self.backgroundStyle;
    if(backgroundStyle == NSBackgroundStyleEmphasized) {
        self.nameTextfield.textColor = [NSColor whiteColor];
    }
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    [super setBackgroundStyle:backgroundStyle];
    [self updateContentData:self.previewItem];
}



@end
