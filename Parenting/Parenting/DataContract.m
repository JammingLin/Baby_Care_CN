//
//  DataContract.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-3-28.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import "DataContract.h"

@implementation DataContract

+(id)dataContract
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        
    });
    return _sharedObject;
}

-(NSMutableDictionary*)UserCreateDict:(int) registerType
                       account:(NSString*) account
                      password:(NSString*) password
{
    NSArray *key = @[@"account",@"password",@"rtype"];
    NSArray *data = [[NSArray alloc]initWithObjects:account,password,[NSNumber numberWithInt:registerType] ,nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjects:data forKeys:key];
    return dict;
}

-(NSMutableDictionary*)UserLoginDict:(int) registerType
                             account:(NSString*) account
                            password:(NSString*) password
{
    NSArray *key = @[@"account",@"password",@"rtype"];
    NSArray *data = [[NSArray alloc]initWithObjects:account,password,[NSNumber numberWithInt:registerType] ,nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjects:data forKeys:key];
    return dict;
}

-(NSMutableDictionary*)BabyCreateByUserIdDict:(int) userid
{
    NSArray *key = @[@"userId"];
    NSArray *data = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:userid],nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjects:data forKeys:key];
    return dict;
}

#pragma mark 封装宝贝信息实体
-(NSMutableDictionary*)BabyInfoCreateByBabyID:(int)babyid Brith:(long)birth Sex:(int)sex NickName:(NSString*)nickName
{
    NSArray *key = @[@"babyId",@"birth",@"sex",@"nickName"];
    NSArray *data = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:babyid],[NSNumber numberWithLong:birth],[NSNumber numberWithInt:sex],nickName,nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:data forKeys:key];
    return dict;
}

@end
