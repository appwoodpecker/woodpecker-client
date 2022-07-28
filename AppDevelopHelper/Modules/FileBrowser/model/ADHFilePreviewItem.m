//
//  FSPreviewItem.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/21.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHFilePreviewItem.h"

//安卓早期系统获取文件lastModifiedTime精度有问题，所以这里设置高一些（如果精度没问题设置0.01）
NSTimeInterval const kADHFilePreviewItemMinInterval = 1;


@implementation ADHFilePreviewItem

- (ADHFileItem *)viewFileItem
{
    ADHFileItem * targetFileItem = nil;
    if([self bothExists]){
        if((self.localFileItem.updateTime - self.fileItem.updateTime) > [self minTimeInterval]){
            targetFileItem = self.localFileItem;
        }else{
            targetFileItem = self.fileItem;
        }
    }else{
        if(self.remoteExists){
            targetFileItem = self.fileItem;
        }else if(self.localExists){
            targetFileItem = self.localFileItem;
        }
    }
    return targetFileItem;
}

- (BOOL)isDir
{
    BOOL isDir = NO;
    if(self.remoteExists){
        isDir = self.fileItem.isDir;
    }else if(self.localExists){
        isDir = self.localFileItem.isDir;
    }
    return isDir;
}

- (BOOL)bothExists
{
    return (self.localExists && self.remoteExists);
}

- (BOOL)needSync
{
    BOOL needSync = NO;
    if(![self bothExists]){
        needSync = YES;
    }else{
        if(!self.isDir){
            NSTimeInterval delta = self.localFileItem.updateTime - self.fileItem.updateTime;
            if(ABS(delta) > [self minTimeInterval]){
                needSync = YES;
            }
        }
    }
    return needSync;
}

- (BOOL)localNeedSync
{
    BOOL ret = NO;
    if([self needSync]){
        if(!self.localExists || (self.fileItem.updateTime - self.localFileItem.updateTime) > [self minTimeInterval]){
            ret = YES;
        }
    }
    return ret;
}

- (BOOL)remoteNeedSync
{
    BOOL ret = NO;
    if([self needSync]){
        if(!self.remoteExists || (self.localFileItem.updateTime - self.fileItem.updateTime) > [self minTimeInterval]){
            ret = YES;
        }
    }
    return ret;
}

- (BOOL)isWell
{
    return ![self needSync];
}


- (NSString *)fileExtension
{
    NSString * fileExt = [self.localFileItem.path pathExtension];
    return fileExt;
}

- (NSString *)localFilePath
{
    return self.localFileItem.path;
}

- (NSInteger)level
{
    NSInteger level = 0;
    ADHFilePreviewItem * parent = self.parent;
    while (parent) {
        level++;
        parent = parent.parent;
    }
    return level;
}

- (NSTimeInterval)minTimeInterval {
    return kADHFilePreviewItemMinInterval;
}

@end


















