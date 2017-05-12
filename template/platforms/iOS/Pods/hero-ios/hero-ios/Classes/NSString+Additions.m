//
//  NSStringAdditions.m
//  loopu
//
//  Created by key key on 10-9-29.
//  Copyright 2010 loopu. All rights reserved.
//

#import "NSString+Additions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Helpme360)

- (CGFloat)textHeightForWidth:(CGFloat)maxWidth withFont:(UIFont *)font {
    CGFloat maxHeight = 9999;
    CGSize maximumLabelSize = CGSizeMake(maxWidth, maxHeight);
    CGSize expectedLabelSize = [self sizeWithFont:font
                                   constrainedToSize:maximumLabelSize
                                       lineBreakMode:NSLineBreakByWordWrapping];
    return expectedLabelSize.height;
}

- (CGSize)textSizeForWidth:(CGFloat)maxWidth withFont:(UIFont *)font {
    CGFloat maxHeight = 9999;
    CGSize maximumLabelSize = CGSizeMake(maxWidth, maxHeight);
    
    CGSize expectedLabelSize = [self sizeWithFont:font
                                   constrainedToSize:maximumLabelSize
                                       lineBreakMode:NSLineBreakByCharWrapping];
    
    return expectedLabelSize;
}

- (NSString *)stringToXMLString {
    NSString *data = self;
    data = [data stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    data = [data stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    data = [data stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    data = [data stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    data = [data stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    return data;
}

- (NSString *)stringWithFormatterInFullDateString:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [outputFormatter setDateFormat:format];      //@"YYYYMMdd"
    
    NSDate *dda = [dateFormatter dateFromString:self];
    NSString *title = [outputFormatter stringFromDate:dda];
    return title;
}

- (NSDictionary *)dictionaryByMessage {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSArray *items = [self componentsSeparatedByString:@","];
    for (NSString *item in items) {
        NSRange range = [item rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString *name = [item substringToIndex:range.location];
            NSString *co = [[item substringFromIndex:range.location + range.length] stringByTrimmingCharactersInSet:set];
            [dict setObject:co forKey:name];
        }
    }
    for (id key in dict) {
        //[dict valueForKey:key]
        //DLog(@"处理好的key=%@,value=%@",key,[dict valueForKey:key]);
    }
    return dict;
}

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [[NSString
             stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1],
             result[2], result[3],
             result[4], result[5],
             result[6], result[7],
             result[8], result[9],
             result[10], result[11],
             result[12], result[13],
             result[14], result[15]
             ] lowercaseString];
}

//得到文件名的路径,如果文件在文档目录中不存在,将从资源中复制
+ (NSString *)stringByAppendDocumentDirectory:(NSString *)filename {
    NSArray *fileInfo = [filename componentsSeparatedByString:@"."];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathToUserCopyOfPlist = [documentsDirectory stringByAppendingPathComponent:filename];
    
    if ([fileManager fileExistsAtPath:pathToUserCopyOfPlist] == NO) {
        NSString *pathToDefaultPlist = [[NSBundle mainBundle] pathForResource:[fileInfo objectAtIndex:0] ofType:[fileInfo objectAtIndex:1]];
        //HHLOG(@"Bundle Path:%@",pathToDefaultPlist);
        if (pathToDefaultPlist) {
            if ([fileManager copyItemAtPath:pathToDefaultPlist toPath:pathToUserCopyOfPlist error:&error] == NO) {
                //HHLOG(@"copy file to document directory error");
                NSAssert1(0, @"Failed to copy data with error message '%@'.", [error localizedDescription]);
            }
        }
    }
    return pathToUserCopyOfPlist;
}

//得到文件名的路径从资源中
+ (NSString *)stringByAppendBundle:(NSString *)filename {
    NSArray *fileInfo = [filename componentsSeparatedByString:@"."];
    return [[NSBundle mainBundle] pathForResource:[fileInfo objectAtIndex:0] ofType:[fileInfo objectAtIndex:1]];
}

//得到当前系统的当前语言
+ (NSString *)stringByCurrentLanguage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = @"en";
    if (languages.count > 0) {
        currentLanguage = [languages objectAtIndex:0];
    }
    return currentLanguage;
}

//得到当前系统的型号
+ (NSString *)stringByModel {
    UIDevice *device = [UIDevice currentDevice];
    return [device model];
}

+ (NSString *)stringByConvertTimeInfo:(int64_t)timestamp {
    NSDate *date = [NSDate date];
    
    NSInteger nowTimeStamp = (int)[date timeIntervalSince1970];
    timestamp = nowTimeStamp - timestamp / 1000;
    
    NSInteger seconds = timestamp;
    NSInteger month = seconds / (30 * 24 * 3600); // 月
    if (month > 0) return [NSString stringWithFormat:@"%tu月前发布", month];
    NSInteger day = seconds / (24 * 3600); // 天
    if (day > 0) return [NSString stringWithFormat:@"%tu天前发布", day];
    NSInteger hour = seconds / (3600); // 小时
    if (hour > 0) return [NSString stringWithFormat:@"%tu小时前发布", hour];
    NSInteger minute = seconds / (60); // 分钟
    if (minute > 0) return [NSString stringWithFormat:@"%tu分钟前发布", minute];
    return NSLocalizedString(@"B_JustPublish", nil);
}

+ (NSString *)stringByConvertToShortDistance:(int64_t)distance {
    if (distance <= 100) return NSLocalizedString(@"B_About0.1km", nil);
    
    /*
     if (distance <= 200) return @"约0.2Km";
     if (distance <= 300) return @"约0.3Km";
     if (distance <= 500) return @"约0.5Km";
     if (distance <= 600) return @"约0.6Km";
     if (distance <= 800) return @"约0.8Km";
     if (distance <= 1000) return @"约1Km";
     if (distance <= 1500) return @"约1.5Km";
     if (distance <= 2000) return @"约2Km";
     if (distance <= 3000) return @"约3Km";
     if (distance <= 5000) return @"约5Km";
     if (distance <= 8000) return @"约8Km";
     if (distance <= 10000) return @"约10Km";
     if (distance <= 15000) return @"约15Km";
     if (distance <= 20000) return @"约20Km";
     if (distance <= 30000) return @"约30Km";
     if (distance <= 50000) return @"约50Km";
     if (distance <= 80000) return @"约80Km";
     if (distance <= 100000) return @"约100Km";
     if (distance <= 200000) return @"约200Km";
     if (distance <= 300000) return @"约300Km";
     if (distance <= 500000) return @"约500Km";
     if (distance <= 800000) return @"约800Km";
     */
    return [NSString stringWithFormat:@"%@%.1fKm",NSLocalizedString(@"B_About", nil), distance / 1000.0];
}

- (BOOL)isEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL) isMobilePhone {
    //NSRegularExpression *phoneRegex = [NSRegularExpression regularExpressionWithPattern:@"^((13[0-9])|(15[^4,\\D])|(18[0-9]))\\d{8}$" options:0 error:nil];
    NSRegularExpression *phoneRegex = [NSRegularExpression regularExpressionWithPattern:@"^1\\d{10}$" options:0 error:nil];
    
    NSTextCheckingResult *phoneMatch = [phoneRegex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    if (phoneMatch) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isCloudNumber {
    if (self.length == 9 && [self intValue] > 100000000) {
        return YES;
    }
    return NO;
}

- (NSString *)getMd5 {
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    
    NSString *immutableStr = [NSString stringWithString: ret];
    return immutableStr;
}

- (NSString *)getMarkAudioName {
    NSString *targetStr = @"";
    if ([self isAudioURLString]) {
        NSArray *array = [self componentsSeparatedByString:@"/"];
        NSString *lastStr = [array lastObject];
        targetStr = [lastStr substringWithRange:NSMakeRange(0, lastStr.length - 4)];
    }
    return targetStr;
}

- (BOOL)isAudioURLString {
    if ([self hasPrefix:@"http"] && ([self hasSuffix:@".amr"] || [self hasSuffix:@".wav"])) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isPhoneNumber {
    if ([self length] < 11) {
        return NO;
    }
    NSString *str = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@""];
    if (str.integerValue < 1000000000) {
        return NO;
    }
    return YES;
}

- (BOOL)isNumberOnly {
    if ([self length] == 0) {
        return NO;
    }
    NSString *regex = @"^[0-9]\\d*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    if (isMatch) {
        return YES;
    }
    return NO;
}
- (BOOL)biggerThan:(NSString*)str{
    NSString *a = [self stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *b = [str  stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [a intValue] > [b intValue];
}

- (NSString *)getCodeByNumberString {
    NSMutableString *targetStr = [NSMutableString stringWithString:@""];
    if ([self isNumberOnly]) {
        int length = self.length;
        for (int i = 0; i < length ; i ++) {
            NSString *num = [self substringWithRange:NSMakeRange(i, 1)];
            [targetStr appendString:[self getCharByNumber:[num integerValue]]];
        }
    } else {
        return nil;
    }
    return [targetStr lowercaseString];
}

- (NSString *)getCharByNumber:(NSInteger)number {
    NSString *str = @"";
    switch (number) {
        case 0:
            str = @"H";
            break;
        case 1:
            str = @"I";
            break;
        case 2:
            str = @"J";
            break;
        case 3:
            str = @"K";
            break;
        case 4:
            str = @"L";
            break;
        case 5:
            str = @"M";
            break;
        case 6:
            str = @"N";
            break;
        case 7:
            str = @"O";
            break;
        case 8:
            str = @"P";
            break;
        case 9:
            str = @"Q";
            break;
        default:
            break;
    }
    return str;
}

- (NSString *)encodeToPercentEscapeString
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return outputStr;
}

- (NSString *)decodeFromPercentEscapeString
{
    NSString *result = (__bridge NSString*)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
    return result;
}

@end