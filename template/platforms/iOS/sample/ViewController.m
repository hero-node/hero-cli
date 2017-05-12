//
//  ViewController.m
//  sample
//
//  Created by Liu Guoping on 2017/5/10.
//  Copyright © 2017年 hero. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController

static bool customUserAgentHasSet = false;
+(void)heroUseragent{
    if (customUserAgentHasSet) {
        return;
    }
    customUserAgentHasSet = true;
    UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectZero];
    NSString *userAgent = [webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    userAgent = [NSString stringWithFormat:@"Sample %@%@/%@ (%@; iOS %@; Scale/%0.2f)",userAgent,[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@%@",userAgent,@"hero-ios"], @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

-(void)loadView{
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    ((UIScrollView*)self.view).contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}
-(void)viewDidLoad{
    [super viewDidLoad];
}
- (void)on:(NSDictionary *)json {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self on:json];
        });
        return;
    }
    [super on:json];
    if ([json isKindOfClass:[NSDictionary class]]) {
    }
}
//loading重载
-(void)showLoading:(NSString*)str{
}
-(void)stopLoading{
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


@end
