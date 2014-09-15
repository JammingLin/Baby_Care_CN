//
//  GuideViewController.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 13-11-26.
//  Copyright (c) 2013年 奥芬多. All rights reserved.
//

#import "GuideViewController.h"
#import "LoginViewController.h"
@interface GuideViewController ()

@end

@implementation GuideViewController
@synthesize fitHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)viewWillAppear:(BOOL)animated
{
    [self prefersStatusBarHidden];
    
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self prefersStatusBarHidden];
    
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //版本适配尺寸
    if ([UIScreen mainScreen].bounds.size.height==568){
        fitHeight = 996/2.0;
    }
    else if ([UIScreen mainScreen].bounds.size.height==480){
        fitHeight = 827/2.0;
    }
  
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, kDeviceHeight)];
    _scrollView.bounces = YES; //检查是否已到边界
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_scrollView];
    
    // 初始化数组
    _slideImages = [[NSMutableArray alloc] init];
    if ([UIScreen mainScreen].bounds.size.height >= 568) {
        [_slideImages addObject:@"640-1136.1.png"];
        [_slideImages addObject:@"640-1136.2.png"];
        [_slideImages addObject:@"640-1136.3.png"];
        [_slideImages addObject:@"640-1136.4.png"];
    }
    else
    {
        [_slideImages addObject:@"640-960.1.png"];
        [_slideImages addObject:@"640-960.2.png"];
        [_slideImages addObject:@"640-960.3.png"];
        [_slideImages addObject:@"640-960.4.png"];
    }
    
    // 创建四个UImageIVew到UIScrollView中
    for (int i = 0;i<[_slideImages count];i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_slideImages objectAtIndex:i]]];
        imageView.frame = CGRectMake(320 * i, 0, 320, kDeviceHeight);
        
        UIButton *buttonSkip = [[UIButton alloc]initWithFrame:CGRectMake(107/2.0, fitHeight, 213, 39)];
        [buttonSkip setAlpha:0.1];
        buttonSkip.layer.cornerRadius = 8.0f;
        [buttonSkip setBackgroundColor:[UIColor clearColor]];
        [buttonSkip addTarget:self action:@selector(skipToMain:) forControlEvents:(UIControlEventTouchUpInside)];
        [imageView addSubview:buttonSkip];
        
        [imageView setUserInteractionEnabled:YES];
        [_scrollView addSubview:imageView];
    }
    
    //设置UIScrollView的page 定义实际内容大小，会让滚动生效
    [_scrollView setContentSize:CGSizeMake(320*_slideImages.count, kDeviceHeight)]; //不知道什么用
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    [_scrollView scrollRectToVisible:CGRectMake(0,0,320,kDeviceHeight) animated:NO];
}

-(void)skipToMain:(id)sender{ 
    //根据登录状态跳转
//     if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] != nil)  {
        _mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:_mainViewController animated:YES completion:^{}];
//    }
//    else{
//        LoginViewController *loginViewController = [[LoginViewController alloc]init];
//        loginViewController.mainViewController = _mainViewController;
//        UINavigationController *naviLogi = [[UINavigationController alloc]initWithRootViewController:loginViewController];
//        self.view.window.rootViewController= naviLogi;
//    }
}

// scrollview 委托函数
- (void)scrollViewDidScroll:(UIScrollView *)sender{
}

// scrollview 委托函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
