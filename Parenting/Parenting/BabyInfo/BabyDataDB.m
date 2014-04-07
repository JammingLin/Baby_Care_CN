//
//  BabyDataDB.m
//  Amoy Baby Care
//
//  Created by @Arvi@ on 14-2-27.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import "BabyDataDB.h"

@implementation BabyDataDB
+(id)babyinfoDB
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        
    });
    return _sharedObject;
}

+(BOOL)createNewBabyInfo:(int)user_id
                  BabyId:(int)baby_id
                Nickname:(NSString *)nickname
                Birthday:(long)birthday
                     Sex:(int)sex
               HeadPhoto:(NSString *)headphoto
            RelationShip:(NSString *)relationship
    RelationShipNickName:(NSString *)relationship_nickname
              Permission:(int)permission
              CreateTime:(long)create_time
              UpdateTime:(long)update_time
{
    BOOL res;
    [[NSUserDefaults standardUserDefaults] setInteger:baby_id forKey:@"cur_babyid"];
    
    //创建文件夹
    NSString *dbFilePath = [NSString stringWithFormat:@"%@/Documents/%d_%d",NSHomeDirectory(),user_id,baby_id];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dbFilePath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:dbFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id,baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_baby (baby_id  INTEGER PRIMARY KEY NOT NULL, user_id INTEGER NOT NULL, nickname Varchar DEFAULT NULL, birth Timestamp DEFAULT NULL,tall Varchar DEFAULT NULL,weight Varchar  DEFAULT NULL,hc Varchar DEFAULT NULL,sex Varchar DEFAULT NULL,head Varchar DEFAULT NULL,relationship Varchar DEFAULT NULL,relationship_nickname Varchar DEFAULT NULL, permission integer default 0, create_time integer default 0, update_time integer default 0)"];
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"insert into bc_baby(baby_id,user_id,nickname, birth,sex,head,relationship,relationship_nickname,permission,create_time,update_time) values(?,?,?,?,?,?,?,?,?,?,?)",[NSNumber numberWithInt:user_id],
        [NSNumber numberWithInt:baby_id],
        nickname,
        [NSNumber numberWithLong:birthday],
        [NSNumber numberWithInt:sex],
        headphoto,
        relationship,
        relationship_nickname,
        [NSNumber numberWithInt:permission],
        [NSNumber numberWithLong:create_time],
        [NSNumber numberWithLong:update_time]
    ];
    
    if (!res)
    {
        NSLog(@"插入失败");
        [db close];
        return res;
    }

    [db close];
    return res;
}

-(NSArray*)selectBabyListByUserId:(int)user_id
{
    BOOL res;
    NSMutableArray *array=[[NSMutableArray alloc]initWithCapacity:0];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id,baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return nil;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from bc_baby where user_id = %d", user_id];
    
    FMResultSet *resultset=[db executeQuery:sql];
    while ([resultset next]) {
        NSDictionary *dic = [self selectBabyInfoByBabyId:[resultset intForColumn:@"baby_id"]];
        if (dic != nil) {
            [array addObject:dic];
        }
    }
    [db close];
    return array;

}

-(NSDictionary*)selectBabyInfoByBabyId:(int)baby_id
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id,baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return nil;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from bc_baby where baby_id = %d", baby_id];
    
    FMResultSet *resultset=[db executeQuery:sql];
    if ([resultset next])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:11];
        [dic setValue:[NSNumber numberWithInt:[resultset intForColumn:@"user_id"]] forKey:@"user_id"];
        [dic setValue:[NSNumber numberWithInt:[resultset intForColumn:@" baby_id"]] forKey:@"baby_id"];
        [dic setValue:[resultset stringForColumn:@"nickname"] forKey:@"nickname"];
        [dic setValue:[NSNumber numberWithLong:[resultset longForColumn:@"birth"]] forKey:@"birth"];
        [dic setValue:[NSNumber numberWithInt:[resultset intForColumn:@"sex"]] forKey:@"sex"];
        [dic setValue:[resultset stringForColumn:@"icon"] forKey:@"icon"];
        [dic setValue:[resultset stringForColumn:@"relationship"] forKey:@"relationship"];
        [dic setValue:[resultset stringForColumn:@"relationship_nickname"] forKey:@"relationship_nickname"];
        [dic setValue:[NSNumber numberWithInt:[resultset intForColumn:@"permission"]] forKey:@"permission"];
        [dic setValue:[NSNumber numberWithLong:[resultset longForColumn:@"create_time"]] forKey:@"create_time"];
        [dic setValue:[NSNumber numberWithLong:[resultset longForColumn:@"update_time"]] forKey:@"update_time"];
        [db close];
        return dic;
    }
    [db close];
    return nil;

}

-(BOOL)updateBabyInfoName:(NSString*)newNickname BabyId:(int)baby_id
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby set nickname= ? where baby_id=?",newNickname, [NSNumber numberWithInt:baby_id]];
    if (!res) {
        NSLog(@"更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateBabyBirth:(long)birth BabyId:(int)baby_id
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby set birth= ? where baby_id=?",[NSNumber numberWithLong:birth], [NSNumber numberWithInt:baby_id]];
    if (!res) {
        NSLog(@"更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateBabySex:(int)sex BabyId:(int)baby_id
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby set sex= ? where baby_id=?",[NSNumber numberWithInt:sex], [NSNumber numberWithInt:baby_id]];
    if (!res) {
        NSLog(@"更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateBabyIcon:(NSString*)icon BabyId:(int)baby_id
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby set icon= ? where baby_id=?",icon, [NSNumber numberWithInt:baby_id]];
    if (!res) {
        NSLog(@"更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateBabyInfoUpdateTime:(long)update_time BabyId:(int)baby_id
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby set update_time= ? where baby_id=?",[NSNumber numberWithLong:update_time], [NSNumber numberWithInt:baby_id]];
    if (!res) {
        NSLog(@"更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)insertBabyPhysiology:(long)create_time
                 UpdateTime:(long)update_time
                MeasureTime:(long)measure_time
                       Type:(int)type
                      Value:(double)value
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_baby_physiology (create_time integer NOT NULL PRIMARY KEY, update_time integer DEFAULT 0, type integer defalut 0, measure_time integer default 0, value double default 0)"];
    
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"insert into bc_baby_physiology values(?,?,?,?,?)",
        [NSNumber numberWithLong:create_time],
        [NSNumber numberWithLong:update_time],
        [NSNumber numberWithLong:measure_time],
        [NSNumber numberWithInt:type],
        [NSNumber numberWithDouble:value]
         ];
    
    if (!res) {
        NSLog(@"%@",NSHomeDirectory());
        NSLog(@"插入失败");
        [db close];
        return res;
    }
    
    [db close];
    return res;

}

-(BOOL)updateBabyPhysiology:(double)value ByCreateTime:(long)create_time andType:(int)type
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];

    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby_physiology set value= ? where create_time=? and type = ?",[NSNumber numberWithDouble:value], [NSNumber numberWithLong:create_time],[NSNumber numberWithInt:type]];
    if (!res) {
        NSLog(@"更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(NSArray*)selectBabyPhysiologyList:(int)type
{
    BOOL res;
    NSMutableArray *array=[[NSMutableArray alloc]initWithCapacity:0];
    
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];

    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return nil;
    }
    
    NSString *sql =[NSString stringWithFormat:@"select * from bc_baby_physiology where type = %d",type];
    FMResultSet *resultset=[db executeQuery:sql];
    while ([resultset next]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:11];
        [dic setValue:[NSNumber numberWithInt:[resultset longForColumn:@"create_time"]] forKey:@"create_time"];
        [dic setValue:[NSNumber numberWithInt:[resultset longForColumn:@"update_time"]] forKey:@"update_time"];
        [dic setValue:[NSNumber numberWithInt:[resultset intForColumn:@"type"]] forKey:@"type"];
        [dic setValue:[NSNumber numberWithDouble:[resultset doubleForColumn:@"value"]] forKey:@"value"];
        [dic setValue:[NSNumber numberWithLong:[resultset longForColumn:@"measure_time"]] forKey:@"measure_time"];
        [array addObject:dic];
    }
    [db close];
    return array;
}

-(BOOL)deleteBabyPhysiologyByType:(int)type andCreateTime:(long)create_time
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];

    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"delete bc_baby_physiology where create_time=? and type = ?", [NSNumber numberWithLong:create_time],[NSNumber numberWithInt:type]];
    if (!res) {
        NSLog(@"删除失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(NSArray*)selectWFAByType:(int)type andSex:(int)sex
{
    BOOL res;
    NSMutableArray *array=[[NSMutableArray alloc]initWithCapacity:0];
    NSString *path=[[NSBundle mainBundle] pathForResource:@"BC_Info" ofType:@"sqlite"];
    
    FMDatabase *db=[FMDatabase databaseWithPath:path];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return nil;
    }
    NSString *sql =[NSString stringWithFormat:@"select * from bc_wfa where type = %d and sex = %d",type, sex];
    FMResultSet *resultset=[db executeQuery:sql];
    while ([resultset next]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:11];
        [dic setValue:[NSNumber numberWithInt:[resultset intForColumn:@"type"]] forKey:@"type"];
        [dic setValue:[NSNumber numberWithInt:[resultset intForColumn:@"sex"]] forKey:@"sex"];
        [dic setValue:[NSNumber numberWithInt:[resultset intForColumn:@"age"]] forKey:@"age"];
        [dic setValue:[NSNumber numberWithDouble:[resultset doubleForColumn:@"L"]] forKey:@"L"];
        [dic setValue:[NSNumber numberWithDouble:[resultset doubleForColumn:@"M"]] forKey:@"M"];
        [dic setValue:[NSNumber numberWithDouble:[resultset doubleForColumn:@"S"]] forKey:@"S"];
        [dic setValue:[NSNumber numberWithDouble:[resultset doubleForColumn:@"P01"]] forKey:@"P01"];
        [dic setValue:[NSNumber numberWithDouble:[resultset doubleForColumn:@"P25"]] forKey:@"P25"];
        [dic setValue:[NSNumber numberWithDouble:[resultset doubleForColumn:@"P50"]] forKey:@"P50"];
        [dic setValue:[NSNumber numberWithDouble:[resultset doubleForColumn:@"P75"]] forKey:@"P75"];
        [dic setValue:[NSNumber numberWithDouble:[resultset doubleForColumn:@"P99"]] forKey:@"P99"];
        [array addObject:dic];
    }
    [db close];
    return array;
}

-(BOOL)insertBabyBathRecord:(long)create_time
                 UpdateTime:(long)update_time
                  StartTime:(NSDate*)start_time
                      Month:(int)month
                       Week:(int)week
                    Weekday:(int)weekday
                   Duration:(int)duration
                   BathType:(NSString*)bath_type
                     Remark:(NSString*)remark
                   MoreInfo:(NSString*)more_info
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_baby_bath (create_time integer NOT NULL PRIMARY KEY, update_time integer DEFAULT 0, starttime Timestamp DEFAULT NULL, month INTEGER DEFAULT NULL, week INTEGER DEFAULT NULL, weekday INTEGER DEFAULT NULL, duration INTEGER DEFAULT NULL, remark Varchar DEFAULT NULL, bath_type Varchar DEFAULT NULL,moreinfo Varchar DEFAULT NULL,type Varchar DEFAULT NULL)"];
    
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"insert into bc_baby_bath values(?,?,?,?,?,?,?,?,?,?,?)",
         [NSNumber numberWithLong:create_time],
         [NSNumber numberWithLong:update_time],
         start_time,
         [NSNumber numberWithInt:month],
         [NSNumber numberWithInt:week],
         [NSNumber numberWithInt:weekday],
         [NSNumber numberWithInt:duration],
         remark,
         bath_type,
         more_info,
         @"Bath"
         ];
    
    if (!res) {
        NSLog(@"%@",NSHomeDirectory());
        NSLog(@"插入失败");
        [db close];
        return res;
    }
    [db close];
    
    return res;
}

-(BOOL)insertBabyDiaperRecord:(long)create_time
                   UpdateTime:(long)update_time
                    StartTime:(NSDate *)start_time
                        Month:(int)month
                         Week:(int)week
                      Weekday:(int)weekday
                       Status:(NSString *)status
                        Color:(NSString *)color
                         Hard:(NSString *)hard
                       Remark:(NSString *)remark
                     MoreInfo:(NSString *)more_info
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_baby_diaper (create_time integer NOT NULL PRIMARY KEY, update_time integer DEFAULT 0, starttime Timestamp DEFAULT NULL, month INTEGER DEFAULT NULL, week INTEGER DEFAULT NULL, weekday INTEGER DEFAULT NULL, status Varchar DEFAULT NULL, remark Varchar DEFAULT NULL, color Varchar DEFAULT NULL,hard Varchar DEFAULT NULL,moreinfo Varchar DEFAULT NULL,type Varchar DEFAULT NULL)"];
    
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"insert into bc_baby_diaper values(?,?,?,?,?,?,?,?,?,?,?,?)",
         [NSNumber numberWithLong:create_time],
         [NSNumber numberWithLong:update_time],
         start_time,
         [NSNumber numberWithInt:month],
         [NSNumber numberWithInt:week],
         [NSNumber numberWithInt:weekday],
         status,
         remark,
         color,
         hard,
         more_info,
         @"Diaper"
         ];
    
    if (!res) {
        NSLog(@"%@",NSHomeDirectory());
        NSLog(@"插入失败");
        [db close];
        return res;
    }
    [db close];
    
    return res;

}

-(BOOL)insertBabyFeedRecord:(long)create_time
                 UpdateTime:(long)update_time
                  StartTime:(NSDate *)start_time
                      Month:(int)month
                       Week:(int)week
                    Weekday:(int)weekday
                   Duration:(int)duration
                         Oz:(double)oz
                   FeedType:(NSString *)feed_type
                   FoodType:(NSString *)food_type
                     Remark:(NSString *)remark
                   MoreInfo:(NSString *)more_info
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_baby_feed (create_time integer NOT NULL PRIMARY KEY, update_time integer DEFAULT 0, starttime Timestamp DEFAULT NULL, month INTEGER DEFAULT NULL, week INTEGER DEFAULT NULL, weekday INTEGER DEFAULT NULL, duration INTEGER DEFAULT 0, oz DOUBLE DEFAULT 0,remark Varchar DEFAULT NULL, feed_type Varchar DEFAULT NULL,food_type Varchar DEFAULT NULL,moreinfo Varchar DEFAULT NULL,type Varchar DEFAULT NULL)"];
    
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"insert into bc_baby_feed values(?,?,?,?,?,?,?,?,?,?,?,?,?)",
         [NSNumber numberWithLong:create_time],
         [NSNumber numberWithLong:update_time],
         start_time,
         [NSNumber numberWithInt:month],
         [NSNumber numberWithInt:week],
         [NSNumber numberWithInt:weekday],
         [NSNumber numberWithInt:duration],
         [NSNumber numberWithDouble:oz],
         remark,
         feed_type,
         food_type,
         more_info,
         @"Feed"
         ];
    
    if (!res) {
        NSLog(@"%@",NSHomeDirectory());
        NSLog(@"插入失败");
        [db close];
        return res;
    }
    [db close];
    
    return res;
}

-(BOOL)insertBabyPlayRecord:(long)create_time
                 UpdateTime:(long)update_time
                  StartTime:(NSDate *)start_time
                      Month:(int)month
                       Week:(int)week
                    Weekday:(int)weekday
                   Duration:(int)duration
                      Place:(NSString *)place
                  PlaceType:(NSString *)play_type
                     Remark:(NSString *)remark
                   MoreInfo:(NSString *)more_info
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_baby_play (create_time integer NOT NULL PRIMARY KEY, update_time integer DEFAULT 0, starttime Timestamp DEFAULT NULL, month INTEGER DEFAULT NULL, week INTEGER DEFAULT NULL, weekday INTEGER DEFAULT NULL, duration INTEGER DEFAULT 0, remark Varchar DEFAULT NULL, place Varchar DEFAULT NULL,play_type Varchar DEFAULT NULL,moreinfo Varchar DEFAULT NULL,type Varchar DEFAULT NULL)"];
    
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"insert into bc_baby_play values(?,?,?,?,?,?,?,?,?,?,?,?)",
         [NSNumber numberWithLong:create_time],
         [NSNumber numberWithLong:update_time],
         start_time,
         [NSNumber numberWithInt:month],
         [NSNumber numberWithInt:week],
         [NSNumber numberWithInt:weekday],
         [NSNumber numberWithInt:duration],
         remark,
         place,
         play_type,
         more_info,
         @"Play"
         ];
    
    if (!res) {
        NSLog(@"%@",NSHomeDirectory());
        NSLog(@"插入失败");
        [db close];
        return res;
    }
    [db close];
    
    return res;
}

-(BOOL)insertBabySleepRecord:(long)create_time
                  UpdateTime:(long)update_time
                   StartTime:(NSDate *)start_time
                       Month:(int)month
                        Week:(int)week
                     Weekday:(int)weekday
                    Duration:(int)duration
                     Posture:(NSString *)posture
                       Place:(NSString *)place
                      Remark:(NSString *)remark
                    MoreInfo:(NSString *)more_info
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"CREATE TABLE if not exists bc_baby_sleep (create_time integer NOT NULL PRIMARY KEY, update_time integer DEFAULT 0, starttime Timestamp DEFAULT NULL, month INTEGER DEFAULT NULL, week INTEGER DEFAULT NULL, weekday INTEGER DEFAULT NULL, duration INTEGER DEFAULT 0, remark Varchar DEFAULT NULL, posture Varchar DEFAULT NULL,place Varchar DEFAULT NULL,moreinfo Varchar DEFAULT NULL,type Varchar DEFAULT NULL)"];
    
    if (!res) {
        NSLog(@"表格创建失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"insert into bc_baby_sleep values(?,?,?,?,?,?,?,?,?,?,?,?)",
         [NSNumber numberWithLong:create_time],
         [NSNumber numberWithLong:update_time],
         start_time,
         [NSNumber numberWithInt:month],
         [NSNumber numberWithInt:week],
         [NSNumber numberWithInt:weekday],
         [NSNumber numberWithInt:duration],
         remark,
         posture,
         place,
         more_info,
         @"Sleep"
         ];
    
    if (!res) {
        NSLog(@"%@",NSHomeDirectory());
        NSLog(@"插入失败");
        [db close];
        return res;
    }
    [db close];
    
    return res;
}

-(BOOL)updateBathRecord:(NSDate*)starttime
                  Month:(int)month
                   Week:(int)week
                WeekDay:(int)weekday
               Duration:(int)duration
               BathType:(NSString*)bath_type
                 Remark:(NSString*)remark
               MoreInfo:(NSString*)more_info
             CreateTime:(long)createtime
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby_bath set starttime = ?, month=?,week = ?,weekday=?,duration=?,deal_way=?,remark=?,more_info = ? where create_time=?",starttime,[NSNumber numberWithInt:month],[NSNumber numberWithInt:week],[NSNumber numberWithInt:weekday],[NSNumber numberWithInt:duration],bath_type,remark,more_info,[NSNumber numberWithLong:createtime]];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateDiaperRecord:(NSDate*)starttime
                    Month:(int)month
                     Week:(int)week
                  WeekDay:(int)weekday
                   Status:(NSString *)status
                    Color:(NSString *)color
                     Hard:(NSString *)hard
                   Remark:(NSString *)remark
                 MoreInfo:(NSString*)more_info
               CreateTime:(long)createtime
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby_diaper set starttime = ?, month=?,week = ?,weekday=?,status=?,color=?,hard = ?,remark=?,more_info = ? where create_time=?",starttime,[NSNumber numberWithInt:month],[NSNumber numberWithInt:week],[NSNumber numberWithInt:weekday],status,color,hard,remark,more_info,[NSNumber numberWithLong:createtime]];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateFeedRecord:(NSDate*)starttime
                  Month:(int)month
                   Week:(int)week
                WeekDay:(int)weekday
               Duration:(int)duration
                     Oz:(double)oz
               FeedType:(NSString *)feed_type
               FoodType:(NSString *)food_type
                 Remark:(NSString *)remark
               MoreInfo:(NSString*)more_info
             CreateTime:(long)createtime
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby_feed set starttime = ?, month=?,week = ?,weekday=?,duration=?,oz=?,feed_type = ?,food_type = ?,remark=?,more_info = ? where create_time=?",starttime,[NSNumber numberWithInt:month],[NSNumber numberWithInt:week],[NSNumber numberWithInt:weekday],[NSNumber numberWithInt:duration],[NSNumber numberWithDouble:oz],feed_type,food_type,remark,more_info,[NSNumber numberWithLong:createtime]];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updatePlayRecord:(NSDate*)starttime
                  Month:(int)month
                   Week:(int)week
                WeekDay:(int)weekday
               Duration:(int)duration
                  Place:(NSString *)place
              PlaceType:(NSString *)play_type
                 Remark:(NSString *)remark
               MoreInfo:(NSString*)more_info
             CreateTime:(long)createtime
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby_play set starttime = ?, month=?,week = ?,weekday=?,duration=?,place = ?,play_type = ?,remark=?,more_info = ? where create_time=?",starttime,[NSNumber numberWithInt:month],[NSNumber numberWithInt:week],[NSNumber numberWithInt:weekday],[NSNumber numberWithInt:duration],place,play_type,remark,more_info,[NSNumber numberWithLong:createtime]];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateSleepRecord:(NSDate*)starttime
                   Month:(int)month
                    Week:(int)week
                 WeekDay:(int)weekday
                Duration:(int)duration
                 Posture:(NSString *)posture
                   Place:(NSString *)place
                  Remark:(NSString *)remark
                MoreInfo:(NSString*)more_info
              CreateTime:(long)createtime
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    res=[db executeUpdate:@"update bc_baby_sleep set starttime = ?, month=?,week = ?,weekday=?,duration=?,place = ?,posture = ?,remark=?,more_info = ? where create_time=?",starttime,[NSNumber numberWithInt:month],[NSNumber numberWithInt:week],[NSNumber numberWithInt:weekday],[NSNumber numberWithInt:duration],place,posture,remark,more_info,[NSNumber numberWithLong:createtime]];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;
}

-(BOOL)updateDuration:(long)create_time
             Duration:(int)duration
            Tablename:(NSString*)tablename
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    NSString* str = [NSString stringWithFormat:@"update bc_baby_%@ set duration = ? where create_time = ?", tablename];
    res = [db executeUpdate:str, [NSNumber numberWithInt:duration],[NSNumber numberWithLong:create_time]];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;

}

-(BOOL)deleteBabyRecord:(long)create_time
              Tablename:(NSString*)tablename
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];
    
    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    NSString* str = [NSString stringWithFormat:@"delete bc_baby_%@ where create_time = ?", tablename];
    res = [db executeUpdate:str, [NSNumber numberWithLong:create_time]];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }
    [db close];
    return res;

}

-(BOOL)updateUploadtime:(NSString*)tablename andUploadTime:(long)uploadtime andCreateTime:(long)create_time
{
    BOOL res;
    int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
    int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];
    FMDatabase *db=[FMDatabase databaseWithPath:USERDBPATH(user_id, baby_id)];

    res=[db open];
    if (!res) {
        NSLog(@"数据库打开失败");
        [db close];
        return res;
    }
    
    NSString* str = [NSString stringWithFormat:@"update bc_baby_%@ set upload_time = ? where create_time = ?", tablename];
    res = [db executeUpdate:str, [NSNumber numberWithLong:uploadtime],[NSNumber numberWithLong:create_time]];
    if (!res) {
        NSLog(@"数据库更新失败");
        [db close];
        return res;
    }

    [db close];
    return res;
}

@end
