//
//  UIAlertView+blockDelegate.h
//  CloudKnows
//
//  Created by atman on 13-6-6.
//  Copyright (c) 2013年 atman. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "common.h"
typedef void (^DismissBlock)(NSInteger buttonIndex);
typedef void (^CancelBlock)();

@interface UIAlertView (blockDelegate)
+ (UIAlertView*) showAlertViewWithTitle:(NSString*) title
                                message:(NSString*) message
                      cancelButtonTitle:(NSString*) cancelButtonTitle
                      otherButtonTitles:(NSArray*) otherButtons
                              onDismiss:(DismissBlock) dismissed
                               onCancel:(CancelBlock) cancelled;

+ (void) showAlertViewWithView:(UIView*) view
                          data:(NSDictionary*)data
                     onDismiss:(DismissBlock) dismissed
                      onCancel:(CancelBlock) cancelled;

@end
