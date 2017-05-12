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

#import "HeroLabel.h"
@implementation HeroLabel
{
    UIFont *attributeFont;
}
-(void)on:(NSDictionary *)json{
    [super on:json];
    if (json[@"text"]) {
        if ([json[@"text"] isKindOfClass:[NSNumber class]]) {
            self.text = [NSString stringWithFormat:@"%@",json[@"text"]];
        }else{
            self.text = [NSString stringWithFormat:@"%@",json[@"text"]];
        }
    }
    if (json[@"alignment"]) {
        NSString *alignment = json[@"alignment"];
        if ([alignment isEqualToString:@"center"]) {
            self.textAlignment = NSTextAlignmentCenter;
        }else if ([alignment isEqualToString:@"left"]){
            self.textAlignment = NSTextAlignmentLeft;
        }else if ([alignment isEqualToString:@"right"]){
            self.textAlignment = NSTextAlignmentRight;
        }
    }
    if (json[@"numberOfLines"]) {
        self.numberOfLines = ((NSNumber*)json[@"numberOfLines"]).intValue;
    }
    if (json[@"warpType"]) {
        if ([@"start" isEqualToString:json[@"warpType"]]) {
            self.lineBreakMode = NSLineBreakByTruncatingHead;
        }
    }
    if (json[@"size"]) {
        double size = ((NSNumber*)json[@"size"]).doubleValue;
        self.font = [UIFont systemFontOfSize:size];
    }
    if (json[@"textColor"]) {
        self.textColor = UIColorFromStr(json[@"textColor"]);
    }
    if (json[@"font"]) {
        double size = ((NSNumber*)json[@"size"]).doubleValue;
        if ([@"bold" isEqualToString:json[@"font"]]) {
            self.font = [UIFont boldSystemFontOfSize:size];
        }
    }
    if (json[@"lineBreakMode"]) {
        NSString *lineBreakMode = json[@"lineBreakMode"];
        if ([lineBreakMode isEqualToString:@"NSLineBreakByWordWrapping"]) {
            self.lineBreakMode = NSLineBreakByWordWrapping;
        } else if ([lineBreakMode isEqualToString:@"NSLineBreakByCharWrapping"]) {
            self.lineBreakMode = NSLineBreakByCharWrapping;
        }else if ([lineBreakMode isEqualToString:@"NSLineBreakByClipping"]) {
            self.lineBreakMode = NSLineBreakByClipping;
        }else if ([lineBreakMode isEqualToString:@"NSLineBreakByTruncatingHead"]) {
            self.lineBreakMode = NSLineBreakByTruncatingHead;
        }else if ([lineBreakMode isEqualToString:@"NSLineBreakByTruncatingTail"]) {
            self.lineBreakMode = NSLineBreakByTruncatingTail;
        }else if ([lineBreakMode isEqualToString:@"NSLineBreakByTruncatingMiddle"]) {
            self.lineBreakMode = NSLineBreakByTruncatingMiddle;
        }
    }
    if (json[@"attribute"]) {
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:self.text];
        if (json[@"size"]) {
            [attributeStr addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributeStr.length-1)];
        }
        if (json[@"textColor"]) {
            [attributeStr addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, attributeStr.length-1)];
        }
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
        if (json[@"alignment"]) {
            NSString *alignment = json[@"alignment"];
            if ([alignment isEqualToString:@"center"]) {
                style.alignment = NSTextAlignmentCenter;
                [attributeStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeStr.length)];
            }else if ([alignment isEqualToString:@"left"]){
                style.alignment = NSTextAlignmentLeft;
                [attributeStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeStr.length)];
            }else if ([alignment isEqualToString:@"right"]){
                style.alignment = NSTextAlignmentRight;
                [attributeStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeStr.length)];
            }
        }
        NSDictionary *attribute = json[@"attribute"];
        for (NSString *key in [attribute allKeys]) {
            if ([key hasPrefix:@"color("]) {
                NSString *rangeStr = [key stringByReplacingOccurrencesOfString:@"color(" withString:@""];
                rangeStr = [rangeStr stringByReplacingOccurrencesOfString:@")" withString:@""];
                NSRange range = NSMakeRange([[rangeStr componentsSeparatedByString:@","][0] integerValue], [[rangeStr componentsSeparatedByString:@","][1] integerValue]);
                [attributeStr addAttribute:NSForegroundColorAttributeName value:UIColorFromStr(attribute[key]) range:range];
            }else if([key hasPrefix:@"size("]){
                NSString *rangeStr = [key stringByReplacingOccurrencesOfString:@"size(" withString:@""];
                rangeStr = [rangeStr stringByReplacingOccurrencesOfString:@")" withString:@""];
                NSRange range = NSMakeRange([[rangeStr componentsSeparatedByString:@","][0] integerValue], [[rangeStr componentsSeparatedByString:@","][1] integerValue]);
                UIFont *_font = [UIFont systemFontOfSize:[attribute[key] intValue]];
                if (!attributeFont || attributeFont.pointSize<_font.pointSize) {
                    attributeFont = _font;
                }
                [attributeStr addAttribute:NSFontAttributeName value:_font range:range];
            }else if([key hasPrefix:@"middleline("]){
                NSString *rangeStr = [key stringByReplacingOccurrencesOfString:@"middleline(" withString:@""];
                rangeStr = [rangeStr stringByReplacingOccurrencesOfString:@")" withString:@""];
                NSRange range = NSMakeRange([[rangeStr componentsSeparatedByString:@","][0] integerValue], [[rangeStr componentsSeparatedByString:@","][1] integerValue]);
                UIFont *_font = [UIFont systemFontOfSize:[attribute[key] intValue]];
                if (!attributeFont || attributeFont.pointSize<_font.pointSize) {
                    attributeFont = _font;
                }
                [attributeStr addAttributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]} range:range];
            }else if([key hasPrefix:@"gap"]){
                style.lineSpacing = [attribute[key] intValue];
                style.minimumLineHeight =  (int)attributeFont.lineHeight+1; //line height equals to image height
                [attributeStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeStr.length)];
            }
        }
        self.attributedText = attributeStr;
    }
    if (json[@"attributedText"]) {
        NSString *string = json[@"attributedText"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]
                                                     initWithData:data
                                                     options:@{
                                                               NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
                                                               }
                                                     documentAttributes:nil
                                                     error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.attributedText = attrString;
            });
        });
    }
    if (json[@"hAuto"]) {
        self.numberOfLines = 0;
        CGSize size = [self sizeThatFits:self.bounds.size];
        [self on:@{@"frame":@{@"x":[@(self.frame.origin.x) description],@"y":[@(self.frame.origin.y) description],@"w":[@(self.frame.size.width) description],@"h":[@(size.height) description],}}];
    }
    if (json[@"wAuto"]) {
        self.numberOfLines = 1;
        [self sizeToFit];
        [self on:@{@"frame":@{@"x":[@(self.frame.origin.x) description],@"y":[@(self.frame.origin.y) description],@"w":[@(self.bounds.size.width) description],@"h":[@(self.bounds.size.height) description],}}];
    }
    if (json[@"canCopy"]) {
        self.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongPress:)];
        [self addGestureRecognizer:ges];
    }

}
- (BOOL)canBecomeFirstResponder{
    return YES;
}
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender{
    if (action ==@selector(copy:)){
        return YES;
    }
    return NO;
}
-(void)onLongPress:(UILongPressGestureRecognizer *)ges{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}
-(void)copy:(id)sender{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    if (self.attributedText.length > 0) {
        [gpBoard setString:[NSString stringWithFormat:@"%@",self.attributedText.string]];
    }else{
        [gpBoard setString:[NSString stringWithFormat:@"%@",self.text]];
    }

}
-(void)dealloc{
    DLog(@"label dealloced");
}
@end
