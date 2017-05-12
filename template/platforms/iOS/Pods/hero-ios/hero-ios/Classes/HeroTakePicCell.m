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
//  Created by 朱成尧 on 5/4/16.
//

#import "HeroTakePicCell.h"
#import "HeroPhotoImage.h"

@interface HeroTakePicCell ()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *label;

@end

@implementation HeroTakePicCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:CGRectMake(0, 0, 2, 2)])) return nil;
    self.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(.55, .45, .8, .8)];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.image = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:iconBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    [self addSubview:self.imageView];
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1.45, 2, .25)];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.label.font = [UIFont systemFontOfSize:12];
    self.label.textColor = [UIColor colorWithWhite:.3 alpha:1];
    self.label.text = @"相机拍摄";
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    return self;
}

@end
