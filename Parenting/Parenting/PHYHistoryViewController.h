//
//  PHYHistoryViewController.h
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-7-16.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>   

@interface PHYHistoryViewController : ACViewController<UITableViewDataSource,UITableViewDelegate,TempSaveViewDelegate,PhySaveViewDelegate>
{
    NSMutableArray *arrDS;
    NSString* itemName;
    NSString* itemUnit;
    int itemType; //身高0 体重1 BMI2 头围3 体温4
    
    TempSaveView *tempSaveView;
    PhySaveView *phySaveView;
}

@property (strong, nonatomic) UIImageView *phyDetailImageView;
@property (strong, nonatomic) UIButton *buttonBack;  

@property (strong, nonatomic) UITableView *tableView;

-(void)setType:(int)Type;
@end
