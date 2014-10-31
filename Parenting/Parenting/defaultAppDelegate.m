//
//  defaultAppDelegate.m
//  Parenting
//
//  Created by 爱摩信息科技 on 13-5-16.
//  Copyright (c) 2013年 家明. All rights reserved.
//

#import "defaultAppDelegate.h"
#import "APService.h"
#import "LoginViewController.h"
#import "SyncController.h"
#import <TestinAgent/TestinAgent.h>
#import "UMSocialTencentWeiboHandler.h"

@implementation defaultAppDelegate

NSUncaughtExceptionHandler* _uncaughtExceptionHandler = nil;
void UncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    // 出现异常的原因
    NSString *reason = [exception reason];
    // 异常名称
    NSString *name = [exception name];
    NSString *syserror = [NSString stringWithFormat:@"mailto://amoycaretech@gmail.com?subject=Bug Report&body=Thank you for your coordination!<br><br><br>"
                          "Crash Detail:<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@",
                          name,reason,[stackArray componentsJoinedByString:@"<br>"]];
    NSURL *url = [NSURL URLWithString:[syserror stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
    return;
}


- (void)getRemoteNotify:(NSDictionary*)notifyDic
{
    NSDictionary* pushNotification = [notifyDic objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSDictionary *aps = [pushNotification valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的
    if (![content isEqualToString:@""] && content != nil) {
        [[UserDataDB dataBase] insertNotifyMessage:content andTitle:content];
    }
    
    int badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.applicationIconBadgeNumber = 0;

    [self getRemoteNotify:launchOptions];
    
    [self initializePlat];
    // Override point for customization after application launch.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
       
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        self.window.clipsToBounds =YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"timerOn"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"hastimerbefore" forKey:@"timerOnBefore"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userreviews"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"none" forKey:@"userreviews"];
        [[NSUserDefaults standardUserDefaults] setObject:[ACDate date] forKey:@"userstartuserdate"];
    }
    
    //复制db到document才
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ISEXISIT_BC_INFO"])
    {
        //BC_INFO表
        NSString *document  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *newFile = [document stringByAppendingPathComponent:@"BC_Info.sqlite"];
        NSString *oldFile = [[NSBundle mainBundle] pathForResource:@"BC_Info" ofType:@"sqlite"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        if ([fileManager copyItemAtPath:oldFile toPath:newFile error:&error]) {
             [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ISEXISIT_BC_INFO"];
        }
        
        /*
         *  新装APP由于未初始化数据库会导致数据库失败
         *  临时解决办法 - cwb
         */
        [[NSUserDefaults standardUserDefaults] setObject:kAccountGuest forKey:@"ACCOUNT_UID"];
        [[NSUserDefaults standardUserDefaults] setObject:kTempBaby forKey:@"BABYID"];
        
        [BabyDataDB createNewBabyInfo:ACCOUNTUID BabyId:BABYID Nickname:@"" Birthday:nil Sex:nil HeadPhoto:@"" RelationShip:@"" RelationShipNickName:@"" Permission:nil CreateTime:nil UpdateTime:nil];
        
    }
    [self tap];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"btn3.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"btn3.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
     [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f) {
        [[UINavigationBar appearance] setBarTintColor:[ACFunction colorWithHexString:@"0x68bfcc"]];

    }
    
    [[UINavigationBar appearance] setBackgroundColor:[ACFunction colorWithHexString:@"0x68bfcc"]];
    
    [[UINavigationBar appearance] setTintColor:[ACFunction colorWithHexString:@"0x68bfcc"]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],
                                                          UITextAttributeTextColor,
                                                          
                                                          [UIFont fontWithName:@"Arival-MTBOLD" size:20],
                                                
                                                UITextAttributeFont,
                                                          nil]];

    [self.window makeKeyAndVisible];

    _uncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    }
    else
    {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
#else
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
#endif
        // Required
        [APService setupWithOption:launchOptions];
    }
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"BLE_ENV"  forKey:@"BLE_ENV"];
//    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BLE_ENV"] != nil)
//    {
//        bleweatherCtrler = [BLEWeatherController bleweathercontroller];
//
//    }
    
    [MAMapServices sharedServices].apiKey = AMAP_KEY;
    
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = @selector(openUDIDString);
//    NSString *deviceID = nil;
//    if(cls && [cls respondsToSelector:deviceIDSelector]){
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSLog(@"{\"oid\": \"%@\"}", deviceID);
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    return YES;
}

-(void)tap
{
    summaryViewController     = [SummaryViewController summary];
    if (ISBLE)
    {
        envirViewController   = [[EnvironmentViewController alloc] init];
        settingViewController = [[SettingViewController alloc] init];
    }
    else
    {
        settingViewController = [[SettingViewController alloc] init];
    }
    homeViewController     = [[HomeViewController alloc] init];
    actViewController      = [[ActivityViewController alloc] init];
    phyViewController      = [[PhysiologyViewController alloc] init];
    calendarViewController = [[CalendarController alloc] init];
    guideViewController    = [[GuideViewController alloc] init];
    loginViewController    = [[LoginViewController alloc] init];
    
    myPageNavigationViewController   = [[BaseNavigationController alloc]
                                        initWithRootViewController:homeViewController];
    if (!ISBLE) {
        settingNavigationViewController    = [[BaseNavigationController alloc]
                                              initWithRootViewController:settingViewController];
    }
    else
    {
        settingNavigationViewController    = [[BaseNavigationController alloc]
                                              initWithRootViewController:settingViewController];
        envirNavigationViewController    = [[BaseNavigationController alloc]
                                        initWithRootViewController:envirViewController];
    }
    actNavigationViewController      = [[BaseNavigationController alloc]
                                        initWithRootViewController:actViewController];
    phyNavigationViewController      = [[BaseNavigationController alloc]
                                        initWithRootViewController:phyViewController];
    calendarNavigationViewController = [[BaseNavigationController alloc]
                                        initWithRootViewController:calendarViewController];
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];

    if (!ISBLE) {
        [controllers addObject:myPageNavigationViewController];
        [controllers addObject:calendarNavigationViewController];
        [controllers addObject:actNavigationViewController];
        [controllers addObject:phyNavigationViewController];
        [controllers addObject:settingNavigationViewController];
    }
    else
    {
        [controllers addObject:myPageNavigationViewController];
        [controllers addObject:calendarNavigationViewController];
        [controllers addObject:actNavigationViewController];
        //[controllers addObject:phyNavigationViewController];
        [controllers addObject:envirNavigationViewController];
        [controllers addObject:settingNavigationViewController];
    }
    
    myTabController = [[MyTabBarController alloc] init];
    [myTabController setViewControllers:controllers];
     
    
    //  向导版本有更新则跳转
    if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"GUIDE_V"]  isEqual: GUIDE_V]){
        guideViewController.mainViewController = myTabController;
        self.window.rootViewController = guideViewController;
        [[NSUserDefaults standardUserDefaults] setObject:GUIDE_V forKey:@"GUIDE_V"];
    }
    /*  未登录账号则跳转
     *  登陆移到首页时处理 - 20140914 by cwb
    else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] == nil){
        UINavigationController *loginNavigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.mainViewController = myTabController;
        self.window.rootViewController = loginNavigationController;
    }*/
    else{
        self.window.rootViewController  = myTabController;
    }
//    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
    
    /*
     同步数据
     */
    [[SyncController syncController] SyncBasicContent];
}

- (void)initializePlat
{
    //Testin Crash
    [TestinAgent init:TESTIN_KEY];
    
    //UMeng 统计
    [MobClick startWithAppkey:UMENGAPPKEY];
    
    [MobClick checkUpdate];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] != nil)
    {
        [TestinAgent setUserInfo:[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"]];
    }

    
    //添加新浪微博应用
    [UMSocialConfig setFollowWeiboUids:[NSDictionary dictionaryWithObjectsAndKeys:SINA_WEIBO_ID,UMShareToSina,nil]];

    [UMSocialData setAppKey:UMENGAPPKEY];
    
    //添加QQ分享
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:QQAPPKEY url:@"http://www.umeng.com/social"];
    
    //添加微信分享
    [UMSocialWechatHandler setWXAppId:WXAPPID appSecret:WXSECRETKEY url:@"http://www.umeng.com/social"];
    
    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] != nil) {
        [[ASIController asiController] postLoginState:0];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"weather"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"weather"];
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    


}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] != nil) {
        [[ASIController asiController] postLoginState:1];
    }
    
    application.applicationIconBadgeNumber = 0;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"weather"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"weather"];
    }
    
    [UMSocialSnsService  applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] != nil) {
        [[ASIController asiController] postLoginState:-1];
    }
    
    _uncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    //return [ShareSDK handleOpenURL:url
    //                    wxDelegate:self];
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如新浪微博SDK等
    }
    return  result;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如新浪微博SDK等
    }
    return  result;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Required
    // 取得 APNs 标准信息内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
    //NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
    //NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
    
    // 取得自定义字段内容
    //NSString *customizeField1 = [userInfo valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
    //NSLog(@"content =[%@], badge=[%d], sound=[%@], customize field =[%@]",content,badge,sound,customizeField1);
    
    application.applicationIconBadgeNumber += 1;
    //当用户打开程序时候收到远程通知后执行
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:[NSString stringWithFormat:@"\n%@",
                                                                     [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            //hide the badge
            application.applicationIconBadgeNumber = 0;
            
        });
        
        [alertView show];
    }

    [[UserDataDB dataBase] insertNotifyMessage:content andTitle:content];
    
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [APService registerDeviceToken:deviceToken];
   
}

- (void)networkDidReceiveMessage:(NSNotification *)notification
{
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    //NSString *extras = [userInfo valueForKey:@"extras"];
    //NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
    [[UserDataDB dataBase] insertNotifyMessage:content andTitle:content];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (notification) {
        NSLog(@"didFinishLaunchingWithOptions");
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:nil message:notification.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

@end
