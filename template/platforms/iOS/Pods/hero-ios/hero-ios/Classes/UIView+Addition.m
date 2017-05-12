//
//  UIView+Addition.m
//  CloudKnows
//
//  Created by atman on 13-5-7.
//  Copyright (c) 2013年 atman. All rights reserved.
//

#import "UIView+Addition.h"
@interface BlockContainner : UIView
@property (nonatomic,strong) dispatch_block_t block;
-(void)fireBlock:(id)sender;
@end
@implementation BlockContainner
-(void)fireBlock:(id)sender
{
    [self.superview removeFromSuperview];
    self.block();
}
@end

@implementation UIView (Addition)

- (void)setOriginX:(CGFloat)x{
    [self setFrame:CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
}

- (void)setOriginY:(CGFloat)y{
    [self setFrame:CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height)];
}

- (void)setWidth:(CGFloat)width{
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height)];
}

- (void)setHeight:(CGFloat)height{
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height)];
}

- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}
- (id)findFirstClass:(Class)cls
{
    for (UIView *view in self.subviews) {
        if ([view class] == cls) {
            return view;
        }
        else
        {
            UIView *v = [view findFirstClass:cls];
            if (v) {
                return v;
            }
        }
    }
    return NULL;
}
- (id)findFirstClass:(Class)cls bigThan:(float)wAndH
{
    for (UIView *view in self.subviews) {
        if ([view class] == cls && view.bounds.size.width > wAndH && view.bounds.size.height > wAndH) {
            return view;
        }
        else
        {
            UIView *v = [view findFirstClass:cls bigThan:wAndH];
            if (v) {
                return v;
            }
        }
    }
    return NULL;
}
- (void)showView:(UIView*)view onView:(UIView*)underView completeBlock:(dispatch_block_t) completeBlock
{
    UIButton *u = [[UIButton alloc]initWithFrame:self.bounds];
    u.tag = 100123;
    [self addSubview:u];
    BlockContainner *block = [[BlockContainner alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    block.block = completeBlock;
    [u addTarget:block action:@selector(fireBlock:) forControlEvents:UIControlEventTouchDown];
    [u addSubview:block];
    CGRect rect = [underView.superview convertRect:underView.frame toView:self];
    rect.origin.y -= view.bounds.size.height;
    rect.size.height = view.bounds.size.height;
    view.frame = rect;
    [u addSubview:view];
}
- (void)removeShowingView
{
    UIView *v = [self viewWithTag:100123];
    [v removeFromSuperview];
}
- (void)removeTagView:(int)tag
{
    while ([self viewWithTag:tag]) {
        UIView *v = [self viewWithTag:tag];
        [v removeFromSuperview];
    }
}
- (void)removeClassView:(Class)classType
{
    for (UIView *view in self.subviews) {
        if ([view class] == classType) {
            view.tag = 107876;
        }
    }
    [self removeTagView:107876];
}
-(UIView*)getFocusView
{
    if ([self isFirstResponder]) {
        return self;
    }
    else
    {
        for (UIView *v in self.subviews) {
            UIView *v1 = [v getFocusView];
            if (v1) {
                return v1;
            }
        }
    }
    return nil;
}

@end
