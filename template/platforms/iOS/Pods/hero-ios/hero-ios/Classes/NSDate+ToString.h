//
//  NSDate+ToString.h
//  CloudKnows
//
//  Created by clwang on 13-7-22.
//  Copyright (c) 2013年 atman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"
@interface NSDate (ToString)

- (NSString *)gettime;
- (NSString *)getDate;
- (NSString *)getDateMMdd;
+ (NSString *)getDateForMarkReply:(NSTimeInterval) sendTime;
/**
 *	@brief	根据出生日期计算年龄
 *  @param  birthday    出生日期
 */
- (NSString *)getAgeByBirthdayString:(NSString *)birthday;

- (NSString *)getCreateMarkDateForNew;

/**
 根据时间返回下拉刷新的信息
 */
- (NSString *)getEGOLastUpdateInfo;

+ (NSString *)getDateMMdd:(NSTimeInterval)sendTime;
+ (NSString *)getDateHHmm:(NSTimeInterval)sendTime;

/**
 返回系统时间作为录音的一部分名称
 */
- (NSString *)getDateStringForRecord;

/**
 *  获取时间字符串作为动态时间显示
 *
 *  @return 时间字符串
 */
- (NSString *)getDateForTrends;
/**
 *  返回时间字符串：2014.03.06
 *
 *  @return 时间字符串
 */
- (NSString *)getDateStringAsPointYYYYMMDD;
- (NSString *)getDateForDaily;

@end
