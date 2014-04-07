//
//  SettingViewController.m
//  Parenting
//
//  Created by 家明 on 13-5-17.
//  Copyright (c) 2013年 家明. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingItem.h"
#import "CopyrightViewController.h"
#import "BabyinfoViewController.h"
#import "defaultAppDelegate.h"
#import "UMFeedbackViewController.h"
#import "MyLocalNofityViewController.h"
#import "MyDevicesViewController.h"
#import "LoginViewController.h"

@interface SettingViewController ()
@property (strong, nonatomic) UITableView *settingTable;
@property (strong, nonatomic) NSArray *settingArray;
@end

@implementation SettingViewController
@synthesize permissions,
loginSuccessLabel,
shareInfoLabel,
messageLabel,
settingArray=_settingArray,
settingTable=_settingTable,
messageView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 100, 20)];
        titleView.backgroundColor=[UIColor clearColor];
        UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        titleText.backgroundColor = [UIColor clearColor];
        [titleText setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20]];
        titleText.textColor = [UIColor whiteColor];
        [titleText setTextAlignment:NSTextAlignmentCenter];
        [titleText setText:NSLocalizedString(@"tabbarsettings", nil)];
        [titleView addSubview:titleText];
        
        self.navigationItem.titleView = titleView;
        //self.title  =NSLocalizedString(@"tabbarsettings", nil);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareMessage) name:@"share" object:nil];
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if ( IOS7_OR_LATER )
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
#endif  // #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        //self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"设置页面"];
    
    [self makeArray];
    [self.settingTable reloadData];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        buttonForFacebook.selected=YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"设置页面"];
}

-(void)makeArray
{
    UIButton *tongbuBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [tongbuBtn setBackgroundImage:[UIImage imageNamed:@"all_toptongbu"] forState:UIControlStateNormal];
    
    [tongbuBtn addTarget:self action:@selector(tongbu) forControlEvents:UIControlEventTouchUpInside];
    tongbuBtn.frame=CGRectMake(0, 0, 22, 22);
    
    UIBarButtonItem *rightbar=[[UIBarButtonItem alloc]initWithCustomView:tongbuBtn];
    self.navigationItem.rightBarButtonItem=rightbar;

    NSMutableArray *_array1=[[NSMutableArray alloc]initWithCapacity:0];
    NSMutableArray *_array2=[[NSMutableArray alloc]initWithCapacity:0];
    NSMutableArray *_array3=[[NSMutableArray alloc]initWithCapacity:0];
    
    SettingItem *_item1 = [[SettingItem alloc]init];
    SettingItem *_item2 = [[SettingItem alloc]init];
    SettingItem *_item3 = [[SettingItem alloc]init];
    SettingItem *_item4=[[SettingItem alloc]init];
    SettingItem *_item5=[[SettingItem alloc]init];
    SettingItem *_item6 = [[SettingItem alloc]init];
    SettingItem *_item7 = [[SettingItem alloc]init];
    SettingItem *_item8 = [[SettingItem alloc]init];
    SettingItem *_item9 = [[SettingItem alloc]init];
    //cwb-AccountManage
    SettingItem *_item10 = [[SettingItem alloc]init];
    SettingItem *_item11 = [[SettingItem alloc] init];
    
    //高德地图
    SettingItem *_item12 = [[SettingItem alloc] init];
    SettingItem *_item13 = [[SettingItem alloc] init];
    
    _item1.name=NSLocalizedString(@"Baby information",nil);
    _item2.name=NSLocalizedString(@"Metric/Imperial",nil);
    _item3.name=NSLocalizedString(@"Notifications",nil);
    _item4.name=NSLocalizedString(@"Submit feedback online",nil);
    //    _item4.name=NSLocalizedString(@"Facebook",nil);
    _item5.name=NSLocalizedString(@"My Devices",nil);
    _item6.name=NSLocalizedString(@"Submit feedback/improvements",nil);
    _item7.name=NSLocalizedString(@"Copyright",nil);
    _item8.name=NSLocalizedString(@"Clear all logged data",nil);
    _item9.name=NSLocalizedString(@"LocalNotify", nil);
    _item11.name = @"2G/3G下自动备份";
    _item12.name = @"查看小区附近的麻麻们";
    _item13.name = @"允许发布自己位置及状态";
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] == nil) {
        _item10.name=@"账号登录";
        UIButton *buttonLogin=[UIButton buttonWithType:UIButtonTypeCustom];
        [buttonLogin setTitle:@"登录" forState:UIControlStateNormal];
        //FIXME:修改图片
        [buttonLogin setBackgroundImage:[UIImage imageNamed:@"btn_setting.png"] forState:UIControlStateNormal];
        [buttonLogin addTarget:self action:@selector(goLogin) forControlEvents:UIControlEventTouchUpInside];
        buttonLogin.bounds=CGRectMake(0, 0, 95, 30);
        _item10.accessView = buttonLogin;
    }
    else{
        _item10.name=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"]];
        UIButton *buttonLoginOut=[UIButton buttonWithType:UIButtonTypeCustom];
        [buttonLoginOut setTitle:@"登出" forState:UIControlStateNormal];
        //FIXME:修改图片
        [buttonLoginOut setBackgroundImage:[UIImage imageNamed:@"btn_delete.png"] forState:UIControlStateNormal];
        [buttonLoginOut addTarget:self action:@selector(goLoginOut) forControlEvents:UIControlEventTouchUpInside];
        buttonLoginOut.bounds=CGRectMake(0, 0, 95, 30);
        _item10.accessView = buttonLoginOut;
    }
    
    
    UIButton *detailforbaby=[UIButton buttonWithType:UIButtonTypeCustom];
    [detailforbaby setImage:[[UIImage imageNamed:@"btn_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    detailforbaby.frame=CGRectMake(0, 0, 20, 20);
    
    UIButton *detailforReview=[UIButton buttonWithType:UIButtonTypeCustom];
    [detailforReview setImage:[[UIImage imageNamed:@"btn_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    detailforReview.frame=CGRectMake(0, 0, 20, 20);
    
    UIButton *myreminder=[UIButton buttonWithType:UIButtonTypeCustom];
    [myreminder setImage:[[UIImage imageNamed:@"btn_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    myreminder.frame=CGRectMake(0, 0, 20, 20);
    
    UIButton *feedbackOnline=[UIButton buttonWithType:UIButtonTypeCustom];
    [feedbackOnline setImage:[[UIImage imageNamed:@"btn_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    feedbackOnline.frame=CGRectMake(0, 0, 20, 20);
    
    UIButton *myDevices=[UIButton buttonWithType:UIButtonTypeCustom];
    [myDevices setImage:[[UIImage imageNamed:@"btn_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    myDevices.frame=CGRectMake(0, 0, 20, 20);
    
    UIButton *detailforSubmit=[UIButton buttonWithType:UIButtonTypeCustom];
    [detailforSubmit setImage:[[UIImage imageNamed:@"btn_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    detailforSubmit.frame=CGRectMake(0, 0, 20, 20);
    
    
    UIButton *detailforCopyright=[UIButton buttonWithType:UIButtonTypeCustom];
    [detailforCopyright setImage:[[UIImage imageNamed:@"btn_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    detailforCopyright.frame=CGRectMake(0, 0, 20, 20);
    [detailforCopyright addTarget:self action:@selector(showCopyright) forControlEvents:UIControlEventTouchUpInside];
    
    segementForMetric=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
    
    UIButton *Metric=[UIButton buttonWithType:UIButtonTypeCustom];
    Metric.frame=CGRectMake(0, 0, 70, 30);
    [Metric setBackgroundImage:[UIImage imageNamed:@"feedway_left_focus.png"]  forState:UIControlStateDisabled];
    [Metric setBackgroundImage:[UIImage imageNamed:@"feedway_left.png"]  forState:UIControlStateNormal];
    [Metric setTitle:NSLocalizedString(@"Metric", nil)  forState:UIControlStateNormal];
    [Metric setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [Metric setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    Metric.tag=101;
    [segementForMetric addSubview:Metric];
    [Metric addTarget:self action:@selector(Metric:) forControlEvents:UIControlEventTouchUpInside];
    [self Metric:Metric];
    Metric.highlighted=NO;
    
    
    UIButton *Imperial=[UIButton buttonWithType:UIButtonTypeCustom];
    Imperial.frame=CGRectMake(70, 0, 80, 30);
    [Imperial setBackgroundImage:[[UIImage imageNamed:@"feedway_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 8, 20, 8) ] forState:UIControlStateNormal];
    [Imperial setBackgroundImage:[[UIImage imageNamed:@"feedway_right_focus.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(20, 8, 20, 8)] forState:UIControlStateDisabled];
    [Imperial setTitle:NSLocalizedString(@"Imperial",nil) forState:UIControlStateNormal];
    [segementForMetric addSubview:Imperial];
    Imperial.tag=102;
    [Imperial addTarget:self action:@selector(Metric:) forControlEvents:UIControlEventTouchUpInside];
    Imperial.highlighted=NO;
    [Imperial setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [Imperial setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    UISwitch *switchForNotifications=[[UISwitch alloc]init];
    switchForNotifications.on=YES;
    switchForNotifications.onTintColor=[UIColor colorWithRed:1/255.0 green:161/255.0 blue:190/255.0 alpha:1.000];
    [switchForNotifications addTarget:self action:@selector(chageNotification:) forControlEvents:UIControlEventValueChanged];
    
    UISwitch *switchForBackup=[[UISwitch alloc]init];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"2G/3GBackUp"] == TRUE)
    {
        switchForBackup.on = YES;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"2G/3GBackUp"];
        switchForBackup.on=NO;
    }
    
    switchForBackup.onTintColor=[UIColor colorWithRed:1/255.0 green:161/255.0 blue:190/255.0 alpha:1.000];
    [switchForBackup addTarget:self action:@selector(chageBackUp:) forControlEvents:UIControlEventValueChanged];
    
    UISwitch *switchForOpenwild=[[UISwitch alloc]init];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OpenWild"] == TRUE)
    {
        switchForOpenwild.on = YES;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"OpenWild"];
        switchForOpenwild.on=NO;
    }
    
    switchForOpenwild.onTintColor=[UIColor colorWithRed:1/255.0 green:161/255.0 blue:190/255.0 alpha:1.000];
    [switchForOpenwild addTarget:self action:@selector(chageOpenwild:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *detailforMap=[UIButton buttonWithType:UIButtonTypeCustom];
    [detailforMap setImage:[[UIImage imageNamed:@"btn_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    detailforMap.frame=CGRectMake(0, 0, 20, 20);
    [detailforMap addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
    
    buttonForFacebook=[UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [buttonForFacebook setTitle:NSLocalizedString(@"Sign in",nil) forState:UIControlStateNormal];
    [buttonForFacebook setTitle:NSLocalizedString(@"Sign out",nil) forState:UIControlStateSelected];
    buttonForFacebook.bounds=CGRectMake(0, 0, 95, 30);
    [buttonForFacebook setBackgroundImage:[UIImage imageNamed:@"btn_setting.png"] forState:UIControlStateNormal];
    [buttonForFacebook setBackgroundImage:[UIImage imageNamed:@"btn_setting_focus.png"] forState:UIControlStateHighlighted];
    [buttonForFacebook addTarget:self action:@selector(showLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonForClear=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonForClear setTitle:NSLocalizedString(@"Delete",nil) forState:UIControlStateNormal];
    [buttonForClear setBackgroundImage:[UIImage imageNamed:@"btn_delete.png"] forState:UIControlStateNormal];
    [buttonForClear setBackgroundImage:[UIImage imageNamed:@"btn_delete_focus.png"] forState:UIControlStateHighlighted];
    [buttonForClear addTarget:self action:@selector(clearAll) forControlEvents:UIControlEventTouchUpInside];
    buttonForClear.bounds=CGRectMake(0, 0, 95, 30);
    
    _item1.accessView=detailforbaby;
    _item2.accessView=segementForMetric;
    _item3.accessView=switchForNotifications;
    _item4.accessView=feedbackOnline;
    _item5.accessView=myDevices;
    _item6.accessView=detailforSubmit;
    _item7.accessView=detailforCopyright;
    _item8.accessView=buttonForClear;
    _item9.accessView=myreminder;
    _item11.accessView = switchForBackup;
    _item12.accessView = detailforMap;
    _item13.accessView = switchForOpenwild;
    
    [_array1 addObject:_item1];
    [_array1 addObject:_item9];
    [_array1 addObject:_item12];
    
    [_array2 addObject:_item2];
    [_array2 addObject:_item11];
    [_array2 addObject:_item13];
    [_array2 addObject:_item3];
    [_array2 addObject:_item4];

    [_array2 addObject:_item5];
    [_array2 addObject:_item6];
    [_array2 addObject:_item7];
    [_array3 addObject:_item8];
    [_array3 addObject:_item10];
    
    _settingArray=[[NSArray alloc]initWithObjects:_array1,_array2,_array3, nil];
}

-(void)goLogin
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    loginViewController.mainViewController = self.navigationController;
    [self.navigationController pushViewController:loginViewController animated:NO];
}

-(void)goLoginOut
{
    //TODO:同步数据 实现AlertDelegate里面的同步方法
//    logoutAlert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否同步本地数据至服务器?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"同步",@"不同步", nil];
    logoutAlert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定登出账号?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登出",nil];
    [logoutAlert show];
}

-(void)setting
{
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_title.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setting];
    [self makeArray];
    
    self.settingTable= [[UITableView alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    _settingTable.dataSource=self;
    _settingTable.delegate  =self;
    _settingTable.backgroundColor = [UIColor clearColor];
    _settingTable.backgroundView  = nil;
    _settingTable.showsVerticalScrollIndicator =NO;
    //    _settingTable.bounces=NO;
    _settingTable.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_settingTable];
    
    //在线反馈
    [UMFeedback setLogEnabled:YES];
    self.umFeedback = [UMFeedback sharedInstance];
    [self.umFeedback setAppkey:UMENGAPPKEY delegate:self];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    NSLog(@"%i", [_settingArray count]);
    return [_settingArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_settingArray objectAtIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (Cell==nil) {
        Cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        Cell.textLabel.font=[UIFont systemFontOfSize:17];
        Cell.textLabel.textColor=[UIColor colorWithRed:0xAF/255.0 green:0xAF/255.0 blue:0xAF/255.0 alpha:0xFF/255.0];
    }
    
    SettingItem *item=[[_settingArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    Cell.textLabel.text=item.name;
    Cell.accessoryView=item.accessView;
    Cell.accessoryView.contentMode=UIViewContentModeScaleAspectFit;
    return Cell;
}


-(void)clearAll
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"timerOn"])
    {
        UIAlertView *warningTimerOn= [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CloseTimerMsg", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YES", nil) otherButtonTitles:nil, nil];
        [warningTimerOn show];
    }
    else
    {
        clearalert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Clear all logged data",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"NO",nil) otherButtonTitles:NSLocalizedString(@"YES",nil), nil];
        [clearalert show];
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==clearalert) {
        int user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_userid"] integerValue];
        int baby_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cur_babyid"] integerValue];

        if (buttonIndex==1)
        {
            [[NSFileManager defaultManager] removeItemAtPath:USERDBPATH(user_id, baby_id) error:nil];
        }
    }
    else
    {
        if (buttonIndex==1) {
            NSLog(@"denglu");
        }
    }
    
    if (alertView==logoutAlert) {
        //记录历史账号
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"ACCOUNT_TYPE"]intValue] == RTYPE_APP)
        {
            [[NSUserDefaults standardUserDefaults]setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] forKey:@"HISTORY_ACCOUNT_NAME"];
        }

        //TODO:是否清除本地数据
        if (buttonIndex==1) {
            //TODO:同步数据
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"ACCOUNT_NAME"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"ACCOUNT_TYPE"];
            [self makeArray];
            [self.settingTable reloadData];
            
            [[ASIController asiController] postLoginState:-1];
        }
        else if (buttonIndex==2){
            //TODO:不同步数据
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"ACCOUNT_NAME"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"ACCOUNT_TYPE"];
            [self makeArray];
            [self.settingTable reloadData];
            [[ASIController asiController] postLoginState:-1];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingItem *item=[[_settingArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([item.name isEqualToString:NSLocalizedString(@"Baby information",nil)]) {
        BabyinfoViewController *baby=[[BabyinfoViewController alloc]initWithNibName:@"BabyinfoViewController" bundle:nil];
        [self.navigationController pushViewController:baby animated:YES];
    }
    else if([item.name isEqualToString:NSLocalizedString(@"Review App",nil)])
    {
        
    }
    else if ([item.name isEqualToString:NSLocalizedString(@"Submit feedback online", nil)]){
        //undone feedback
        UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
        feedbackViewController.appkey = UMENGAPPKEY;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
        navigationController.navigationBar.barStyle = UIBarStyleBlack;
        navigationController.navigationBar.translucent = NO;
        [self presentViewController:navigationController animated:YES completion:^{}];//        [self onlineFeedBack];
    }
    else if ([item.name isEqualToString:NSLocalizedString(@"My Devices", nil)]){
        //undone feedback
        MyDevicesViewController *myDevicesViewController = [[MyDevicesViewController alloc] initWithNibName:@"MyDevicesViewController" bundle:nil];
        [self.navigationController pushViewController:myDevicesViewController animated:YES];
    }
    else if([item.name isEqualToString:NSLocalizedString(@"Submit feedback/improvements",nil)])
    {
        [self sendEMail];
    }
    else if([item.name isEqualToString:NSLocalizedString(@"Copyright",nil)])
    {
        [self showCopyright];
    }
    else if([item.name isEqualToString:NSLocalizedString(@"查看小区附近的麻麻们",nil)])
    {
        [self showMap];
    }
    else if([item.name isEqualToString:NSLocalizedString(@"LocalNotify",nil)])
    {
        MyLocalNofityViewController *mynotify = [[MyLocalNofityViewController alloc]init];
        [self.navigationController pushViewController:mynotify animated:YES];
    }
    
}
-(void)showCopyright
{
    CopyrightViewController *copyright=[[CopyrightViewController alloc]initWithNibName:@"CopyrightViewController" bundle:nil];
    [self.navigationController pushViewController:copyright animated:YES];
}

-(void)chageOpenwild:(UISwitch*)sender
{
    if (sender.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OpenWild"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"OpenWild"];
        
    }
}

-(void)chageBackUp:(UISwitch*)sender
{
    if (sender.isOn) {
        NSLog(@"on");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"2G/3GBackUp"];
    }
    else
    {
        NSLog(@"off");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"2G/3GBackUp"];

    }
}

-(void)chageNotification:(UISwitch*)sender
{
    if (sender.isOn) {
        NSLog(@"on");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RemoteNotify"];
    }
    else
    {
        NSLog(@"off");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RemoteNotify"];
    }
}

-(void)Metric:(UIButton *)sender
{
    sender.enabled=NO;
    UIButton *another;
    if (sender.tag==101) {
        another=(UIButton*)[segementForMetric viewWithTag:102];
        [[NSUserDefaults standardUserDefaults]setObject:@"Mls:" forKey:@"metric" ];
        
    }
    else
    {
        another=(UIButton*)[segementForMetric viewWithTag:101];
        [[NSUserDefaults standardUserDefaults]setObject:@"Oz:" forKey:@"metric" ];
        
    }
    another.enabled=YES;
    
}


- (void) alertWithTitle: (NSString *)_title_ msg: (NSString *)msg

{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title_
                          
                                                    message:msg
                          
                                                   delegate:nil
                          
                                          cancelButtonTitle:@"确定"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
}


//在线反馈
-(void)onlineFeedBack{
    
}

-(void)showMap
{
    NSLog(@"show map");
    MyMapViewController *mymap = [[MyMapViewController alloc] init];
    [self.navigationController pushViewController:mymap animated:YES];

}

-(void)tongbu
{
    NSLog(@"tongbu record");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = -60.0f;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.alpha = 0.5;
    hud.color = [UIColor grayColor];
    hud.labelText = @"数据同步中...";
    BOOL res = [UpLoadController checkDiaperUpload:1];
    if (res == NO) {
        hud.labelText = @"同步失败,请确认是否已经登录或网络是否正常!";
    }
    else
    {
        hud.labelText = @"同步完成";
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

//点击按钮后，触发这个方法
-(void)sendEMail
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}
//可以发送邮件的话
-(void)displayComposerSheet
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    //[mailPicker.navigationItem.leftBarButtonItem setBackgroundImage:[UIImage imageNamed:@"btn2.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        mailPicker.edgesForExtendedLayout = UIRectEdgeNone;
        mailPicker.extendedLayoutIncludesOpaqueBars = NO;
        mailPicker.modalPresentationCapturesStatusBarAppearance = NO;
    }
#endif  // #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    //    mailPicker.navigationBar.tintColor = [UIColor colorWithRed:0x11/255.0 green:0x87/255.0 blue:0x98/255.0 alpha:0xFF/255.0];
    
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject:NSLocalizedString(@"Feedback",nil)];
    
    // 添加发送者
    NSArray *toRecipients = [NSArray arrayWithObject: @"amoycaretech@gmail.com"];
    
    [mailPicker setToRecipients: toRecipients];
    
    [self presentViewController:mailPicker animated:YES completion:nil];
}

-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:amoycaretech@gmail.com";
    
    NSString *email = [NSString stringWithFormat:@"%@", recipients];
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultSaved:
            msg = @"邮件保存成功";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            [self alertWithTitle:nil msg:msg];
            break;
        default:
            break;
    }
    
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
