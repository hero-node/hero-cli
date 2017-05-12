//
//  BSD License
//  Copyright (c) Hero software.
//  All rights reserved.
//  Created by gpliu@icloud.com
//
//Redistribution and use in source and binary forms, with or without modification,
//are permitted provided that the following conditions are met:
//
//* Redistributions of source code must retain the above copyright notice, this
//list of conditions and the following disclaimer.
//
//* Redistributions in binary form must reproduce the above copyright notice,
//this list of conditions and the following disclaimer in the documentation
//and/or other materials provided with the distribution.
//
//* Neither the name Facebook nor the names of its contributors may be used to
//endorse or promote products derived from this software without specific
//prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SCREEN_W                ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_H                ([[UIScreen mainScreen] bounds].size.height)
#define CONTROLLER_W            (self.controller.view.bounds.size.width?(self.controller.view.bounds.size.width-((UIScrollView*)self.controller.view).contentInset.left-((UIScrollView*)self.controller.view).contentInset.right):SCREEN_W)
#define CONTROLLER_H            (self.controller.view.bounds.size.height?(self.controller.view.bounds.size.height-((UIScrollView*)self.controller.view).contentInset.top - ((UIScrollView*)self.controller.view).contentInset.bottom):SCREEN_H)
#define KEY_WINDOW              [[UIApplication sharedApplication]keyWindow]
#define ROOT_VIEW               ([[UIApplication sharedApplication]keyWindow].rootViewController.view)
#define ROOT_VIEWCONTROLLER     ([[UIApplication sharedApplication]keyWindow].rootViewController)
#define APP                     [UIApplication sharedApplication]
#define SCALE                   [[UIScreen mainScreen]scale]
#define PARENT_W                (self.superview.bounds.size.width?(self.superview.bounds.size.width-([self.superview isKindOfClass:[UIScrollView class]]?(((UIScrollView*)self.superview).contentInset.left + ((UIScrollView*)self.superview).contentInset.right):0)):CONTROLLER_W)
#define PARENT_H                (self.superview.bounds.size.height?(self.superview.bounds.size.height-([self.superview isKindOfClass:[UIScrollView class]]?(((UIScrollView*)self.superview).contentInset.top + ((UIScrollView*)self.superview).contentInset.bottom):0)):CONTROLLER_H)
#define NOT_NULL(s)             (s?s:@"")
#define LS(str)                 NSLocalizedString(str, nil)
#define SUBFIX(str)             ([NSString stringWithFormat:@"%@%@",[self class],str])
#define SUBFIXCAST(str)         ([NSString stringWithFormat:@"CAST%@",str])
#define SUBFIX2(str,i)          ([NSString stringWithFormat:@"%@%@%d",[self class],str,i])
#define SUBFIX3(str,s)          ([NSString stringWithFormat:@"%@%@%@",[self class],str,s])
#define isBackGround            (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)||([UIApplication sharedApplication].applicationState == UIApplicationStateInactive))
#define UIColorFromRGBA(rgbValue,alphaValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue])
#define UIColorFromRGB(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(1-((float)((rgbValue & 0xFF000000) >> 24))/255.0)])

#define AppVersion() [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define IOS7_OR_LATER           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
#define IOS8_OR_LATER           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f)
#define IOS9_OR_LATER           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f)
#define IOS10_OR_LATER           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0f)
#define IS_IPAD                 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#ifdef DEBUG
#define DLog(fmt,...) NSLog((@"%@ [line %u]: " fmt), NSStringFromClass(self.class), __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

static inline UIColor* UIColorFromStr(NSString *str){
    if (!str) {
        return [UIColor whiteColor];
    }
    if (str.length == 8) {
        NSString *alphaStr = [str substringFromIndex:6];
        NSScanner* scanner = [NSScanner scannerWithString: alphaStr];
        unsigned long long alphaValue;
        [scanner scanHexLongLong: &alphaValue];
        
        NSString *colorStr = [str substringToIndex:6];
        scanner = [NSScanner scannerWithString: colorStr];
        unsigned long long colorValue;
        [scanner scanHexLongLong: &colorValue];
        return UIColorFromRGBA(colorValue,alphaValue/255.0);
    }
    NSScanner* scanner = [NSScanner scannerWithString: str];
    unsigned long long longValue;
    [scanner scanHexLongLong: &longValue];
    return UIColorFromRGB(longValue);
}
static NSMutableDictionary *loadedCSS;
static inline NSString *StrFromCSS(NSString *bundle,NSString *name,NSString *type,NSString *key,NSString *defaultStr){
    if (!loadedCSS) {
        loadedCSS = [NSMutableDictionary dictionary];
    }
    if (bundle && (name || type)) {
        if (!loadedCSS[bundle]) {
            NSString *cssFile = [NSString stringWithFormat:@"%@/document/css/%@.json",NSHomeDirectory(),bundle];
            NSData *cssData = [NSData dataWithContentsOfFile:cssFile];
            if (!cssData) {
                cssFile = [[NSBundle mainBundle] pathForResource:bundle ofType:@"json"];
                cssData = [NSData dataWithContentsOfFile:cssFile];
            }
            if (cssData) {
                NSDictionary *css = [NSJSONSerialization JSONObjectWithData:cssData options:NSJSONReadingMutableContainers error:nil];
                [loadedCSS setObject:css forKey:bundle];
            }
        }
        NSDictionary *css = loadedCSS[bundle];
        NSString *cssValue;
        if (type && css[type]) {
            cssValue = css[type][key];
        }
        if (name && css[name]) {
            cssValue = css[name][key];
        }
        if (cssValue) {
            return cssValue;
        }
    }
    return defaultStr;
}


