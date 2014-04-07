//
//  GuideViewController.h
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 13-11-26.
//  Copyright (c) 2013年 陈伟斌. All rights reserved.
//哈哈

#import <UIKit/UIKit.h>
#import "defaultAppDelegate.h"

@interface GuideViewController : UIViewController<UIScrollViewDelegate>
 
@property NSInteger fitHeight;
@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) NSMutableArray *slideImages;
@property (strong,nonatomic) UIViewController   *mainViewController; 

@end
