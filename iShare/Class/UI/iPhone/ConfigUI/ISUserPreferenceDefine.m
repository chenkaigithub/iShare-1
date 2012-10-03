//
//  ISUserPreferenceDefine.m
//  iShare
//
//  Created by Jin Jin on 12-9-11.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISUserPreferenceDefine.h"

#define kEnableThumbnail @"enableThumbnail"
#define kRememberWIFIShare @"rememberWIFIShare"
#define kWifiShareIsEnabled @"wifiShareIsEnabled"
#define kHTTPShareAuthEnabled @"HttpShareAuthEnabled"
#define kHTTPShareUsername @"httpShareUsername"
#define kHTTPSharePassword @"httpSharePassword"
#define kHTTPSharePort @"httpSharePort"

@implementation ISUserPreferenceDefine

+(BOOL)enableThumbnail{
    return [self boolValueForIdentifier:kEnableThumbnail];
}

+(BOOL)rememberStatusOfWifiShare{
    return [self boolValueForIdentifier:kRememberWIFIShare];
}

+(BOOL)wifiShareIsEnabled{
    return [self boolValueForIdentifier:kWifiShareIsEnabled];
}

+(BOOL)shouldAutoStartHTTPShare{
    return ([self rememberStatusOfWifiShare] && [self wifiShareIsEnabled]);
}

+(BOOL)HttpShareAuthEnabled{
    return [self boolValueForIdentifier:kHTTPShareAuthEnabled];
}

+(void)setHttpShareAuthEnabled:(BOOL)encrypted{
    [self valueChangedForIdentifier:kHTTPShareAuthEnabled value:[NSNumber numberWithBool:encrypted]];
}

+(NSString*)httpShareUsername{
    return [self valueForIdentifier:kHTTPShareUsername];
}

+(void)setHttpShareUsername:(NSString*)username{
    [self valueChangedForIdentifier:kHTTPShareUsername value:username];
}

+(NSString*)httpSharePassword{
    return [self valueForIdentifier:kHTTPSharePassword];
}

+(void)setHttpSharePassword:(NSString*)password{
    [self valueChangedForIdentifier:kHTTPSharePassword value:password];
}

+(NSUInteger)httpSharePort{
    return [[self valueForIdentifier:kHTTPSharePort] integerValue];
}

+(void)setHttpSharePort:(NSUInteger)port{
    [self valueChangedForIdentifier:kHTTPSharePort value:[NSNumber numberWithInteger:port]];
}

+(void)setHttpShareStarted:(BOOL)started{
    [self valueChangedForIdentifier:kWifiShareIsEnabled value:[NSNumber numberWithBool:started]];
}

@end
