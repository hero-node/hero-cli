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


#import "HeroTextView.h"
@interface HeroTextView()
@end

@implementation HeroTextView{
    UILabel *_placeHolderLabel ;
    BOOL enableReturn;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        enableReturn = NO;
    }
    return self;
}

-(void)on:(NSDictionary *)json{
    [super on:json];
    self.delegate = self;
    if (json[@"text"]) {
        self.text = json[@"text"];
        if (self.text.length > 0) {
            _placeHolderLabel.hidden = true;
        }else{
            _placeHolderLabel.hidden = false;
        }
    }
    if (json[@"enableReturn"]) {
        enableReturn = [json[@"enableReturn"] boolValue];
    }
    if (json[@"appendText"]) {
        self.text = [NSString stringWithFormat:@"%@\r%@",self.text,json[@"appendText"]];
    }
    if (json[@"placeHolder"]) {
        if (!_placeHolderLabel) {
            _placeHolderLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 34)];
            _placeHolderLabel.adjustsFontSizeToFitWidth = YES;
            _placeHolderLabel.minimumScaleFactor = 0.5f;
            _placeHolderLabel.text = json[@"placeHolder"];
            _placeHolderLabel.textColor = UIColorFromRGB(0xcccccc);
            [self addSubview:_placeHolderLabel];
        }
    }
    if (json[@"editable"]) {
        NSString *editable =  json[@"editable"];
        if ([@"false" isEqualToString:editable]) {
            self.editable = false;
        }
    }
    if (json[@"size"]) {
        double size = ((NSNumber*)json[@"size"]).doubleValue;
        self.font = [UIFont systemFontOfSize:size];
        if (_placeHolderLabel) {
            _placeHolderLabel.font = [UIFont systemFontOfSize:size];
        }
    }
    if (json[@"textColor"]) {
        self.textColor = UIColorFromStr(json[@"textColor"]);
    }
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (_placeHolderLabel) {
        _placeHolderLabel.hidden = true;
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView;
{
    if (_placeHolderLabel) {
        if (self.text.length > 0) {
            _placeHolderLabel.hidden = true;
        }else{
            _placeHolderLabel.hidden = false;
        }
    }
}
-(void)textViewDidChange:(UITextView *)textView{
    if (self.json[@"textFieldDidEditing"]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.json[@"textFieldDidEditing"]];
        [dic setObject:self.text forKey:@"value"];
        [self.controller on:dic];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!enableReturn) {
        if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
            return YES;
        }
        [textView resignFirstResponder];
        return NO;
    }
    return YES;

}
@end
