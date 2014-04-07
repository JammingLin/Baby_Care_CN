//
//  UserRecordDB.m
//  Amoy Baby Care
//
//  Created by @Arvi@ on 14-3-19.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import "UserDataDB.h"
#import "NotifyItem.h"

@implementation UserDataDB
+(id)dataBase
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        
    });
    return _sharedObject;
}

-(BOOL)createNewUser:(int)user_id andCategoryIds:(NSString*)cgids andIcon:(NSString*)icon andUserType:(int)userType andUserAccount:(NSString*)account andAppVer:(NSString*)appver andCreateTime:(long)createtime andUpdateTime:(long)updatetime
{
    BOOL res;

    FMDatabase *db=[FMDatabase databaseWithPath:UDBPATH];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        return res;
    }
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_user (user_id int NOT NULL PRIMARY KEY, category_ids Varchar DEFAULT NULL, icon Varchar DEFAULT NULL, user_type INTEGER DEFAULT NULL, user_account Varchar DEFAULT NULL, app_ver Varchar DEFAULT NULL, create_time int not NULL, update_time int not NULL)"];
    
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"insert into bc_user values(?,?,?,?,?,?,?,?)",[NSNumber numberWithInt:user_id],
         cgids,
         icon,
         [NSNumber numberWithInt:userType],
         account,
         appver,
         [NSNumber numberWithInt:createtime],
         [NSNumber numberWithInt:updatetime]
    ];
    
    if (!res) {
        NSLog(@"%@",NSHomeDirectory());
        NSLog(@"插入失败");
        [db close];
        return res;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:user_id forKey:@"cur_userid"];
    
    [db close];
    
    return res;
}

-(NSDictionary*)selectUser:(int)user_id
{
    BOOL res;
    FMDatabase *db=[FMDatabase databaseWithPath:UDBPATH];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return nil;
    }
    
    NSString *sql =[NSString stringWithFormat:@"select * from bc_user where user_id = %d",user_id];
    FMResultSet *resultset=[db executeQuery:sql];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:8];
    if ([resultset next]) {
        [dic setValue:[NSNumber numberWithInt:[resultset intForColumn:@"user_id"]] forKey:@"user_id"];
        [dic setValue:[resultset stringForColumn:@"category_ids"] forKey:@"category_ids"];
        [dic setValue:[resultset stringForColumn:@"icon"] forKey:@"icon"];
        [dic setValue:[NSNumber numberWithInt:@"user_type"] forKey:@"user_type"];
        [dic setValue:[resultset stringForColumn:@"user_account"] forKey:@"user_account"];
        [dic setValue:[resultset stringForColumn:@"app_ver"] forKey:@"app_ver"];
        [dic setValue:[NSNumber numberWithLong:[resultset longForColumn:@"create_time"]] forKey:@"create_time"];
        [dic setValue:[NSNumber numberWithLong:[resultset longForColumn:@"update_time"]] forKey:@"update_time"];
    }
    else{
        return nil;
    }
    
    [db close];
    return dic;

}

-(BOOL)updateUserCategoryIds:(NSString*)ids andUserId:(int)user_id
{
    BOOL res;
    FMDatabase *db=[FMDatabase databaseWithPath:UDBPATH];    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_user set  category_ids= ? where user_id=?",ids, [NSNumber numberWithInt:user_id]];
    if (!res) {
        NSLog(@"更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateUserPhoto:(NSString*)photo andUserId:(int)user_id
{
    BOOL res;
    FMDatabase *db=[FMDatabase databaseWithPath:UDBPATH];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_user set icon= ? where user_id=?",photo, [NSNumber numberWithInt:user_id]];
    if (!res) {
        NSLog(@"更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}


-(BOOL)insertNotifyMessage:(NSString *)msg andTitle:(NSString *)title
{
    BOOL res;
    NSString *path=[[NSBundle mainBundle] pathForResource:@"BC_Info" ofType:@"sqlite"];
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];

    FMDatabase *db=[FMDatabase databaseWithPath:path];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_msg (msgid INTEGER PRIMARY KEY AUTOINCREMENT,user_id integer not null, create_time INTEGER default 0,update integer default 0, message Varchar DEFAULT NULL, tilte message Varchar DEFAULT NULL, status INTEGER NOT NULL)"];
    
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return res;
    }
    
    
    res=[db executeUpdate:@"insert into bc_msg (user_id, create_time, update_time, message, title,  status) values(?,?,0,?,?,0)",
         [NSNumber numberWithInt:user_id],
         [NSNumber numberWithLong:
          [ACDate getTimeStampFromDate:
           [ACDate date]
           ]],
         msg,
         title
    ];
    
    if (!res) {
        NSLog(@"数据库插入失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateNotifyMessageById:(int)userid andCreateTime:(long)create_time
{
    BOOL res;
    FMDatabase *db=[FMDatabase databaseWithPath:UDBPATH];

    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_msg set status = 1 where user_id=? and create_time = ?",[NSNumber numberWithInt:userid], [NSNumber numberWithLong:create_time]];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateNotifyMessageAll
{
    BOOL res;
    NSString *path=[[NSBundle mainBundle] pathForResource:@"BC_Info" ofType:@"sqlite"];
    
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    
    FMDatabase *db=[FMDatabase databaseWithPath:path];

    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    
    res=[db executeUpdate:@"update notify_message set status = 1 where status=0 where user_id=?",user_id];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(NSArray*)selectNotifyMessage:(int)flagid;
{
    NSMutableArray *array=[[NSMutableArray alloc]initWithCapacity:0];
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:UDBPATH];

    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return nil;
    }
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_msg (msgid INTEGER PRIMARY KEY AUTOINCREMENT,user_id integer  not null, create_time INTEGER default 0,update integer default 0, message Varchar DEFAULT NULL, tilte message Varchar DEFAULT NULL, status INTEGER NOT NULL)"];
    
    
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return nil;
        
    }
    
    if (flagid == 0)
    {
        FMResultSet *set=[db executeQuery:@"select * from  bc_msg where user_id = ? order by create_time desc", [NSNumber numberWithInt:user_id]];
        while ([set next])
        {
            NotifyItem *item = [[NotifyItem alloc]init];
            item.notifyid    = [set longForColumn:@"create_time"];
            item.content     = [set stringForColumn:@"message"];
            item.status      = [set intForColumn:@"status"];
            item.notify_time = [ACDate getDateFromTimeStamp:[set longForColumn:@"create_time"]];
            [array addObject:item];
        }
        
    }
    else
    {
        FMResultSet *set=[db executeQuery:@"select * from  bc_msg where msgid=? where user_id = ? order by create_time desc", [NSNumber numberWithInt:flagid], [NSNumber numberWithInt:user_id]];

        while ([set next])
        {
            NotifyItem *item = [[NotifyItem alloc]init];
            item.notifyid    = [set intForColumn:@"msgid"];
            item.content     = [set stringForColumn:@"message"];
            item.status      = [set intForColumn:@"status"];
            item.notify_time = [ACDate getDateFromTimeStamp:[set longForColumn:@"create_time"]];
            [array addObject:item];
        }
        
    }
    
    [db close];
    return  array;
    
}

-(BOOL)deleteNotifyMessage:(NSDate*)date
{
    BOOL res;
    FMDatabase *db=[FMDatabase databaseWithPath:UDBPATH];

    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"delete from notify_message where notify_time < ?",date];
    if (!res) {
        NSLog(@"数据库删除失败");
        [db close];
        return res;
    }
    [db close];
    return res;
    
}

-(BOOL)deleteNotifyMessageById:(int)msgid
{
    BOOL res;
    NSString *path=[[NSBundle mainBundle] pathForResource:@"BC_Info" ofType:@"sqlite"];
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:path];

    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"delete from notify_message where msgid = ? and user_id = ?", [NSNumber numberWithInt:msgid], [NSNumber numberWithInt:user_id]];

    if (!res) {
        NSLog(@"数据库删除失败");
        [db close];
        return res;
    }
    
    [db close];
    return res;
}

@end
