//
//  CloudItemView.m
//  Woodpecker
//
//  Created by 张小刚 on 2019/9/22.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "CloudItemView.h"
#import "ADHCloudItem.h"

@interface CloudItemView ()
@property (weak) IBOutlet NSImageView *fileIcon;

@property (weak) IBOutlet NSTextField *nameLabel;


@end

@implementation CloudItemView

- (void)setData:(ADHCloudItem *)item {
    self.nameLabel.stringValue = item.name;
    if(item.isDir){
        NSString *fileExt = [item.name pathExtension];
        NSImage *icon = nil;
        if(fileExt.length > 0) {
            icon = [[NSWorkspace sharedWorkspace] iconForFileType:fileExt];
        }
        if(!icon) {
            icon = [NSImage imageNamed:NSImageNameFolder];
        }
        self.fileIcon.image = icon;
    }else {
        NSString *fileExt = [item.name pathExtension];
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
    self.toolTip = [item getStateText];
}

@end
