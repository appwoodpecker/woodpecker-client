//
//  ViewImageViewAttrCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/27.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewImageViewAttrCell.h"

@interface ViewImageViewAttrCell ()

@property (weak) IBOutlet NSButton *downloadButton;
@property (weak) IBOutlet NSImageView *imageWell;
@property (weak) IBOutlet NSTextField *infoLabel;


@end

@implementation ViewImageViewAttrCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateAppearanceUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.downloadButton setTintColor:[Appearance actionImageColor]];
}

- (void)setData:(id)data contentWidth:(CGFloat)contentWidth {
    if(data) {
        NSImage *image = [[NSImage alloc] initWithData:data];
        self.imageWell.image = image;
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        self.infoLabel.stringValue = [NSString stringWithFormat:@"%.f x %.f",width,height];
    }else {
        self.imageWell.image = nil;
        self.infoLabel.stringValue = @"";
    }
}

- (IBAction)valueUpdateAction:(id)sender {
    NSImage *image = self.imageWell.image;
    NSData *data = [image TIFFRepresentation];
    if(data) {
        [self.delegate valueUpdateRequest:self value:data info:nil];
    }
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self.delegate valueRequest:self info:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    NSData *data = [self.attribute getAttrValue:self.item];
    if(!data) return;
    NSSavePanel *panel = [NSSavePanel savePanel];
    NSString *fileName = [ADHDateUtil formatStringWithDate:[NSDate date] dateFormat:@"yyyy-MM-dd hh-mm-ss"];
    fileName = [fileName stringByAppendingString:@".png"];
    panel.nameFieldStringValue = fileName;
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if(result == NSModalResponseOK) {
            NSURL *fileURL = panel.URL;
            NSError *error = nil;
            if(![data writeToURL:fileURL options:0 error:&error]) {
                
            }
        }
    }];
}

+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 60.0f;
}

@end
