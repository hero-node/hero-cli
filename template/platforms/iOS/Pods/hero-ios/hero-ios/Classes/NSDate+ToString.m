//
//  NSDate+ToString.m
//  CloudKnows
//
//  Created by clwang on 13-7-22.
//  Copyright (c) 2013年 atman. All rights reserved.
//

#import "NSDate+ToString.h"

@implementation NSDate (ToString)

+ (NSString *)getDateMMdd:(NSTimeInterval)sendTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:sendTime]];
}

+ (NSString *)getDateHHmm:(NSTimeInterval)sendTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:sendTime]];
}

- (NSString *)gettime
{
    if (self.timeIntervalSince1970 < 1392428) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:self];
    
}
- (NSString *)getDateMMdd
{
    if (self.timeIntervalSince1970 < 1392428) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    return [dateFormatter stringFromDate:self];
}
- (NSString *)getDate
{
    if (self.timeIntervalSince1970 < 1392428) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)getCreateMarkDateForNew {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM.dd HH:mm"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter stringFromDate:self];
}

+ (NSString *)getDateForMarkReply:(NSTimeInterval) sendTime {
    NSDate *sendDate = [NSDate dateWithTimeIntervalSince1970:sendTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:self]];
    NSDate *sendDate2 = [dateFormatter dateFromString:[dateFormatter stringFromDate:sendDate]];
    NSInteger dayCount = ([currentDate timeIntervalSince1970] - [sendDate2 timeIntervalSince1970]) / (24 * 3600);
    NSString *preFix = @"";
    switch (dayCount) {
        case 0:
            preFix = NSLocalizedString(@"B_Today", nil);
            [dateFormatter setDateFormat:@"HH:mm"];
            break;
        case 1:
            preFix = NSLocalizedString(@"B_Yesterday", nil);
            [dateFormatter setDateFormat:@"HH:mm"];
            break;
        case 2:
            preFix = NSLocalizedString(@"B_BeYesterday", nil);
            [dateFormatter setDateFormat:@"HH:mm"];
            break;
        default:
            [dateFormatter setDateFormat:@"yyyy.MM.dd"];
            break;
    }
    DLog(@"****** %@", [dateFormatter stringFromDate:sendDate]);
    return [NSString stringWithFormat:@"%@ %@",preFix,[dateFormatter stringFromDate:sendDate]];
}

/*
 根据给出的出生年月计算出年龄
 */
- (NSString *)getAgeByBirthdayString:(NSString *)birthday {
    if (birthday == nil || birthday.length != @"yyyy-MM-dd".length) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSString *currentDate = [dateFormatter stringFromDate:self];
    NSArray *birthDayArr = [birthday componentsSeparatedByString:@"-"];
    NSArray *currentDateArr = [currentDate componentsSeparatedByString:@"-"];
    int userAge = [[currentDateArr objectAtIndex:0] intValue] - [[birthDayArr objectAtIndex:0] intValue];
    int monthDec = [[currentDateArr objectAtIndex:1] intValue] - [[birthDayArr objectAtIndex:1] intValue];
    if (monthDec == 0) {
        int dayDec = [[currentDateArr objectAtIndex:2] intValue] - [[birthDayArr objectAtIndex:2] intValue];
        if (dayDec == 0) {
            return [NSString stringWithFormat:@"%d", userAge];
        }
        /*
         birthday:1990/09/01
         today   :2013/09/06
         age     :23
         */
        else if (dayDec > 0) {
            return [NSString stringWithFormat:@"%d", userAge];
        }
        /*
         birthday:1990/09/22
         today   :2013/09/06
         age     :22
         */
        else if (dayDec < 0) {
            return [NSString stringWithFormat:@"%d", --userAge];
        }
        
    }
    /*
     birthday:1990/01/01
     today   :2013/09/06
     age     :23
     */
    else if (monthDec > 0) {
        return [NSString stringWithFormat:@"%d", userAge];
    
    }
    /*
     birthday:1990/10/01
     today   :2013/09/06
     age     :22
     */
    else {
        return [NSString stringWithFormat:@"%d", --userAge];
    }
    return [NSString stringWithFormat:@"%d", userAge];
}

#define aMinute         60
#define anHour          3600
#define aDay            86400
#define aMonth          2592000

- (NSString *)getEGOLastUpdateInfo {
    
    NSString *targetString = @"";
    
    NSTimeInterval timeSinceLastUpdate = [self timeIntervalSinceNow];
    NSInteger timeToDisplay = 0;
    timeSinceLastUpdate *= -1;
    
    if (timeSinceLastUpdate < anHour) {
        if (timeSinceLastUpdate < 60) {
            targetString = NSLocalizedString(@"B_LastRefreshG", nil);
        } else {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMinute);
            targetString = [NSString stringWithFormat:@"%@: %tu%@",NSLocalizedString(@"B_LastRefresha", nil), (long)timeToDisplay,NSLocalizedString(@"HP_MinuteAgo", nil)];
        }
    } else if (timeSinceLastUpdate < aDay) {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / anHour);
        targetString = [NSString stringWithFormat:@"%@: %tu%@",NSLocalizedString(@"B_LastRefresha", nil), (long)timeToDisplay,NSLocalizedString(@"HP_HourAgo", nil)];
    } else if (timeSinceLastUpdate < aMonth) {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / aDay);
        targetString = [NSString stringWithFormat:@"%@: %tu%@",NSLocalizedString(@"B_LastRefresha", nil), (long)timeToDisplay,NSLocalizedString(@"HP_DayAgo", nil)];
    } else {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMonth);
        targetString = [NSString stringWithFormat:@"%@: %tu%@",NSLocalizedString(@"B_LastRefresha", nil), (long)timeToDisplay,NSLocalizedString(@"HP_MonthAgo", nil)];
    }
    return targetString;
}

- (NSString *)getDateForTrends {
    NSString *targetString = @"";
    
    NSTimeInterval timeSinceLastUpdate = [self timeIntervalSinceNow];
    NSInteger timeToDisplay = 0;
    timeSinceLastUpdate *= -1;
    
    if (timeSinceLastUpdate < anHour) {
        if (timeSinceLastUpdate < 60) {
            targetString = NSLocalizedString(@"HP_Just", nil);
        } else {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMinute);
            targetString = [NSString stringWithFormat:@"%tu%@", (long)timeToDisplay,NSLocalizedString(@"HP_MinuteAgo", nil)];
        }
    } else if (timeSinceLastUpdate < aDay) {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / anHour);
        targetString = [NSString stringWithFormat:@"%tu%@", (long)timeToDisplay,NSLocalizedString(@"HP_HourAgo", nil)];
    } else if (timeSinceLastUpdate < aMonth) {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / aDay);
        targetString = [NSString stringWithFormat:@"%tu%@", (long)timeToDisplay,NSLocalizedString(@"HP_DayAgo", nil)];
    } else {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMonth);
        targetString = [NSString stringWithFormat:@"%tu%@", (long)timeToDisplay,NSLocalizedString(@"HP_MonthAgo", nil)];
    }
    return targetString;
}
- (NSString *)getDateForDaily {
    NSString *targetString = @"";
    NSTimeInterval timeSinceLastUpdate = [self timeIntervalSinceNow];
    NSInteger timeToDisplay = 0;
    timeSinceLastUpdate *= -1;
    if (timeSinceLastUpdate < anHour) {
        if (timeSinceLastUpdate < 60) {
            targetString = NSLocalizedString(@"HP_Just", nil);
        } else {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMinute);
            targetString = [NSString stringWithFormat:@"%tu%@", (long)timeToDisplay,NSLocalizedString(@"HP_MinuteAgo", nil)];
        }
    } else if (timeSinceLastUpdate < aDay) {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / anHour);
        targetString = [NSString stringWithFormat:@"%tu%@", (long)timeToDisplay,NSLocalizedString(@"HP_HourAgo", nil)];
    } else if (timeSinceLastUpdate < 86400) {
        targetString = NSLocalizedString(@"B_Yesterday", nil);
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy.MM.dd"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        return [dateFormatter stringFromDate:self];
    }
    return targetString;
}

- (NSString *)getDateStringForRecord {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy_MM_dd_hh_mm_ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)getDateStringAsPointYYYYMMDD {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy.MM.dd"];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    return [df stringFromDate:self];
}

@end
