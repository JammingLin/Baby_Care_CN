//
//  RegisterViewController.m
//  LoginModule
//
//  Created by CHEN WEIBIN on 13-12-26.
//  Copyright (c) 2013年 CHEN WEIBIN. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginMainViewController.h"
#import "MBProgressHUD.h"
#import "MD5.h"
#import "APService.h"
#import "NetWorkConnect.h"
#import "DataContract.h"
#import "UserDataDB.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
    
    //UINavigationItem stuff
    self.tableView.scrollEnabled = NO;
    self.navigationItem.title = NSLocalizedString(@"navRegister", nil);
    
    UIButton *backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [backbutton setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 34, 28)];
    title.backgroundColor = [UIColor clearColor];
    [title setTextAlignment:NSTextAlignmentCenter];
    title.textColor = [UIColor whiteColor];
    title.text = NSLocalizedString(@"navback", nil);
    title.font = [UIFont systemFontOfSize:14];
    [backbutton addSubview:title];
    
    [backbutton addTarget:self action:@selector(doGoBack) forControlEvents:UIControlEventTouchUpInside];
    backbutton.frame=CGRectMake(0, 0, 44, 28);
    
    UIBarButtonItem *backbar=[[UIBarButtonItem alloc]initWithCustomView:backbutton];
    self.navigationItem.leftBarButtonItem=backbar;
    
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"btn1.png"] forState:UIControlStateNormal];
    UILabel *title1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 28)];
    title1.backgroundColor = [UIColor clearColor];
    [title1 setTextAlignment:NSTextAlignmentCenter];
    title1.textColor = [UIColor whiteColor];
    title1.text =NSLocalizedString(@"navRegister", nil);
    title1.font = [UIFont systemFontOfSize:14];
    [rightButton addSubview:title1];
    [rightButton addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame=CGRectMake(0, 0, 44, 28);
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBar;

    arrData = @[@"邮箱",@"密码",@"重复"];
}

-(void)doGoBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma 注册成功跳转到主页
-(void)doGoMain{
    _mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:_mainViewController animated:YES completion:^{}];
}

-(void)doRegister{
    //输入判断
    UITextField *inputEmail = (UITextField*)[_tableView viewWithTag:1];
    UITextField *inputPd = (UITextField*)[_tableView viewWithTag:3];
    UITextField *inputRePd = (UITextField*)[_tableView viewWithTag:4];
    
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
    
    if ([inputRePd.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"重复密码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (inputRePd.text.length < 6) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"重复密码长度至少要求6位" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (![inputPd.text isEqualToString:inputRePd.text]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"输入密码不一致" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    //注册接口
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //隐藏键盘
    [inputEmail resignFirstResponder];
    [inputPd resignFirstResponder];
    [inputRePd resignFirstResponder];
    hud.yOffset = -60.0f;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.alpha = 0.5;
    hud.color = [UIColor grayColor];
    hud.labelText = http_requesting;
    
    //封装数据
    NSMutableDictionary *dictBody = [[DataContract dataContract]UserCreateDict:RTYPE_APP account:inputEmail.text password:[MD5 md5:inputPd.text]];
    //Http请求
    [[NetWorkConnect sharedRequest]
     httpRequestWithURL:USER_CREATE_URL
     data:dictBody
     mode:@"POST"
     HUD:hud
     didFinishBlock:^(NSDictionary *result){
         hud.labelText = [result objectForKey:@"msg"];
         //处理反馈信息: code=1为成功  code=99为失败
         if ([[result objectForKey:@"code"]intValue] == 1) {
             NSMutableDictionary *resultBody = [result objectForKey:@"body"];
             //保存用户名
             [[NSUserDefaults standardUserDefaults] setObject:inputEmail.text forKey:@"ACCOUNT_NAME"];
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RTYPE_APP] forKey:@"ACCOUNT_TYPE"];
             [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"ACCOUNT_UID"];
             [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
             //数据库保存用户信息
             [[UserDataDB dataBase] createNewUser:[[resultBody objectForKey:@"userId"]intValue] andCategoryIds:@"" andIcon:@"" andUserType:RTYPE_APP andUserAccount:inputEmail.text  andAppVer:PROVERSION andCreateTime:[[resultBody objectForKey:@"createTime"] longValue] andUpdateTime:[[resultBody objectForKey:@"updateTime"] longValue]];
             [hud hide:YES afterDelay:0.8];
             [self performSelector:@selector(doGoMain) withObject:nil afterDelay:0.8];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
}

#pragma textfield protocol
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doRegister];
    return YES;
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UILabel *title;
    UITextField *input;
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        title = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, 48, 32)];
        title.text = [arrData objectAtIndex:indexPath.row];
        input = [[UITextField alloc]initWithFrame:CGRectMake(80,7, 180, 32)];
        input.returnKeyType =UIReturnKeyDone;
        input.delegate = self;
        
        if (indexPath.row == 0) {
            input.tag = 1;
            input.placeholder = @"请输入邮箱地址";
            input.keyboardType = UIKeyboardTypeEmailAddress;
            input.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [input becomeFirstResponder];
            
        }
//        else if (indexPath.row == 1){
//            input.tag = 2;
//            input.placeholder = @"请输入昵称";
//            input.keyboardType = UIKeyboardTypeDefault;
//        }
        else if (indexPath.row == 1){
            input.tag = 3;
            input.placeholder = @"请输入密码";
            input.secureTextEntry = YES;
        }
        else if (indexPath.row == 2){
            input.tag = 4;
            input.placeholder = @"请输入密码";
            input.secureTextEntry = YES;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:input];
        title.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:title];
    }
    return cell;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
