//
//  DataBase.h
//  Parenting
//
//  Created by user on 13-5-28.
//  Copyright (c) 2013年 家明. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBase : NSObject

typedef enum{
    Play,
    Dath,
    Feed,
    Sleep,
    Diaper
}tableName;

+(id)dataBase;
-(BOOL)insertfeedStarttime:(NSDate*)starttime
                 Month:(int)month
                  Week:(int)week
                WeekDay:(int)weekday
              Duration:(int)duration
               Feedway:(int)feedway
                OzorLR:(NSString*)ozorlr
                Remark:(NSString*)remark;

-(BOOL)insertdiaperStarttime:(NSDate*)starttime
                 Month:(int)month
                  Week:(int)week
               WeekDay:(int)weekday
                Status:(NSString*)status
                 Color:(NSString*)color
                  Hard:(NSString*)hard 
                Remark:(NSString*)remark
            UploadTime:(NSDate*)uploadtime;

-(BOOL)insertsleepStarttime:(NSDate*)starttime
                 Month:(int)month
                  Week:(int)week
                WeekDay:(int)weekday
              Duration:(int)duration
                 Place:(NSString*)place
                Remark:(NSString*)remark;

-(BOOL)insertplayStarttime:(NSDate*)starttime
                      Month:(int)month
                       Week:(int)week
                    WeekDay:(int)weekday
                   Duration:(int)duration
                     Place:(NSString*)place
                   WithWho:(NSString*)withwho
                    DoWhat:(NSString*)dowhat
                     Remark:(NSString*)remark;

-(BOOL)insertbathStarttime:(NSDate*)starttime
                      Month:(int)month
                       Week:(int)week
                    WeekDay:(int)weekday    
                   Duration:(int)duration
                     Remark:(NSString*)remark;

-(BOOL)insertUserAdviseLock;

-(NSArray*)selectAll;
-(NSArray*)selectAllforsummary;
-(NSArray*)selectfeedforsummary;
-(NSArray*)selectdiaperforsummary;
-(NSArray*)selectbathforsummary;
-(NSArray*)selectsleepforsummary;
-(NSArray*)selectplayforsummary;
-(NSString*)selectFromfeed;
-(NSString*)selectFrombath;
-(NSString*)selectFromsleep;
-(NSString*)selectFromplay;
-(NSString*)selectFromdiaper;


-(NSArray*)searchFromfeed:(NSDate*)start;
-(NSArray*)searchFromdiaper:(NSDate*)start;
-(int)searchIDFromdiaper:(NSDate*)start;
-(NSArray*)searchFromdiaperNoUpload;
-(NSArray*)searchFrombath:(NSDate*)start;
-(NSArray*)searchFromplay:(NSDate*)start;
-(NSArray*)searchFromsleep:(NSDate*)start;

+(int)selectFromUserAdvise:(int)advice_type;

-(BOOL)updatefeedOzorlr:(NSDate*)starttime
                  Month:(int)month
                   Week:(int)week
                WeekDay:(int)weekday
               Duration:(int)duration
                 OzorLR:(NSString*)ozorlr
                 Remark:(NSString*)remark
           OldStartTime:(NSDate*)oldstarttime;

-(BOOL)updatediaperStatus:(NSDate*)starttime
                    Month:(int)month
                     Week:(int)week
                  WeekDay:(int)weekday
                   Status:(NSString*)status
                    Color:(NSString*)color
                     Hard:(NSString*)hard
                   Remark:(NSString*)remark
             OldStartTime:(NSDate*)oldstarttime;

-(BOOL)updatesleepRemark:(NSDate*)starttime
                   Month:(int)month
                    Week:(int)week
                 WeekDay:(int)weekday
                Duration:(int)duration
                  Remark:(NSString*)remark
            OldStartTime:(NSDate*)oldstarttime;

-(BOOL)updateplayRemark:(NSDate*)starttime
                  Month:(int)month
                   Week:(int)week
                WeekDay:(int)weekday
               Duration:(int)duration
                 Remark:(NSString*)remark
           OldStartTime:(NSDate*)oldstarttime;

-(BOOL)updatebathRemark:(NSDate*)starttime
                  Month:(int)month
                   Week:(int)week
                WeekDay:(int)weekday
               Duration:(int)duration
                 Remark:(NSString*)remark
           OldStartTime:(NSDate*)oldstarttime;

-(BOOL)updateUserAdvise:(int)advice_type S_Lock:(int)s_lock;

//Sumary使用
//+ (NSArray *)dataFromTable:(NSString *)table andFieldTag:(int)fileTag;
//+ (NSArray *)dataSourceFromDatabase:(int)fileTag;
+ (int)scrollWidth:(int)tag;
+ (int)scrollWidthWithTag:(int)tag andTableName:(NSString*)tablename;
+ (NSArray *)scrollData:(int)scrollpage andTable:(NSString *)table andFieldTag:(int)fileTag;
+ (int)getMonthMax:(int)scrollpage;

+(NSArray*)selectbabyinfo:(int)age;

+(NSArray*)selectsuggestionbath:(int)s_lock;
+(NSArray*)selectsuggestiondiaper:(int)s_lock;
+(NSArray*)selectsuggestionsleep:(int)s_lock;
+(NSArray*)selectsuggestionplay:(int)s_lock;
+(NSArray*)selectsuggestionfeed:(int)s_lock;

-(BOOL)deleteWithStarttime:(NSDate*)starttime;

#pragma -mark notify message
+(BOOL)insertNotifyMessage:(NSString*)msg;
+(BOOL)updateNotifyMessageById:(int)msgid;
+(BOOL)updateNotifyMessageAll;
/**
 *	请求所有推送消息如果flagid为0则全部，否则为指定msgid=flagid
 *
 *	@return	封装好的数组对象
 */
+(NSArray*)selectNotifyMessage:(int)flagid;

+(BOOL)deleteNotifyMessage:(NSDate*) date;
+(BOOL)deleteNotifyMessageById:(int)msgid;

/**
 *	自定义提醒模块
 *
 *	@param	notifytime	自定义提醒
 *	@param	redundant	重复次数
 *	@param	title	提醒主题
 *
 *	@return
 */
+(BOOL)insertNotifyTime:(NSDate*)createtime andNotifyTime:(NSString*)notifytime andRedundant:(NSString*) redundant andTitle:(NSString*)title;
+(BOOL)updateNotifyTime:(NSDate*)createtime andNotifyTime:(NSString*)notifytime andRedundant:(NSString*) redundant andTitle:(NSString*)title;
+(BOOL)updateNotifyTimeStatus:(NSDate*)createtime andStatus:(int)status;
+(BOOL)deleteNotifyTime:(NSDate*) createtime;
/**
 *	查询notifytime
 *
 *	@param	createtime	如果为空查询所有记录
 *
 *	@return	返回记录组
 */
+(NSArray*)selectNotifyTime:(NSDate*)createtime;

-(void)updateUploadtimeByList:(NSArray*)returnArray andTableName:(NSString*)tablename;

/**
 *	更新上传时间
 */
-(BOOL)updateUploadtime:(NSString*)tablename andUploadTime:(NSDate*)uploadtime andID:(long)upload_id;


/**
 根据表名,字段名&值判断记录是否存在
 */
+(BOOL)checkRecordExistByID:(int)Id
                  FiledName:(NSString*)filedName
                  TableName:(NSString*)tableName
                     DBPath:(NSString*)path;
/**
 根据表名,字段名&值,更新时间判断记录是否存在
 */
+(BOOL)checkRecordNeedUpdateByID:(int)Id
                      UpdateTime:(int)updateTime
                       FiledName:(NSString*)filedName
                       TableName:(NSString*)tableName
                          DBPath:(NSString*)path;
@end
