//
//  BSD License
//  Copyright (c) Hero software.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name Facebook nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific
//  prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

//  Created by zhuyechao on 3/10/16.
//

#import "HeroDevice.h"
#include <sys/sysctl.h>
#import <AdSupport/AdSupport.h>

@implementation HeroDevice

- (void)on:(NSDictionary *)json {
    [super on:json];
    NSDictionary *getInfo = json[@"getInfo"];
    if (getInfo) {
        if (getInfo[@"appInfo"]) {
            NSString *value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSDictionary *dict = @{@"appInfo":@{@"value":value}};
            [self.controller on:dict];
        }
        if (getInfo[@"deviceInfo"]) {
            NSString *value = [self getDevicePlatform];
            NSDictionary *dict = @{@"deviceInfo":@{@"value":value}};
            [self.controller on:dict];
        }
        if (getInfo[@"sysInfo"]) {
            UIDevice *device = [UIDevice currentDevice];
            NSString *value = device.systemVersion;
            NSDictionary *dict = @{@"sysInfo":@{@"value":value}};
            [self.controller on:dict];
        }
        if (getInfo[@"channel"]) {
            NSDictionary *dict = @{@"channel":@{@"value":@"m_appstore"}};
            [self.controller on:dict];
        }
        if (getInfo[@"UMDeviceToken"]) {
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"uDeviceToken"];
            if (!deviceToken) {
                deviceToken = @"";
            }
            NSDictionary *dict = @{@"UMDeviceToken":@{@"value":deviceToken}};
            [self.controller on:dict];
        }
        if (getInfo[@"deviceId"]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *uuid = [defaults stringForKey:@"deviceId_UUID"];
            if (uuid.length == 0) {
                uuid = [self idfaString];
                if (uuid.length == 0) {
                    uuid = [self idfvString];
                }
                [defaults setObject:uuid forKey:@"deviceId_UUID"];
                [defaults synchronize];
            }
            NSDictionary *dict = @{@"deviceId":@{@"value":@{@"uuid":uuid,@"idfa":[self idfaString],@"idfv":[self idfvString],}}};
            [self.controller on:dict];
        }
    }
    if (json[@"copy"]) {
        UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
        [gpBoard setString:json[@"copy"]];
    }
    if (json[@"paste"]) {
        UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
        [self.controller on:@{@"name":self.name,@"value":gpBoard.string}];
    }
    if (json[@"getAppList"]) {
        id action = getInfo[@"getAppList"];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:action];
        [dic setObject:@{@"appList":@[]} forKey:@"value"];
        [dic setObject:@"iOS" forKey:@"system"];
        [self.controller on:dic];
    }
}

- (NSString *)getDevicePlatform {
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (UK+Europe+Asis+China)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (UK+Europe+Asis+China)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";

    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";

    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (GSM+CDMA)";

    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

-(NSString *)idfaString {
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];

    if (adSupportBundle == nil) {
        return @"";
    }

    Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
    ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
    if (asIM.advertisingTrackingEnabled) {
        return [asIM.advertisingIdentifier UUIDString];
    }
    return @"";
}

- (NSString *)idfvString {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return @"";
}

@end
