//
//  MyPageViewController.m
//  Amoy Baby Care
//
//  Created by @Arvi@ on 14-3-19.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import "MyPageViewController.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"

#import "SyncController.h"

@interface MyPageViewController ()

@end

@implementation MyPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"首页"];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated    {
    [MobClick beginLogPageView:@"首页"];
    
    [self LoadData];
    
    //是否有创建过宝宝
    if (!BABYID) {
        BabyinfoViewController *bi=[[BabyinfoViewController alloc]initWithNibName:@"BabyinfoViewController" bundle:nil];
        [self.navigationController pushViewController:bi animated:YES];
    }
}

-(void)LoadData{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 150, 60)];
    [btn setTitle:@"同步" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    [btn addTarget:self action:@selector(sync) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)sync
{
    MBProgressHUD *hud;
    [[SyncController syncController] syncBabyDataCollectionsByUserID:ACCOUNTUID HUD:hud SyncFinished:^(){} ViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
