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
//  Copyright (c) 2014年 GPLIU. All rights reserved.
//

#import "HeroSegmentControl.h"
#import "UILazyImageView.h"
@implementation HeroSegmentControl
{
    NSArray *_data;
    NSMutableArray *_actions;
    CGRect frame;
}
-(void)on:(NSDictionary *)json
{
    [super on:json];
    frame = self.frame;
    self.momentary = NO;
    [self addTarget:self action:@selector(onChange:) forControlEvents:UIControlEventValueChanged];
    if (json[@"dataSource"]) {
        _data = json[@"dataSource"];
        for (int i = 0; i < _data.count; i++) {
            NSDictionary *item = _data[i];
            if (item[@"image"]) {
                [UILazyImageView registerForName:item[@"image"] block:^(NSData *data) {
                    [self insertSegmentWithImage:[UIImage imageWithData:data scale :[UIScreen mainScreen].scale] atIndex:self.numberOfSegments animated:YES];
                }];
            }
            if (item[@"title"]) {
                [self insertSegmentWithTitle:item[@"title"] atIndex:self.numberOfSegments animated:YES];
            }
            
        }
    }
    if (json[@"selectedSegmentIndex"]) {
        self.selectedSegmentIndex = ((NSNumber*)json[@"selectedSegmentIndex"]).integerValue;
        [self sendData:self.selectedSegmentIndex];
    }
    if (json[@"action"]) {
        _actions = [NSMutableArray arrayWithArray:json[@"action"]];
        [self sendData:self.selectedSegmentIndex];
    }

}
-(void)onChange:(UISegmentedControl*)sender
{
    [self sendData:self.selectedSegmentIndex];
}
-(void)sendData:(NSInteger)index{
    if (_actions) {
        if (_actions.count > self.selectedSegmentIndex) {
            [self.controller on:_actions[index]];
        }
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.frame = frame;
    if (self.superview) {
        self.center = CGPointMake(self.superview.bounds.size.width/2, self.superview.bounds.size.height/2);
    }
}
-(void)didMoveToSuperview{
    [super didMoveToSuperview];
}
@end
