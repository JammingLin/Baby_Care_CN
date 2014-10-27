//
//  DataContract.h
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-3-28.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataContract : NSObject

+(id)dataContract;

-(NSMutableDictionary*)UserCreateDict:(int) registerType
                       account:(NSString*) account
                      password:(NSString*) password;

-(NSMutableDictionary*)UserLoginDict:(int) registerType
                             account:(NSString*) account
                            password:(NSString*) password;

-(NSMutableDictionary*)BabyCreateByUserIdDict:(int) userid;

#pragma mark 封装宝贝信息实体
-(NSMutableDictionary*)BabyInfoCreateByBabyID:(int)babyid Brith:(long)birth Sex:(int)sex NickName:(NSString*)nickName;

@end
