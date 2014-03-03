//
//  UpLoadController.m
//  Amoy Baby Care
//
//  Created by @Arvi@ on 14-2-28.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import "UpLoadController.h"
#import "Reachability.h"

@implementation UpLoadController
+(id)uploadCtrller
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        
    });
    return _sharedObject;
}

+(void)checkDiaperUpload:(int)flag
{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"ACCOUNT_TYPE"])
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:nil message:@"麻麻,您还没有登录呦!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        BOOL isCanupload = NO;

        //手动同步,直接同步
        if (flag == 0)
        {
            isCanupload = YES;
        }
        //自动同步,需要判断是否可以同步
        else
        {
            Reachability *r=[Reachability reachabilityWithHostName:@"www.apple.com"];
                        switch ([r currentReachabilityStatus]) {
                case NotReachable: // 没有网络连接
                    break;
                case ReachableViaWWAN:
                {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"2G/3GBackUp"] == TRUE)
                    {
                        isCanupload = YES;
                    }
                }
                    break;
                case ReachableViaWiFi:
                {
                    isCanupload = YES;
                }
                    break;
            }
        }
        
        if (isCanupload)
        {
            NSArray *array = [[DataBase dataBase] searchFromdiaperNoUpload];
            [UpLoadController PostActivityRecord:array Type:QCM_TYPE_DIAPER];
        }
    }

}

+(NSArray*)PostActivityRecord:(NSArray*) records Type:(int)type
{
    return nil;
}

@end
