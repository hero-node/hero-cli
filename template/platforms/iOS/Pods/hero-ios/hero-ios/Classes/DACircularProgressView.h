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
//

#import <UIKit/UIKit.h>

@interface DACircularProgressView : UIView

@property(nonatomic, strong) UIColor *trackTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *progressTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *innerTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic) NSInteger roundedCorners UI_APPEARANCE_SELECTOR; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(
@property(nonatomic) CGFloat thicknessRatio UI_APPEARANCE_SELECTOR;
@property(nonatomic) NSInteger clockwiseProgress UI_APPEARANCE_SELECTOR; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(
@property(nonatomic) CGFloat progress;

@property(nonatomic) CGFloat indeterminateDuration UI_APPEARANCE_SELECTOR;
@property(nonatomic) NSInteger indeterminate UI_APPEARANCE_SELECTOR; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated initialDelay:(CFTimeInterval)initialDelay;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated initialDelay:(CFTimeInterval)initialDelay withDuration:(CFTimeInterval)duration;

@end
