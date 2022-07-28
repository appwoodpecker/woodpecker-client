//
//  LogCell.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "LogCell.h"
#import "LogRecorder.h"

@interface LogCell ()

@property (weak) IBOutlet NSTextField *dateLabel;
@property (weak) IBOutlet NSTextField *contentLabel;
@property (weak) IBOutlet NSButton *fileButton;
@property (weak) IBOutlet NSTextField *fileNameLabel;
@property (weak) IBOutlet NSView *seperatorView;

@end

@implementation LogCell
    
- (void)awakeFromNib {
    [super awakeFromNib];
    self.seperatorView.wantsLayer = YES;
    self.seperatorView.layer.backgroundColor = [[NSColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    self.dateLabel.textColor = [NSColor whiteColor];
    self.fileNameLabel.textColor = [NSColor whiteColor];
}

- (void)setData: (id)data contentWidth: (CGFloat)contentWidth
{
    LogItem * item = (LogItem *)data;
    CGFloat height = 4.0;
    if(item.filePath){
        self.fileButton.hidden = NO;
        self.fileNameLabel.stringValue = adhvf_safestringfy(item.fileName);
        height += (21.0f+8.0f);
    }else{
        self.fileButton.hidden = YES;
        self.fileNameLabel.stringValue = adhvf_const_emptystr();
    }
    CGFloat textHeight = 0;
    CGFloat textWidth = contentWidth - 6.0 * 2;
    NSSize boxSize = NSMakeSize(textWidth,CGFLOAT_MAX);
    if(item.text){
        self.contentLabel.stringValue = item.text;
    }else{
        self.contentLabel.stringValue = adhvf_const_emptystr();
    }
    if(item.textColor){
        self.contentLabel.textColor = item.textColor;
    }else{
        self.contentLabel.textColor = [Appearance colorWithRed:0x96 green:0x93 blue:0xAA alpha:1.0f];
    }
    textHeight = [self.contentLabel sizeThatFits:boxSize].height;
    self.contentLabel.frame = NSMakeRect(6.0, height, ceil(textWidth),ceil(textHeight));
    if(textHeight > 0){
        height += (textHeight + 8.0f);
    }
    if(item.date){
        self.dateLabel.stringValue = [ADHDateUtil formatStringWithDate:item.date dateFormat:@"HH:mm:ss yy/MM/dd"];
        CGRect dateRect = self.dateLabel.frame;
        dateRect.origin.y = height;
        self.dateLabel.frame = dateRect;
        height += (15+8.0f);
    }else{
        self.dateLabel.stringValue = adhvf_const_emptystr();
    }
    //line
    height += 5.0f;
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setSeperatorVisible: (BOOL)visible{
    self.seperatorView.hidden = !visible;
}
    
- (IBAction)openFileButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(logCellRequestOpenFile:)]){
        [self.delegate logCellRequestOpenFile:self];
    }
}
    
+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth {
    static dispatch_once_t onceToken;
    static LogCell * templateCell = nil;
    dispatch_once(&onceToken, ^{
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:@"LogCell" owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[LogCell class]]){
                templateCell = object;
                break;
            }
        }
    });
    [templateCell setData:data contentWidth:contentWidth];
    CGFloat height = templateCell.frame.size.height;
    return height;
}
    

@end







