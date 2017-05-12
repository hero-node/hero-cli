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


#import "HeroTextField.h"
@interface HeroTextFieldDelegate :NSObject<UITextFieldDelegate>
@property (nonatomic,weak) HeroTextField *textField;
@property (nonatomic,assign) NSInteger maxLen;
@property (nonatomic,assign) NSInteger minLen;
@property (nonatomic,copy) NSString *allowString;
@end
@implementation HeroTextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.textField.json[@"return"]) {
        [self.textField.controller on:self.textField.json[@"return"]];
    }
    [textField resignFirstResponder];
    return true;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.textField.json[@"textFieldDidEndEditing"]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.textField.json[@"textFieldDidEndEditing"]];
        [dic setObject:textField.text forKey:@"value"];
        [dic setObject:textField.name forKey:@"name"];
        [dic setObject:@"textFieldDidEndEditing" forKey:@"event"];
        [self.textField.controller on:dic];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.textField.json[@"textFieldDidBeginEditing"]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.textField.json[@"textFieldDidBeginEditing"]];
        [dic setObject:textField.text forKey:@"value"];
        [dic setObject:textField.name forKey:@"name"];
        [dic setObject:@"textFieldDidBeginEditing" forKey:@"event"];
        [self.textField.controller on:dic];
    }
}


- (BOOL)textField:(HeroTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Note textField's current state before performing the change, in case
    // reformatTextField wants to revert it
    textField.previousTextFieldContent = textField.text;
    textField.previousSelection = textField.selectedTextRange;

    return YES;
}

@end

@interface HeroTextField()
@property (nonatomic,strong)HeroTextFieldDelegate *outDelegate;
@end
@implementation HeroTextField
{
    HeroViewController *controller;
}

-(void)on:(NSDictionary *)json{
    [super on:json];
    self.outDelegate = [[HeroTextFieldDelegate alloc]init];
    self.outDelegate.textField = self;
    self.delegate = self.outDelegate;
    if (json[@"text"]) {
        if (![json[@"text"] isKindOfClass:[NSString class]]) {
            self.text = NULL;
        }else{
            self.text = json[@"text"];
            controller = self.controller;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.json[@"textFieldDidEditing"]) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.json[@"textFieldDidEditing"]];
                    [dic setObject:self.text forKey:@"value"];
                    [controller on:dic];
                }
            });
        }
    }
    if (json[@"clear"]) {
        self.text = NULL;
    }
    if (json[@"secure"]) {
        self.secureTextEntry = [json[@"secure"] boolValue];
    }
    if (json[@"placeHolder"]) {
        self.placeholder = json[@"placeHolder"];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: UIColorFromStr(@"cccccc")}];
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
    if (json[@"type"]) {
        NSString *type = json[@"type"];
        if ([@"number" isEqualToString:type]) {
            self.keyboardType = UIKeyboardTypeDecimalPad;
        }
        if ([@"email" isEqualToString:type]) {
            self.keyboardType = UIKeyboardTypeEmailAddress;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        if ([@"phone" isEqualToString:type]) {
            self.keyboardType = UIKeyboardTypePhonePad;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        if ([@"pin" isEqualToString:type]) {
            self.keyboardType = UIKeyboardTypeNumberPad;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
        }
    }
    if (json[@"return"]) {
        self.returnKeyType = UIReturnKeyDone;
    }
    if (json[@"maxLength"]) {
        self.outDelegate.maxLen = ((NSNumber*)json[@"maxLength"]).integerValue;
    }
    if (json[@"minLength"]) {
        self.outDelegate.minLen = ((NSNumber*)json[@"minLength"]).integerValue;
    }
    if (json[@"allowString"]) {
        self.outDelegate.allowString = json[@"allowString"];
    }
    if (json[@"textColor"]) {
        self.textColor = UIColorFromStr(json[@"textColor"]);
    }
    if (json[@"placeHolderColor"]) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: UIColorFromStr(json[@"placeHolderColor"])}];
    }
    if (json[@"size"]) {
        double size = ((NSNumber*)json[@"size"]).doubleValue;
        self.font = [UIFont systemFontOfSize:size];
    }
    if (json[@"whileEditing"]) {
        if ([json[@"whileEditing"] boolValue]) {
            self.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
    }

    if (self.json[@"textFieldDidEditing"]) {
        [self addTarget:self action:@selector(onTextChanged:) forControlEvents:UIControlEventEditingChanged];
    }

    if (json[@"focus"]) {
        if ([json[@"focus"] boolValue]) {
            [self becomeFirstResponder];
        } else {
            [self resignFirstResponder];
        }
    }
}

- (void)onTextChanged:(HeroTextField *)sender {
    if (sender.json[@"textFieldDidEditing"]) {
        if ([sender markedTextRange] == NULL) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:sender.json[@"textFieldDidEditing"]];
            [dic setObject:sender.text forKey:@"value"];
            [dic setObject:self.name forKey:@"name"];
            [dic setObject:@"UIControlEventEditingChanged" forKey:@"event"];
            [sender.controller on:dic];
        }
    }
}

@end

