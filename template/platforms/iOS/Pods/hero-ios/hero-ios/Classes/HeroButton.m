//
//  BSD License
//  Copyright (c) Hero software.
//  All rights reserved.
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


#import "HeroButton.h"
#import "UILazyImageView.h"
#import "UIImage+alpha.h"
#import "common.h"
@implementation HeroButton
{
    id actionObject;
    NSString *backgroundColor;
    NSString *backgroundDisabledColor;
}

-(instancetype)init{
    self = [self.class buttonWithType:UIButtonTypeSystem];
    if(self){
    }
    return self;
}
-(void)on:(NSDictionary *)json{
    [super on:json];
    self.reversesTitleShadowWhenHighlighted = YES;
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (json[@"title"]) {
        [self setTitle:json[@"title"] forState:UIControlStateNormal];
        [self setTitle:json[@"title"] forState:UIControlStateDisabled];
    }
    if (json[@"size"]) {
        double size = ((NSNumber*)json[@"size"]).doubleValue;
        self.titleLabel.font = [UIFont systemFontOfSize:size];
//        self.font = [UIFont systemFontOfSize:size];
    }
    if (json[@"titleH"]) {
        [self setTitle:json[@"titleH"] forState:UIControlStateHighlighted];
    }
    if (json[@"titleColor"]) {
        [self setTitleColor:UIColorFromStr(json[@"titleColor"]) forState:UIControlStateNormal];
    }
    if (json[@"backgroundColor"]) {
        backgroundColor = json[@"backgroundColor"];
        [self setBackgroundColor:UIColorFromStr(backgroundColor)];
    }
    if (json[@"titleDisabledColor"]) {
        [self setTitleColor:UIColorFromStr(json[@"titleDisabledColor"]?:@"999999") forState:UIControlStateDisabled];
    }
    if (json[@"backgroundDisabledColor"]) {
        backgroundDisabledColor = json[@"backgroundDisabledColor"];
    }
    if (json[@"titleColorH"]) {
        [self setTitleColor:UIColorFromStr(json[@"titleColorH"]) forState:UIControlStateHighlighted];
    }
    if (json[@"tinyColor"]) {
        [self setTintColor:UIColorFromStr(json[@"tinyColor"])];
    }
    if (json[@"enable"]) {
        BOOL enable = ((NSNumber*)(json[@"enable"])).boolValue;
        [self setEnabled:enable];
        if (!enable) {
            [self setBackgroundColor:UIColorFromStr(backgroundDisabledColor?:@"aaaaaa")];
        }else{
            [self setBackgroundColor:UIColorFromStr(backgroundColor)];
        }
    }
    if (json[@"imageN"]) {
        NSString *imageStr = json[@"imageN"];
        if ([imageStr hasPrefix:@"#"]) {
            imageStr = [imageStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
            [self setBackgroundImage:[UIImage imageWithColor:UIColorFromStr(imageStr)] forState:UIControlStateNormal];
        }else if([imageStr hasPrefix:@"http"]){
            int scale = [[UIScreen mainScreen]scale];
            [UILazyImageView registerForName:imageStr block:^(NSData *data) {
                [self setBackgroundImage:[UIImage imageWithData:data scale:scale] forState:UIControlStateNormal];
            }];
        }else{
            [self setBackgroundImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
        }
    }
    if (json[@"imageH"]) {
        NSString *imageStr = json[@"imageH"];
        if ([imageStr hasPrefix:@"#"]) {
            imageStr = [imageStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
            [self setBackgroundImage:[UIImage imageWithColor:UIColorFromStr(imageStr)] forState:UIControlStateHighlighted];
        }else if([imageStr hasPrefix:@"http"]){
            int scale = [[UIScreen mainScreen]scale];
            [UILazyImageView registerForName:imageStr block:^(NSData *data) {
                [self setBackgroundImage:[UIImage imageWithData:data scale:scale] forState:UIControlStateHighlighted];
            }];
        }else{
            [self setBackgroundImage:[UIImage imageNamed:imageStr] forState:UIControlStateHighlighted];
        }
    }
    if (json[@"click"]) {
        actionObject = json[@"click"];
    }
}
-(void)onClicked:(id)sender
{
    [KEY_WINDOW endEditing:YES];
    if (actionObject) {
        [self.controller on:actionObject];
    }
}

@end
