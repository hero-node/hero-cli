//
//  UIColor+Reverse.m
//  hero
//
//  Created by Liu Guoping on 15/11/7.
//  Copyright © 2015年 Liu Guoping. All rights reserved.
//

#import "UIColor+Reverse.h"

@implementation UIColor (Reverse)
-(UIColor*) inverseColor
{
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:a];
}
@end
