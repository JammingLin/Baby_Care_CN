//
//  TimeLineView.h
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-4-9.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BabyBaseInfoView.h"

@interface TimeLineView : UIView<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *timeLineArray;
    NSTimer *timer;
    UIPickerView *picker_sex_birth;
    BabyBaseInfoView *babyInfo;
}

@property (nonatomic,strong)UITableView *timeLineTableView;

@end