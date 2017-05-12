//
//  UIAlertView+blockDelegate.m
//  CloudKnows
//
//  Created by atman on 13-6-6.
//  Copyright (c) 2013年 atman. All rights reserved.
//

#import "UIAlertView+blockDelegate.h"
static DismissBlock _dismissBlock;
static CancelBlock _cancelBlock;

@implementation UIAlertView (blockDelegate)

+ (UIAlertView*) showAlertViewWithTitle:(NSString*) title
                                message:(NSString*) message
                      cancelButtonTitle:(NSString*) cancelButtonTitle
                      otherButtonTitles:(NSArray*) otherButtons
                              onDismiss:(DismissBlock) dismissed
                               onCancel:(CancelBlock) cancelled {
    
    _cancelBlock = [cancelled copy];
    
    _dismissBlock = [dismissed copy];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self self]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    for(NSString *buttonTitle in otherButtons)
        [alert addButtonWithTitle:buttonTitle];
    
    [alert show];
    return alert;
}
+ (void)alertView:(UIAlertView*) alertView
didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
    if(buttonIndex == [alertView cancelButtonIndex]) {
        if (_cancelBlock) {
            _cancelBlock();
        }
    }
    else {
        if (_dismissBlock) {
            _dismissBlock(buttonIndex - 1);// 取消按钮是0
        }
    }
    
}

+ (void) showAlertViewWithView:(UIView*) view
                          data:(NSDictionary*)data
                     onDismiss:(DismissBlock) dismissed
                      onCancel:(CancelBlock) cancelled {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIButton *shadowView = [[UIButton alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // stopLoading使用的tag
    shadowView.tag = 733742;
    if (data[@"shadowColor"]) {
        shadowView.backgroundColor = UIColorFromStr(data[@"shadowColor"]);
    } else {
        shadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    }
    shadowView.alpha = 0;

    BOOL cancelable = YES;
    if (data[@"cancelable"]) {
        cancelable = [data[@"cancelable"] boolValue];
    }
    if (cancelable) {
        [shadowView addTarget:self action:@selector(onViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    [keyWindow addSubview:shadowView];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4;
    [shadowView addSubview:view];
    view.center = shadowView.center;

    if (data[@"closeImage"]) {
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width - 20, 5, 15, 15)];
        [closeButton setBackgroundImage:[UIImage imageNamed:data[@"closeImage"]] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onCloseTapped:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:closeButton];
    }
    for (UIView *v in view.subviews) {
        if ([[v class] isSubclassOfClass:[UIButton class]]) {
            [((UIButton*)v) addTarget:self action:@selector(onCloseTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [UIView animateWithDuration:0.3 animations:^{
        shadowView.alpha = 1;
    }];

    _cancelBlock = [cancelled copy];
}

+ (void)onViewTapped:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        if (sender) {
            sender.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [sender removeFromSuperview];
    }];
    if (_cancelBlock) {
        _cancelBlock();
    }
}

+ (void)onCloseTapped:(UIButton *)sender {
    UIView *shadowView = sender.superview.superview;
    [UIView animateWithDuration:0.3 animations:^{
        if (shadowView) {
            shadowView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [shadowView removeFromSuperview];
    }];
    if (_cancelBlock) {
        _cancelBlock();
    }
}

@end
