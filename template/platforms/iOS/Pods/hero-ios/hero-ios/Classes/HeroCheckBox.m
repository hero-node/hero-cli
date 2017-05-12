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
//  Created by zhuyechao on 11/25/15.
//

#import "HeroCheckBox.h"
#import "UILazyImageView.h"
#import "UIImage+alpha.h"

@implementation HeroCheckBox {
    id actionObject;
    UIImage *image_on;
    UIImage *image_off;
    BOOL checked;
}

-(void)on:(NSDictionary *)json{
    [super on:json];
    self.reversesTitleShadowWhenHighlighted = YES;
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (json[@"enable"]) {
        BOOL enable = ((NSNumber*)(json[@"enable"])).boolValue;
        if (!enable) {
            [self setBackgroundColor:[UIColor grayColor]];
            [self setTintColor:[UIColor lightGrayColor]];
        }
    }
    checked = [json[@"checked"] boolValue];
    if (json[@"selectedImage"]) {
        NSString *imageStr = json[@"selectedImage"];
        if ([imageStr hasPrefix:@"http"]) {
            int scale = [[UIScreen mainScreen]scale];
            [UILazyImageView registerForName:imageStr block:^(NSData *data) {
                image_on = [UIImage imageWithData:data scale:scale];
                if (checked) {
                    [self setImage:image_on forState:UIControlStateNormal];
                }
            }];
        } else{
            if ([imageStr isEqualToString:@""]) {
                image_on = [UIImage imageNamed:@"hero_check_on.png"];
            } else {
                image_on = [UIImage imageNamed:imageStr];
            }
        }
    }
    if (json[@"unselectedImage"]) {
        NSString *imageStr = json[@"unselectedImage"];
        if ([imageStr hasPrefix:@"http"]) {
            int scale = [[UIScreen mainScreen]scale];
            [UILazyImageView registerForName:imageStr block:^(NSData *data) {
                image_off = [UIImage imageWithData:data scale:scale];
                if (!checked) {
                    [self setImage:image_off forState:UIControlStateNormal];
                }
            }];
        } else{
            if ([imageStr isEqualToString:@""]) {
                image_off = [UIImage imageNamed:@"hero_check_off.png"];
            } else {
                image_off = [UIImage imageNamed:imageStr];
            }
        }
    }
    if (checked) {
        [self setImage:image_on forState:UIControlStateNormal];
    } else {
        [self setImage:image_off forState:UIControlStateNormal];
    }

    if (json[@"click"]) {
        actionObject = json[@"click"];
    }
}

-(void)onClicked:(id)sender
{
    checked = !checked;
    if (checked) {
        [self setImage:image_on forState:UIControlStateNormal];
    }
    else {
        [self setImage:image_off forState:UIControlStateNormal];
    }
    [self.controller.view endEditing:YES];
    if (actionObject) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:actionObject];
        [dict setObject:[NSNumber numberWithBool:checked] forKey:@"value"];
        [self.controller on:dict];
    }
}

@end
