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

@end
