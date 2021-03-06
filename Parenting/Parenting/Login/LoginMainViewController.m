//
//  LoginMainViewController.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 13-12-31.
//  Copyright (c) 2013年 爱摩科技有限公司. All rights reserved.
//

#import "LoginMainViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h" 
#import "DataContract.h"
#import "NetWorkConnect.h"
#import "SyncController.h"
#import "UserDataDB.h"
#import "MBProgressHUD.h"
#import "MD5.h"
#import "APService.h"
#import "InitCreateDB.h"


@interface LoginMainViewController ()

@end

@implementation LoginMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
}

-(void)initView{
    [self.view setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
    
    //UINavigationItem stuff
    self.tableView.scrollEnabled = NO;
    self.navigationItem.title = @"提交";
    
    UIButton *backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [backbutton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    backbutton.frame=CGRectMake(0, 0, 50, 41);
    backbutton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    [backbutton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [backbutton addTarget:self action:@selector(doGoBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backbar=[[UIBarButtonItem alloc]initWithCustomView:backbutton];
    self.navigationItem.leftBarButtonItem=backbar;
    
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"btn1.png"] forState:UIControlStateNormal];
    UILabel *title1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 28)];
    title1.backgroundColor = [UIColor clearColor];
    [title1 setTextAlignment:NSTextAlignmentCenter];
    title1.textColor = [UIColor whiteColor];
    title1.text =NSLocalizedString(@"navLogin", nil);
    title1.font = [UIFont systemFontOfSize:14];
    [rightButton addSubview:title1];
    [rightButton addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame=CGRectMake(0, 0, 44, 28);
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBar;
    
    NSArray *arr1 = [[NSArray alloc]init];
    NSArray *arr2 = [[NSArray alloc]init];
    arr1 = @[@"邮箱",@"密码"];
    arr2 = @[@"注册账号"];
    arrData = [[NSArray alloc]initWithObjects:arr1,arr2,nil];
}

-(void)doLogin{
    //输入判断
    UITextField *inputEmail = (UITextField*)[_tableView viewWithTag:1];
    UITextField *inputPd = (UITextField*)[_tableView viewWithTag:2];
    
    if ([inputEmail.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"邮箱地址不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (![LoginMainViewController validateEmail:inputEmail.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"邮箱格式错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if ([inputPd.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"密码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (inputPd.text.length < 6) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"密码长度至少要求6位" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    //注册接口
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //隐藏键盘
        [inputEmail resignFirstResponder];
        [inputPd resignFirstResponder];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.alpha = 0.5;
        hud.color = [UIColor grayColor];
        hud.labelText = http_requesting;
    
    //封装数据
    NSMutableDictionary *dictBody = [[DataContract dataContract]UserLoginDict:RTYPE_APP account:inputEmail.text password:[MD5 md5:inputPd.text]];
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
             //数据库保存用户信息:APP不需要
             NSMutableDictionary *resultBody = [result objectForKey:@"body"];
             //保存用户名
             [[NSUserDefaults standardUserDefaults] setObject:inputEmail.text forKey:@"ACCOUNT_NAME"];
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RTYPE_APP] forKey:@"ACCOUNT_TYPE"];
             [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"ACCOUNT_UID"];
             [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"cur_userid"];
             
             [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
             //判断是否有登录过
            if ([[UserDataDB dataBase] selectUser:[[resultBody objectForKey:@"userId"] intValue]] == nil){
                [[UserDataDB dataBase] createNewUser:[[resultBody objectForKey:@"userId"]intValue] andCategoryIds:@"" andIcon:@"" andUserType:RTYPE_APP andUserAccount:inputEmail.text  andAppVer:PROVERSION andCreateTime:[[resultBody objectForKey:@"createTime"] longValue] andUpdateTime:[[resultBody objectForKey:@"updateTime"] longValue]];
                
            }

             //[hud hide:YES];
             [self performSelector:@selector(isSyncData) withObject:nil afterDelay:1];
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
}

-(void)doGoBack{
//    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:NO];
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
            [self.navigationController popToViewController:_mainViewController animated:NO];
            return;
        }
        
        if (!BABYID) {
            //注册接口
            if (![hud isHidden]) {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                //隐藏键盘
                hud.mode = MBProgressHUDModeIndeterminate;
                hud.alpha = 0.5;
                hud.color = [UIColor grayColor];
            }
            hud.labelText = http_requesting;
            //封装数据
            NSMutableDictionary *dictBody = [[DataContract dataContract]BabyCreateByUserIdDict:ACCOUNTUID];
            //Http请求
            [[NetWorkConnect sharedRequest]
             httpRequestWithURL:BABY_CREATEBYUSERID_URL
             data:dictBody
             mode:@"POST"
             HUD:hud
             didFinishBlock:^(NSDictionary *result){
                 hud.labelText = [result objectForKey:@"msg"];
                 //处理反馈信息: code=1为成功  code=99为失败
                 if ([[result objectForKey:@"code"]intValue] == 1) {
                     NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                     //保存Babyid
                     [[NSUserDefaults standardUserDefaults]setObject:[resultBody objectForKey:@"babyId"] forKey:@"BABYID"];
                     //数据库保存Baby信息
                     [BabyDataDB createNewBabyInfo:ACCOUNTUID BabyId:BABYID Nickname:@"" Birthday:nil Sex:nil HeadPhoto:@"" RelationShip:@"" RelationShipNickName:@"" Permission:nil CreateTime:[resultBody objectForKey:@"create_time"] UpdateTime:nil];
                      
                     _mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                     [self.navigationController popToViewController:_mainViewController animated:NO];
                     [hud hide:YES afterDelay:1];
                 }
                 else{
                     hud.labelText = http_error;
                     [hud hide:YES afterDelay:1];
                 }
             }
             didFailBlock:^(NSString *error){
                 //请求失败处理
                 hud.labelText = http_error;
                 [hud hide:YES afterDelay:1];
             }
             isShowProgress:YES
             isAsynchronic:NO
             netWorkStatus:YES
             viewController:self];
        }
    }
}

#pragma textfield protocol
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doLogin];
    return YES;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[arrData objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *title;
    UITextField *input;
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if (indexPath.section == 1) {
            title = [[UILabel alloc]initWithFrame:CGRectMake(18, 5, 96, 32)];
            title.text = [[arrData objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
            title.textColor = [ACFunction colorWithHexString:TEXTCOLOR];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else{
            title = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, 48, 32)];
            title.text = [[arrData objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
            title.textColor = [ACFunction colorWithHexString:TEXTCOLOR];
            input = [[UITextField alloc]initWithFrame:CGRectMake(80,7, 180, 32)];
            input.returnKeyType =UIReturnKeyDone;
            input.delegate = self;
            
            if (indexPath.row == 0) {
                input.tag = 1;
                input.placeholder = @"请输入邮箱地址";
                input.keyboardType = UIKeyboardTypeEmailAddress;
                input.autocapitalizationType = UITextAutocapitalizationTypeNone;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HISTORY_ACCOUNT_NAME"] != nil)
                {
                    input.text =[[NSUserDefaults standardUserDefaults] objectForKey:@"HISTORY_ACCOUNT_NAME"];
                }

                [input becomeFirstResponder];
            }
            else{
                input.tag = 2;
                input.placeholder = @"请输入密码";
                input.secureTextEntry = YES;
            }
            input.textColor = [ACFunction colorWithHexString:TEXTCOLOR];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell addSubview:input];
        }
        title.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:title];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        //跳转到注册页面
        RegisterViewController *registerViewController = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
        registerViewController.mainViewController = _mainViewController;
        [self.navigationController pushViewController:registerViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(BOOL)validateEmail:(NSString*)email
{
    if((0 != [email rangeOfString:@"@"].length) &&
       (0 != [email rangeOfString:@"."].length))
    {
        NSCharacterSet* tmpInvalidCharSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSMutableCharacterSet* tmpInvalidMutableCharSet = [tmpInvalidCharSet mutableCopy];
        [tmpInvalidMutableCharSet removeCharactersInString:@"_-"];
        
        /*
         *使用compare option 来设定比较规则，如
         *NSCaseInsensitiveSearch是不区分大小写
         *NSLiteralSearch 进行完全比较,区分大小写
         *NSNumericSearch 只比较定符串的个数，而不比较字符串的字面值
         */
        NSRange range1 = [email rangeOfString:@"@"
                                      options:NSCaseInsensitiveSearch];
        
        //取得用户名部分
        NSString* userNameString = [email substringToIndex:range1.location];
        NSArray* userNameArray   = [userNameString componentsSeparatedByString:@"."];
        
        for(NSString* string in userNameArray)
        {
            NSRange rangeOfInavlidChars = [string rangeOfCharacterFromSet: tmpInvalidMutableCharSet];
            if(rangeOfInavlidChars.length != 0 || [string isEqualToString:@""])
                return NO;
        }
        
        //取得域名部分
        NSString *domainString = [email substringFromIndex:range1.location+1];
        NSArray *domainArray   = [domainString componentsSeparatedByString:@"."];
        
        for(NSString *string in domainArray)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:tmpInvalidMutableCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return NO;
        }
        
        return YES;
    }
    else {
        return NO;
    }
}

#pragma alertview protocol
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

@end