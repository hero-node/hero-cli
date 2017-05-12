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
//  Created by atman on 14/12/18.
//

#import "HeroChatView.h"
#import "HeroChatMsgView.h"
#import "UIImage+alpha.h"
@interface HeroWebFakeTextView : UITextView // web fake common keyboard delegate
@end
@implementation HeroWebFakeTextView
@end


@interface HeroChatView()<UITextViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *data;
@property (nonatomic,strong) UIView *inputBar;
@property (nonatomic,strong) UIScrollView *faceInputView;
@property (nonatomic,strong) UIScrollView *otherInputView;
@property (nonatomic,strong) HeroWebFakeTextView *textView;
@end
@implementation HeroChatView
{
    CGRect _visableRect;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 200, 200);
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 200, 150)];
        self.inputBar = [[UIView alloc]initWithFrame:CGRectMake(0, 150, 200, 50)];
        self.tableView.backgroundColor = UIColorFromStr(@"eeeeee");
        self.inputBar.backgroundColor = UIColorFromStr(@"F0EFF5");
        self.inputBar.layer.borderColor = UIColorFromStr(@"cccccc").CGColor;
        self.inputBar.layer.borderWidth = 1.0f/SCALE;
        [self addSubview:self.tableView];
        [self addSubview:self.inputBar];
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.inputBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin ;
        [self setUpInputBar];

        self.tableView.dataSource = self;
        self.tableView.delegate  = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
-(void)dealloc{
    self.tableView.dataSource = nil;
    self.tableView.delegate  = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)on:(NSDictionary *)json
{
    [super on:json];
    if (json[@"data"]) {
        self.data = [NSMutableArray arrayWithArray:json[@"data"]];
        [self.tableView reloadData];
        if (self.tableView.contentSize.height > self.bounds.size.height) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.bounds.size.height) animated:YES];
        }
    }
    if (json[@"newMsg"]) {
        NSDictionary *newMsg = json[@"newMsg"];
        if (!self.data) {
            self.data = [NSMutableArray array];
        }
        [self.data addObject:newMsg];
        [self.tableView reloadData];
        if (self.tableView.contentSize.height > self.bounds.size.height) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.bounds.size.height) animated:YES];
        }
    }
    if (json[@"customInputView"]) {
        [self setCustomInputView:json[@"customInputView"]];
    }
}

#pragma mark tableView delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellItem  = self.data[indexPath.row];
    return [HeroChatMsgView height:cellItem];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellItem = self.data[indexPath.row];
    HeroChatMsgView *cell = [tableView dequeueReusableCellWithIdentifier:(cellItem[@"type"]?cellItem[@"type"]:@"HeroChatMsgView")];
    if (!cell) {
        cell = [[HeroChatMsgView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(cellItem[@"type"]?cellItem[@"type"]:@"HeroChatMsgView")];
        cell.controller = self.controller;
        [cell on:cellItem];
    }else{
        [cell on:cellItem];
    }
    return cell;
}

#pragma mark setup input view

-(void)setUpInputBar{
    _textView = [[HeroWebFakeTextView alloc]initWithFrame:CGRectMake(10, 7, self.inputBar.bounds.size.width-100, 36)];
    _textView.layer.borderColor = UIColorFromStr(@"cccccc").CGColor;
    _textView.layer.borderWidth = 1.0f/SCALE;
    _textView.layer.cornerRadius = 3;
    _textView.showsVerticalScrollIndicator = NO;
    _textView.showsHorizontalScrollIndicator = NO;
    _textView.tag = 10001;
    _textView.font = [UIFont systemFontOfSize:17];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textView.returnKeyType = UIReturnKeySend;
    _textView.delegate = self;
    [self.inputBar addSubview:_textView];
    
    UIButton *emoji = [[UIButton alloc]initWithFrame:CGRectMake(self.inputBar.bounds.size.width-80, 8, 36, 36)];
    [emoji setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:(UIControlStateNormal)];
    [emoji setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:(UIControlStateHighlighted)];
    [emoji addTarget:self action:@selector(onInputEmoji:) forControlEvents:UIControlEventTouchUpInside];
    emoji.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin ;
    emoji.tag = 10002;
    [self.inputBar addSubview:emoji];

    UIButton *add = [[UIButton alloc]initWithFrame:CGRectMake(self.inputBar.bounds.size.width-40, 8, 36, 36)];
    [add setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:(UIControlStateNormal)];
    [add setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:(UIControlStateHighlighted)];
    [add addTarget:self action:@selector(onInputAdd:) forControlEvents:UIControlEventTouchUpInside];
    add.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    add.tag = 10003;
    [self.inputBar addSubview:add];
}
-(void)setCustomInputView:(NSDictionary*)json{
    if (![self.inputBar viewWithTag:10004]) {
        UIButton *trans = [[UIButton alloc]initWithFrame:CGRectMake(10, 8, 36, 36)];
        trans.tag = 10004;
        trans.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [trans setImage:[UIImage imageNamed:@"Mode_texttolist"] forState:(UIControlStateNormal)];
        [trans setImage:[UIImage imageNamed:@"Mode_texttolistHL"] forState:(UIControlStateHighlighted)];
        [trans addTarget:self action:@selector(onInputTrans:) forControlEvents:UIControlEventTouchUpInside];
        [self.inputBar addSubview:trans];
        trans.alpha = 0.0f;
        [UIView animateWithDuration:0.2 animations:^{
            trans.alpha = 1.0f;
            [self.inputBar viewWithTag:10001].frame = CGRectMake(50, 7, self.inputBar.bounds.size.width-140, 36);
        }];
    }
    if (![self.inputBar viewWithTag:10005]) {
        UIView *v = [[NSClassFromString(json[@"class"]) alloc]init];
        v.controller = self.controller;
        v.tag = 10005;
        v.hidden = YES;
        [v on :json ];
        [self.inputBar addSubview:v];
    }
}
-(BOOL)canResignFirstResponder{
    return YES;
}
#pragma mark input view action
- (void)textViewDidChange:(UITextView *)textView;
{
    [self setInputBarHeight:MIN(MAX(textView.contentSize.height+4,50), 120)];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([@"\n" isEqualToString:text]) {
        [self onSend:nil];
        return false;
    }
    if ([@"" isEqualToString:text]) {
        [self onDelete:nil];
        return false;
    }
    return true;
}
- (void)updateInputBarWithTime:(float)time{
    [UIView animateWithDuration:time animations:^{
        self.tableView.frame = CGRectMake(0, 0, self.bounds.size.width, _visableRect.size.height-self.inputBar.bounds.size.height);
        self.inputBar.frame = CGRectMake(0, _visableRect.size.height-self.inputBar.bounds.size.height, self.bounds.size.width,self.inputBar.bounds.size.height);
    } completion:^(BOOL finished) {
        if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.bounds.size.height) animated:YES];
        }
    }];
}
- (void)keyboardWillShow:(NSNotification*)notification {
    if (![self.textView isFirstResponder]) {
        return;
    }
    UIView *view = [self inputBar];
    if (view) {
        NSDictionary *info = [notification userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        NSNumber *animationTime = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        CGRect begainValue = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardSize = [value CGRectValue];
        CGRect rect = [view convertRect:view.bounds toView:KEY_WINDOW];
        float distance = SCREEN_H - rect.origin.y - rect.size.height - keyboardSize.size.height;
        float h = 0;
        if (begainValue.origin.y+begainValue.size.height/2 > SCREEN_H) {
            h =   ( distance > 0 ? 0:(-distance) );
        }else{
            h = begainValue.size.height ;
        }
        if (_visableRect.size.height == 0) {
            _visableRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        }
        _visableRect = CGRectMake(0, 0, self.bounds.size.width,_visableRect.size.height-h);
        [self updateInputBarWithTime:[animationTime floatValue]];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    if ((!self.faceInputView.superview) && (!self.otherInputView.superview)) {
        NSDictionary *info = [notification userInfo];
        NSNumber *animationTime = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        _visableRect = self.frame;
        [self updateInputBarWithTime:[animationTime floatValue]];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self.faceInputView removeFromSuperview];
    [self.otherInputView removeFromSuperview];
    UIButton *emoji = [self.inputBar viewWithTag:10002];
    [emoji setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:(UIControlStateNormal)];
    [emoji setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:(UIControlStateHighlighted)];
}
- (void)textViewDidEndEditing:(UITextView *)textView{
}
-(void)setInputBarHeight:(float)height{
    self.tableView.frame = CGRectMake(0, 0, self.bounds.size.width, _visableRect.size.height-height);
    self.inputBar.frame = CGRectMake(0,_visableRect.size.height-height,self.bounds.size.width,height);
}
#pragma mark input view action
-(void)onInputEmoji:(UIButton*)sender{
    [self.otherInputView removeFromSuperview];
    if (self.faceInputView.superview) {
        [sender setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:(UIControlStateNormal)];
        [sender setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:(UIControlStateHighlighted)];
        [self.textView  becomeFirstResponder];
    }else{
        [sender setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:(UIControlStateNormal)];
        [sender setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:(UIControlStateHighlighted)];
        _visableRect = CGRectMake(0, 0, self.bounds.size.width,self.bounds.size.height-self.faceInputView.bounds.size.height);
        self.faceInputView.frame = CGRectMake(0, self.bounds.size.height, self.faceInputView.bounds.size.width, self.faceInputView.bounds.size.height);
        [self addSubview:self.faceInputView];
        [self updateInputBarWithTime:0.25];
        [UIView animateWithDuration:0.35 animations:^{
            self.faceInputView.frame = CGRectMake(0, self.bounds.size.height-self.faceInputView.bounds.size.height, self.faceInputView.bounds.size.width, self.faceInputView.bounds.size.height);
        }];
        [self.textView resignFirstResponder];
    }
}
-(void)onInputAdd:(id)sender{
    if (self.otherInputView.superview) {
        [self.textView  becomeFirstResponder];
    }else{
        _visableRect = CGRectMake(0, 0, self.bounds.size.width,self.bounds.size.height-self.otherInputView.bounds.size.height);
        self.otherInputView.frame = CGRectMake(0, self.bounds.size.height, self.otherInputView.bounds.size.width, self.otherInputView.bounds.size.height);
        [self addSubview:self.otherInputView];
        [self updateInputBarWithTime:0.25];
        [UIView animateWithDuration:0.35 animations:^{
            self.otherInputView.frame = CGRectMake(0, self.bounds.size.height-self.otherInputView.bounds.size.height, self.otherInputView.bounds.size.width, self.otherInputView.bounds.size.height);
        }];
        [self.textView resignFirstResponder];
    }
}
-(void)onInputTrans:(UIButton *)sender{
    [self.textView resignFirstResponder];
    UIView * customInputView = [self.inputBar viewWithTag:10005];
    customInputView.hidden = false;
    if (customInputView) {
        if (customInputView.frame.origin.y == 1) {
            [sender setImage:[UIImage imageNamed:@"Mode_texttolist"] forState:(UIControlStateNormal)];
            [sender setImage:[UIImage imageNamed:@"Mode_texttolistHL"] forState:(UIControlStateHighlighted)];
            [UIView animateWithDuration:0.25 animations:^{
                customInputView.frame = CGRectMake(50, 120+1, _inputBar.bounds.size.width-50, _inputBar.bounds.size.height);
            }];
        }else{
            [sender setImage:[UIImage imageNamed:@"Mode_listtotext"] forState:(UIControlStateNormal)];
            [sender setImage:[UIImage imageNamed:@"Mode_listtotextHL"] forState:(UIControlStateHighlighted)];
            [UIView animateWithDuration:0.25 animations:^{
                customInputView.frame = CGRectMake(50, 1, _inputBar.bounds.size.width-50, _inputBar.bounds.size.height);
            }];
        }
    }
}
-(void)onInputLoc:(UIButton*)sender{
    [self.controller on:@{@"msgObj":@{@"loc":@{@"lo":@(131.111),@"la":@(33.1)}}}];
}
-(void)onInputImage:(UIButton*)sender{
    [self.controller on:@{@"msgObj":@{@"image":@"http://fanyi.baidu.com/static/translation/img/header/logo_cbfea26.png?120,33"}}];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (self.otherInputView.superview || self.faceInputView.superview) {
        [self.otherInputView removeFromSuperview];
        [self.faceInputView removeFromSuperview];
        _visableRect = self.frame;
        [self updateInputBarWithTime:0.25f];
    }
}
#pragma mark face input view
+(NSMutableDictionary*)faceList{
    static NSMutableArray* mExpressByEmotionDict;
    if (mExpressByEmotionDict) {
        return mExpressByEmotionDict;
    }
    mExpressByEmotionDict= [[NSMutableDictionary alloc] init];
    [mExpressByEmotionDict setValue:@"[微笑]" forKey:@"Expression_1"];
    [mExpressByEmotionDict setValue:@"[皱眉]"forKey:@"Expression_2"];
    [mExpressByEmotionDict setValue:@"[色]"forKey:@"Expression_3"];
    [mExpressByEmotionDict setValue:@"[囧逼]"forKey:@"Expression_4"];
    [mExpressByEmotionDict setValue:@"[酷]"forKey:@"Expression_5"];
    [mExpressByEmotionDict setValue:@"[流泪]"forKey:@"Expression_6"];
    [mExpressByEmotionDict setValue:@"[羞涩]"forKey:@"Expression_7"];
    [mExpressByEmotionDict setValue:@"[闭嘴]"forKey:@"Expression_8"];
    [mExpressByEmotionDict setValue:@"[睡]"forKey:@"Expression_9"];
    [mExpressByEmotionDict setValue:@"[大哭]"forKey:@"Expression_10"];
    [mExpressByEmotionDict setValue:@"[怕怕]"forKey:@"Expression_11"];
    [mExpressByEmotionDict setValue:@"[怒了]"forKey:@"Expression_12"];
    [mExpressByEmotionDict setValue:@"[调皮]"forKey:@"Expression_13"];
    [mExpressByEmotionDict setValue:@"[呲牙]"forKey:@"Expression_14"];
    [mExpressByEmotionDict setValue:@"[吃惊]"forKey:@"Expression_15"];
    [mExpressByEmotionDict setValue:@"[难过]"forKey:@"Expression_16"];
    [mExpressByEmotionDict setValue:@"[非常酷]"forKey:@"Expression_17"];
    [mExpressByEmotionDict setValue:@"[脸红]"forKey:@"Expression_18"];
    [mExpressByEmotionDict setValue:@"[抓狂]"forKey:@"Expression_19"];
    [mExpressByEmotionDict setValue:@"[吐]"forKey:@"Expression_20"];
    [mExpressByEmotionDict setValue:@"[偷笑]"forKey:@"Expression_21"];
    [mExpressByEmotionDict setValue:@"[羞羞]"forKey:@"Expression_22"];
    [mExpressByEmotionDict setValue:@"[好奇]"forKey:@"Expression_23"];
    [mExpressByEmotionDict setValue:@"[不耻]"forKey:@"Expression_24"];
    [mExpressByEmotionDict setValue:@"[饿]"forKey:@"Expression_25"];
    [mExpressByEmotionDict setValue:@"[懵]"forKey:@"Expression_26"];
    [mExpressByEmotionDict setValue:@"[吓惨了]"forKey:@"Expression_27"];
    [mExpressByEmotionDict setValue:@"[汗]"forKey:@"Expression_28"];
    [mExpressByEmotionDict setValue:@"[憨笑]"forKey:@"Expression_29"];
    [mExpressByEmotionDict setValue:@"[悠闲]"forKey:@"Expression_30"];
    [mExpressByEmotionDict setValue:@"[奋斗]"forKey:@"Expression_31"];
    [mExpressByEmotionDict setValue:@"[大骂]"forKey:@"Expression_32"];
    [mExpressByEmotionDict setValue:@"[疑问]"forKey:@"Expression_33"];
    [mExpressByEmotionDict setValue:@"[嘘嘘]"forKey:@"Expression_34"];
    [mExpressByEmotionDict setValue:@"[晕]"forKey:@"Expression_35"];
    [mExpressByEmotionDict setValue:@"[钱没了]"forKey:@"Expression_36"];
    [mExpressByEmotionDict setValue:@"[衰]"forKey:@"Expression_37"];
    [mExpressByEmotionDict setValue:@"[骷髅]"forKey:@"Expression_38"];
    [mExpressByEmotionDict setValue:@"[打击]"forKey:@"Expression_39"];
    [mExpressByEmotionDict setValue:@"[再见]"forKey:@"Expression_40"];
    [mExpressByEmotionDict setValue:@"[流汗]"forKey:@"Expression_41"];
    [mExpressByEmotionDict setValue:@"[扣鼻]"forKey:@"Expression_42"];
    [mExpressByEmotionDict setValue:@"[鼓掌]"forKey:@"Expression_43"];
    [mExpressByEmotionDict setValue:@"[吓傻了]"forKey:@"Expression_44"];
    [mExpressByEmotionDict setValue:@"[呲牙]"forKey:@"Expression_45"];
    [mExpressByEmotionDict setValue:@"[左哼哼]"forKey:@"Expression_46"];
    [mExpressByEmotionDict setValue:@"[右哼哼]"forKey:@"Expression_47"];
    [mExpressByEmotionDict setValue:@"[困]"forKey:@"Expression_48"];
    [mExpressByEmotionDict setValue:@"[鄙视]"forKey:@"Expression_49"];
    [mExpressByEmotionDict setValue:@"[委屈]"forKey:@"Expression_50"];
    [mExpressByEmotionDict setValue:@"[伤心]"forKey:@"Expression_51"];
    [mExpressByEmotionDict setValue:@"[猥琐]"forKey:@"Expression_52"];
    [mExpressByEmotionDict setValue:@"[亲亲]"forKey:@"Expression_53"];
    [mExpressByEmotionDict setValue:@"[吓]"forKey:@"Expression_54"];
    [mExpressByEmotionDict setValue:@"[萌]"forKey:@"Expression_55"];
    [mExpressByEmotionDict setValue:@"[刀]"forKey:@"Expression_56"];
    [mExpressByEmotionDict setValue:@"[西瓜]"forKey:@"Expression_57"];
    [mExpressByEmotionDict setValue:@"[美味]"forKey:@"Expression_58"];
    [mExpressByEmotionDict setValue:@"[篮球]"forKey:@"Expression_59"];
    [mExpressByEmotionDict setValue:@"[乒乓球]"forKey:@"Expression_60"];
    [mExpressByEmotionDict setValue:@"[咖啡]"forKey:@"Expression_61"];
    [mExpressByEmotionDict setValue:@"[饭]"forKey:@"Expression_62"];
    [mExpressByEmotionDict setValue:@"[猪头]"forKey:@"Expression_63"];
    [mExpressByEmotionDict setValue:@"[玫瑰]"forKey:@"Expression_64"];
    [mExpressByEmotionDict setValue:@"[凋谢]"forKey:@"Expression_65"];
    [mExpressByEmotionDict setValue:@"[红唇]"forKey:@"Expression_66"];
    [mExpressByEmotionDict setValue:@"[爱心]"forKey:@"Expression_67"];
    [mExpressByEmotionDict setValue:@"[心碎]"forKey:@"Expression_68"];
    [mExpressByEmotionDict setValue:@"[蛋糕]"forKey:@"Expression_69"];
    [mExpressByEmotionDict setValue:@"[闪电]"forKey:@"Expression_70"];
    [mExpressByEmotionDict setValue:@"[炸弹]"forKey:@"Expression_71"];
    [mExpressByEmotionDict setValue:@"[小刀]"forKey:@"Expression_72"];
    [mExpressByEmotionDict setValue:@"[足球]"forKey:@"Expression_73"];
    [mExpressByEmotionDict setValue:@"[虫]"forKey:@"Expression_74"];
    [mExpressByEmotionDict setValue:@"[便便]"forKey:@"Expression_75"];
    [mExpressByEmotionDict setValue:@"[月亮]"forKey:@"Expression_76"];
    [mExpressByEmotionDict setValue:@"[太阳]"forKey:@"Expression_77"];
    [mExpressByEmotionDict setValue:@"[礼物]"forKey:@"Expression_78"];
    [mExpressByEmotionDict setValue:@"[抱抱]"forKey:@"Expression_79"];
    [mExpressByEmotionDict setValue:@"[强]"forKey:@"Expression_80"];
    [mExpressByEmotionDict setValue:@"[弱]"forKey:@"Expression_81"];
    [mExpressByEmotionDict setValue:@"[合作]"forKey:@"Expression_82"];
    [mExpressByEmotionDict setValue:@"[胜利]"forKey:@"Expression_83"];
    [mExpressByEmotionDict setValue:@"[抱拳]"forKey:@"Expression_84"];
    [mExpressByEmotionDict setValue:@"[勾引]"forKey:@"Expression_85"];
    [mExpressByEmotionDict setValue:@"[拳头]"forKey:@"Expression_86"];
    [mExpressByEmotionDict setValue:@"[小样]"forKey:@"Expression_87"];
    return mExpressByEmotionDict;
}
+ (NSString *)allExpress{
    static NSMutableString * wExpressStr ;
    if (wExpressStr) {
        return wExpressStr;
    }
    if (wExpressStr.length > 2) {
        return wExpressStr;
    }
    wExpressStr = [[NSMutableString alloc]initWithCapacity:1];
    NSArray * wEmotionList = [[self faceList] allValues];
    for (int i = 0; i < wEmotionList.count; i++)
    {
        NSString * wValue = [wEmotionList objectAtIndex:i];
        wValue = [wValue stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
        wValue = [wValue stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
        if (i == 0)
        {
            [wExpressStr appendFormat:@"(%@)", wValue];
        }
        else
        {
            [wExpressStr appendFormat:@"|(%@)", wValue];
        }
    }
    return wExpressStr;
}
+ (NSRegularExpression *)allExpressRex{
    static NSRegularExpression * wRex ;
    if (wRex) {
        return wRex;
    }
    NSError * wError = nil;
    wRex = [NSRegularExpression regularExpressionWithPattern:[self allExpress] options:NSRegularExpressionCaseInsensitive error:&wError];
    return wRex;
}
-(UIView *)otherInputView{
    if (!_otherInputView) {
        _otherInputView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 200)];
        _otherInputView.backgroundColor = UIColorFromStr(@"F0EFF5");
        _otherInputView.contentSize = CGSizeMake(_faceInputView.bounds.size.width*3, 0);
        _otherInputView.pagingEnabled = YES;
        UIButton *pic = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_W-200)/5, 15, 50, 50)];
        [pic setImage:[UIImage imageNamed: @"sharemore_pic"] forState:(UIControlStateNormal)];
        pic.layer.cornerRadius = 12;
        pic.backgroundColor = [UIColor whiteColor];
        pic.clipsToBounds = YES;
        pic.layer.borderColor = UIColorFromStr(@"aaaaaa").CGColor;
        pic.layer.borderWidth = 0.99/SCALE;
        [pic addTarget:self action:@selector(onInputImage:) forControlEvents:(UIControlEventTouchUpInside)];
        [_otherInputView addSubview:pic];
        
        UIButton *loc = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_W-200)/5*2+50, 15, 50, 50)];
        [loc setImage:[UIImage imageNamed: @"sharemore_location"] forState:(UIControlStateNormal)];
        loc.layer.cornerRadius = 12;
        loc.backgroundColor = [UIColor whiteColor];
        loc.clipsToBounds = YES;
        loc.layer.borderColor = UIColorFromStr(@"aaaaaa").CGColor;
        loc.layer.borderWidth = 0.99/SCALE;
        [loc addTarget:self action:@selector(onInputLoc:) forControlEvents:(UIControlEventTouchUpInside)];
        [_otherInputView addSubview:loc];
    }
    return _otherInputView;
}
-(UIView *)faceInputView{
    if (_faceInputView) {
        return _faceInputView;
    }
    _faceInputView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 200)];
    _faceInputView.backgroundColor = UIColorFromStr(@"F0EFF5");
    _faceInputView.contentSize = CGSizeMake(_faceInputView.bounds.size.width*3, 0);
    _faceInputView.pagingEnabled = YES;
    UIView *s = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _faceInputView.bounds.size.width*3, _faceInputView.bounds.size.height)];
    [_faceInputView addSubview:s];
    NSMutableDictionary *faceList = [[self class] faceList];
    for (int i = 0; i<faceList.count; i++) {
        UIButton *faceBtn = [[UIButton alloc]initWithFrame:CGRectMake(i/29*_faceInputView.bounds.size.width+i%29%8*_faceInputView.bounds.size.width/8, i%29/8*_faceInputView.bounds.size.height/4, _faceInputView.bounds.size.width/8, _faceInputView.bounds.size.height/4)];
        [faceBtn setImage:[UIImage imageNamed: [NSString stringWithFormat:@"Expression_%d",i+1]] forState:(UIControlStateNormal)];
        faceBtn.tag = i;
        [faceBtn addTarget:self action:@selector(onEmojiSelect:) forControlEvents:(UIControlEventTouchUpInside)];
        [s addSubview:faceBtn];
        if (i == 28 || i == 57 || i == 86) {
            int j = i+1;
            UIButton *deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(_faceInputView.bounds.size.width/8*5+i/32*_faceInputView.bounds.size.width,_faceInputView.bounds.size.height/4*3, _faceInputView.bounds.size.width/8, _faceInputView.bounds.size.height/4)];
            [deleteBtn setImage:[UIImage imageNamed:@"DeleteEmoticonBtn"] forState:(UIControlStateNormal)];
            [deleteBtn addTarget:self action:@selector(onDelete:) forControlEvents:(UIControlEventTouchUpInside)];
            [s addSubview:deleteBtn];
            j++;
            UIButton *sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(_faceInputView.bounds.size.width/8*6+i/32*_faceInputView.bounds.size.width+10, _faceInputView.bounds.size.height/4*3+10, _faceInputView.bounds.size.width/4-20, _faceInputView.bounds.size.height/4-20)];
            [sendBtn addTarget:self action:@selector(onSend:) forControlEvents:(UIControlEventTouchUpInside)];
            [sendBtn setBackgroundColor:UIColorFromStr(@"33b653")];
            [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
            sendBtn.layer.cornerRadius = 5;
            [s addSubview:sendBtn];
        }
        
    }
    return _faceInputView;
}
-(void)onEmojiSelect:(UIButton*)sender{
    NSString *word = [[[self class]faceList] objectForKey:[NSString stringWithFormat:@"Expression_%d",sender.tag+1]];
    UITextView *textView = [self.inputBar viewWithTag:10001];
    textView.text = [NSString stringWithFormat:@"%@%@",textView.text,word];
    [self textViewDidChange:textView];
}
-(void)onDelete:(UIButton*)sender{
    UITextView *textView = [self.inputBar viewWithTag:10001];
    NSString * wExpress = [[self class]allExpress];
    NSError * wError = nil;
    NSRegularExpression * wRegex = [NSRegularExpression regularExpressionWithPattern:wExpress options:NSRegularExpressionCaseInsensitive error:&wError];
    NSArray * wResultList = [wRegex matchesInString:textView.text options:NSMatchingReportProgress range:NSMakeRange(0, textView.text.length)];
    for (NSTextCheckingResult * wResult in wResultList) {
        if (wResult.range.location + wResult.range.length >= textView.text.length) {
            textView.text = [textView.text stringByReplacingCharactersInRange:wResult.range withString:@""];
            return;
        }
    }
    if (textView.text.length > 0) {
        textView.text = [textView.text substringToIndex:textView.text.length -1];
    }
}
-(void)onSend:(UIButton*)sender{
    [self.controller on:@{@"msg":self.textView.text}];
    self.textView.text = @"";
    [self setInputBarHeight:50];
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }else{
        UIButton *emoji = [self.inputBar viewWithTag:10002];
        [emoji setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:(UIControlStateNormal)];
        [emoji setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:(UIControlStateHighlighted)];
        [UIView animateWithDuration:0.25 animations:^{
            self.faceInputView.frame = CGRectMake(0, self.bounds.size.height, self.faceInputView.bounds.size.width, self.faceInputView.bounds.size.height);
        } completion:^(BOOL finished) {
            [self.faceInputView removeFromSuperview];
        }];
        _visableRect = self.frame;
        [self updateInputBarWithTime:0.25];
    }
    

}
@end

