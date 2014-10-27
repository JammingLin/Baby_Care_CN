/*
 *  2014/08/25 - 时间轴内容
 *
 *  0:系统消息
 *
 *  **** 提醒根据时间节点判断进行添删 ****
 *  key:代表该目标ID
 *  1:用户自定义提醒
 *  10:疫苗提醒
 *  11:评测提醒
 *  12:日志提醒
 *  20:生理-身高记录提醒
 *  21:生理-体重记录提醒
 *  22:生理-头围记录提醒
 *
 *  **** 贴士推送 ****
 *  key:代表该贴士ID
 *  99:贴士推送-（根据用户及贴士属性推送）
 *
 */

#import "InitTimeLineData.h"
#import "SyncController.h"
#import "BaseSQL.h"

@implementation InitTimeLineData

+(InitTimeLineData*)initTimeLine
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(void)getTimeLineData{
    /** 检测用户自定义提醒:1 **/
    [self checkUserRemind];
    /** 检测疫苗提醒:10 **/
    [self checkBabyVaccine];
    /** 检测评测提醒:11 **/
    [self checkBabyEvaluating];
    /** 检测日志提醒:12 **/
    [self checkBabyLog];
    /** 检测身高记录提醒:20 **/
    [self checkBabyHeight];
    /** 检测体重记录提醒:21 **/
    [self checkBabyWeight];
    /** 检测头围记录提醒:22 **/
    [self checkBabyHS];
    /** 检测系统消息:0 **/
    [self checkSysMsg];
    
    /** 检测贴士推送:99 **/
    [self checkTips:0];
}

/** 检测系统消息:0 **/
//key = version
-(void)checkSysMsg{
    /*
    int msgType = 0;
    NSString *version = [[NSUserDefaults standardUserDefaults] stringForKey:@"GUIDE_V"];
    if (![[BabyMessageDataDB babyMessageDB] isSysUpdateMsgExist:version]) {
        NSString *msgContent = [NSString stringWithFormat:@"欢迎使用母婴助手%@版本!",version];
        [[BabyMessageDataDB babyMessageDB] insertBabyMessageNormal:[ACDate getTimeStampFromDate:[NSDate date]] UpdateTime:[ACDate getTimeStampFromDate:[NSDate date]] key:version type:msgType content:msgContent];
    }
     */
}

/** 检测用户自定义提醒:1 **/
-(void)checkUserRemind{
    
}

 /** 检测疫苗提醒:10 **
 *  一个疫苗只插入一次消息库
 *  在每5、3、1天的时候提醒只更新消息表库中对应消息的内容及create_time
 *  key:id 疫苗ID
 */
-(void)checkBabyVaccine{
    int msgType = 10;
    NSArray *array = [BaseSQL queryData_vaccine_recent];
    if ([array count] == 0)
        return;
    
    for (int i=0; i<[array count]; i++) {
        NSDictionary *dic = [array objectAtIndex:i];
        int targetId = [[dic objectForKey:@"id"] intValue];
        int days = [[dic objectForKey:@"days"] intValue];
        NSString* vaccinceName = [dic objectForKey:@"vaccine"];
        
        // res:0 该条提醒未入库->入库 | 1 该条提醒已入库->更新 | -1 不需操作
        int res = [[BabyMessageDataDB babyMessageDB] isVaccineExistWithKey:targetId Days:days];
        NSString *msgContent;
        if (days == 0) {
            msgContent = [NSString stringWithFormat:@"今天宝宝要接种%@哦!",vaccinceName];
        }
        else{
            msgContent = [NSString stringWithFormat:@"%d天后宝宝要接种%@哦!",days,vaccinceName];
        }
        
        if (res == 0 || res == 1) {
            [[BabyMessageDataDB babyMessageDB] insertBabyMessageNormal:[ACDate getTimeStampFromDate:[NSDate date]] UpdateTime:[ACDate getTimeStampFromDate:[NSDate date]] key:[NSString stringWithFormat:@"%d",targetId] type:msgType content:msgContent];
        }
    }
}

/** 检测评测提醒:11 **/
/** key:month 月份 **/
-(void)checkBabyEvaluating{
    int msgType = 11;
    NSDictionary *dict = [[BabyDataDB babyinfoDB]selectBabyInfoByBabyId:BABYID];
    long birth_time = [[dict objectForKey:@"birth"] longValue];
    int months = [ACDate getDiffMonthFromBirth:[ACDate getDateFromTimeStamp:birth_time]];
    
    int days = [ACDate getBirthDay:[dict[@"birth"] longValue]];
    
    //当月评测是否未完成
    if (([BaseSQL isFinishTestWithMonth:months] && days >= 25) && [[BabyMessageDataDB babyMessageDB] isTestExistTodayWithKey:months] == 0) {
        NSString *msgContent = [NSString stringWithFormat:@"宝宝第%d月的评测开始啦!",months];
        [[BabyMessageDataDB babyMessageDB] insertBabyMessageNormal:[ACDate getTimeStampFromDate:[NSDate date]] UpdateTime:[ACDate getTimeStampFromDate:[NSDate date]] key:[NSString stringWithFormat:@"%d",months] type:msgType content:msgContent];
    }
}
/** 检测日志提醒:12 **/
/** key=nil **/
-(void)checkBabyLog{
    int msgType = 12;
    if (![BaseSQL isNoteRecent] && [[BabyMessageDataDB babyMessageDB] isNoteRemind]) {
        NSString *msgContent = @"好久没有记录日志啦,麻麻快点把心情记录下来呗?";
        [[BabyMessageDataDB babyMessageDB] insertBabyMessageNormal:[ACDate getTimeStampFromDate:[NSDate date]] UpdateTime:[ACDate getTimeStampFromDate:[NSDate date]] key:@"" type:msgType content:msgContent];
    }
}
/** 检测身高记录提醒:20 **/
-(void)checkBabyHeight{
    int msgType = 20;
    NSArray *arrHeight = [[BabyDataDB babyinfoDB] selectBabyPhysiologyList:0];
    NSDictionary *dic = [arrHeight firstObject];
    NSDate *lastRecordDate = [ACDate getDateFromTimeStamp:[[dic objectForKey:@"measure_time"] longValue]];
    
    NSDictionary *dicBabyInfo = [[BabyDataDB babyinfoDB]selectBabyInfoByBabyId:BABYID];
    int days = [ACDate getBirthDay:[dicBabyInfo[@"birth"] longValue]];
    
    //case 1:phyHeight表中该月没有记录
    if ([ACDate getDiffMonthFromDate:lastRecordDate] != 0)//该月无记录
    {
        //case 2:本月最后5天且当天未提醒
        if (days >= 25 && ([[BabyMessageDataDB babyMessageDB] isPhyExistTodayWithType:msgType] == 0)) {
            NSString *msgContent = @"本月尚未记录宝宝身高,要记得哦!";
            [[BabyMessageDataDB babyMessageDB] insertBabyMessageNormal:[ACDate getTimeStampFromDate:[NSDate date]] UpdateTime:[ACDate getTimeStampFromDate:[NSDate date]] key:@"" type:msgType content:msgContent];
        }
    }
}
/** 检测体重记录提醒:21 **/
-(void)checkBabyWeight{
    int msgType = 21;
    NSArray *arrHeight = [[BabyDataDB babyinfoDB] selectBabyPhysiologyList:1];
    NSDictionary *dic = [arrHeight firstObject];
    NSDate *lastRecordDate = [ACDate getDateFromTimeStamp:[[dic objectForKey:@"measure_time"] longValue]];
    NSDictionary *dicBabyInfo = [[BabyDataDB babyinfoDB]selectBabyInfoByBabyId:BABYID];
    int days = [ACDate getBirthDay:[dicBabyInfo[@"birth"] longValue]];
    //case 1:phyHeight表中该月没有记录
    if ([ACDate getDiffMonthFromDate:lastRecordDate] != 0)//该月无记录
    {
        //case 2:本月最后5天且当天未提醒
        if (days >= 25 && ([[BabyMessageDataDB babyMessageDB] isPhyExistTodayWithType:msgType]==0)) {
            NSString *msgContent = @"本月尚未记录宝宝体重,要记得哦!";
            [[BabyMessageDataDB babyMessageDB] insertBabyMessageNormal:[ACDate getTimeStampFromDate:[NSDate date]] UpdateTime:[ACDate getTimeStampFromDate:[NSDate date]] key:@"" type:msgType content:msgContent];
        }
    }
}
/** 检测头围记录提醒:22 **/
-(void)checkBabyHS{
    return;
}

#pragma 同步贴士
/** 检测贴士推送:99 **/
-(void)checkTips:(long)date{
    /*
     *  获取5条数据，判断之前4天的贴士插入情况。
     *  如果在4天内的每12点、18点整不存在数据，则插入贴士
     */
    int msgType = 99;
    long lastCreateTime = [[BabyMessageDataDB babyMessageDB] getMsgTipLastCreateTime];
    int months = [self getbabyMonths];
    
    [[SyncController syncController] getTipsHome:ACCOUNTUID
                                  LastCreateTime:lastCreateTime
                                      BabyMonths:months
                                             HUD:_hud
                                    SyncFinished:^(NSArray *retArr)
    {
        //取出获取到数据的ids
        int iArrCount = [retArr count];
        if (iArrCount !=0){
            NSArray *insertTimeList = [self getLastMsgTipInsertTime:date];
            
            for (int i = 0; i < iArrCount; i++) {
                NSDictionary *dict = [retArr objectAtIndex:i];
                NSString *msgContent = [dict objectForKey:@"title"];
                //key格式:categoryId|tipId
                NSString *key = [NSString stringWithFormat:@"%d,%d",[[dict objectForKey:@"category_id"] intValue],[[dict objectForKey:@"tipId"] intValue]];
                NSString *picUrl = [dict objectForKey:@"picUrl"];
                
                long insertCreateTime = [[BabyMessageDataDB babyMessageDB] getMsgTipLastInsertCreateTime:insertTimeList];
                
                if (insertCreateTime != 0) {
                    [[BabyMessageDataDB babyMessageDB] insertBabyMessageTip:insertCreateTime UpdateTime:[[dict objectForKey:@"update_time"] longValue] key:key type:msgType content:msgContent picUrl:picUrl];
                }
                else {
                    break;
                }
            } 
        }
        [_delegate willRefreshTimeLine];
    }
                                  ViewController:_targetViewController];
}

#pragma 获取贴士的后5个消息的插入时间点-返回0表示不需插入
-(NSArray*)getLastMsgTipInsertTime:(long)timeNow
{
    if (timeNow == 0) {
        timeNow = [ACDate getTimeStampFromDate:[NSDate date]];
    }
    
    NSDate *time=[ACDate getDateFromTimeStamp:timeNow];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps=[calendar components:unitFlags fromDate:time];
    
    long time12 = 12*3600;
    long time18 = 18*3600;
    long now = [comps hour]*3600 + [comps minute]*60 + [comps second];
    
    NSString *strdate12 = [NSString stringWithFormat:@"%d-%d-%d 12:00:00",[comps year],[comps month],[comps day]];
    NSDateFormatter *formater=[[NSDateFormatter alloc]init];
    [formater setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    long date12 = [ACDate getTimeStampFromDate:[formater dateFromString:strdate12]];
    
    NSMutableArray *timeArr = [[NSMutableArray alloc] initWithCapacity:5];
    long date=0;
    if (now < time12) {
        //-18小时
        date = date12 - 18*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-6
        date = date - 6*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-18
        date = date - 18*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-6
        date = date - 6*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-18
        date = date - 18*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
    }
    else if (time12 <= now < time18){
        //12点
        date = date12;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-18
        date = date - 18*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-6
        date = date - 6*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-18
        date = date - 18*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-6
        date = date - 6*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
    }
    else if (time18 <= now){
        //18点
        date = date12;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-6
        date = date - 6*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-18
        date = date - 18*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-6
        date = date - 6*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
        //-18
        date = date - 18*3600;
        [timeArr addObject:[NSNumber numberWithLong:date]];
    }
    
    return timeArr;
}

- (int)getbabyMonths
{
    long birth = 0;
    NSDictionary *dict = [[BabyDataDB babyinfoDB]selectBabyInfoByBabyId:BABYID];
    if ([[dict objectForKey:@"birth"] intValue] != 0){
        birth = [[dict objectForKey:@"birth"] longValue];
    }
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
    if ([comps year] == 0 && [comps month] == 0) {
        return 1;
    }
    else if ([comps year] ==0 && [comps month] != 0)
    {
        return [comps month] + 1;
    }
    else if ([comps year] !=0 && [comps month] == 0)
    {
        return [comps year] * 12;
    }
    else if ([comps year] !=0 && [comps month] != 0)
    {
        return [comps year] * 12 + [comps month] + 1;
    }
    else{
        return 0;
    }
}


#pragma mark 完成提醒事项后处理
-(void)refreshByFinishItemsWithTypeID:(int)typeID
                              ProTime:(long)proTime
                                  Key:(NSString*)key
                              Content:(NSString*)content{
    //**  step1:删除消息表中关于该事项的提醒  **
    //**  step2:添加消息表完成该事项的记录  **
    
    NSString *msg_key;
    switch (typeID) {
        case 10:
            //删除测疫苗提醒10:delete msg_type=10 and key=key
            [[BabyMessageDataDB babyMessageDB]deleteBabyMessageWithTypeID:typeID Key:key];
            //添加消息
            msg_key = [NSString stringWithFormat:@"已完成|%@",key];
            [[BabyMessageDataDB babyMessageDB] insertBabyMessageNormal:[ACDate getTimeStampFromDate:[NSDate date]] UpdateTime:[ACDate getTimeStampFromDate:[NSDate date]] key:msg_key type:typeID content:content];
            break;
        case 11 : case 12 : case 20 :case 21:
            //删除评测提醒11:delete msg_type=11 and key not like "已完成%"
            [[BabyMessageDataDB babyMessageDB]deleteBabyMessageWithoutDone:typeID];
            //添加消息
            msg_key = [NSString stringWithFormat:@"已完成|%@",key];
            [[BabyMessageDataDB babyMessageDB] insertBabyMessageNormal:[ACDate getTimeStampFromDate:[NSDate date]] UpdateTime:[ACDate getTimeStampFromDate:[NSDate date]] key:msg_key type:typeID content:content];
            break;
        default:
            break;
    }
    
    //**  step3:删除时间轴TableView中该条提醒记录  **
    //**  step4:添加时间轴tableview中完成事项的记录  **
    
    //判断tableview是否为空
    if (self.delegate != nil) {
        switch (typeID) {
            case 10 : case 11:
                [self.delegate willDeleteMsgsWithTypeID:typeID Key:key];
                break;
            case 12: case 20 : case 21:
                [self.delegate willDeleteMsgsWithTypeID:typeID Key:@""];
            default:
                break;
        }
        
        //刷新时间轴
        [self.delegate willInsertMsg];
    }
    
}

@end
