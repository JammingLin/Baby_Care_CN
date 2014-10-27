//
//  SyncController.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-4-3.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import "SyncController.h"
#import "NetWorkConnect.h"
#import "MBProgressHUD.h"
#import "BabyDataDB.h"
#import "TipCategoryDB.h"
#import "UserLittleTips.h"

@implementation SyncController

+(id)syncController
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        
    });
    return _sharedObject;
}

#pragma 同步婴儿数据
-(void)syncBabyDataCollectionsByUserID:(int) UserID
                           HUD:(MBProgressHUD*) hud
                  SyncFinished:(SyncFinishBlock) syncFinishBlock
                ViewController:(UIViewController*) viewController
{
    NSMutableDictionary *dictBody = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:UserID],@"userId",nil];
    hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.alpha = 0.5;
    //提示消息
    hud.labelText = @"接收数据中";
    
    [[NetWorkConnect sharedRequest]httpRequestWithURL:BABY_SYNC_URL
                                                 data:dictBody
                                                 mode:@"POST"
                                                  HUD:hud
                                       didFinishBlock:^(NSDictionary *result)
    {
        //处理反馈信息:   1有数据需同步  2无数据同步     99同步失败
        if ([[result objectForKey:@"code"]intValue] == 1) {
            //判断获取到几个婴儿数据
            NSMutableArray *babysArr = [[result objectForKey:@"body"] objectForKey:@"bc_baby"];
            for (NSDictionary* baby in babysArr) {
                //处理婴儿表&创建数据库
                NSString* nickName = [baby objectForKey:@"nickname"];
                hud.labelText = [NSString stringWithFormat:@"正在写入 %@ 的基本信息",nickName];
                [self SaveBabyInfo:baby];
                
                //处理婴消息表
                hud.labelText = [NSString stringWithFormat:@"正在写入 %@ 的消息列表",nickName];
                [self SaveBabyMsg:[baby objectForKey:@"bc_baby_msg"]];
                
                //处理婴儿生理表
                hud.labelText = [NSString stringWithFormat:@"正在写入 %@ 的生理数据",nickName];
                //FIXME:0403
                //[self SaveBabyPhysiology:[baby objectForKey:@"bc_baby_physiology"]];
                
                //处理婴儿活动表-6种
                hud.labelText = [NSString stringWithFormat:@"正在写入 %@ 的活动记录",nickName];
                
                //同步结束
                hud.labelText = @"数据同步结束";
            }
        }
        else if ([[result objectForKey:@"code"]intValue] == 2){
            hud.labelText = @"无需同步数据";
        }
        else{
            hud.labelText = [result objectForKey:@"msg"];
        }
        
        [hud hide:YES afterDelay:0.8];
        if (syncFinishBlock) {
            syncFinishBlock();
        }
     }
                                         didFailBlock:^(NSString *error)
    {
         //请求失败处理
         hud.labelText = http_error;
         [hud hide:YES afterDelay:1];
     }
                                       isShowProgress:YES
                                        isAsynchronic:YES
                                        netWorkStatus:YES
                                       viewController:viewController];

}

//婴儿基础数据存储
-(void)SaveBabyInfo:(NSDictionary *)babyDict{
    if (
    [BabyDataDB createNewBabyInfo:[[babyDict objectForKey:@"userId"] intValue]
                           BabyId:[[babyDict objectForKey:@"babyId"] intValue]
                         Nickname:[babyDict objectForKey:@"nickname"]
                         Birthday:[[babyDict objectForKey:@"birth"] longValue]
                              Sex:[[babyDict objectForKey:@"sex"] intValue]
                        HeadPhoto:[babyDict objectForKey:@"icon"]
                     RelationShip:[babyDict objectForKey:@"relationship"]
             RelationShipNickName:[babyDict objectForKey:@"relationalnickname"]
                       Permission:[[babyDict objectForKey:@"permission"] intValue]
                       CreateTime:[[babyDict objectForKey:@"create_time"] intValue]
                       UpdateTime:[[babyDict objectForKey:@"update_time"] intValue]]){
        [[NSUserDefaults standardUserDefaults] setObject:[babyDict objectForKey:@"babyId"] forKey:@"BABYID"];
    }
    
}

//婴儿消息数据存储
-(void)SaveBabyMsg:(NSArray*) msgArray{
    
}

//婴儿生理数据存储
-(void)SaveBabyPhysiology:(NSArray*)phyArray{
    
}

//婴儿活动数据存储
-(void)SaveBabyActivity:(NSArray*)actArray{
    
}

#pragma 同步贴士类目
-(void)syncCategoryInfo:(int) UserID
                    HUD:(MBProgressHUD*) hud
           SyncFinished:(SyncFinishBlock) syncFinishBlock
         ViewController:(UIViewController*) viewController{
    
    NSMutableDictionary *dictBody = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:UserID],@"userId",nil];
    hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.alpha = 0.5;
    //提示消息
    hud.labelText = @"接收数据中";
    
    [[NetWorkConnect sharedRequest]httpRequestWithURL:CATEGORY_SYNC_URL
                                                 data:dictBody
                                                 mode:@"POST"
                                                  HUD:hud
                                       didFinishBlock:^(NSDictionary *result)
     {
         //请求成功处理
         NSMutableArray *categoryArr = [[result objectForKey:@"body"] objectForKey:@"Bc_Category"];
         NSString *forDeleteIds=@"";
         for (NSDictionary* category in categoryArr) {
             //处理贴士类目表&创建数据库
             int categoryId = [[category objectForKey:@"categoryId"] intValue];
             forDeleteIds = [forDeleteIds stringByAppendingString:[NSString stringWithFormat:@"%d,",categoryId]];
             
             int createTime = [[category objectForKey:@"create_time"] intValue];
             int updateTime = [[category objectForKey:@"update_time"] intValue];
             int parentId = [[category objectForKey:@"parent_id"] intValue];
             NSString* name = [category objectForKey:@"name"];
             NSString* describe = [category objectForKey:@"describe"];
             NSString* icon = [category objectForKey:@"icon"];
             
             //检测照片是否一致
             NSString *docDir = [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
             NSFileManager *fileManager = [NSFileManager defaultManager];
             NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir,icon];
             NSString *picUrl = [NSString stringWithFormat:@"%@/%@",WEBPHOTO(@"icon"),icon];
             if(![icon isEqual:@""] && ![fileManager fileExistsAtPath:pngFilePath] && [[NetWorkConnect sharedRequest] remoteFileExist:picUrl]) //如果不存在
             {
                 UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]]];
                 NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                 [data1 writeToFile:pngFilePath atomically:YES];
             }

             //检测该数据是否已入库 返回:YES需要更新 NO不需要更新
             BOOL isUpdate = [TipCategoryDB checkUpdateState:categoryId UpdateTime:updateTime];
             if (isUpdate) {
                 [TipCategoryDB insertCategoryDB:categoryId CreateTime:createTime UpdateTime:updateTime ParentId:parentId name:name describe:describe icon:icon];
             }
        }
         //处理服务器已删除类目
         if (![forDeleteIds  isEqual: @""]) {
             forDeleteIds = [forDeleteIds substringToIndex:[forDeleteIds length]-1];
             [TipCategoryDB checkDeleteCategory:forDeleteIds];
         }
         if (syncFinishBlock) {
             syncFinishBlock();
         }
         [hud hide:YES afterDelay:0.8];
     }
                                         didFailBlock:^(NSString *error)
     {
         //请求失败处理
         hud.labelText = http_error;
        [hud hide:YES afterDelay:0.8];
     }
                                       isShowProgress:YES
                                        isAsynchronic:YES
                                        netWorkStatus:YES
                                       viewController:viewController];

}


#pragma 根据贴士类目、最后创建时间、条数获取贴士
-(void)getTips:(int) UserID
    CategoryID:(int) categoryID
LastCreateTime:(long) lastCreateTime
     GetNumber:(int) getNumber
           HUD:(MBProgressHUD*) hud
  SyncFinished:(SyncFinishBlockP) syncFinishBlockP
ViewController:(UIViewController*) viewController{
    
    NSMutableDictionary *dictBody = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:UserID],@"userId",[NSNumber numberWithInt:categoryID],@"categoryId",[NSNumber numberWithLong:lastCreateTime],@"lastCreateTime",[NSNumber numberWithInt:getNumber],@"getNumber",nil];
    hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.alpha = 0.5;
    //提示消息
    hud.labelText = @"接收数据中";
    
    [[NetWorkConnect sharedRequest]httpRequestWithURL:GETTIPS_SYNC_URL
                                                 data:dictBody
                                                 mode:@"POST"
                                                  HUD:hud
                                       didFinishBlock:^(NSDictionary *result)
     {
         //请求成功处理
         NSMutableArray *categoryArr = [[result objectForKey:@"body"] objectForKey:@"Bc_Tips"];
         
         if ([[result objectForKey:@"code"]intValue] == 1) {
             for (NSDictionary* category in categoryArr) {
                 //处理贴士类目表&创建数据库
                 int tipsId = [[category objectForKey:@"tipId"] intValue];
                 int createTime = [[category objectForKey:@"create_time"] intValue];
                 int updateTime = [[category objectForKey:@"update_time"] intValue];
                 int categoryId = [[category objectForKey:@"category_id"] intValue];
                 NSString* title = [category objectForKey:@"title"];
                 NSString* summary = [category objectForKey:@"summary"];
                 NSString* picUrl = [category objectForKey:@"picUrl"];
                 
                 //检测该数据是否已入库 返回:YES需要更新 NO不需要更新
                 //上述已集成到insert方法中
                 [TipCategoryDB insertTipDB:tipsId CreateTime:createTime UpdateTime:updateTime CategoryId:categoryId Title:title Summary:summary PicUrl:picUrl];
             }
             if (syncFinishBlockP) {
                 syncFinishBlockP(categoryArr);
             }
             [hud hide:YES afterDelay:0.8];
         }
         else{
             //请求失败处理
             if (syncFinishBlockP) {
                 syncFinishBlockP(nil);
             }
             hud.labelText = @"无可更新数据";
             [hud hide:YES afterDelay:1.5];
         }
     }
                                         didFailBlock:^(NSString *error)
     {
         //请求失败处理
         hud.labelText = http_error;
         [hud hide:YES afterDelay:0.8];
     }
                                       isShowProgress:YES
                                        isAsynchronic:YES
                                        netWorkStatus:YES
                                       viewController:viewController];
}

#pragma 根据贴士类目、最后创建时间、条数获取贴士
-(void)getTipsHome:(int) UserID
    LastCreateTime:(long) lastCreateTime
        BabyMonths:(int) babyMonth
               HUD:(MBProgressHUD*) hud
      SyncFinished:(SyncFinishBlockP) syncFinishBlockP
    ViewController:(UIViewController*) viewController{
    
    NSMutableDictionary *dictBody = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:UserID],@"userId",[NSNumber numberWithInt:babyMonth],@"babyMonths",[NSNumber numberWithLong:lastCreateTime],@"lastCreateTime",nil]; 
//    hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.alpha = 0.5;
    //提示消息
    hud.labelText = @"接收数据中";
    
    NetWorkConnect *net = [[NetWorkConnect alloc] init];
    [net httpRequestWithURL:GETTIPSHOME_SYNC_URL
                       data:dictBody
                       mode:@"POST"
                        HUD:hud
             didFinishBlock:^(NSDictionary *result)
     {
         //请求成功处理
         NSMutableArray *categoryArr = [[result objectForKey:@"body"] objectForKey:@"Bc_Tips"];
         
         if ([[result objectForKey:@"code"]intValue] == 1) {
             
             [hud hide:YES afterDelay:1.0];
             if (syncFinishBlockP) {
                 syncFinishBlockP(categoryArr);
             }
         }
         else{
             hud.labelText = @"无可更新数据";
             [hud hide:YES afterDelay:1.5];
             if (syncFinishBlockP) {
                 syncFinishBlockP(nil);
             }
         }
     }
               didFailBlock:^(NSString *error)
     {
         //请求失败处理
         hud.labelText = http_error;
         [hud hide:YES afterDelay:0.8];
         if (syncFinishBlockP) {
             syncFinishBlockP(nil);
         }
     }
             isShowProgress:YES
              isAsynchronic:YES
              netWorkStatus:YES
             viewController:viewController];
}

#pragma 同步基本内容:小窍门
-(void)SyncBasicContent{
    [self SyncBasicLittleTips];
}

#pragma 同步小窍门
-(void)SyncBasicLittleTips{
    long lastUpdateTime = [UserLittleTips getLastUpdateTime];
    NSMutableDictionary *dictBody = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:ACCOUNTUID],@"userId",[NSNumber numberWithLong:lastUpdateTime],@"lastUpdateTime",[NSNumber numberWithInt:LITTLETIPS_MAXGETNUMBER],@"maxGetNumber",nil];
    
    NetWorkConnect *net = [[NetWorkConnect alloc] init];
    [net httpRequestWithURL:LITTLETIPS_SYNC_URL
                                                 data:dictBody
                                                 mode:@"POST"
                                                  HUD:nil
                                       didFinishBlock:^(NSDictionary *result)
     {
         //请求成功处理
         NSMutableArray *littleTipsArr = [[result objectForKey:@"body"] objectForKey:@"Bc_LittleTips"];
         if([[result objectForKey:@"code"] intValue] != 1){
             return;
         }
         for (NSDictionary* littleTip in littleTipsArr) {
             //数据插入
             int littleTipsId = [[littleTip objectForKey:@"littletips_Id"] intValue];
             int createTime = [[littleTip objectForKey:@"create_time"] intValue];
             int updateTime = [[littleTip objectForKey:@"update_time"] intValue];
             int start = [[littleTip objectForKey:@"start_month"] intValue];
             int end = [[littleTip objectForKey:@"end_month"] intValue];
             int lock = [[littleTip objectForKey:@"tips_lock"] intValue];
             NSString* content = [littleTip objectForKey:@"tips_content"];
             int feed = [[littleTip objectForKey:@"feed"] intValue];
             int sleep = [[littleTip objectForKey:@"sleep"] intValue];
             int bath = [[littleTip objectForKey:@"bath"] intValue];
             int play = [[littleTip objectForKey:@"play"] intValue];
             int diaper = [[littleTip objectForKey:@"diaper"] intValue];
             int medicine = [[littleTip objectForKey:@"medicine"] intValue];
             
             //检测该数据是否已入库 返回:YES需要更新 NO不需要更新
             //上述已集成到insert方法中
             //%DEBUG&FIXE
             [UserLittleTips insertLittleTip:littleTipsId CreateTime:createTime UpdateTime:updateTime StartMonth:start EndMonth:end TipLock:lock TipContent:content Feed:feed Sleep:sleep Bath:bath Play:play Diaper:diaper Medicine:medicine];
         }
         
         //如果获取数据集等于最大获取量，则继续获取
         if([littleTipsArr count]== LITTLETIPS_MAXGETNUMBER)
         {
             [self SyncBasicLittleTips];
         }
     }
                                         didFailBlock:^(NSString *error)
     {
         //请求失败处理
         NSLog(@"SyncLittleTips error");
     }
                                       isShowProgress:YES
                                        isAsynchronic:YES
                                        netWorkStatus:YES
                                       viewController:nil];
}

#pragma mark 上传宝贝信息并刷新上传状态(user_baby_id)
-(void)UploadBabyInfo:(NSMutableDictionary*)babyInfo andUserBabyID:(NSString*)user_baby_id
{
    NetWorkConnect *net = [[NetWorkConnect alloc] init];
    [net httpRequestWithURL:BABYINFO_UPLOAD_URL
                       data:babyInfo
                       mode:@"POST"
                        HUD:nil
             didFinishBlock:^(NSDictionary *result)
     {
         //如果上传成功则做标记
         if ([result[@"code"] intValue] == 1) {
             [[NSUserDefaults standardUserDefaults] setObject:@"Uploaded" forKey:user_baby_id];
         }
     }
               didFailBlock:^(NSString *error)
     {
         
     }
             isShowProgress:YES
              isAsynchronic:YES
              netWorkStatus:YES
             viewController:nil];
}

@end
