//
//  LoginView.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-10-14.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import "LoginView.h"
#import "HomeViewController.h"

@implementation LoginView

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        isPushSocialView = NO;
        [self initSubView];
    }
    return self;
}

-(void)initSubView{
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.9;
    
    //**  登陆按钮  **
    UIButton *buttonLogin = [[UIButton alloc]initWithFrame:CGRectMake(45, [UIScreen mainScreen].bounds.size.height - 50 -40 -50-50-50, 230, 38)];
    [buttonLogin setImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
    [buttonLogin addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonLogin];
    
    //**  腾讯登陆按钮  **
    UIButton *buttonTen = [[UIButton alloc]initWithFrame:CGRectMake(45, [UIScreen mainScreen].bounds.size.height - 40 -50, 230, 38)];
    [buttonTen setImage:[UIImage imageNamed:@"btn_tent"] forState:UIControlStateNormal];
    [buttonTen addTarget:self action:@selector(doTenLogin) forControlEvents:UIControlEventTouchUpInside];
    if ([QQApi isQQInstalled])
    {
        [self addSubview:buttonTen];
    }
    
    //**  腾讯微博  **
    UIButton *buttonTentWeibo = [[UIButton alloc]initWithFrame:CGRectMake(45, [UIScreen mainScreen].bounds.size.height- 50 -40 -50-50, 230, 38)];
    [buttonTentWeibo setImage:[UIImage imageNamed:@"btn_tentweibo"] forState:UIControlStateNormal];
    [buttonTentWeibo addTarget:self action:@selector(doTentWeiboLogin) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonTentWeibo];
    
    //**  新浪登陆按钮  **
    UIButton *buttonSina = [[UIButton alloc]initWithFrame:CGRectMake(45, [UIScreen mainScreen].bounds.size.height - 50 - 40-50, 230, 38)];
    [buttonSina setImage:[UIImage imageNamed:@"btn_sina.png"] forState:UIControlStateNormal];
    [buttonSina addTarget:self action:@selector(doSinaLogin) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonSina];
}

#pragma 登陆相关
-(void)doLogin{
    self.hidden = YES;
    LoginMainViewController *loginMainViewController = [[LoginMainViewController alloc]initWithNibName:@"LoginMainViewController" bundle:nil];
    loginMainViewController.mainViewController = _mainViewController;
    [_mainViewController.navigationController pushViewController:loginMainViewController animated:YES];
}

-(void)doTenLogin{
    self.hidden = YES;
    
    isPushSocialView = YES;
    
    BOOL isOauth = [UMSocialAccountManager isOauthWithPlatform:UMShareToQQ];
    if (isOauth) {
        //TODO:有登录过，如何处理
        //return;
    }
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    snsPlatform.loginClickHandler(_mainViewController,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response)
                                  {
                                      //加载登录进度条
                                      _hud = [MBProgressHUD showHUDAddedTo:_mainViewController.view animated:YES];
                                      _hud.mode = MBProgressHUDModeIndeterminate;
                                      _hud.alpha = 0.5;
                                      _hud.color = [UIColor grayColor];
                                      _hud.labelText = @"登录验证中...";
                                      
                                      if ([[snsPlatform platformName] isEqualToString:UMShareToQQ])
                                      {
                                          [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *accountResponse){
                                              if ([[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToQQ] == NULL) {
                                                  [MBProgressHUD hideHUDForView:_mainViewController.view animated:YES];
                                                  return;
                                              }
                                              
                                              //封装数据
                                              NSMutableDictionary *dictBody = [[DataContract dataContract]UserCreateDict:RTYPE_TENCENT account:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToQQ] objectForKey:@"username"]  password:@""];
                                              
                                              
                                              
                                              //Http请求
                                              [[NetWorkConnect sharedRequest]
                                               httpRequestWithURL:USER_LOGIN_URL
                                               data:dictBody
                                               mode:@"POST"
                                               HUD:_hud
                                               didFinishBlock:^(NSDictionary *result){
                                                   _hud.labelText = [result objectForKey:@"msg"];
                                                   //处理反馈信息: code=1为成功  code=99为失败
                                                   if ([[result objectForKey:@"code"]intValue] == 1) {
                                                       NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToQQ] objectForKey:@"username"]  forKey:@"ACCOUNT_NAME"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RTYPE_TENCENT] forKey:@"ACCOUNT_TYPE"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"ACCOUNT_UID"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"cur_userid"];
                                                       [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
                                                       //数据库保存用户信息
                                                       if ([[UserDataDB dataBase] selectUser:[[resultBody objectForKey:@"userId"] intValue]] == nil){
                                                           [[UserDataDB dataBase] createNewUser:[[resultBody objectForKey:@"userId"]intValue] andCategoryIds:@"" andIcon:@"" andUserType:RTYPE_TENCENT andUserAccount:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToQQ] objectForKey:@"username"]   andAppVer:PROVERSION andCreateTime:[[resultBody objectForKey:@"createTime"] longValue] andUpdateTime:[[resultBody objectForKey:@"updateTime"] longValue]];
                                                       }
                                                       //提示是否同步数据
                                                       [_hud hide:YES];
                                                       [self performSelector:@selector(isSyncData) withObject:nil afterDelay:0.8];
                                                   }
                                                   else{
                                                       [_hud hide:YES afterDelay:1.2];
                                                   }
                                               }
                                               didFailBlock:^(NSString *error){
                                                   //请求失败处理
                                                   _hud.labelText = http_error;
                                                   [_hud hide:YES afterDelay:1];
                                               }
                                               isShowProgress:YES
                                               isAsynchronic:YES
                                               netWorkStatus:YES
                                               viewController:_mainViewController];
                                              
                                          }];
                                      }
                                  });
}

-(void)doTentWeiboLogin{
    self.hidden = YES;
    
    isPushSocialView = YES;
    
    BOOL isOauth = [UMSocialAccountManager isOauthWithPlatform:UMShareToTencent];
    if (isOauth) {
        //TODO:有登录过，如何处理
        //return;
    }
    //
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToTencent];
    snsPlatform.loginClickHandler(_mainViewController,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response)
                                  {
                                      //加载登录进度条
                                      _hud = [MBProgressHUD showHUDAddedTo:_mainViewController.view animated:YES];
                                      _hud.mode = MBProgressHUDModeIndeterminate;
                                      _hud.alpha = 0.5;
                                      _hud.color = [UIColor grayColor];
                                      _hud.labelText = @"登录验证中...";
                                      
                                      if ([[snsPlatform platformName] isEqualToString:UMShareToTencent])
                                      {
                                          [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *accountResponse){
                                              if ([[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToTencent] == NULL) {
                                                  [MBProgressHUD hideHUDForView:_mainViewController.view animated:YES];
                                                  return;
                                              }
                                              
                                              //封装数据
                                              NSMutableDictionary *dictBody = [[DataContract dataContract]UserCreateDict:RTYPE_TENCENT account:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToTencent] objectForKey:@"username"]  password:@""];
                                              //Http请求
                                              [[NetWorkConnect sharedRequest]
                                               httpRequestWithURL:USER_LOGIN_URL
                                               data:dictBody
                                               mode:@"POST"
                                               HUD:_hud
                                               didFinishBlock:^(NSDictionary *result){
                                                   _hud.labelText = [result objectForKey:@"msg"];
                                                   //处理反馈信息: code=1为成功  code=99为失败
                                                   if ([[result objectForKey:@"code"]intValue] == 1) {
                                                       NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToTencent] objectForKey:@"username"]  forKey:@"ACCOUNT_NAME"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RTYPE_TENCENT] forKey:@"ACCOUNT_TYPE"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"ACCOUNT_UID"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"cur_userid"];
                                                       [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
                                                       //数据库保存用户信息
                                                       if ([[UserDataDB dataBase] selectUser:[[resultBody objectForKey:@"userId"] intValue]] == nil){
                                                           [[UserDataDB dataBase] createNewUser:[[resultBody objectForKey:@"userId"]intValue] andCategoryIds:@"" andIcon:@"" andUserType:RTYPE_TENCENT andUserAccount:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToTencent] objectForKey:@"username"]   andAppVer:PROVERSION andCreateTime:[[resultBody objectForKey:@"createTime"] longValue] andUpdateTime:[[resultBody objectForKey:@"updateTime"] longValue]];
                                                       }
                                                       //提示是否同步数据
                                                       [_hud hide:YES];
                                                       [self performSelector:@selector(isSyncData) withObject:nil afterDelay:0.8];
                                                   }
                                                   else{
                                                       [_hud hide:YES afterDelay:1.2];
                                                   }
                                               }
                                               didFailBlock:^(NSString *error){
                                                   //请求失败处理
                                                   _hud.labelText = http_error;
                                                   [_hud hide:YES afterDelay:1];
                                               }
                                               isShowProgress:YES
                                               isAsynchronic:YES
                                               netWorkStatus:YES
                                               viewController:_mainViewController];
                                              
                                          }];
                                      }
                                  });
}

-(void)doSinaLogin{
    self.hidden = YES;
    
    isPushSocialView = YES;
    [[UMSocialDataService defaultDataService] requestAddFollow:UMShareToSina followedUsid:@[SINA_WEIBO_ID] completion:nil];
    
    [UMSocialConfig setFollowWeiboUids:[NSDictionary dictionaryWithObjectsAndKeys:SINA_WEIBO_ID,UMShareToSina,nil]];
    
    BOOL isOauth = [UMSocialAccountManager isOauthWithPlatform:UMShareToSina];
    if (isOauth) {
        //TODO:有登录过，如何处理
        //return;
    }
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    
    snsPlatform.loginClickHandler(_mainViewController,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response)
                                  {
                                      //加载登录进度条
                                      _hud = [MBProgressHUD showHUDAddedTo:_mainViewController.view animated:YES];
                                      _hud.mode = MBProgressHUDModeIndeterminate;
                                      _hud.alpha = 0.5;
                                      _hud.color = [UIColor grayColor];
                                      _hud.labelText = @"登录验证中...";
                                      
                                      if ([[snsPlatform platformName] isEqualToString:UMShareToSina])
                                      {
                                          [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *accountResponse){
                                              if ([[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] == NULL) {
                                                  [MBProgressHUD hideHUDForView:_mainViewController.view animated:YES];
                                                  return;
                                              }
                                              //封装数据
                                              NSMutableDictionary *dictBody = [[DataContract dataContract]UserCreateDict:RTYPE_SINA account:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]  password:@""];
                                              
                                              //Http请求
                                              [[NetWorkConnect sharedRequest]
                                               httpRequestWithURL:USER_LOGIN_URL
                                               data:dictBody
                                               mode:@"POST"
                                               HUD:_hud
                                               didFinishBlock:^(NSDictionary *result){
                                                   _hud.labelText = [result objectForKey:@"msg"];
                                                   //处理反馈信息: code=1为成功  code=99为失败
                                                   if ([[result objectForKey:@"code"]intValue] == 1) {
                                                       NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]  forKey:@"ACCOUNT_NAME"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RTYPE_TENCENT] forKey:@"ACCOUNT_TYPE"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"ACCOUNT_UID"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"cur_userid"];
                                                       [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
                                                       //数据库保存用户信息
                                                       if ([[UserDataDB dataBase] selectUser:[[resultBody objectForKey:@"userId"] intValue]] == nil){
                                                           [[UserDataDB dataBase] createNewUser:[[resultBody objectForKey:@"userId"]intValue] andCategoryIds:@"" andIcon:@"" andUserType:RTYPE_SINA andUserAccount:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]   andAppVer:PROVERSION andCreateTime:[[resultBody objectForKey:@"createTime"] longValue] andUpdateTime:[[resultBody objectForKey:@"updateTime"] longValue]];
                                                       }
                                                       //提示是否同步数据
                                                       [_hud hide:YES];
                                                       [self performSelector:@selector(isSyncData) withObject:nil afterDelay:0.8];
                                                   }
                                                   else{
                                                       [_hud hide:YES afterDelay:1.2];
                                                   }
                                               }
                                               didFailBlock:^(NSString *error){
                                                   //请求失败处理
                                                   _hud.labelText = http_error;
                                                   [_hud hide:YES afterDelay:1];
                                               }
                                               isShowProgress:YES
                                               isAsynchronic:YES
                                               netWorkStatus:YES
                                               viewController:_mainViewController];
                                          }];
                                      }
                                  });
    
}

-(void)isSyncData{
    [self checkBaby];
    
    /*UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否同步该账户数据" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
     alertView.tag = 10109;
     [alertView show];
     */
}

#pragma 检测or创建宝贝
-(void)checkBaby{
    if (ACCOUNTUID) {
        int babyId=0;
        /*
         *  判断该账户下是否已有宝宝,如有,则默认加载
         */
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
        BOOL isDir = NO;
        for (NSString *file in fileList) {
            NSString *path = [documentDir stringByAppendingPathComponent:file];
            [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
            if (isDir) {
                NSArray *split = [file componentsSeparatedByString:@"_"];
                if ([split count] == 2 && [[split objectAtIndex:0] intValue] == ACCOUNTUID) {
                    babyId = [[split objectAtIndex:1] intValue];
                    break;
                }
            }
            isDir = NO;
        }
        
        if (babyId != 0) {
            //保存Babyid
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:babyId] forKey:@"BABYID"];
            [[NSUserDefaults standardUserDefaults] setInteger:babyId forKey:@"cur_babyid"];
            NSDictionary *dict = [[BabyDataDB babyinfoDB] selectBabyInfoByBabyId:babyId];
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"nickname"] forKey:@"kBabyNickname"];
            _mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            //隐藏登陆页面
            self.hidden = YES;
            [_mainViewController viewWillAppear:YES];
            [_mainViewController.navigationController popToViewController:_mainViewController animated:NO];
            return;
        }
        
        if (!BABYID) {
            //注册接口
            if (![_hud isHidden]) {
                _hud = [MBProgressHUD showHUDAddedTo:_mainViewController.view animated:YES];
                //隐藏键盘
                _hud.mode = MBProgressHUDModeIndeterminate;
                _hud.alpha = 0.5;
                _hud.color = [UIColor grayColor];
            }
            _hud.labelText = http_requesting;
            //封装数据
            NSMutableDictionary *dictBody = [[DataContract dataContract]BabyCreateByUserIdDict:ACCOUNTUID];
            
            //隐藏登陆页面
            self.hidden = YES;
            //Http请求
            [[NetWorkConnect sharedRequest]
             httpRequestWithURL:BABY_CREATEBYUSERID_URL
             data:dictBody
             mode:@"POST"
             HUD:_hud
             didFinishBlock:^(NSDictionary *result){
                 _hud.labelText = [result objectForKey:@"msg"];
                 //处理反馈信息: code=1为成功  code=99为失败
                 if ([[result objectForKey:@"code"]intValue] == 1) {
                     NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                     //保存Babyid
                     [[NSUserDefaults standardUserDefaults]setObject:[resultBody objectForKey:@"babyId"] forKey:@"BABYID"];
                     //数据库保存Baby信息
                     [BabyDataDB createNewBabyInfo:ACCOUNTUID BabyId:BABYID Nickname:@"" Birthday:nil Sex:nil HeadPhoto:@"" RelationShip:@"" RelationShipNickName:@"" Permission:nil CreateTime:[resultBody objectForKey:@"create_time"] UpdateTime:nil];
                     
                     _mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                     [_mainViewController.navigationController popToViewController:_mainViewController animated:NO];
                     [_hud hide:YES afterDelay:1];
                 }
                 else{
                     _hud.labelText = http_error;
                     [_hud hide:YES afterDelay:1];
                 }
                 
                 [_mainViewController viewWillAppear:YES];
             }
             didFailBlock:^(NSString *error){
                 //请求失败处理
                 _hud.labelText = http_error;
                 [_hud hide:YES afterDelay:1];
                 
                 [_mainViewController viewWillAppear:YES];
             }
             isShowProgress:YES
             isAsynchronic:NO
             netWorkStatus:YES
             viewController:_mainViewController];
        }
    }
}

@end
