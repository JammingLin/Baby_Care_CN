//
//  HomeViewController.h
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-9-29.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeHeadView.h"
#import "LoginView.h"
#import "BCBaby.h"
#import "BCBabyMsg.h"
#import "InitTimeLineData.h"
#import "InitBabyInfoViewController.h"
#import "MBProgressHUD.h"


@interface HomeViewController : UIViewController<SelectBabyPhotoDelegate,RefreshTimeLineDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>{
    NSMutableArray * _timeLineDS;
    NSMutableArray * _timeLineCells;
    
    InitTimeLineData *_initTimeLineData;
    
    UIImagePickerController *_imagePicker;
    UIActionSheet *_action;
    
    MBProgressHUD *_hud;
    
    UIAlertView *_alertView;
    
    __weak NSString * test1;
    NSString *test2;
}

#pragma mark 宝宝数据对象类
@property (nonatomic,strong) BCBaby *bcBaby;

#pragma mark 首页头部视图
@property (nonatomic,strong) HomeHeadView *homeHeadView;

#pragma mark 登陆视图
@property (nonatomic,strong) LoginView *loginView;

#pragma mark 首页动图视图
@property (nonatomic,strong) UIScrollView *homeScrollView;

#pragma mark 时间轴
@property (nonatomic,strong) UITableView *timeLineTableView;

#pragma mark 活动指示控件
@property (nonatomic,strong) UIActivityIndicatorView *actView;

@property (nonatomic,assign) BOOL isLogining;

#pragma mark 时间轴数据操作类
//@property (nonatomic,strong) InitTimeLineData *InitTimeLineData;

@end
