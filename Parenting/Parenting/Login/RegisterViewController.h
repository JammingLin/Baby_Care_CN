//
//  RegisterViewController.h
//  LoginModule
//
//  Created by CHEN WEIBIN on 13-12-26.
//  Copyright (c) 2013年 CHEN WEIBIN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    MBProgressHUD *hud;
    NSArray *arrData;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIViewController* mainViewController;
@end
