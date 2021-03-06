//
//  TempDetailViewController.h
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-8-7.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TempCorePlot.h"
#import "TempSaveView.h"

@interface TempDetailViewController : ACViewController<TempSaveViewDelegate>{
    NSArray *arrayCurrent;
    NSArray *arrValues;
    
    int sizeInterval;
    
    NSString *itemName;
    NSString *itemUnit;
    int itemType;
    long plotHeight;
    
    TempCorePlot *plot;
    float yBaseValue;
    float ySizeInterval;
    UIImageView *adviseImageView;
    
    TempSaveView *tempSaveView;
}

@property (strong, nonatomic) UIImageView *phyDetailImageView;
@property (strong, nonatomic) UIButton *buttonBack;
@property (strong, nonatomic) UIButton *buttonAdd;
@property (strong, nonatomic) UIButton *buttonTip;

//顶部数值视图
@property (strong, nonatomic) UIView *viewTop1;
@property (strong, nonatomic) UILabel *labelLastValue;
@property (strong, nonatomic) UILabel *labelLastDate;
@property (strong, nonatomic) UILabel *labelCURValue;
@property (strong, nonatomic) UILabel *labelCURDate;
@property (strong, nonatomic) UILabel *labelChangeValue;

//详细数值视图
@property (strong, nonatomic) UIView *viewHistroy;

//WHO曲线区域
@property (strong, nonatomic) UIView *viewPlot;

-(void)setVar:(NSArray*) array;

@end
