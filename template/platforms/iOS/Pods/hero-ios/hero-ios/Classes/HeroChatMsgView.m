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
//  Created by atman on 14/12/18.
//

#import "HeroChatMsgView.h"
#import "HeroChatView.h"
#import "UILazyImageView.h"
#import "UIImage+alpha.h"
#define kPadding 10
#define kbubbleMinHeight 30
#define kAvatarSize 40
#define kNameHeight 18
#define kNameWidht 250
#define kbubbleMaxWidth (SCREEN_W-kAvatarSize*2-kPadding*5)
#define kMessageFont  [UIFont systemFontOfSize:15]
#define kSysMessageFont  [UIFont boldSystemFontOfSize:11]
#define kNameFont  [UIFont systemFontOfSize:11]
#define kMessageColor [UIColor blackColor]
#define kNameColor UIColorFromStr(@"666666")
#define kSysMessageColor UIColorFromStr(@"fefefe")
static UIImage *senderTextBackground,*senderTextBackgroundHL,*recTextBackground,*recTextBackgroundHL,*senderImgMask,*recImgMask;
@interface HeroChatMsgView()

@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,strong) UIImageView *bubble;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILazyImageView *avatarView;

@end

@implementation HeroChatMsgView
{
    BOOL _fromSelf;
    BOOL _showNickName;
}
-(void)hiddenMenu
{
    if ([self isFirstResponder])
    {
        [self resignFirstResponder];
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible])  {
        [menu setMenuVisible:NO animated:YES];
        _bubble.highlighted = NO;
    }
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, SCREEN_W, 50);
        self.autoresizingMask = 0x111111;
        self.backgroundView = nil;
        self.backgroundColor = UIColorFromStr(@"eeeeee");
        self.selectedBackgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //bubble view

        _bubble = [[UIImageView alloc]initWithFrame:CGRectMake(kPadding*2+kAvatarSize, kPadding, kbubbleMaxWidth, kbubbleMinHeight)];
        _bubble.userInteractionEnabled = YES;
        [self.contentView addSubview:_bubble];
        
        _avatarView = [[UILazyImageView alloc] initWithFrame:CGRectMake(kPadding, kPadding, kAvatarSize, kAvatarSize)];
        _avatarView.layer.borderColor = UIColorFromStr(@"cccccc").CGColor;
        _avatarView.layer.borderWidth = 1.0f/SCALE;
        _avatarView.layer.cornerRadius = 2;
        _avatarView.clipsToBounds = YES;
        _avatarView.userInteractionEnabled = YES;
        [self.contentView addSubview:_avatarView];

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPadding*2+kAvatarSize, kPadding, kNameWidht, kNameHeight)];
        _nameLabel.font = kNameFont;
        _nameLabel.textColor = kNameColor;
        _nameLabel.hidden = true;
        [self.contentView addSubview:_nameLabel];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongPress:)];
        [_bubble addGestureRecognizer:longPress];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapAvatar:)];
        [_avatarView addGestureRecognizer:tap];


        if (!senderTextBackground) {
            senderTextBackground = [[UIImage imageNamed:@"SenderTextNodeBkg"] stretchableImageWithLeftCapWidth:10 topCapHeight:35];
            senderTextBackgroundHL = [[UIImage imageNamed:@"SenderTextNodeBkgHL"] stretchableImageWithLeftCapWidth:10 topCapHeight:35];
            recTextBackground = [[UIImage imageNamed:@"ReceiverTextNodeBkg"] stretchableImageWithLeftCapWidth:10 topCapHeight:35];
            recTextBackgroundHL = [[UIImage imageNamed:@"ReceiverTextNodeBkgHL"] stretchableImageWithLeftCapWidth:10 topCapHeight:35];
            
            senderImgMask = [[UIImage imageNamed:@"SenderImageNodeBorder"] stretchableImageWithLeftCapWidth:10 topCapHeight:35];
            recImgMask = [[UIImage imageNamed:@"ReceiverImageNodeBorder"] stretchableImageWithLeftCapWidth:10 topCapHeight:35];

        }
    }
    return self;
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
-(void)copy:(id)sender{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    [gpBoard setString:[NSString stringWithFormat:@"%@",self.data[@"text"]]];
}
-(void)WillHideMenu:(NSNotification*)noti{
    [_bubble setHighlighted:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setUserInteractionEnabled:YES];
}
-(void)onLongPress:(UILongPressGestureRecognizer *)ges{
    [self setUserInteractionEnabled:NO];
    [self becomeFirstResponder];
    [_bubble setHighlighted:YES];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:_bubble.frame inView:_bubble.superview];
    [menu setMenuVisible:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillHideMenu:)name:UIMenuControllerWillHideMenuNotification object:nil];
}
-(void)onTapAvatar:(UIGestureRecognizer *)ges{
    if(self.data[@"userid"]){
        [self.controller on:@{@"user":@"click",@"value":self.data[@"userid"]}];
    }
}
+(float)height:(NSMutableDictionary*)json{
    if (json[@"height"]) {
        return [json[@"height"] floatValue];
    }
    if (json[@"text"]) {
        NSString *text = json[@"text"];
        NSMutableAttributedString *str=[[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:kMessageFont}];
        NSRegularExpression *wRegex = [HeroChatView allExpressRex];
        NSArray * wResultList = [wRegex matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
        int rangeShift = 0;
        for (NSTextCheckingResult * wResult in wResultList) {
            NSString * wEmotion = [text substringWithRange:wResult.range];
            NSString * wEmotionName = [[HeroChatView faceList] allKeysForObject:wEmotion][0];
            NSTextAttachment *attachment=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
            UIImage *img=[UIImage imageNamed:wEmotionName];
            attachment.image=img;
            attachment.bounds=CGRectMake(0,kMessageFont.descender, kMessageFont.lineHeight, kMessageFont.lineHeight);
            [str replaceCharactersInRange:NSMakeRange(wResult.range.location-rangeShift, wResult.range.length) withString:@""];
            NSMutableAttributedString *emoji=[NSMutableAttributedString attributedStringWithAttachment:attachment];
            [str insertAttributedString:emoji atIndex:wResult.range.location-rangeShift];
            rangeShift += (wResult.range.length-1);
        }
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.minimumLineHeight = kMessageFont.lineHeight; //line height equals to image height
        paragraphStyle.lineSpacing = 3;
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];

        CGRect rect = [str boundingRectWithSize:CGSizeMake(kbubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
        json[@"rect"] = [NSValue valueWithCGRect:rect];
        json[@"height"] = @(MAX(kbubbleMinHeight, rect.size.height)+4*kPadding + (json[@"nickname"]?kNameHeight:0));
        json[@"aText"] = str;
        return MAX(kbubbleMinHeight, rect.size.height)+4*kPadding +(json[@"nickname"]?kNameHeight:0);
    }else if (json[@"systemMsg"]) {
        NSString *text = json[@"systemMsg"];
        CGRect rect = [text boundingRectWithSize:CGSizeMake(kbubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kSysMessageFont} context:nil];
        json[@"rect"] = [NSValue valueWithCGRect:rect];
        json[@"height"] = @(rect.size.height+2*kPadding);
        return rect.size.height+2*kPadding;
    }else if (json[@"image"]) {
        NSString *imageUrl = json[@"image"];
        CGSize size = CGSizeZero;
        if ([imageUrl componentsSeparatedByString:@"?"].count == 2) {
            NSString *sizeStr = [imageUrl componentsSeparatedByString:@"?"][1];
            if ([sizeStr componentsSeparatedByString:@","].count == 2) {
                NSString *strW = [sizeStr componentsSeparatedByString:@","][0];
                NSString *strH = [sizeStr componentsSeparatedByString:@","][1];
                size = CGSizeMake(strW.integerValue,strH.integerValue);
            }
        }
        if (size.width == 0) {
            size = CGSizeMake(160, 240);
        }
        json[@"rect"] = [NSValue valueWithCGRect:CGRectMake(0, 0, size.width, size.height)];
        json[@"height"] = @(MAX(kbubbleMinHeight,size.height)+4*kPadding+ (json[@"nickname"]?kNameHeight:0));
        return MAX(kbubbleMinHeight,size.height)+4*kPadding+ (json[@"nickname"]?kNameHeight:0);
    }else if (json[@"ui"]) {
        NSMutableDictionary *element = json[@"ui"];
        if (element[@"class"]) {
            UIView *v = [[NSClassFromString(element[@"class"]) alloc]init];
            if (!v) {
                v = [[UIView alloc]init];
                v.backgroundColor = [UIColor redColor];
            }
            [v on: element];
            json[@"ui"] = v;
            json[@"rect"] = [NSValue valueWithCGRect:CGRectMake(0, 0,v.bounds.size.width, v.bounds.size.height)];
            json[@"height"] = @(MAX(kbubbleMinHeight,v.bounds.size.height)+4*kPadding+ (json[@"nickname"]?kNameHeight:0));
            return MAX(kbubbleMinHeight,v.bounds.size.height)+4*kPadding+ (json[@"nickname"]?kNameHeight:0);
        }
    }
    return kbubbleMinHeight+4*kPadding+(json[@"nickname"]?kNameHeight:0);
}
-(void)on:(NSDictionary *)json
{
    if (self.data == json) {
        return;
    }
    for (UIView*v in _bubble.subviews) {
        [v removeFromSuperview];
    }
    for (UIView*v in self.contentView.subviews) {
        if (v != _bubble && v != _nameLabel && v != _avatarView) {
            [v removeFromSuperview];
        }
    }

    self.data = json;
    CGRect rect = [json[@"rect"] CGRectValue];
    if (json[@"self"]) {
        _fromSelf = [json[@"self"] boolValue];
        self.nameLabel.frame = CGRectMake(_fromSelf?SCREEN_W-kAvatarSize-kPadding*2.5-kNameWidht:kPadding*2.5+kAvatarSize, kPadding-3, kNameWidht, kNameHeight);
        self.nameLabel.textAlignment = _fromSelf?NSTextAlignmentRight:NSTextAlignmentLeft;
        _avatarView.frame = CGRectMake(_fromSelf?SCREEN_W-kAvatarSize-kPadding:kPadding, kPadding, kAvatarSize, kAvatarSize);
        _bubble.frame = CGRectMake(_fromSelf?SCREEN_W-kPadding*5-kAvatarSize-rect.size.width:kPadding*2+kAvatarSize, kPadding, rect.size.width+3*kPadding, rect.size.height+kPadding*2);
        _bubble.image = (_fromSelf?senderTextBackground:recTextBackground);
        _bubble.highlightedImage = (_fromSelf?senderTextBackgroundHL:recTextBackgroundHL);
    }
    if (json[@"avatar"]) {
        _avatarView.imageURL = [NSURL URLWithString:json[@"avatar"]];
    }
    if (json[@"nickname"]) {
        self.nameLabel.hidden = false;
        self.nameLabel.text = json[@"nickname"];
        CGRect rect = _bubble.frame;
        _bubble.frame = CGRectMake(rect.origin.x,kPadding+kNameHeight,rect.size.width,rect.size.height);
    }else{
        CGRect _bubbleRect = _bubble.frame;
        self.nameLabel.hidden = true;
        _bubble.frame = CGRectMake(_bubbleRect.origin.x,kPadding,_bubbleRect.size.width,_bubbleRect.size.height);
    }
    if (json[@"text"]) {
        _bubble.hidden = NO;
        _avatarView.hidden = NO;
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake([json[@"self"] boolValue]?kPadding:kPadding*2 , kPadding, rect.size.width, rect.size.height)];
        textLabel.font = kMessageFont;
        textLabel.textColor = kMessageColor;
        textLabel.numberOfLines = 0;
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        textLabel.attributedText = json[@"aText"];
        [_bubble addSubview:textLabel];
        
    }else if (json[@"systemMsg"]) {
        _bubble.hidden = YES;
        _nameLabel.hidden = YES;
        _avatarView.hidden = YES;
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, rect.size.width+kPadding, rect.size.height+kPadding)];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.clipsToBounds = YES;
        textLabel.layer.cornerRadius = 4.0f;
        textLabel.layer.borderColor = UIColorFromStr(@"cccccc").CGColor;
        textLabel.layer.borderWidth = 2.0f;
        textLabel.backgroundColor = UIColorFromStr(@"cccccc");
        textLabel.center = CGPointMake(SCREEN_W/2, rect.size.height/2+kPadding);
        textLabel.font = kSysMessageFont;
        textLabel.textColor = kSysMessageColor;
        textLabel.numberOfLines = 0;
        textLabel.text = json[@"systemMsg"];
        [self.contentView addSubview:textLabel];
    }else if (json[@"image"]) {
        _bubble.hidden = true;
        _avatarView.hidden = false;
        UILazyImageView *imageView = [[UILazyImageView alloc]initWithFrame:_bubble.frame];
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 4.0f;
        NSString *imageStr = json[@"image"];
        if ([imageStr hasPrefix:@"data:"]) {
            self.image = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:imageStr options:NSDataBase64DecodingIgnoreUnknownCharacters]];
        }else if([imageStr hasPrefix:@"http"]){
            imageView.imageURL = [NSURL URLWithString:json[@"image"]];
        }
        [_bubble.superview addSubview:imageView];
        //        UIImageView *mask = [[UIImageView alloc]initWithFrame:imageView.bounds];
        //        mask.image = [json[@"self"] boolValue]?senderImgMask:recImgMask;
        //        [imageView addSubview:mask];
    }else if (json[@"ui"]) {
        _bubble.hidden = true;
        _avatarView.hidden = false;
        UIView *v = json[@"ui"];
        v.controller = self.controller;
        v.frame = CGRectMake(_fromSelf?SCREEN_W-kPadding*2-kAvatarSize-rect.size.width:kPadding*2+kAvatarSize, json[@"nickname"]?kPadding+kNameHeight:kPadding, rect.size.width, rect.size.height);
        [self.contentView addSubview:v];
    }

}

@end
