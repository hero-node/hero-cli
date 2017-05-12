//
//  NSStringAdditions.h
//  loopu
//
//  Created by key key on 10-9-29.
//  Copyright 2010 loopu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (PrivateMethod)

- (CGFloat)textHeightForWidth:(CGFloat)width withFont:(UIFont *)font;
- (CGSize)textSizeForWidth:(CGFloat)maxWidth withFont:(UIFont *)font;
- (NSString *)stringToXMLString;
- (NSString *)stringWithFormatterInFullDateString:(NSString *)format;
- (NSDictionary *)dictionaryByMessage;
- (NSString *)md5;

//得到文件名的路径,如果文件在文档目录中不存在,将从资源中复制
+ (NSString *)stringByAppendDocumentDirectory:(NSString *)filename;
//得到文件名的路径从资源中
+ (NSString *)stringByAppendBundle:(NSString *)filename;

//得到当前系统的当前语言
+ (NSString *)stringByCurrentLanguage;
//得到当前系统的唯一串

//得到当前系统的型号
+ (NSString *)stringByModel;
+ (NSString *)stringByConvertTimeInfo:(int64_t)timestamp;
+ (NSString *)stringByConvertToShortDistance:(int64_t)distance;

//验证是否为邮箱
- (BOOL)isEmail;
//验证是否为手机号
- (BOOL)isMobilePhone;
- (BOOL)isCloudNumber;

- (NSString *) getMd5;

- (NSString *)getMarkAudioName;
- (BOOL)isAudioURLString;
- (BOOL)isPhoneNumber;
- (BOOL)isNumberOnly;
- (BOOL)biggerThan:(NSString*)str;

- (NSString *)getCodeByNumberString;

- (NSString *)encodeToPercentEscapeString;
- (NSString *)decodeFromPercentEscapeString;

@end
