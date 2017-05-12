    //
//  UINavigationController+Addition.m
//  CloudKnows
//
//  Created by atman on 13-5-7.
//  Copyright (c) 2013年 atman. All rights reserved.
//
#import <objc/runtime.h>
#import "UINavigationController+webViewBack.h"
#import "HeroViewController.h"

@implementation UINavigationController(webViewBack)
- (BOOL)navigationBarWithWeb:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    if (self.topViewController) {
        if ([self.topViewController isKindOfClass:[HeroViewController class]]) {
            if(((HeroViewController*)self.topViewController).webview.canGoBack && ((HeroViewController*)self.topViewController).webview.superview){
                [((HeroViewController*)self.topViewController).webview goBack];
                return NO;
            }
            for (UIWebView *v in ((HeroViewController*)self.topViewController).view.subviews) {
                if ([v isKindOfClass:[UIWebView class]] && v.canGoBack) {
                    [v goBack];
                    return NO;
                }
            }
        }
    }
    return [self navigationBarWithWeb:navigationBar shouldPopItem:item] ;
}
+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(navigationBar: shouldPopItem:)), class_getInstanceMethod(self, @selector(navigationBarWithWeb: shouldPopItem:)));
}

@end
