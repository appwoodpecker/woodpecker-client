//
//  LogCell.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ApiItemCell.h"
#import "ApiActionItem.h"

@interface ApiItemCell ()

@property (weak) IBOutlet NSTextField *dateLabel;
@property (weak) IBOutlet NSTextField *contentLabel;
@property (weak) IBOutlet NSButton *fileButton;
@property (weak) IBOutlet NSView *seperatorView;
@property (weak) IBOutlet NSView *actionLayout;
@property (weak) IBOutlet NSTextField *actionLabel;

@end

@implementation ApiItemCell
    
- (void)awakeFromNib {
    [super awakeFromNib];
    self.seperatorView.wantsLayer = YES;
    self.seperatorView.layer.backgroundColor = [[NSColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
}

- (void)setData: (id)data contentWidth: (CGFloat)contentWidth {
    ApiActionItem * item = (ApiActionItem *)data;
    CGFloat height = 4.0;
    if(item.filePath){
        self.fileButton.hidden = NO;
        height += (21.0f+8.0f);
    }else{
        self.fileButton.hidden = YES;
    }
    CGFloat textHeight = 0;
    CGFloat textWidth = contentWidth - 6.0 * 2;
    NSSize boxSize = NSMakeSize(textWidth,CGFLOAT_MAX);
    if(item.text){
        self.contentLabel.stringValue = item.text;
    }else{
        self.contentLabel.stringValue = adhvf_const_emptystr();
    }
    textHeight = [self.contentLabel sizeThatFits:boxSize].height;
    self.contentLabel.frame = NSMakeRect(6.0, height, ceil(textWidth),ceil(textHeight));
    if(textHeight > 0){
        height += (textHeight + 8.0f);
    }
    //action request
    if(item.actionRequest){
        NSMutableString * content = [NSMutableString string];
        [content appendFormat:@"→ (%@ %@",item.actionRequest.service,item.actionRequest.action];
        if(item.actionRequest.body){
            [content appendFormat:@"  [body]"];
        }
        if(item.actionRequest.filePath){
            [content appendFormat:@"  [payload: %@]",item.actionRequest.filePath.lastPathComponent];
        }
        [content appendString:@")"];
        self.actionLabel.stringValue = content;
        self.actionLayout.hidden = NO;
        CGRect actionFrame = self.actionLayout.frame;
        actionFrame.origin.y = height;
        self.actionLayout.frame = actionFrame;
        height += (self.actionLayout.frame.size.height + 8.0f);
    }else{
        self.actionLayout.hidden = YES;
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
    if(self.delegate && [self.delegate respondsToSelector:@selector(apiCellRequestOpenFile:)]){
        [self.delegate apiCellRequestOpenFile:self];
    }
}

+ (CGFloat)heightForData: (id)data contentWidth: (CGFloat)contentWidth {
    static dispatch_once_t onceToken;
    static ApiItemCell * templateCell = nil;
    dispatch_once(&onceToken, ^{
        NSArray * topObjects = nil;
        [[NSBundle mainBundle] loadNibNamed:@"ApiItemCell" owner:nil topLevelObjects:&topObjects];
        for(id object in topObjects){
            if([object isKindOfClass:[ApiItemCell class]]){
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
