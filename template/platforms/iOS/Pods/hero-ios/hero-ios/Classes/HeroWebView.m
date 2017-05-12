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

//
//  Created by atman on 15/1/7.
//  Copyright (c) 2015年 GPLIU. All rights reserved.
//

#import "HeroWebView.h"
#import "UIView+Hero.h"
#import <JavaScriptCore/JSContext.h>
#import "NSString+Additions.h"

@interface HeroWebView()<UIWebViewDelegate>

@end
@implementation HeroWebView
{
    UILabel *_ownnerLabel;
    NSString *_urlStr;
    BOOL _isGetRequest;
    id _postData;
    NSArray *_hijackURLs;
}

-(void)on:(NSDictionary *)json
{
    [super on:json];
    self.backgroundColor = UIColorFromRGB(0xf6f6f6);
    self.delegate = self;
    if (json[@"hijackURLs"]) {
        _hijackURLs = json[@"hijackURLs"];
    }
    if (json[@"url"]) {
        _isGetRequest = YES;
        if ([json[@"url"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*)json[@"url"];
            NSString *method = dic[@"method"];
            _urlStr = dic[@"url"];
            _postData = dic[@"data"];
            if (_postData) {
                _isGetRequest = NO;
            }
            if (method) {
                if ([method isEqualToString:@"POST"]) {
                    _isGetRequest = NO;
                } else {
                    _isGetRequest = YES;
                }
            }
        } else {
            _urlStr = json[@"url"];
        }
        if (_isGetRequest) {
#ifdef DEBUG
            if ([_urlStr componentsSeparatedByString:@"?"].count > 1) {
                _urlStr = [NSString stringWithFormat:@"%@%@",_urlStr,@"&test=true" ];
            }else{
                _urlStr = [NSString stringWithFormat:@"%@%@",_urlStr,@"?test=true" ];
            }
#endif
            NSURL *url = [NSURL URLWithString:_urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"httpHeader"]) {
                NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"httpHeader"];
                for (NSString *key in [dic allKeys]) {
                    [request setValue:dic[key] forHTTPHeaderField:key];
                }
            }
            [self loadRequest:request];
        } else {
            NSURL *url = [NSURL URLWithString:_urlStr];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod:@"POST"];
            if (_postData) {
                [request setHTTPBody:[_postData dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [self loadRequest:request];
        }
    }
    if (json[@"innerHtml"]) {
        [self loadHTMLString:json[@"innerHtml"] baseURL:NULL];
    }
    if (json[@"contentSize"]) {
        NSString *x = json[@"contentSize"][@"x"];
        NSString *y = json[@"contentSize"][@"y"];
        CGSize size = CGSizeMake(x.floatValue, y.floatValue);
        if ([x hasSuffix:@"x"]) {
            size.width = SCREEN_W*x.floatValue;
        }
        if ([y hasSuffix:@"x"]) {
            size.width = SCREEN_H*x.floatValue;
        }
        self.scrollView.contentSize = size;
    }
    if (json[@"contentOffset"]) {
        NSString *x = json[@"contentOffset"][@"x"];
        NSString *y = json[@"contentOffset"][@"y"];
        CGPoint point = CGPointMake(x.floatValue, y.floatValue);
        if ([x hasSuffix:@"x"]) {
            point.x = SCREEN_W*x.floatValue;
        }
        if ([y hasSuffix:@"x"]) {
            point.y = SCREEN_H*x.floatValue;
        }
        self.scrollView.contentOffset = CGPointMake(x.floatValue, y.floatValue);
    }
}

- (void)refresh {
    if (!_isGetRequest && [self.request.URL.absoluteString isEqualToString:_urlStr]) {
        NSURL *url = [NSURL URLWithString:_urlStr];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        if (_postData) {
            [request setHTTPBody:[_postData dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [self loadRequest:request];
    } else {
        [self reload];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title && title.length > 0) {
        self.controller.title = title;
    }
    if (self.json[@"webViewDidFinishLoad"]) {
        [self.controller on:self.json[@"webViewDidFinishLoad"]];
    }
    if (self.controller.webview.superview) { //普通web页面
        if (!_ownnerLabel) {
            _ownnerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 48)];
            _ownnerLabel.textAlignment = NSTextAlignmentCenter;
            _ownnerLabel.font = [UIFont systemFontOfSize:12];
            _ownnerLabel.textColor = UIColorFromRGB(0xaaaaaa);
        }
        _ownnerLabel.text = [NSString stringWithFormat:@"本页面由 %@ 提供",webView.request.URL.host];
        [self addSubview:_ownnerLabel];
        [self sendSubviewToBack:_ownnerLabel];
        [self.controller on:@{@"common":@{@"event":@"finish"}}];
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.deviceWidth=%f;window.deviceHeight=%f",SCREEN_W,SCREEN_H]];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if([error code] == NSURLErrorCancelled)  {
        return;
    }
    if (self.json[@"didFailLoadWithError"]) {
        [self.controller on:self.json[@"didFailLoadWithError"]];
    }
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"404" ofType:@"html"]]]];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *path = [request URL].absoluteString;
    for (NSDictionary *item in _hijackURLs) {
        NSString *hackurl = item[@"url"];
        BOOL isLoad = [item[@"isLoad"] boolValue];
        if ([hackurl isEqualToString:path]) {
            [self.controller on:@{@"name":self.name,@"url":hackurl}];
            return isLoad;
        }
    }
    if ([request.URL.absoluteString hasPrefix:@"http"] || [request.URL.absoluteString hasPrefix:@"file"]) {
        return YES;
    }else{
        if ([request.URL.absoluteString hasPrefix:@"hero://"]) {
            NSString* str;
            if ([request.URL.absoluteString hasSuffix:@"ready"]) {
                str = [webView stringByEvaluatingJavaScriptFromString:
                       @"Hero.outObjects()"];
            }else{
                str = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"hero://" withString:@""];
                str = [str decodeFromPercentEscapeString];
            }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                [self.controller on:json];
            }
        }else{
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            NSString *query = [[request URL] query];
            NSArray *components = [query componentsSeparatedByString:@"&"];
            for (NSString *component in components) {
                NSArray *pair = [component componentsSeparatedByString:@"="];
                if (pair.count == 2) {
                    [params setObject:[[pair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSMacOSRomanStringEncoding] forKey:[pair objectAtIndex:0]];
                }
            }
            [self.controller on:@{@"common":params}];
        }
        return false;
    }
}


-(void)dealloc
{
    DLog(@"webview dealloced");
}

@end
