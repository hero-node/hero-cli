
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

#import "UIView+Hero.h"
#import "UIView+Paper.h"
#import <objc/runtime.h>
static void *s_json = &s_json;
static void *s_controller = &s_controller;

@implementation UIView (Hero)
@dynamic json;

-(NSDictionary *)json{
    return objc_getAssociatedObject(self, s_json);
}
-(void)setJson:(NSDictionary *)json
{
    objc_setAssociatedObject(self, s_json, json, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(HeroViewController *)controller{
    return objc_getAssociatedObject(self, s_controller);
}
-(void)setController:(UIViewController *)controller{
    objc_setAssociatedObject(self, s_controller, controller, OBJC_ASSOCIATION_ASSIGN);
    for (UIView *v in self.subviews) {
        v.controller = controller;
    }
}
-(NSString *)name{
    if (self.json[@"name"]) {
        return self.json[@"name"];
    }else{
        return [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self class]),(long)self.tag];
    }
}
-(NSString*)parent{
    return self.json[@"parent"];
}
-(NSMutableArray*)layoutListenners{
    if(self.json[@"layoutListenners"]){
        return self.json[@"layoutListenners"];
    }else{
        NSMutableArray *layoutListenners = [NSMutableArray array];
        [self.json setValue:layoutListenners forKey:@"layoutListenners"];
        return layoutListenners;
    }
}
-(NSDictionary *)action{
    return self.json[@"action"];
}
-(NSArray *)obersevers{
    return self.json[@"obersevers"];
}
-(UIView*) findViewByName:(NSString*)name{
    if (!name) {
        return nil;
    }
    if ([name isEqualToString:self.name]) {
        return self;
    }
    for (UIView *view in self.subviews) {
        if ([view.name isEqualToString:name]) {
            return view;
        }
        else if(view.subviews.count > 0)
        {
            UIView *v = [view findViewByName:name];
            if (v) {
                return v;
            }
        }
    }
    return NULL;

}
-(UIView*)findFocusView
{
    if ([self isFirstResponder] && ([self isKindOfClass:[UITextView class]] || [self isKindOfClass:[UITextField class]])) {
        return self;
    }
    else
    {
        for (UIView *v in self.subviews) {
            UIView *v1 = [v findFocusView];
            if (v1) {
                return v1;
            }
        }
    }
    return nil;
}

-(void)on:(NSDictionary *)json{
    if (json[@"class"]) {   //一般适用于数据不太改变，table需要自己维护自己的datasource
        self.json = json;
    }
    if (json[@"animation"]) {
        float animation = [json[@"animation"] floatValue];
        float animationDelay = [json[@"animationDelay"] floatValue];
        NSString *animationType = json[@"animationType"];
        //类型动画
        if (animationType){
            if ([animationType isEqualToString:@"shake"]) {
                CGPoint point = self.center;
                for (int i = 0; i<animation; i++) {
                    [UIView animateKeyframesWithDuration:0.05 delay:0.05*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                        self.center = CGPointMake(point.x+((i%2==0)?-3:3), point.y);
                    } completion:^(BOOL finished) {
                        self.center = point;
                    }];
                }
            }
            if ([animationType isEqualToString:@"doflip"]) {
                [UIView beginAnimations:@"doflip" context:nil];
                [UIView setAnimationDuration:animation];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft  forView:self cache:NO];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:json];
                [dic removeObjectForKey:@"animation"];
                [self on:dic];
                [UIView commitAnimations];
            }
            return;
        }
        //属性变换动画
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:json];
        [dic removeObjectForKey:@"animation"];
        [UIView animateWithDuration:animation animations:^{
            [self on:dic];
        }];
        return;
    }
    //alpha
    if (json[@"alpha"]) {
        self.alpha = ((NSNumber*)(json[@"alpha"])).floatValue;
    }
    //background
    if (json[@"backgroundColor"]) {
        self.backgroundColor = UIColorFromStr(json[@"backgroundColor"]);
    }
    //tinyColor
    if (json[@"tinyColor"]) {
        self.tintColor = UIColorFromStr(json[@"tinyColor"]);
    }
    //hidden
    if (json[@"hidden"]) {
        self.hidden = ((NSNumber*)(json[@"hidden"])).boolValue;
    }
    if (json[@"ios_hidden"]) {
        self.hidden = ((NSNumber*)(json[@"ios_hidden"])).boolValue;
    }
    //layer borderWidth
    if (json[@"borderWidth"]) {
        self.layer.borderWidth = ((NSNumber*)(json[@"borderWidth"])).floatValue;
    }
    //layer borderColor
    if (json[@"borderColor"]) {
        self.layer.borderColor = UIColorFromStr(json[@"borderColor"]).CGColor;
        if (self.layer.borderWidth == 0) {
            if (SCALE >2 ) {
                self.layer.borderWidth = 0.33f;
            }else{
                self.layer.borderWidth = 0.5f;
            }
        }
    }
    if (json[@"shadowColor"]) {
        //暂时只支持默认的shadow，使用shadow应该比较小心避免造成性能问题。／／推荐使用图片代替
        self.layer.shadowColor = UIColorFromStr(json[@"shadowColor"]).CGColor;
    }
    if (json[@"ripple"]) {
        self.ripple = ((NSNumber*)(json[@"ripple"])).boolValue;
    }
    if (json[@"raised"]) {
        self.raised = ((NSNumber*)(json[@"raised"])).boolValue;
    }
    if (json[@"rippleExpanding"]) {
        self.rippleExpanding = ((NSNumber*)(json[@"rippleExpanding"])).boolValue;
    }
    if (json[@"enable"]) {
        self.userInteractionEnabled = ((NSNumber*)(json[@"enable"])).boolValue;
    }
    if (json[@"clip"]) {
        self.clipsToBounds = ((NSNumber*)(json[@"clip"])).boolValue;
    }
    //layer borderColor
    if (json[@"cornerRadius"]) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = ((NSNumber*)(json[@"cornerRadius"])).floatValue;
    }
    if (json[@"frame"]) {
        if (self.json[@"frame"] != json[@"frame"]) {
            [self.json setValue:json[@"frame"] forKey:@"frame"];
        }
        NSString *x = json[@"frame"][@"x"];
        NSString *y = json[@"frame"][@"y"];
        NSString *w = json[@"frame"][@"w"];
        NSString *h = json[@"frame"][@"h"];
        
        NSString *t = json[@"frame"][@"t"];
        NSString *l = json[@"frame"][@"l"];
        NSString *r = json[@"frame"][@"r"];
        NSString *b = json[@"frame"][@"b"];
        CGRect rect = CGRectMake(0, 0, 0, 0);
        if (x) {
            rect.origin.x = [x hasSuffix:@"x"]?[x floatValue]*PARENT_W:[x floatValue];
        }
        if (y) {
            rect.origin.y = [y hasSuffix:@"x"]?[y floatValue]*PARENT_H:[y floatValue];
        }
        if (l) {
            rect.origin.x = [l hasSuffix:@"x"]?[l floatValue]*PARENT_W:[l floatValue];
        }
        if (t) {
            rect.origin.y = [t hasSuffix:@"x"]?[t floatValue]*PARENT_H:[t floatValue];
        }
        if (w) {
            rect.size.width = [w hasSuffix:@"x"]?[w floatValue]*PARENT_W:[w floatValue];
        }
        if (h) {
            rect.size.height = [h hasSuffix:@"x"]?[h floatValue]*PARENT_H:[h floatValue];
        }
        if (r) {
            if ((!x) && (!l)) {
                rect.origin.x = PARENT_W - (rect.size.width + ([r hasSuffix:@"x"]?[r floatValue]*PARENT_W:[r floatValue]));
            }else{
                rect.size.width = PARENT_W - (rect.origin.x + ([r hasSuffix:@"x"]?[r floatValue]*PARENT_W:[r floatValue]));
            }
        }
        if (b) {
            if ((!t) && (!y)) {
                rect.origin.y = PARENT_H - (rect.size.height + ([b hasSuffix:@"x"]?[b floatValue]*PARENT_H:[b floatValue]));
            }else{
                rect.size.height = PARENT_H - (rect.origin.y + ([b hasSuffix:@"x"]?[b floatValue]*PARENT_H:[b floatValue]));
            }
        }
        if (json[@"yOffset"]) {
            if (self.json[@"yOffset"] != json[@"yOffset"]) {
                [self.json setValue:json[@"yOffset"] forKey:@"yOffset"];
            }
            NSString *yOffset = json[@"yOffset"]; //name+offset
            NSString *name = [yOffset componentsSeparatedByString:@"+"][0];
            float offset = [[yOffset componentsSeparatedByString:@"+"][1] floatValue];
            UIView *top = [self.superview findViewByName:name] ?: [self.controller.view findViewByName:name];
            rect.origin.y = top.frame.origin.y + top.frame.size.height + offset;
            [self.json setValue:[NSMutableDictionary dictionaryWithDictionary: @{@"x":[@(rect.origin.x) description],@"y":[@(rect.origin.y) description],@"w":[@(rect.size.width) description],@"h":[@(rect.size.height) description]} ]forKey:@"frame"];
            NSMutableArray *layoutListenners = top.layoutListenners;
            if (![layoutListenners containsObject:self]) {
                [layoutListenners addObject:self];
            }
        }
        if (json[@"xOffset"]) {
            if (self.json[@"xOffset"] != json[@"xOffset"]) {
                [self.json setValue:json[@"xOffset"] forKey:@"xOffset"];
            }
            NSString *yOffset = json[@"xOffset"]; //name+offset
            NSString *name = [yOffset componentsSeparatedByString:@"+"][0];
            float offset = [[yOffset componentsSeparatedByString:@"+"][1] floatValue];
            UIView *top = [self.superview findViewByName:name] ?: [self.controller.view findViewByName:name];
            rect.origin.x = top.frame.origin.x + top.frame.size.width + offset;
            [self.json setValue:[NSMutableDictionary dictionaryWithDictionary: @{@"x":[@(rect.origin.x) description],@"y":[@(rect.origin.y) description],@"w":[@(rect.size.width) description],@"h":[@(rect.size.height) description]} ]forKey:@"frame"];
            NSMutableArray *layoutListenners = top.layoutListenners;
            if (![layoutListenners containsObject:self]) {
                [layoutListenners addObject:self];
            }
        }
        self.frame = rect;
        if (self.json[@"contentSizeElement"]) {
            if (!self.hidden) {
                if ([self.superview isKindOfClass:[UIScrollView class]]) {
                    UIScrollView *scrollView = (UIScrollView*)self.superview;
                    CGSize contentSize = CGSizeMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
                    scrollView.contentSize = contentSize;
                }else if ([self.superview isKindOfClass:[UIView class]]){
                    NSDictionary *frame = self.superview.json[@"frame"];
                    [frame setValue:[NSString stringWithFormat:@"%@",@(rect.origin.x+rect.size.width)]  forKey:@"w"];
                    [frame setValue:[NSString stringWithFormat:@"%@",@(rect.origin.y+rect.size.height)] forKey:@"h"];
                    [self.superview on:@{@"frame":frame}];
                }
            }
        }
        if (self.json[@"contentSizeElementY"]) {
            if (!self.hidden) {
                if ([self.superview isKindOfClass:[UIScrollView class]]) {
                    UIScrollView *scrollView = (UIScrollView*)self.superview;
                    CGSize contentSize = CGSizeMake(scrollView.contentSize.width, rect.origin.y+rect.size.height);
                    scrollView.contentSize = contentSize;
                }else if ([self.superview isKindOfClass:[UIView class]]){
                    NSDictionary *frame = self.superview.json[@"frame"];
                    [frame setValue:[NSString stringWithFormat:@"%@",@(rect.origin.y+rect.size.height)] forKey:@"h"];
                    [self.superview on:@{@"frame":frame}];
                }
            }
        }
        if (self.layoutListenners.count > 0) {
            for (UIView *listenner in self.layoutListenners) {
                if (listenner.json[@"yOffset"]) {
                    [listenner on:@{@"frame":listenner.json[@"frame"],@"yOffset":listenner.json[@"yOffset"]}];
                }
                if (listenner.json[@"xOffset"]) {
                    [listenner on:@{@"frame":listenner.json[@"frame"],@"xOffset":listenner.json[@"xOffset"]}];
                }
            }
        }
    }
    else if(self.frame.size.width + self.frame.size.height == 0)
    {
        if (self.superview) {
            self.frame = self.superview.bounds;
        }
    }
    if (json[@"center"]) {
        NSString *x = json[@"center"][@"x"];
        NSString *y = json[@"center"][@"y"];
        CGPoint center = CGPointMake([x hasSuffix:@"x"]?x.floatValue*PARENT_W:x.floatValue, [y hasSuffix:@"x"]?y.floatValue*PARENT_H:y.floatValue);
        [self.json[@"frame"] setValue:[NSString stringWithFormat:@"%f",center.x-self.bounds.size.width/2] forKey:@"x"];
        [self.json[@"frame"] setValue:[NSString stringWithFormat:@"%f",center.y-self.bounds.size.height/2] forKey:@"y"];
        self.center = center;
    }
    if (json[@"autolayout"]) {
        NSString *autolayout = json[@"autolayout"];
        BOOL l = [autolayout rangeOfString:@"l"].length>0;
        BOOL t = [autolayout rangeOfString:@"t"].length>0;
        BOOL r = [autolayout rangeOfString:@"r"].length>0;
        BOOL b = [autolayout rangeOfString:@"b"].length>0;
        BOOL w = [autolayout rangeOfString:@"w"].length>0;
        BOOL h = [autolayout rangeOfString:@"h"].length>0;
        self.autoresizingMask = (r?1<<0:0) + (t?1<<5:0) + (l?1<<2:0) + (b?1<<3:0) + (w?1<<1:0) + (h?4<<0:0);
    }
    if (json[@"dashBorder"]) {
        NSDictionary *dash = json[@"dashBorder"];
        NSString *color = dash[@"color"];
        NSArray *pattern = dash[@"pattern"];
        UIBezierPath *path = nil;
        if (dash[@"left"]) {
            CAShapeLayer *dashedborder = [CAShapeLayer layer];
            dashedborder.strokeColor = UIColorFromStr(color).CGColor;
            dashedborder.fillColor = nil;
            dashedborder.lineDashPattern = pattern;
            UIBezierPath *path = nil;
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, 0)];
            [path addLineToPoint:CGPointMake(0, self.bounds.size.height)];
            dashedborder.path = path.CGPath;
            [self.layer addSublayer:dashedborder];
        }
        if (dash[@"right"]) {
            CAShapeLayer *dashedborder = [CAShapeLayer layer];
            dashedborder.strokeColor = UIColorFromStr(color).CGColor;
            dashedborder.fillColor = nil;
            dashedborder.lineDashPattern = pattern;
            UIBezierPath *path = nil;
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(self.bounds.size.width, 0)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
            dashedborder.path = path.CGPath;
            [self.layer addSublayer:dashedborder];
        }
        if (dash[@"bottom"]) {
            CAShapeLayer *dashedborder = [CAShapeLayer layer];
            dashedborder.strokeColor = UIColorFromStr(color).CGColor;
            dashedborder.fillColor = nil;
            dashedborder.lineDashPattern = pattern;
            UIBezierPath *path = nil;
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, self.bounds.size.height)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
            dashedborder.path = path.CGPath;
            [self.layer addSublayer:dashedborder];
        }
        if (dash[@"top"]) {
            CAShapeLayer *dashedborder = [CAShapeLayer layer];
            dashedborder.strokeColor = UIColorFromStr(color).CGColor;
            dashedborder.fillColor = nil;
            dashedborder.lineDashPattern = pattern;
            UIBezierPath *path = nil;
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, 0)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
            dashedborder.path = path.CGPath;
            [self.layer addSublayer:dashedborder];
        }
        if (!(dash[@"right"] || dash[@"left"] || dash[@"top"] || dash[@"bottom"])) {
            CAShapeLayer *dashedborder = [CAShapeLayer layer];
            dashedborder.strokeColor = UIColorFromStr(color).CGColor;
            dashedborder.fillColor = nil;
            dashedborder.lineDashPattern = pattern;
            path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius];
            [self.layer addSublayer:dashedborder];
            dashedborder.frame = self.bounds;
            dashedborder.path = path.CGPath;
            [self.layer addSublayer:dashedborder];
        }
    }
    if (json[@"gesture"]) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        NSArray *gesObjects = json[@"gesture"];
        for (int i = 0; i<gesObjects.count; i++) {
            NSDictionary *gesObject = gesObjects[i];
            if ([@"swip" isEqualToString: gesObject[@"name"]]) {
                UISwipeGestureRecognizer *ges = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onHeroSwip:)];
                ges.accessibilityValue = [NSString stringWithFormat:@"%d",i];
                NSString *direction = gesObject[@"direction"];
                if ([@"right" isEqualToString:direction]) {
                    ges.direction = UISwipeGestureRecognizerDirectionRight;
                }else if ([@"left" isEqualToString:direction]){
                    ges.direction = UISwipeGestureRecognizerDirectionLeft;
                }else if ([@"up" isEqualToString:direction]){
                    ges.direction = UISwipeGestureRecognizerDirectionUp;
                }else if ([@"down" isEqualToString:direction]){
                    ges.direction = UISwipeGestureRecognizerDirectionDown;
                }
                [self addGestureRecognizer:ges];
            }
        }
    }
    if (json[@"gradientBackgroundColor"]) {
        NSMutableArray *gradientColors = [NSMutableArray array];
        for (int i = 0; i < [json[@"gradientBackgroundColor"] count]; i++) {
            [gradientColors addObject:(__bridge id)UIColorFromStr(json[@"gradientBackgroundColor"][i]).CGColor];
        }
        if ([gradientColors count] > 0) {
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.colors = gradientColors;
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint = CGPointMake(0, 1.0);
            gradientLayer.frame = self.bounds;
            [self.layer addSublayer:gradientLayer];
        }
    }
    //subViews
    if (json[@"subViews"]) {
        for (UIView *v in self.subviews) {
            [v removeFromSuperview];
        }
        for (NSDictionary *dic in json[@"subViews"]) {
            NSString *type = dic[@"class"];
            UIView *view = [[NSClassFromString(type) alloc]init];
            view.controller = self.controller;
            [self addSubview:view];
            [view on:dic];
        }
    }
}

-(void)onHeroSwip:(UISwipeGestureRecognizer *)sender{
    int tag = [sender.accessibilityValue intValue];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(tag) forKey:@"value"];
    [dic setValue:self.json[@"gesture"] forKey:@"gesture"];
    [dic setValue:self.name forKey:@"name"];
    [self.controller on:dic];
}

@end
