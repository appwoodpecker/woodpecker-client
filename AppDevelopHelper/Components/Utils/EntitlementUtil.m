//
//  EntitlementUtil.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/1/9.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "EntitlementUtil.h"

@implementation EntitlementUtil

+ (NSDictionary *)parseEntitlementData: (NSData *)data {
    NSDictionary *result = nil;
    if([data isKindOfClass:[NSData class]] && data.length > 0) {
        CMSDecoderRef decoder = NULL;
        CFDataRef dataRef = NULL;
        NSString *plistString = nil;
        @try {
            CMSDecoderCreate(&decoder);
            CMSDecoderUpdateMessage(decoder, data.bytes, data.length);
            CMSDecoderFinalizeMessage(decoder);
            CMSDecoderCopyContent(decoder, &dataRef);
            plistString = [[NSString alloc] initWithData:(__bridge NSData *)dataRef encoding:NSUTF8StringEncoding];
            result = [plistString propertyList];
        }
        @catch (NSException *exception) {
            printf("Could not decode file.\n");
        }
        @finally {
            if (decoder) CFRelease(decoder);
            if (dataRef) CFRelease(dataRef);
        }
    }
    return result;
}

@end
