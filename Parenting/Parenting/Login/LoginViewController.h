//
//  LoginViewController.h
//  LoginModule
//
//  Created by CHEN WEIBIN on 13-12-26.
//  Copyright (c) 2013年 CHEN WEIBIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LoginViewController : UIViewController<UIAlertViewDelegate>
{
    BOOL isPushSocialView;
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UIView *viewButtons;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) UIViewController* mainViewController;

@end
