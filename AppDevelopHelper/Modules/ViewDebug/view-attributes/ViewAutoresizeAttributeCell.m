//
//  ViewAutoresizeAttributeCell.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/2/25.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ViewAutoresizeAttributeCell.h"

@interface ViewAutoresizeAttributeCell ()

@property (weak) IBOutlet NSView *boxLayout;
@property (weak) IBOutlet NSImageView *hleft;
@property (weak) IBOutlet NSImageView *hright;
@property (weak) IBOutlet NSImageView *vtop;
@property (weak) IBOutlet NSImageView *vbottom;
@property (weak) IBOutlet NSView *layout;
@property (weak) IBOutlet NSImageView *widthResize;
@property (weak) IBOutlet NSImageView *heightResize;

@end

@implementation ViewAutoresizeAttributeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.boxLayout.wantsLayer = YES;
    self.boxLayout.layer.borderWidth = 1;
    self.boxLayout.layer.borderColor = [NSColor colorWithRed:0xDC/255.0f green:0xDC/255.0f blue:0xDC/255.0f alpha:1.0f].CGColor;
    self.layout.wantsLayer = YES;
    self.layout.layer.borderWidth = 1;
    self.layout.layer.borderColor = [NSColor colorWithRed:0xDC/255.0f green:0xDC/255.0f blue:0xDC/255.0f alpha:1.0f].CGColor;
}

- (void)setData:(id)data contentWidth:(CGFloat)contentWidth {
//    int UIViewAutoresizingNone                 = 0;
    int UIViewAutoresizingFlexibleLeftMargin   = 1 << 0;
    int UIViewAutoresizingFlexibleWidth        = 1 << 1;
    int UIViewAutoresizingFlexibleRightMargin  = 1 << 2;
    int UIViewAutoresizingFlexibleTopMargin    = 1 << 3;
    int UIViewAutoresizingFlexibleHeight       = 1 << 4;
    int UIViewAutoresizingFlexibleBottomMargin = 1 << 5;
    
    int mask = [data intValue];
    
    BOOL flexLeft = ((mask & UIViewAutoresizingFlexibleLeftMargin) > 0);
    BOOL flexRight = ((mask & UIViewAutoresizingFlexibleRightMargin) > 0);
    BOOL flexTop = ((mask & UIViewAutoresizingFlexibleTopMargin) > 0);
    BOOL flexBottom = ((mask & UIViewAutoresizingFlexibleBottomMargin) > 0);
    BOOL flexWidth = ((mask & UIViewAutoresizingFlexibleWidth) > 0);
    BOOL flexHeight = ((mask & UIViewAutoresizingFlexibleHeight) > 0);
    NSString *hFixName = @"autoresize_h";
    NSString *hFlexName = @"autoresize_h_dash";
    NSString *vFixName = @"autoresize_v";
    NSString *vFlexName = @"autoresize_v_dash";
    NSString *widthFlexName = @"autoresize_width";
    NSString *wdithFixName = @"autoresize_width_dash";
    NSString *heightFlexName = @"autoresize_height";
    NSString *heightFixName = @"autoresize_height_dash";
    self.hleft.image = flexLeft ? [NSImage imageNamed:hFlexName] : [NSImage imageNamed:hFixName];
    self.hright.image = flexRight ? [NSImage imageNamed:hFlexName] : [NSImage imageNamed:hFixName];
    self.vtop.image = flexTop ? [NSImage imageNamed:vFlexName] : [NSImage imageNamed:vFixName];
    self.vbottom.image = flexBottom ? [NSImage imageNamed:vFlexName] : [NSImage imageNamed:vFixName];
    self.widthResize.image = flexWidth ? [NSImage imageNamed:widthFlexName] : [NSImage imageNamed:wdithFixName];
    self.heightResize.image = flexHeight ? [NSImage imageNamed:heightFlexName] : [NSImage imageNamed:heightFixName];
}

+ (CGFloat)heightForData:(id)data contentWidth:(CGFloat)contentWidth {
    return 64.0f;
}

@end
