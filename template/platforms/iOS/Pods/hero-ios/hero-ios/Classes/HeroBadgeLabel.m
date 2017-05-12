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
//  Created by 朱成尧 on 4/26/16.
//

#import "HeroBadgeLabel.h"
#import "hero.h"
#import "UIView+Frame.h"

@interface HeroBadgeLabel ()

@property (nonatomic, strong) UIView *backGroudView;
@property (nonatomic, strong) UILabel *badgeLabel;

@end

@implementation HeroBadgeLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
        self.hidden = YES;
    }
    return self;
}

- (void)setupViews {
    _backGroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _backGroudView.backgroundColor = UIColorFromRGB(0xff5323);
    _backGroudView.layer.cornerRadius = 10;
    [self addSubview:_backGroudView];

    _badgeLabel = [[UILabel alloc] initWithFrame:_backGroudView.frame];
    _badgeLabel.backgroundColor = [UIColor clearColor];
    _badgeLabel.textColor = [UIColor whiteColor];
    _badgeLabel.font = [UIFont systemFontOfSize:16.0f];
    _badgeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_badgeLabel];

    _badgeLabel.userInteractionEnabled = YES;
    _backGroudView.userInteractionEnabled = YES;
    self.userInteractionEnabled = YES;
}

- (void)setTitle:(NSString *)title {
    self.badgeLabel.text = title;
    if (title.integerValue > 0) {
        [self show];
    } else {
        [self hide];
    }
}

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

@end
