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


#import "UIView+Paper.h"
#import <objc/runtime.h>
#import <CoreImage/CoreImage.h>

static void *s_ripple = &s_ripple;
static void *s_raised = &s_raised;
static void *s_rippleExpanding = &s_rippleExpanding;
@interface UIViewPaperDelegate : NSObject

@end


@implementation UIView (Paper)
@dynamic raised;
@dynamic ripple;
@dynamic rippleExpanding;

-(BOOL)raised{
    return [objc_getAssociatedObject(self, s_raised) boolValue];
}
-(BOOL)ripple{
    return [objc_getAssociatedObject(self, s_ripple) boolValue];
}
-(BOOL)rippleExpanding{
    return [objc_getAssociatedObject(self, s_rippleExpanding) boolValue];
}
-(void)setRaised:(BOOL)raised
{
    objc_setAssociatedObject(self, s_raised,[NSNumber numberWithBool: raised], OBJC_ASSOCIATION_ASSIGN);
    if (raised) {
        self.clipsToBounds = NO;
        self.layer.shadowColor = [UIColor grayColor].CGColor;//shadowColor阴影颜色
        self.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.layer.shadowOpacity = 0.4;//阴影透明度，默认0
        self.layer.shadowRadius = 4;//阴影半径，默认3
    }
}
-(void)setRipple:(BOOL)ripple
{
    objc_setAssociatedObject(self, s_ripple,[NSNumber numberWithBool: ripple], OBJC_ASSOCIATION_ASSIGN);
    if (ripple) {
        self.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(touchesBeganRipple:)];
        tap.minimumPressDuration = 0.0001f;
        tap.cancelsTouchesInView = NO;
        tap.delaysTouchesEnded = YES;
        [self addGestureRecognizer:tap];
    }
}
-(void)setRippleExpanding:(BOOL)rippleExpanding
{
    objc_setAssociatedObject(self, s_rippleExpanding,[NSNumber numberWithBool: rippleExpanding], OBJC_ASSOCIATION_ASSIGN);
    if (rippleExpanding) {
        [self startRippleExpanding];
    }
}
-(void)startRippleExpanding{
    if ([self rippleExpanding]) {
        UIView *expandingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        expandingView.center = self.center;
        expandingView.alpha = 0.8f;
        expandingView.backgroundColor = self.backgroundColor;
        expandingView.layer.cornerRadius = self.layer.cornerRadius;
        [self.superview insertSubview:expandingView belowSubview:self];
        [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            expandingView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
            expandingView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [expandingView removeFromSuperview];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startRippleExpanding];
        });
    }
}
-(void)touchesBeganRipple:(UITapGestureRecognizer *)ges
{
    if (self.ripple && ges.state == UIGestureRecognizerStateBegan) {
        CGPoint aPntTapLocation = [ges locationInView:self];
        CALayer *backgroundLayer = [CALayer layer];
        backgroundLayer.masksToBounds = YES;
        backgroundLayer.frame = self.bounds;
        [self.layer addSublayer:backgroundLayer];
        CALayer *aLayer = [CALayer layer];
        aLayer.name = @"ripple";
        UIColor *rippleColor = self.backgroundColor?self.backgroundColor:[UIColor colorWithWhite:1.0 alpha:0.3];
        CGFloat red ,green,blue;
        [rippleColor getRed:&red green:&green blue:&blue alpha:nil];
        rippleColor = [UIColor colorWithRed:red>0.8?red-0.2:red+0.2 green:green>0.8?green-0.2:green+0.2 blue:blue>0.8?blue-0.2:blue+0.2 alpha:0.2];
        aLayer.backgroundColor = rippleColor.CGColor;
        aLayer.frame = CGRectMake(0, 0, 20, 20);
        aLayer.cornerRadius = 20/2;
        aLayer.masksToBounds =  YES;
        aLayer.position = aPntTapLocation;
        [backgroundLayer addSublayer:aLayer];
        // Create a basic animation changing the transform.scale value
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        // Set the initial and the final values
        [animation setToValue:[NSNumber numberWithFloat:(2.5*MAX(self.frame.size.height, self.frame.size.width))/20]];
        // Set duration
        [animation setDuration:0.6f];
        
        // Set animation to be consistent on completion
        [animation setRemovedOnCompletion:NO];
        [animation setFillMode:kCAFillModeForwards];
        
        // Add animation to the view's layer
        CAKeyframeAnimation *fade = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        fade.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:0.0], nil];
        fade.duration = 0.5;
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.duration  = 0.5f;
        animGroup.delegate= [UIViewPaperDelegate class];
        animGroup.animations = [NSArray arrayWithObjects:animation,fade, nil];
        [animGroup setValue:aLayer forKey:@"animationLayer"];
        [aLayer addAnimation:animGroup forKey:@"scale"];
    }
}


@end

@implementation UIViewPaperDelegate

+(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    CALayer *layer = [anim valueForKey:@"animationLayer"];
    if(layer && [layer.name isEqualToString:@"ripple"]){
        [layer removeAnimationForKey:@"scale"];
        [layer.superlayer removeFromSuperlayer];
        layer = nil;
        anim = nil;
    }
}
@end

