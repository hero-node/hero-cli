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

//  Created by zhuyechao on 12/25/15.
//

#import "HeroToast.h"

@implementation HeroToast {
    UIView *shadowView;
    UIImageView *imageView;
    UILabel *label;
    BOOL isShowing;
}

-(void)on:(NSDictionary *)json {
    [super on:json];
    DLog(@"HeroToastView");

    CGRect screenBounds = [UIScreen mainScreen].bounds;
    // 如果shadowView为空则初始化
    if (!shadowView) {
        shadowView = [[UIView alloc] init];
        shadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        shadowView.layer.masksToBounds = YES;
        shadowView.layer.cornerRadius = 6;
    }
    // 删除shadowView的subviews
    [shadowView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];

    if (!json[@"icon"] && (!json[@"text"] || [@"" isEqualToString:json[@"text"]])) {
        self.hidden = YES;
        return;
    }

    CGFloat maxWidth = screenBounds.size.width / 2;
    CGFloat top = 0;
    CGFloat spacing = 15;
    CGFloat shadowHeight = 0;
    BOOL show = NO;
    if (json[@"icon"]) {
        show = YES;
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:json[@"icon"]]];
        imageView.frame = CGRectMake(maxWidth / 2 - 16, spacing, 32, 32);
        top += imageView.frame.size.height + imageView.frame.origin.y;
        shadowHeight = imageView.frame.size.height;
        [shadowView addSubview:imageView];
    }
    if (json[@"text"]) {
        show = YES;
        CGFloat topOffset = 8;
        if (0 == top) {
            topOffset = spacing;
        }
        label = [[UILabel alloc] init];
        label.text = json[@"text"];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        CGSize fitSize = [label sizeThatFits:CGSizeMake(maxWidth - 2 * spacing, screenBounds.size.height)];
        [shadowView addSubview:label];
        label.frame = CGRectMake(spacing, top + topOffset, maxWidth - 2 * spacing, fitSize.height);
        if (0 == top) {
            shadowHeight += label.frame.size.height;
        } else {
            shadowHeight += label.frame.size.height + topOffset;
        }
    }
    float time = 2;
    if (json[@"time"]) {
        time = [json[@"time"] floatValue];
    }

    shadowHeight += 2 * spacing;
    shadowView.frame = CGRectMake(0, 0, maxWidth, shadowHeight);
    shadowView.center = KEY_WINDOW.center;

    if (show) {
        // 正在显示不做处理
        if (isShowing)
            return;
        isShowing = YES;
        [KEY_WINDOW addSubview:shadowView];
        self.hidden = NO;
        shadowView.alpha = 0;
        [UIView animateWithDuration:0.45 animations:^{
            shadowView.alpha = 1;
        } completion:nil];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                shadowView.alpha = 0;
            } completion:^(BOOL finished) {
                self.hidden = YES;
                isShowing = NO;
            }];
        });
    } else {
        self.hidden = YES;
    }
}

@end
