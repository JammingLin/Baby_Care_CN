//
//  MyPageViewController.h
//  Amoy Baby Care
//
//  Created by @Arvi@ on 14-3-19.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BabyinfoViewController.h"
#import "MBProgressHUD.h"

@interface MyPageViewController : ACViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>
{
    UIImagePickerController *imagePicker;
    UIActionSheet *action;
    UIView *guideView;
     MBProgressHUD *hud;
}

@end
