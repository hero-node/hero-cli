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
//  Created by atman on 15/1/5.
//  Copyright (c) 2015年 GPLIU. All rights reserved.
//

#import "HeroScrollView.h"
//#import "UIScrollView+MJRefresh.h"
//#import "MJRefresh.h"
@interface HeroScrollView() <UIScrollViewDelegate>
@property (nonatomic,strong)NSMutableArray *fixViews;
@end
@implementation HeroScrollView

-(void)on:(NSDictionary *)json
{
    [super on:json];
    self.delegate = self;
    
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
        self.contentSize = size;
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
        self.contentOffset = CGPointMake(MIN(x.floatValue,MAX(0,self.contentSize.width-self.bounds.size.width)), MIN(y.floatValue,MAX(0,self.contentSize.height-self.bounds.size.height)));
    }
//    if (json[@"pullRefresh"]) {
//        if (self.contentSize.height < self.bounds.size.height) {
//            self.contentSize = CGSizeMake(0, self.bounds.size.height+1);
//        }
//        NSDictionary *pull = json[@"pullRefresh"];
//        NSString *idle = pull[@"idle"]?pull[@"idle"]:LS(@"下拉刷新");
//        NSString *pulling = pull[@"pulling"]?pull[@"pulling"]:LS(@"松开立即刷新");
//        NSString *refreshing = pull[@"refreshing"]?pull[@"refreshing"]:LS(@"加载数据中...");
//        
//        __block HeroScrollView *selfBlock = self;
//        [self addLegendHeaderWithRefreshingBlock:^{
//            [selfBlock.controller on:pull[@"action"]];
//        }];
//        self.header.updatedTimeHidden = YES;
//        [self.header setTitle:idle forState:MJRefreshHeaderStateIdle];
//        [self.header setTitle:pulling forState:MJRefreshHeaderStatePulling];
//        [self.header setTitle:refreshing forState:MJRefreshHeaderStateRefreshing];
//        self.header.font = [UIFont boldSystemFontOfSize:13];
//        self.header.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
//
//    }
//    if (json[@"method"]) {
//        NSString *method = json[@"method"];
//        if ([@"stop" isEqualToString:method]) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.header endRefreshing];
//            });
//        }
//    }
    
}
-(void)addSubview:(UIView *)view{
    [super addSubview:view];
    if (view.frame.size.height+view.frame.origin.y + self.contentInset.top > self.bounds.size.height) {
        self.contentSize = CGSizeMake(self.contentSize.width, view.frame.size.height+view.frame.origin.y);
    }
    if ([view.name hasPrefix:@"scroll_fix"]) {
        if ([view.name hasPrefix:@"scroll_fix_header"]) {
            self.contentInset = UIEdgeInsetsMake(view.bounds.size.height, 0, 0, 0);
        }
        if (!_fixViews) {
            self.fixViews = [NSMutableArray array];
        }
        if (view.json[@"extend"]) {
            [self.fixViews addObject:@{@"view":view,@"extend":view.json[@"extend"],@"frame":[NSValue valueWithCGRect:view.frame]}];
        }else{
            [self.fixViews addObject:@{@"view":view,@"frame":[NSValue valueWithCGRect:view.frame]}];
        }
    }
    
}
#pragma mark touch event
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self endEditing:YES];
}
#pragma mark scrollview delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self endEditing:YES];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.fixViews) {
        for (NSDictionary *fixView in self.fixViews) {
            UIView *v = fixView[@"view"];
            float extendLeft = [fixView[@"extend"][@"l"] floatValue];
            float extendTop = [fixView[@"extend"][@"t"] floatValue];
            float extendRight = [fixView[@"extend"][@"r"] floatValue];
            float extendBottom = [fixView[@"extend"][@"b"] floatValue];
            CGRect frame = [fixView[@"frame"] CGRectValue];
            CGPoint move = CGPointMake(scrollView.contentOffset.x+scrollView.contentInset.left, scrollView.contentOffset.y+scrollView.contentInset.top);

            float newX = frame.origin.x+move.x-(move.x>0&&extendLeft>0?MIN(move.x,extendLeft):0)-(move.x<0&&extendLeft<0?MAX(move.x,extendLeft):0);
            float newY = frame.origin.y+move.y-(move.y>0&&extendTop>0?MIN(move.y,extendTop):0)-(move.y<0&&extendTop<0?MAX(move.y,extendTop):0);
            float newR = (frame.origin.x+frame.size.width)+move.x-(move.x>0&&extendRight<0?MIN(move.x,-extendRight):0)+(move.x<0&&extendRight>0?MIN(-move.x,extendRight):0);
            float newB = (frame.origin.y+frame.size.height)+move.y-(move.y>0&&extendBottom<0?MIN(move.y,-extendBottom):0)+(move.y<0&&extendBottom>0?MIN(-move.y,extendBottom):0);

            CGRect newFrame = CGRectMake(newX,newY,newR-newX,newB-newY);
            v.frame = newFrame;
            [self bringSubviewToFront:v];
        }
    }
}
 -(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height > scrollView.bounds.size.height && scrollView.contentOffset.y + scrollView.bounds.size.height + 44 > scrollView.contentSize.height) {
        if (self.action[@"bottomNear"]) {
            [self.controller on:self.json[@"bottomNear"]];
        }
    }
}
@end
