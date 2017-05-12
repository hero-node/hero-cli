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

//  Created by zhuyechao on 12/8/15.
//

#import "HeroPickerView.h"

@interface HeroPickerView()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIToolbar *toolBar;

@end

@implementation HeroPickerView {
    id actionObject;
    NSString *type;
    BOOL hideToolBar;
}
-(void)show{
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    self.bgView = [[UIView alloc]initWithFrame:screenBounds];
    self.bgView.backgroundColor = [UIColor clearColor];
    _shadowView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H - 216);
    [self.bgView addSubview:_shadowView];
    [KEY_WINDOW addSubview:self.bgView];
    [self.bgView addSubview:self.contentView];
    self.contentView.frame = CGRectMake(0, screenBounds.size.height, screenBounds.size.width, 216);
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = CGRectMake(0, screenBounds.size.height-216, screenBounds.size.width, 216);
        self.bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
    }];
    [self.pickerView reloadAllComponents];
}
-(void)hide{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = CGRectMake(0, _bgView.bounds.size.height, _bgView.bounds.size.width, 216);
        self.bgView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
    }];
}
-(instancetype)init {
    self = [super init];
    if (self) {
        type = @"";
        hideToolBar = NO;
        self.contentView = [[UIView alloc]init];
        self.contentView.backgroundColor = [UIColor whiteColor];

        self.toolBar = [[UIToolbar alloc] init];
        _toolBar.barTintColor = [UIColor whiteColor];
        _toolBar.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 38);
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPickerView)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePickerView)];
        UIBarButtonItem *spaceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = 20;
        _toolBar.items = @[fixedSpace, cancelButton, spaceBtn, doneButton, fixedSpace];
        if ([type isEqualToString:@"date"]) {
            self.datePicker = [[UIDatePicker alloc] init];
            self.datePicker.autoresizingMask = 0x111111;
            [_datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        }
        else {
            self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H / 3)];
            self.pickerView.autoresizingMask = 0x111111;
            _pickerView.dataSource = self;
            _pickerView.delegate  = self;
        }
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H - 216)];
        _shadowView.userInteractionEnabled = YES;
        [_shadowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
        CGFloat width = SCREEN_W;
        CGFloat height = SCREEN_H / 3;
        self.contentView.frame = CGRectMake(0, 0, width, height);
    }
    return self;
}

-(void)on:(NSDictionary *)json{
    [super on:json];
    self.clipsToBounds = YES;

    if (json[@"type"]) {
        type = json[@"type"] ?: @"";
        if ([type isEqualToString:@"date"]) {
            self.datePicker = [[UIDatePicker alloc] init];
            self.datePicker.autoresizingMask = 0x111111;
            [_datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        }
    }
    if (json[@"hideToolBar"]) {
        hideToolBar = [json[@"hideToolBar"] boolValue];
    }
    if (json[@"frame"]) {
        self.contentView.frame = self.bounds;

        if ([type isEqualToString:@"date"]) {
            [self.contentView addSubview:_datePicker];
            if (!hideToolBar) {
                [_contentView addSubview:_toolBar];
            }
        } else {
            [self.contentView addSubview:_pickerView];
            if (!hideToolBar) {
                [_contentView addSubview:_toolBar];
            }
        }
    }else{
        self.hidden = true;

        if ([type isEqualToString:@"date"]) {
            [self.contentView addSubview:_datePicker];
            if (!hideToolBar) {
                [_contentView addSubview:_toolBar];
            }
        } else {
            [self.contentView addSubview:_pickerView];
            if (!hideToolBar) {
                [_contentView addSubview:_toolBar];
            }
        }
    }
    if (json[@"dateMode"]) {
        NSString *dateMode = json[@"dateMode"];
        if ([@"UIDatePickerModeTime" isEqualToString:dateMode]) {
            _datePicker.datePickerMode = UIDatePickerModeTime;
        }
        if ([@"UIDatePickerModeDate" isEqualToString:dateMode]) {
            _datePicker.datePickerMode = UIDatePickerModeDate;
        }
        if ([@"UIDatePickerModeDateAndTime" isEqualToString:dateMode]) {
            _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }
    }
    if (json[@"method"]) {
        NSString *method = json[@"method"];
        if ([method isEqualToString:@"show"]) {
            [self show];
        }
    }
    if (json[@"datas"]) {
        self.datas = json[@"datas"];
    }
    if (json[@"selectIndex"]) {
        NSDictionary *selectIndex = json[@"selectIndex"];
        NSInteger section = [selectIndex[@"section"] integerValue];
        NSInteger row = [selectIndex[@"row"] integerValue];
        [_pickerView selectRow:row inComponent:section animated:YES];
    }
    if (json[@"selectAction"]) {
        actionObject = json[@"selectAction"];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.datas.count > 0) {
        if ([self.datas[0] isKindOfClass:[NSDictionary class]]) {
            return 2;
        }
        return 1;
    }
    return 0;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (0 == component) {
        return [self.datas count];
    } else if (1 == component) {
        return [self.datas[[pickerView selectedRowInComponent:0]][@"rows"] count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    id components = self.datas[component];
    if ([components isKindOfClass:[NSDictionary class]]) {
        if (component == 0) {
            return self.datas[row][@"title"];
        }else if(component == 1){
            NSInteger selectedRow = [pickerView selectedRowInComponent:0];
            if (selectedRow < self.datas.count) {
                id rows = self.datas[selectedRow][@"rows"];
                if (rows && row < [rows count]) {
                    return rows[row];
                }
            }
        }
    }else{
        return self.datas[row];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        id components = self.datas[component];
        if ([components isKindOfClass:[NSDictionary class]]) {
            [pickerView reloadComponent:1];
        }
    }
}

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:actionObject];
    int unix_time = [[NSNumber numberWithDouble:datePicker.date.timeIntervalSince1970] intValue];
    [dict setObject:[NSNumber numberWithInt:unix_time] forKey:@"value" ];
    [self.controller on:dict];
}

- (void)cancelPickerView {
    [self hide];
}

- (void)donePickerView {
    if ([type isEqualToString:@"date"]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:actionObject];
        int unix_time = [[NSNumber numberWithDouble:_datePicker.date.timeIntervalSince1970] intValue];
        [dict setObject:[NSNumber numberWithInt:unix_time] forKey:@"value" ];
        [self.controller on:dict];
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:actionObject];
        if (_pickerView.numberOfComponents == 1) {
            [dict setObject:@{ @"section":@(0),@"row": @([_pickerView selectedRowInComponent:0])} forKey:@"value"];
        } else if (_pickerView.numberOfComponents == 2) {
            [dict setObject:@{ @"section":@([_pickerView selectedRowInComponent:0]),@"row": @([_pickerView selectedRowInComponent:1])} forKey:@"value"];
        }
        [self.controller on:dict];
    }
    [self hide];
}

-(void)dealloc{
    DLog(@"HeroPickerView dealloced");
}
@end
