//
//  defaultAppDelegate.h
//  Parenting
//
//  Created by 爱摩信息科技 on 13-5-16.
//  Copyright (c) 2013年 家明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"
#import "SummaryViewController.h"
#import "HomeViewController.h"
#import "InformationCenterViewController.h"
#import "GuideViewController.h"
#import "LoginViewController.h"

#import "ACTabBarController.h"
#import "MyTabBarController.h"
#import "EnviromemtViewController.h"
#import "ActivityViewController.h"
#import "PhysiologyViewController.h"
#import "CalendarViewController.h"
#import "MyPageViewController.h"

@class defaultViewController;
@interface defaultAppDelegate : UIResponder <UIApplicationDelegate>
{
    ACTabBarController              *TabbarController;
    MyTabBarController              *myTabController;
    
    MyPageViewController            *myPageViewController;
    EnviromemtViewController        *envirViewController;
    ActivityViewController          *actViewController;
    PhysiologyViewController        *phyViewController;
    CalendarViewController          *calendarViewController;
    
    SettingViewController           *settingViewController;
    InformationCenterViewController *icViewController;
    SummaryViewController           *summaryViewController;
    HomeViewController              *homeViewController;
    GuideViewController             *guideViewController;
    LoginViewController             *loginViewController;
    
    BLEWeatherController            *bleweatherCtrler;
   
    UINavigationController          *settingNavigationViewController;
    UINavigationController          *adviseNavigationViewController;
    UINavigationController          *summaryNavigationViewController;
    UINavigationController          *homeNavigationViewController;
    UINavigationController          *icNavigationViewController;
    
    UINavigationController          *myPageNavigationViewController;
    UINavigationController          *envirNavigationViewController;
    UINavigationController          *actNavigationViewController;
    UINavigationController          *phyNavigationViewController;
    UINavigationController          *calendarNavigationViewController; 

}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) defaultViewController *viewController;

@end
