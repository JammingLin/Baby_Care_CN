//
//  LoginViewController.m
//  LoginModule
//
//  Created by CHEN WEIBIN on 13-12-26.
//  Copyright (c) 2013年 CHEN WEIBIN. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginMainViewController.h"
#import "UMSocial.h" 
#import "MBProgressHUD.h"
#import "MD5.h"
#import "APService.h"
#import "DataContract.h"
#import "NetWorkConnect.h"  
#import "UserDataDB.h"
#import "SyncController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //    [self.tabBarController.tabBarItem setImage:[UIImage imageNamed:@"menu1.png"]];
        //self.automaticallyAdjustsScrollViewInsets = NO;
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if ( IOS7_OR_LATER )
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
#endif  // #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isPushSocialView = NO;
    [_buttonLogin addTarget:self action:@selector(goLogin) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (isPushSocialView) {
        isPushSocialView = NO;
    }
    else{
        self.navigationController.navigationBarHidden = NO;
    }
} 

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.translucent = NO;
}

- (void) move:(UIView*)view toY:(CGFloat)y
{
    CGRect frame = view.frame;
    frame.origin.y = y;
    view.frame = frame;
}

- (IBAction)goBack:(id)sender {
    _mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:_mainViewController animated:YES completion:^{}];
}

//跳转到APP登录页面
-(void)goLogin
{
    LoginMainViewController *loginMainViewController = [[LoginMainViewController alloc]initWithNibName:@"LoginMainViewController" bundle:nil];
    loginMainViewController.mainViewController = _mainViewController;
    [self.navigationController pushViewController:loginMainViewController animated:YES];
}

- (IBAction)goLoginByTencent:(id)sender {
    isPushSocialView = YES;
    
    BOOL isOauth = [UMSocialAccountManager isOauthWithPlatform:UMShareToTencent];
    if (isOauth) {
        //TODO:有登录过，如何处理
        //return;
    }
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToTencent];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response)
    {
        //加载登录进度条
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.alpha = 0.5;
        hud.color = [UIColor grayColor];
        hud.labelText = @"登录验证中...";
        
        if ([[snsPlatform platformName] isEqualToString:UMShareToTencent])
        {
                [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *accountResponse){
                    if ([[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToTencent] == NULL) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        return;
                    }
                    
                    //封装数据
                    NSMutableDictionary *dictBody = [[DataContract dataContract]UserCreateDict:RTYPE_TENCENT account:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToTencent] objectForKey:@"username"]  password:@""];
                    //Http请求
                    [[NetWorkConnect sharedRequest]
                     httpRequestWithURL:USER_LOGIN_URL
                     data:dictBody
                     mode:@"POST"
                     HUD:hud
                     didFinishBlock:^(NSDictionary *result){
                         hud.labelText = [result objectForKey:@"msg"];
                         //处理反馈信息: code=1为成功  code=99为失败
                         if ([[result objectForKey:@"code"]intValue] == 1) {
                             NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                             [[NSUserDefaults standardUserDefaults] setObject:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]  forKey:@"ACCOUNT_NAME"];
                             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RTYPE_TENCENT] forKey:@"ACCOUNT_TYPE"];
                             [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"ACCOUNT_UID"];
                             [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
                             //数据库保存用户信息
                             if ([[UserDataDB dataBase] selectUser:[[resultBody objectForKey:@"userId"] intValue]] == nil){
                                 [[UserDataDB dataBase] createNewUser:[[resultBody objectForKey:@"userId"]intValue] andCategoryIds:@"" andIcon:@"" andUserType:RTYPE_TENCENT andUserAccount:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]   andAppVer:PROVERSION andCreateTime:[[resultBody objectForKey:@"createTime"] longValue] andUpdateTime:[[resultBody objectForKey:@"updateTime"] longValue]];
                             } 
                             //提示是否同步数据
                             [hud hide:YES];
                             [self performSelector:@selector(isSyncData) withObject:nil afterDelay:0.8];
                         }
                         else{
                             [hud hide:YES afterDelay:1.2];
                         }
                     }
                     didFailBlock:^(NSString *error){
                         //请求失败处理
                         hud.labelText = http_error;
                         [hud hide:YES afterDelay:1];
                     }
                     isShowProgress:YES
                     isAsynchronic:YES
                     netWorkStatus:YES
                     viewController:self];
                
                }];
        }
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10109)
    {
        //1同步数据 0不同步直接跳转
        if (buttonIndex == 1) {
            [[SyncController syncController]syncBabyDataCollectionsByUserID:ACCOUNTUID HUD:hud SyncFinished:^(){
                _mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:_mainViewController animated:YES completion:^{}];
            }   ViewController:self];
        }
        else{
            _mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:_mainViewController animated:YES completion:^{}];
        }
    }

}

- (IBAction)goLoginBySina:(id)sender {
    isPushSocialView = YES;
    BOOL isOauth = [UMSocialAccountManager isOauthWithPlatform:UMShareToSina];
    if (isOauth) {
        //TODO:有登录过，如何处理
        //return;
    }
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response)
    {
        //加载登录进度条
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.alpha = 0.5;
        hud.color = [UIColor grayColor];
        hud.labelText = @"登录验证中...";
        
        if ([[snsPlatform platformName] isEqualToString:UMShareToSina])
        {
            [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *accountResponse){
                if ([[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] == NULL) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    return;
                }
                //封装数据
                NSMutableDictionary *dictBody = [[DataContract dataContract]UserCreateDict:RTYPE_SINA account:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]  password:@""];
                //Http请求
                [[NetWorkConnect sharedRequest]
                 httpRequestWithURL:USER_LOGIN_URL
                 data:dictBody
                 mode:@"POST"
                 HUD:hud
                 didFinishBlock:^(NSDictionary *result){
                     hud.labelText = [result objectForKey:@"msg"];
                     //处理反馈信息: code=1为成功  code=99为失败
                     if ([[result objectForKey:@"code"]intValue] == 1) {
                         NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                         [[NSUserDefaults standardUserDefaults] setObject:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]  forKey:@"ACCOUNT_NAME"];
                         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RTYPE_TENCENT] forKey:@"ACCOUNT_TYPE"];
                         [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"ACCOUNT_UID"];
                         [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
                         //数据库保存用户信息
                         if ([[UserDataDB dataBase] selectUser:[[resultBody objectForKey:@"userId"] intValue]] == nil){
                             [[UserDataDB dataBase] createNewUser:[[resultBody objectForKey:@"userId"]intValue] andCategoryIds:@"" andIcon:@"" andUserType:RTYPE_SINA andUserAccount:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]   andAppVer:PROVERSION andCreateTime:[[resultBody objectForKey:@"createTime"] longValue] andUpdateTime:[[resultBody objectForKey:@"updateTime"] longValue]];
                         }
                         //提示是否同步数据
                         [hud hide:YES];
                         [self performSelector:@selector(isSyncData) withObject:nil afterDelay:0.8];
                     }
                     else{
                         [hud hide:YES afterDelay:1.2];
                     }
                 }
                 didFailBlock:^(NSString *error){
                     //请求失败处理
                     hud.labelText = http_error;
                     [hud hide:YES afterDelay:1];
                 }
                 isShowProgress:YES
                 isAsynchronic:YES
                 netWorkStatus:YES
                 viewController:self];
            }];
        }
    });
}

-(void)isSyncData{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否同步该账户数据" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertView.tag = 10109;
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
