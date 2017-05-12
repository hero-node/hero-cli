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

//  Created by zhuyechao on 2/14/16.
//

#import "HeroContactView.h"
@import AddressBook;

@implementation HeroContactView {
    NSMutableString *data;
    ABAuthorizationStatus status;
    id getContactObject;
    id getRecentObject;

}

-(void)on:(NSDictionary *)json{
    [super on:json];
    if (json[@"getContact"]) {
        getContactObject = json[@"getContact"];
        [self askPermission];
        data = [NSMutableString string];
        if (kABAuthorizationStatusNotDetermined == status) {
            ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
                if (granted){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self getContacts];
                    });
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self notPermitted];
                    });
                }
            });
        } else if (kABAuthorizationStatusAuthorized == status) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getContacts];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self notPermitted];
            });
        }
    }
    if (json[@"getRecent"]) {
        // iOS为空
//        getRecentObject = json[@"getRecent"];
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:getRecentObject];
//        [dict setObject:@{@"callHistories":@[]} forKey:@"value"];
//        [self.controller on:dict];
    }
}

-(void)askPermission {
    status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusDenied ||
        status == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"Denied");
    } else if (status == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
    } else if (status == kABAuthorizationStatusNotDetermined) {
        //3
        NSLog(@"Not determined");
    }
}

-(void)notPermitted {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:getContactObject];
    [dict setObject:@{@"error":@"no permitted"} forKey:@"value"];
    [self.controller on:dict];

}

-(void)getContacts {
    NSMutableArray *contacts = [NSMutableArray array];
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    for (id record in allContacts){
        ABRecordRef thisContact = (__bridge ABRecordRef)record;

        NSString *compositeName = (__bridge NSString *)ABRecordCopyCompositeName(thisContact);

        if (!compositeName) {
            continue;
        }

        ABMultiValueRef phoneRecord = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
        int counts = (int)ABMultiValueGetCount(phoneRecord);
        for (int k = 0; k < counts; k++)
        {
            //获取电话Label
            NSString * phoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneRecord, k));
            //获取該Label下的电话值
            NSString * phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneRecord, k);
            if (!phoneLabel || !phoneNumber) {
                continue;
            }
//            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
//            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
//            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            [contacts addObject:@{@"name": compositeName, @"phone": phoneNumber}];
        }
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:getContactObject];
    [dict setObject:@{@"contacts":contacts} forKey:@"value"];
    [self.controller on:dict];
    DLog(@"getContacts");
}

@end
