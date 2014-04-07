//
//  defaultAppDelegate.m
//  Parenting
//
//  Created by 爱摩信息科技 on 13-5-16.
//  Copyright (c) 2013年 家明. All rights reserved.
//

#import "defaultAppDelegate.h"
#import "APService.h"
#import "UMSocial.h" 
#import "LoginViewController.h"

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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.applicationIconBadgeNumber = 0;

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
        NSString *document  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *newFile = [document stringByAppendingPathComponent:@"BC_Info.sqlite"];
        NSString *oldFile = [[NSBundle mainBundle] pathForResource:@"BC_Info" ofType:@"sqlite"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager copyItemAtPath:oldFile toPath:newFile error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ISEXISIT_BC_INFO"];
    }

    
    [self tap];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"btn_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,14, 0, 8)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"btn3.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"btn3.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
     [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_title.png"]  forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setBarTintColor:[ACFunction colorWithHexString:@"0x68bfcc"]];
    
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

    [MobClick startWithAppkey:UMENGAPPKEY];
    [MobClick checkUpdate];

    // Required
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    // Required
    [APService setupWithOption:launchOptions];
    
    //[APService setAlias:@"test" callbackSelector:nil object:self];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kAPNetworkDidReceiveMessageNotification object:nil];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BLE_ENV"] != nil)
    {
        bleweatherCtrler = [BLEWeatherController bleweathercontroller];

    }
    
    [MAMapServices sharedServices].apiKey = AMAP_KEY;
    
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = @selector(openUDIDString);
//    NSString *deviceID = nil;
//    if(cls && [cls respondsToSelector:deviceIDSelector]){
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSLog(@"{\"oid\": \"%@\"}", deviceID);
    
    return YES;
}

-(void)tap
{
    //homeViewController    = [[HomeViewController alloc] init];
    summaryViewController   = [SummaryViewController summary];
    //adviseViewController  = [[AdviseMasterViewController alloc] init];
    //settingViewController = [[SettingViewController alloc] init];
    //icViewController      = [[InformationCenterViewController alloc] init];
    myPageViewController   = [[MyPageViewController alloc] init];
    envirViewController    = [[EnviromemtViewController alloc] init];
    actViewController      = [[ActivityViewController alloc] init];
    phyViewController      = [[PhysiologyViewController alloc] init];
    calendarViewController = [[CalendarViewController alloc] init];
    guideViewController    = [[GuideViewController alloc] init];
    loginViewController    = [[LoginViewController alloc] init];
    
    myPageNavigationViewController   = [[UINavigationController alloc]
                                        initWithRootViewController:myPageViewController];
    envirNavigationViewController    = [[UINavigationController alloc]
                                        initWithRootViewController:envirViewController];
    actNavigationViewController      = [[UINavigationController alloc]
                                        initWithRootViewController:actViewController];
    phyNavigationViewController      = [[UINavigationController alloc]
                                        initWithRootViewController:phyViewController];
    calendarNavigationViewController = [[UINavigationController alloc]
                                        initWithRootViewController:calendarViewController];
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];

    [controllers addObject:myPageNavigationViewController];
    [controllers addObject:envirNavigationViewController];
    [controllers addObject:actNavigationViewController];
    [controllers addObject:phyNavigationViewController];
    [controllers addObject:calendarNavigationViewController];
    
    myTabController = [[MyTabBarController alloc] init];
    [myTabController setViewControllers:controllers];
    
    //FIXME:TEST
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ACCOUNT_NAME"];
    
    //  向导版本有更新则跳转
    if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"GUIDE_V"]  isEqual: GUIDE_V]){
        guideViewController.mainViewController = myTabController;
        self.window.rootViewController = guideViewController;
        [[NSUserDefaults standardUserDefaults] setObject:GUIDE_V forKey:@"GUIDE_V"];
    }
    //  未登录账号则跳转
    else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] == nil){
        UINavigationController *loginNavigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.mainViewController = myTabController;
        self.window.rootViewController = loginNavigationController;
    }
    else{
        self.window.rootViewController  = myTabController;
    }
    
    [self initializePlat];
}

- (void)initializePlat
{
    //添加新浪微博应用
    [UMSocialData setAppKey:UMENGAPPKEY];
    [UMSocialConfig setSupportSinaSSO:YES];
    //[ShareSDK connectSinaWeiboWithAppKey:@"2712555917"
    //                           appSecret:@"c76318d478ffd11a81ee70b424f1b162"
    //                         redirectUri:@"http://open.weibo.com/apps/2712555917"];
        
    //添加Facebook应用
    //[ShareSDK connectFacebookWithAppKey:@"315050775296347"
    //                          appSecret:@"2504ebbdbb8c22bd482b905edaf4a16c"];
    
//    //添加腾讯微博应用
//    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
//                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
//                                redirectUri:@"http://www.sharesdk.cn"];
//    
//    //添加QQ空间应用
//    [ShareSDK connectQZoneWithAppKey:@"100371282"
//                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"];
//    
//    //添加网易微博应用
//    [ShareSDK connect163WeiboWithAppKey:@"T5EI7BXe13vfyDuy"
//                              appSecret:@"gZxwyNOvjFYpxwwlnuizHRRtBRZ2lV1j"
//                            redirectUri:@"http://www.shareSDK.cn"];
//    
//    //添加搜狐微博应用
//    [ShareSDK connectSohuWeiboWithConsumerKey:@"SAfmTG1blxZY3HztESWx"
//                               consumerSecret:@"yfTZf)!rVwh*3dqQuVJVsUL37!F)!yS9S!Orcsij"
//                                  redirectUri:@"http://www.sharesdk.cn"];
//    
//    //添加豆瓣应用
//    [ShareSDK connectDoubanWithAppKey:@"07d08fbfc1210e931771af3f43632bb9"
//                            appSecret:@"e32896161e72be91"
//                          redirectUri:@"http://dev.kumoway.com/braininference/infos.php"];
//    
//    //添加人人网应用
//    [ShareSDK connectRenRenWithAppKey:@"fc5b8aed373c4c27a05b712acba0f8c3"
//                            appSecret:@"f29df781abdd4f49beca5a2194676ca4"];
//    
//    //添加开心网应用
//    [ShareSDK connectKaiXinWithAppKey:@"358443394194887cee81ff5890870c7c"
//                            appSecret:@"da32179d859c016169f66d90b6db2a23"
//                          redirectUri:@"http://www.sharesdk.cn/"];
//    
//    //添加Instapaper应用
//    [ShareSDK connectInstapaperWithAppKey:@"4rDJORmcOcSAZL1YpqGHRI605xUvrLbOhkJ07yO0wWrYrc61FA"
//                                appSecret:@"GNr1GespOQbrm8nvd7rlUsyRQsIo3boIbMguAl9gfpdL0aKZWe"];
//    
//    //添加有道云笔记应用
//    [ShareSDK connectYouDaoNoteWithConsumerKey:@"dcde25dca105bcc36884ed4534dab940"
//                                consumerSecret:@"d98217b4020e7f1874263795f44838fe"
//                                   redirectUri:@"http://www.sharesdk.cn/"];
    
//    //添加Facebook应用
//    [ShareSDK connectFacebookWithAppKey:@"107704292745179"
//                              appSecret:@"38053202e1a5fe26c80c753071f0b573"];
    
//    //添加Twitter应用
//    [ShareSDK connectTwitterWithConsumerKey:@"mnTGqtXk0TYMXYTN7qUxg"
//                             consumerSecret:@"ROkFqr8c3m1HXqS3rm3TJ0WkAJuwBOSaWhPbZ9Ojuc"
//                                redirectUri:@"http://www.sharesdk.cn"];
//    
//    //添加搜狐随身看应用
//    [ShareSDK connectSohuKanWithAppKey:@"e16680a815134504b746c86e08a19db0"
//                             appSecret:@"b8eec53707c3976efc91614dd16ef81c"
//                           redirectUri:@"http://sharesdk.cn"];
//    
//    //添加Pocket应用
//    [ShareSDK connectPocketWithConsumerKey:@"11496-de7c8c5eb25b2c9fcdc2b627"
//                               redirectUri:@"pocketapp1234"];
//    
//    //添加印象笔记应用
//    [ShareSDK connectEvernoteWithType:SSEverNoteTypeSandbox
//                          consumerKey:@"sharesdk-7807"
//                       consumerSecret:@"d05bf86993836004"];
//    
//    //添加LinkedIn应用
//    [ShareSDK connectLinkedInWithApiKey:@"ejo5ibkye3vo"
//                              secretKey:@"cC7B2jpxITqPLZ5M"
//                            redirectUri:@"http://sharesdk.cn"];
    
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
    return TRUE;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
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

    [DataBase insertNotifyMessage:content];
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [APService registerDeviceToken:deviceToken];
   
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    //NSString *extras = [userInfo valueForKey:@"extras"];
    //NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
    [DataBase insertNotifyMessage:content];
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
