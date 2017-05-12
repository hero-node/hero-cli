//
//  UIView+Frame.m
//
//  Created by sho yakushiji on 2013/05/15.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGFloat)frameTop
{
    return self.frame.origin.y;
}

- (void)setFrameTop:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)frameRight
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setFrameRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - self.frame.size.width;
    self.frame = frame;
}

- (CGFloat)frameBottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setFrameBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - self.frame.size.height;
    self.frame = frame;
}

- (CGFloat)frameLeft
{
    return self.frame.origin.x;
}

- (void)setFrameLeft:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)frameWidth
{
    return self.frame.size.width;
}

- (void)setFrameWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)frameHeight
{
    return self.frame.size.height;
}

- (void)setFrameHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end
