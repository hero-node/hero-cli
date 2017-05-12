//
//  UIView+Addition.h
//  CloudKnows
//
//  Created by atman on 13-5-7.
//  Copyright (c) 2013年 atman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Addition)

- (void)setOriginX:(CGFloat)x;
- (void)setOriginY:(CGFloat)y;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (BOOL)findAndResignFirstResponder;
- (id)  findFirstClass:(Class)cls;
- (id)  findFirstClass:(Class)cls bigThan:(float)wAndH;
- (void)showView:(UIView*)view onView:(UIView*)underView completeBlock:(dispatch_block_t) completeBlock;
- (void)removeShowingView;
- (void)removeTagView:(int)tag;
- (void)removeClassView:(Class)classType;
- (UIView*)getFocusView;

@end
