//
//  BSD License
//  Copyright (c) Hero software.
//  All rights reserved.
//  Created by atman on 15/2/4.
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
//

#import "HeroBarButtonItem.h"
#import "UILazyImageView.h"
#import "UIImage+alpha.h"

@implementation HeroBarButtonItem
-(instancetype)initWithJson:(NSDictionary*)json{
    NSString *imageName = json[@"image"];
    NSString *title = json[@"title"];
    NSString *tintColor = json[@"tintColor"];
    if (tintColor) {
        self.tintColor = UIColorFromStr(tintColor);
    }

    if (imageName) {
        if ([imageName hasPrefix:@"http"]) {
            NSData *d = [UILazyImageView getCachedImageDataForURL:[NSURL URLWithString:imageName]];
            if (d) {
                self = [super initWithImage:[UIImage imageWithData:d] style:UIBarButtonItemStylePlain target:self action:@selector(onAction:)];
            }else{
                self = [super initWithImage:[UIImage imageWithColor:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(onAction:)];
                [UILazyImageView registerForName:imageName block:^(NSData *data) {
                    self.image = [UIImage imageWithData:data];
                }];
            }
        }else{
            self = [super initWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onAction:)];
        }
        
    }else if (title){
        self = [super initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(onAction:)];
    }else{
        self = [super init];
    }
    if (self) {
        self.json = json;
    }
    return self;
}
-(void)onAction:(id)sender
{
    [self.controller.view endEditing:YES];
    if (self.json[@"click"]) {
        [self.controller on:self.json[@"click"]];
    }
}

@end
