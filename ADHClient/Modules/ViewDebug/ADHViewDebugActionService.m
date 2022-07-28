//
//  ViewDebugActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2019/2/14.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHViewDebugActionService.h"
#import "ADHViewDebugService.h"
#import "ADHAttribute+UIView.h"
#import <objc/runtime.h>


@implementation ADHViewDebugActionService

+ (NSString *)serviceName {
    return @"adh.viewdebug";
}

+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"view" : NSStringFromSelector(@selector(onRequestViewTree:)),
             @"snapshotData" : NSStringFromSelector(@selector(onRequestSnapshotData:)),
             @"setValue" : NSStringFromSelector(@selector(onRequestSetValue:)),
             @"getValue" : NSStringFromSelector(@selector(onRequestGetValue:)),
             };
}

//view tree
- (void)onRequestViewTree: (ADHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *body = request.body;
        if(body[@"instaddr"]) {
            //获取某view的tree
            NSString *insAddr = body[@"instaddr"];
            ADHViewDebugService *service = [ADHViewDebugService service];
            UIView *view = [service getViewWithAddress:insAddr];
            NSDictionary *data = nil;
            if(view) {
                ADHViewDebugService *service = [ADHViewDebugService service];
                ADHViewNode *node = [service captureViewTree:view];
                data = [node dicPresentation];
            }
            if(data) {
                NSMutableDictionary *body = [NSMutableDictionary dictionary];
                body[@"success"] = @(1);
                body[@"serviceAddr"] = [self getInstanceAddr:[ADHViewDebugService service]];
                NSData *treeData = [NSKeyedArchiver archivedDataWithRootObject:data];
                [request finishWithBody:body payload:treeData];
            }else {
                //failed
                [request finishWithBody:@{
                                          @"success" : @(0),
                                          }];
            }
        }else {
            //获取整个window
            UIView *view = nil;
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            view = window;
            NSDictionary *data = nil;
            if(view) {
                ADHViewDebugService *service = [ADHViewDebugService service];
                ADHViewNode *node = [service captureViewTree:view];
                data = [node dicPresentation];
            }
            if(data) {
                NSMutableDictionary *body = [NSMutableDictionary dictionary];
                body[@"success"] = @(1);
                CGFloat scale = window.contentScaleFactor;
                CGSize size = window.bounds.size;
                body[@"size"] = [NSString stringWithFormat:@"%.1f,%.1f",size.width,size.height];
                body[@"scale"] = [NSNumber numberWithFloat:scale];
                body[@"serviceAddr"] = [self getInstanceAddr:[ADHViewDebugService service]];
                NSData *treeData = [NSKeyedArchiver archivedDataWithRootObject:data];
                [request finishWithBody:body payload:treeData];
            }else {
                //failed
                [request finishWithBody:@{
                                          @"success" : @(0),
                                          }];
            }
        }
    });
}

- (void)onRequestSnapshotData: (ADHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *data = request.body;
        NSArray *list = data[@"list"];
        NSString *batchTag = data[@"batchtag"];
        NSData * snapshot = nil;
        if(list.count > 0) {
            ADHViewDebugService *service = [ADHViewDebugService service];
            snapshot = [service snapshotViewList:list];
        }
        BOOL success = (snapshot != nil);
        NSMutableDictionary *retBody = [NSMutableDictionary dictionary];
        retBody[@"success"] = [NSNumber numberWithBool:success];
        if(batchTag) {
            retBody[@"batchtag"] = batchTag;
        }
        [request finishWithBody:retBody payload:snapshot];
    });
}

- (void)onRequestSetValue: (ADHRequest *)request {
    NSDictionary *data = request.body;
    NSString *remoteServiceAddr = data[@"serviceAddr"];
    NSString *serviceAddr = [self getInstanceAddr:[ADHViewDebugService service]];
    if(![remoteServiceAddr isEqualToString:serviceAddr]) {
        [request finish];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *data = request.body;
        NSData *payload = request.payload;
        NSString *insAddr = data[@"instaddr"];
        NSString *attrClass = data[@"attrClass"];
        NSString *key = data[@"key"];
        id value = nil;
        BOOL payloadValue = [data[@"payloadValue"] boolValue];
        if(payloadValue) {
            value = payload;
        }else {
            value = data[@"value"];
        }
        NSDictionary *info = data[@"info"];
        Class clazz = NSClassFromString(attrClass);
        ADHViewDebugService *service = [ADHViewDebugService service];
        UIView *view = [service getViewWithAddress:insAddr];
//        NSLog(@"update key: %@ value: %@",key,value);
        if([view isKindOfClass:[UIView class]]) {
            NSDictionary *retInfo = nil;
            id retValue = [clazz updateValueWithInstance:view key:key value:value info:info retInfo:&retInfo];
            NSMutableDictionary *retData = [NSMutableDictionary dictionary];
            retData[@"success"] = @(1);
            if(![retValue isKindOfClass:[NSData class]]) {
                retData[@"value"] = retValue;
            }
            if(retInfo.count > 0) {
                retData[@"info"] = retInfo;
            }
            NSData *snapshot = [[ADHViewDebugService service] snapshotThisView:view];
            [request finishWithBody:retData payload:snapshot];
        }else {
            [request finish];
        }
    });
}

- (void)onRequestGetValue: (ADHRequest *)request {
    NSDictionary *data = request.body;
    NSString *remoteServiceAddr = data[@"serviceAddr"];
    NSString *serviceAddr = [self getInstanceAddr:[ADHViewDebugService service]];
    if(![remoteServiceAddr isEqualToString:serviceAddr]) {
        [request finish];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *data = request.body;
        NSString *insAddr = data[@"instaddr"];
        NSString *attrClass = data[@"attrClass"];
        NSString *key = data[@"key"];
        NSDictionary *info = data[@"info"];
        Class clazz = NSClassFromString(attrClass);
        ADHViewDebugService *service = [ADHViewDebugService service];
        UIView *view = [service getViewWithAddress:insAddr];
        if([view isKindOfClass:[UIView class]]) {
            NSDictionary *retInfo = nil;
            id retValue = [clazz getValueWithInstance:view key:key info:info retInfo:&retInfo];
            NSData *payload = nil;
            NSMutableDictionary *retData = [NSMutableDictionary dictionary];
            retData[@"success"] = @(1);
            if([retValue isKindOfClass:[NSData class]]) {
                payload = retValue;
            }else if(retValue){
                retData[@"value"] = retValue;
            }
            if(retInfo.count > 0) {
                retData[@"info"] = retInfo;
            }
            [request finishWithBody:retData payload:payload];
        }else {
            [request finish];
        }
    });
}

- (NSString *)getInstanceAddr: (id)instance {
    return [NSString stringWithFormat:@"%p",instance];
}

@end
