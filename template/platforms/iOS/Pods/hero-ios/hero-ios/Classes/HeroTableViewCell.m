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
//  Created by Liu Guoping on 15/9/5.
//

#import "HeroTableViewCell.h"
#import "HeroSwitch.h"
#import "UILazyImageView.h"

@implementation HeroTableViewCell
-(instancetype)initWithJson:(NSDictionary *)json viewController:(HeroViewController *)viewController
{
    if (json[@"res"]) {
        self = [[NSBundle mainBundle]loadNibNamed:json[@"res"] owner:nil options:nil][0];
        self.controller = viewController;
        self.json = json;
        [self on:json];
    }else{
        self.controller = viewController;
        self = [self initWithJson:json];
    }
    return self;
}

-(instancetype)initWithJson:(NSDictionary*)json{
    NSString *boolValue   = json[@"boolValue"];
    NSString *textValue   = json[@"textValue"];
    NSString *imageValue   = json[@"imageValue"];
    if (boolValue) {
        self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"%@",self]];
    }else if (imageValue) {
        self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"%@",self]];
    }else if (textValue) {
        self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"%@",self]];
    }else{
        self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%@",self]];
    }
    return self;
}

-(void)on:(NSDictionary *)json{
    [super on:json];
    NSString *imageStr = json[@"image"];
    NSString *title    = json[@"title"];
    NSString *detail   = json[@"detail"];
    NSString *boolValue   = json[@"boolValue"];
    NSString *textValue   = json[@"textValue"];
    NSString *imageValue   = json[@"imageValue"];
    if (boolValue) {
        HeroSwitch *valueElement = [[HeroSwitch alloc]init];
        [valueElement on:@{@"name":title,@"value":boolValue}];
        self.accessoryView = valueElement;
    }
    else if (imageValue) {
        UIImageView *valueElement = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height)];
        [UILazyImageView registerForName:imageValue block:^(NSData *data) {
            valueElement.image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
        }];
        self.accessoryView = valueElement;
    }
    else if (textValue) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@",textValue ];
    }
    else
    {
        self.detailTextLabel.numberOfLines = 10;
        self.detailTextLabel.text = detail;
    }
    self.textLabel.text = title;
    if (imageStr) {
        [UILazyImageView registerForName:imageStr block:^(NSData *data) {
            self.imageView.image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
            [self layoutSubviews];
        }];
    }
    if (json[@"accessoryType"]) {
        NSString *type = json[@"accessoryType"];
        if ([@"None" isEqualToString:type]) {
            self.accessoryType = UITableViewCellAccessoryNone;
        }else if ([@"DisclosureIndicator" isEqualToString:type]){
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if ([@"DetailDisclosureButton" isEqualToString:type]){
            self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }else if ([@"Checkmark" isEqualToString:type]){
            self.accessoryType = UITableViewCellAccessoryCheckmark;
        }else if ([@"DetailButton" isEqualToString:type]){
            self.accessoryType = UITableViewCellAccessoryDetailButton;
        }
    }
    if (json[@"selectionStyle"]) {
        NSString *style = json[@"selectionStyle"];
        if ([@"None" isEqualToString:style]) {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
