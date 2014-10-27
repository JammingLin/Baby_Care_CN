//
//  ACDate.m
//  ACBase
//
//  Created by @Arvi@ on 14-3-19.
//  Copyright (c) 2014年 com.amoycare. All rights reserved.
//

#import "ACDate.h"

@implementation ACDate
+(NSDate*)date
{
    NSDate *date = [NSDate date];
    return date;
}

+(NSString*)durationFormat
{
    NSDate *date=[[NSUserDefaults standardUserDefaults] objectForKey:@"timerOn"];
    if (date == nil) {
        return @"00:00:00";
    }
    //NSLog(@"durationFormat %@", date);
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMinuteCalendarUnit|NSSecondCalendarUnit|NSHourCalendarUnit;
    comps=  [calendar components:unitFlags fromDate:date toDate:[self date] options:0];
    return [NSString stringWithFormat:@"%02d:%02d:%02d",[comps hour],[comps minute],[comps second]];
}
+(int)getDurationfromdate:(NSString*)fomaterdate
{
    //NSLog(@"%@",fomaterdate);
    NSDateFormatter *fomatter=[[NSDateFormatter alloc]init];
    [fomatter setLocale:[NSLocale currentLocale]];
    [fomatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[fomatter dateFromString:fomaterdate];
    //NSLog(@"%@",date);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit|NSDayCalendarUnit;
    comps=  [calendar components:unitFlags fromDate:date toDate:[ACDate date] options:0];
    return [comps month];
    
}

+(NSString*)getdateFormat
{
    NSDate *time=[self getStarttime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit;
    //NSLog(@"getdateformat : %@", time);
    comps=[calendar components:unitFlags fromDate:time];
    
    NSString *week;
    switch ([comps weekday]) {
        case 1:
            week=NSLocalizedString(@"Sunday", nil);
            break;
        case 2:
            week=NSLocalizedString(@"Monday", nil);
            break;
        case 3:
            week=NSLocalizedString(@"Tuesday", nil);
            break;
        case 4:
            week=NSLocalizedString(@"Wednesday", nil);
            break;
        case 5:
            week=NSLocalizedString(@"Thursday", nil);
            break;
        case 6:
            week=NSLocalizedString(@"Friday", nil);
            break;
        case 7:
            week=NSLocalizedString(@"Saturday", nil);
            break;
            
        default:
            break;
    }
    //NSLog(@"%@",week);
    return [NSString stringWithFormat:@"%@ %02d/%02d",week,[comps day],[comps month]];;
}

+(NSString *)getStarttimefromdate:(NSDate*)date
{
    NSDateFormatter *formater=[[NSDateFormatter alloc]init];
    
    [formater setDateFormat:@"HH:mm"];
    
    return [formater stringFromDate:date];
}

+(NSString *)getDurationfromdate:(NSDate*)date second:(int)second
{
    
    NSDate *datefuture=[date dateByAddingTimeInterval:second];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMinuteCalendarUnit|NSSecondCalendarUnit|NSHourCalendarUnit;
    comps=  [calendar components:unitFlags fromDate:date toDate:datefuture options:0];
    return [NSString stringWithFormat:@"%02d:%02d:%02d",[comps hour],[comps minute],[comps second]];
    
}

+(NSString *)dateFomatdate:(NSDate*)date
{
    //NSLog(@"date  %@",date);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit;
    
    comps=[calendar components:unitFlags fromDate:date];
    NSString *week;
    switch ([comps weekday]) {
        case 1:
            week=NSLocalizedString(@"Sunday", nil);
            break;
        case 2:
            week=NSLocalizedString(@"Monday", nil);
            break;
        case 3:
            week=NSLocalizedString(@"Tuesday", nil);
            break;
        case 4:
            week=NSLocalizedString(@"Wednesday", nil);
            break;
        case 5:
            week=NSLocalizedString(@"Thursday", nil);
            break;
        case 6:
            week=NSLocalizedString(@"Friday", nil);
            break;
        case 7:
            week=NSLocalizedString(@"Saturday", nil);
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %02d/%02d",week,[comps day],[comps month]];;
}

+(NSString *)dateDetailFomatdate:(NSDate*)date
{
    //NSLog(@"date  %@",date);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
    
    comps=[calendar components:unitFlags fromDate:date];
    NSString *week;
    switch ([comps weekday]) {
        case 1:
            week=NSLocalizedString(@"Sunday", nil);
            break;
        case 2:
            week=NSLocalizedString(@"Monday", nil);
            break;
        case 3:
            week=NSLocalizedString(@"Tuesday", nil);
            break;
        case 4:
            week=NSLocalizedString(@"Wednesday", nil);
            break;
        case 5:
            week=NSLocalizedString(@"Thursday", nil);
            break;
        case 6:
            week=NSLocalizedString(@"Friday", nil);
            break;
        case 7:
            week=NSLocalizedString(@"Saturday", nil);
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %02d/%02d %02d:%02d",week,[comps month],[comps day],[comps hour],[comps minute]];;
}

#pragma return:08-31 14:00
+(NSString *)dateDetailFomatdate2:(NSDate*)date
{
    //NSLog(@"date  %@",date);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
    
    comps=[calendar components:unitFlags fromDate:date];
    
    return [NSString stringWithFormat:@"%02d-%02d %02d:%02d",[comps month],[comps day],[comps hour],[comps minute]];
}

#pragma return:星期三 2014-08-31
+(NSString *)dateDetailFomatdate3:(NSDate*)date
{
    //NSLog(@"date  %@",date);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
    
    comps=[calendar components:unitFlags fromDate:date];
    NSString *week;
    switch ([comps weekday]) {
        case 1:
            week=NSLocalizedString(@"Sunday", nil);
            break;
        case 2:
            week=NSLocalizedString(@"Monday", nil);
            break;
        case 3:
            week=NSLocalizedString(@"Tuesday", nil);
            break;
        case 4:
            week=NSLocalizedString(@"Wednesday", nil);
            break;
        case 5:
            week=NSLocalizedString(@"Thursday", nil);
            break;
        case 6:
            week=NSLocalizedString(@"Friday", nil);
            break;
        case 7:
            week=NSLocalizedString(@"Saturday", nil);
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %02d-%02d-%02d",week,[comps year],[comps month],[comps day]];
}

+(NSString*)getDayBeforeDespFromDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =NSDayCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSHourCalendarUnit;
    comps=  [calendar components:unitFlags fromDate:date toDate:[ACDate date] options:nil];
    if ([comps day] >0) {
        return [NSString stringWithFormat:NSLocalizedString(@"DayTips", nil),[comps day]];
    }
    else if ([comps hour]>0) {
        return [NSString stringWithFormat:NSLocalizedString(@"HourTips", nil),[comps hour]];
    }
    else if ([comps minute]>0) {
        return [NSString stringWithFormat:NSLocalizedString(@"MinuteTips", nil),[comps minute]];
    }
    else if ([comps second]>0) {
        return [NSString stringWithFormat:NSLocalizedString(@"SecondTips", nil),[comps second]];
    }
    else
    {
        return @"";
    }

}

+(NSString*)getDaySinceDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =NSDayCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSHourCalendarUnit;
    comps=  [calendar components:unitFlags fromDate:date toDate:[ACDate date] options:nil];
    if ([comps day] >999)
    {
        return @"N年前";
    }
    else if ([comps day]>0)
    {
        return [NSString stringWithFormat:NSLocalizedString(@"DayTips", nil),[comps day]];
    }
    else{
        return @"今天";
    }
}

+(NSString*)getMsgTimeSinceDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSHourCalendarUnit;
    comps=  [calendar components:unitFlags fromDate:date toDate:[ACDate date] options:nil];
    if ([comps year] > 0)
    {
        return [NSString stringWithFormat:@"%d年前",[comps year]];
    }
    else if([comps month] > 0){
        return [NSString stringWithFormat:@"%d月前",[comps month]];
    }
    else if([comps day] > 0){
        return [NSString stringWithFormat:@"%d天前",[comps day]];
    }
    else if([comps hour] > 0){
        return [NSString stringWithFormat:@"%d小时前",[comps hour]];
    }
    else if([comps minute] > 0){
        return [NSString stringWithFormat:@"%d分钟前",[comps minute]];
    }
    else{
        return @"现在";
    }
}

+(NSDate*)getStarttime
{
    NSDate *date=[[NSUserDefaults standardUserDefaults] objectForKey:@"timerOn"];
    return date;
}

+(int)getMonth
{
    NSDate *time=[self getStarttime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps month];
} 

+ (int)getday:(NSDate*) date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    return [comps day];
}

+(int)getWeek
{
    NSDate *time=[self getStarttime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =NSWeekCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps week];
}
+(int)getWeekDay
{
    NSDate *time=[self getStarttime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSWeekdayCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps weekday];
}

+(int)getMonthFromDate:(NSDate*) date{
    NSDate *time=date;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps month];
}

+(int)getWeekFromDate:(NSDate*) date
{
    NSDate *time=date;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =NSWeekCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps week];
}

+(int)getWeekDayFromDate:(NSDate*) date
{
    NSDate *time=date;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSWeekdayCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps weekday];
}

+(NSString*)getStarttimeFormat
{
    NSDate *time=[self getStarttime];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"HH:MM"];
    
    
    return [formatter stringFromDate:time];
    
}


+(int)getCurrentMonth
{
    NSDate *time=[self date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps month];
}
+(int)getCurrentWeek
{
    NSDate *time=[self date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =NSWeekCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps week];
}

+(int)getEarlyWeek:(NSDate*) time
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =NSWeekCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps week];
}

+(int)getCurrentHour
{
    NSDate *time=[self date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSHourCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps hour];
}

+(int)getCurrentWeekDay
{
    NSDate *time=[self date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSWeekdayCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps weekday];
}

+(int)getCurrentYear{
    NSDate *time=[self date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    return [comps year];
}

+(NSString *)dateForSummaryList:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit| NSMinuteCalendarUnit;
    comps=[calendar components:unitFlags fromDate:date];
    NSDateFormatter *formater=[[NSDateFormatter alloc]init];
    [formater setDateFormat:@"MMM.d"];
    NSString *day=[formater stringFromDate:date];
    if ([day hasSuffix:@"1"]) {
        day=[NSString stringWithFormat:@"%@st  ",day];
    }
    else if ([day hasSuffix:@"2"])
    {
        day=[NSString stringWithFormat:@"%@nd  ",day];
    }
    else if([day hasSuffix:@"3"])
    {
        day=[NSString stringWithFormat:@"%@rd  ",day];
    }
    else
    {
        day=[NSString stringWithFormat:@"%@th  ",day];
    }
    [formater setDateFormat:@" HH:mm"];
    day=[NSString stringWithFormat:@"%@%@",day,[formater stringFromDate:date]];
    
    
    
    return day;
}

+(NSDate *) dateFromString:(NSString *)dateString
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
    
}

+(NSDate *) dateFromStringCN:(NSString *)dateString
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy年MM月dd日"];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
    
}

+(NSDate*)getNewDateFromOldDate:(NSDate*)newdate andOldDate:(NSDate*)olddate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *oldcomp1 = [calendar components:units fromDate:olddate];
    NSInteger oldhour = [oldcomp1 hour];
    NSInteger oldmin  = [oldcomp1 minute];
    NSInteger oldsec  = [oldcomp1 second];
    
    
    NSDateComponents *newcomp = [calendar components:units fromDate:newdate];
    NSInteger year   = [newcomp year];
    NSInteger month  = [newcomp month];
    NSInteger day    = [newcomp day];
    
    NSString* str = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",year,month,day,oldhour,oldmin,oldsec];
    return [self dateFromString:str];
}

+(NSDate*)getNewDateFromOldTime:(NSDate*)newdate andOldDate:(NSDate*)olddate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *oldcomp1 = [calendar components:units fromDate:olddate];
    NSInteger oldYear = [oldcomp1 year];
    NSInteger oldMonth  = [oldcomp1 month];
    NSInteger oldDay  = [oldcomp1 day];
    
    
    NSDateComponents *newcomp = [calendar components:units fromDate:newdate];
    NSInteger hour   = [newcomp hour];
    NSInteger min  = [newcomp minute];
    NSInteger sec    = [newcomp second];
    
    NSString* str = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",oldYear,oldMonth,oldDay,hour,min,sec];
    return [self dateFromString:str];
}

+ (NSString*)getWeekBeginAndEndWith:(NSDate *)newDate
{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];//设定周日为周首日
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return nil;
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"MM.dd"];
    NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    NSString *endString = [myDateFormatter stringFromDate:endDate];
    
    return [NSString stringWithFormat:@"%@~%@",beginString,endString];
}

+ (NSString*)getMonthBeginAndEndWith:(NSDate *)newDate
{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];//设定周日为周首日
    BOOL ok = [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return nil;
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    NSString *endString = [myDateFormatter stringFromDate:endDate];
    
    return [NSString stringWithFormat:@"%@~%@",beginString,endString];
    
}

+(long)getTimeStampFromDate:(NSDate*)date
{
    return [[NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]] intValue];
}

+(NSDate*)getDateFromTimeStamp:(long)timestamp
{
    return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)timestamp];
}


//strDate格式 - 2014年06年12日
+(int)getDiffFormNowToDateCN:(NSString*)strDate
{
    if (strDate == nil) {
        return 0;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSRange range;
    range.length = 1;
    range.location = 4;
    NSMutableString *mstrDate = [NSMutableString stringWithString:strDate];
    [mstrDate replaceCharactersInRange:range withString:@"-"];
    range.location = 7;
    [mstrDate replaceCharactersInRange:range withString:@"-"];
    range.location = 10;
    [mstrDate replaceCharactersInRange:range withString:@""];
    
    NSDate *now=[NSDate date];
    now = [dateFormatter dateFromString:[dateFormatter stringFromDate:now]];
    NSDate *target = [dateFormatter dateFromString:mstrDate];
    
    //得到相差秒数
    NSTimeInterval time=[target timeIntervalSinceDate:now];
    
    int days = ((int)time)/(3600*24);
    
    return days;
}

+(int)getDiffDayFormNowToDate:(NSDate*)date{
    //得到相差秒数
    NSTimeInterval time=[date timeIntervalSinceDate:[NSDate date]];
    int days = ((int)time)/(3600*24);
    return days;
}

+(int)getDiffMonthFromBirth:(NSDate*)birthDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
    NSDateComponents *birthComps = [calendar components:units fromDate:birthDate];
    NSDateComponents *nowComps = [calendar components:units fromDate:[NSDate date]];
    //婴儿计算月份需要+1
    return ([nowComps year] - [birthComps year]) * 12 + ([nowComps month] - [birthComps month]) + 1;
}

+(int)getDiffMonthFromDate:(NSDate*)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
    NSDateComponents *dateComps = [calendar components:units fromDate:date];
    NSDateComponents *nowComps = [calendar components:units fromDate:[NSDate date]];
    //婴儿计算月份需要+1
    return ([nowComps year] - [dateComps year]) * 12 + ([nowComps month] - [dateComps month]);
}

#pragma mark 获取出生日数文本
+(NSString*)getBabyBirthOfDaysStr:(long)birth
{
    //时间戳转date
    NSDate *birthDate = [ACDate getDateFromTimeStamp:birth];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSString *age = [dateFormatter stringFromDate:birthDate];
    
    NSDateFormatter *fomatter=[[NSDateFormatter alloc]init];
    [fomatter setLocale:[NSLocale currentLocale]];
    [fomatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[fomatter dateFromString:age];
    //NSLog(@"getbabyage: %@",date);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    comps=  [calendar components:unitFlags fromDate:date toDate:[ACDate date] options:nil];
    if ([comps year] == 0 && [comps month] == 0 && [comps day]==0) {
        return @"1天";
    }
    else if ([comps year]==0 && [comps month] == 0)
    {
        return [NSString stringWithFormat:@"%d天",[comps day]];
    }
    else if ([comps year]==0)
    {
        if  ([comps day] == 0){
            return [NSString stringWithFormat:@"%d月",[comps month]];
        }
        else{
        return [NSString stringWithFormat:@"%d月%d天",[comps month],[comps day]];
        }
    }
    else if ([comps year]!=0 && [comps month] == 0 && [comps day] != 0){
        return [NSString stringWithFormat:@"%d岁%d天",[comps year],[comps day]];
    }
    else if ([comps year]!=0 && [comps month] == 0 && [comps day] == 0){
        return [NSString stringWithFormat:@"%d岁整",[comps year]];
    }
    else if ([comps year]!=0 && [comps month] != 0 && [comps day] == 0){
        return [NSString stringWithFormat:@"%d岁%d月",[comps year],[comps month]];
    }
    else
    {
        return [NSString stringWithFormat:@"%d岁%d月\n%d天",[comps year],[comps month],[comps day]];
    }
    
}

#pragma mark 获取出生的日数
+(int)getBirthDay:(long)birth
{
    //时间戳转date
    NSDate *birthDate = [ACDate getDateFromTimeStamp:birth];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSString *age = [dateFormatter stringFromDate:birthDate];
    
    NSDateFormatter *fomatter=[[NSDateFormatter alloc]init];
    [fomatter setLocale:[NSLocale currentLocale]];
    [fomatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[fomatter dateFromString:age];
    //NSLog(@"getbabyage: %@",date);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    comps=  [calendar components:unitFlags fromDate:date toDate:[ACDate date] options:nil];
    return [comps day];
    
}

+(int)getBirthMonth:(long)birth
{
    //时间戳转date
    NSDate *birthDate = [ACDate getDateFromTimeStamp:birth];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSString *age = [dateFormatter stringFromDate:birthDate];
    
    NSDateFormatter *fomatter=[[NSDateFormatter alloc]init];
    [fomatter setLocale:[NSLocale currentLocale]];
    [fomatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[fomatter dateFromString:age];
    //NSLog(@"getbabyage: %@",date);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    comps=  [calendar components:unitFlags fromDate:date toDate:[ACDate date] options:nil];
    return [comps month] + 1;
    
}


@end
