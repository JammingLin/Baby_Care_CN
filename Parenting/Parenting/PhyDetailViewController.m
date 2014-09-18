//
//  PHYDetailViewController.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-4-24.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import "PHYDetailViewController.h"
#import "BabyDataDB.h"
#import "PHYHistoryViewController.h"
#import "GetPhyAdvise.h"

#define YAXISCOUNT 5
#define SIZEINTERVA 10

#define DEVICE_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)

@interface PHYDetailViewController ()

@end

@implementation PHYDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed=YES;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated{
    [MobClick beginLogPageView:@"生理详细页"];
    self.hidesBottomBarWhenPushed=YES;
    [self initData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    [MobClick endLogPageView:@"生理详细页"];
    
}

-(void)initView{
    //navigationBar
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    titleView.backgroundColor=[UIColor clearColor];
    UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    titleText.backgroundColor = [UIColor clearColor];
    [titleText setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20]];
    titleText.textColor = [UIColor whiteColor];
    [titleText setTextAlignment:NSTextAlignmentCenter];
    [titleText setText:itemName];
    [titleView addSubview:titleText];
    self.phyDetailImageView = [[UIImageView alloc] init];
    [self.phyDetailImageView setFrame:CGRectMake(0, 0, 320, 64)];
    [self.phyDetailImageView setBackgroundColor:[ACFunction colorWithHexString:@"#68bfcc"]];
    
    [self.phyDetailImageView addSubview:titleView];
    [self.view addSubview:self.phyDetailImageView];
    [self.phyDetailImageView setUserInteractionEnabled:YES];
    
    
    _buttonBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonBack setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    _buttonBack.frame = CGRectMake(0, 22, 50, 41);
    [_buttonBack addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_phyDetailImageView addSubview:_buttonBack];
    
    _buttonAdd = [[UIButton alloc] init];
    _buttonAdd.frame = CGRectMake(320-10-40,22, 40, 40);
    _buttonAdd.titleLabel.font = [UIFont systemFontOfSize:14];
    [_buttonAdd setTitle:@"添加" forState:UIControlStateNormal];
    [_buttonAdd addTarget:self action:@selector(AddRecord) forControlEvents:UIControlEventTouchUpInside];
    //BMI无需添加
    if (itemType!=2) {
        [_phyDetailImageView addSubview:_buttonAdd];
    }
    
    _buttonTip = [[UIButton alloc] init];
    _buttonTip.frame = CGRectMake(50, 22, 40, 40);
    _buttonTip.titleLabel.font = [UIFont systemFontOfSize:14];
    [_buttonTip setTitle:@"i" forState:UIControlStateNormal];

    //[_phyDetailImageView addSubview:_buttonTip];
    
    //_viewTop1
    _viewTop1 = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 65)];
    _viewTop1.backgroundColor = [ACFunction colorWithHexString:@"#f6f6f6"];
    [self.view addSubview:_viewTop1];
    
    //_viewTop1_LAST
    _labelLastValue = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 80, 20)];
    _labelLastValue.font = [UIFont fontWithName:@"Arial" size:20];
    _labelLastValue.textColor = [ACFunction colorWithHexString:[arrayCurrent objectAtIndex:7]];
    _labelLastValue.textAlignment = NSTextAlignmentLeft;
    
    UILabel *labelLastTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 80, 20)];
    labelLastTitle.font = [UIFont fontWithName:@"Arial" size:10];
    labelLastTitle.textAlignment = NSTextAlignmentLeft;
    labelLastTitle.text = [NSString stringWithFormat:@"上次%@",itemName];
    
    _labelLastDate = [[UILabel alloc]initWithFrame:CGRectMake(10, 42, 80, 20)];
    _labelLastDate.font = [UIFont fontWithName:@"Arial" size:12];
    _labelLastDate.textAlignment = NSTextAlignmentLeft;
    
    [_viewTop1 addSubview:_labelLastValue];
    [_viewTop1 addSubview:labelLastTitle];
    [_viewTop1 addSubview:_labelLastDate];
    
    //_viewTop1_CURRENT
    _labelCURValue = [[UILabel alloc]initWithFrame:CGRectMake(135, 10, 80, 20)];
    _labelCURValue.font = [UIFont fontWithName:@"Arial" size:20];
    _labelCURValue.textColor = [ACFunction colorWithHexString:[arrayCurrent objectAtIndex:7]];
    _labelCURValue.textAlignment = NSTextAlignmentLeft;
    
    UILabel *labelCURTitle = [[UILabel alloc]initWithFrame:CGRectMake(135, 30, 80, 20)];
    labelCURTitle.font = [UIFont fontWithName:@"Arial" size:10];
    labelCURTitle.textAlignment = NSTextAlignmentLeft;
    labelCURTitle.text = [NSString stringWithFormat:@"当前%@",itemName];
    
    _labelCURDate = [[UILabel alloc]initWithFrame:CGRectMake(135, 42, 80, 20)];
    _labelCURDate.font = [UIFont fontWithName:@"Arial" size:12];
    _labelCURDate.textAlignment = NSTextAlignmentLeft;
    
    //_viewTop1_CHANGE
    _labelChangeValue = [[UILabel alloc]initWithFrame:CGRectMake(260, 10, 60, 20)];
    _labelChangeValue.font = [UIFont fontWithName:@"Arial" size:20];
    _labelChangeValue.textColor = [ACFunction colorWithHexString:[arrayCurrent objectAtIndex:7]];
    _labelCURValue.textAlignment = NSTextAlignmentLeft;
    
    UILabel *labelChangeTitle = [[UILabel alloc]initWithFrame:CGRectMake(260, 30, 60, 20)];
    labelChangeTitle.font = [UIFont fontWithName:@"Arial" size:10];
    labelChangeTitle.textAlignment = NSTextAlignmentLeft;
    labelChangeTitle.text = @"变化";
    
    [_viewTop1 addSubview:_labelCURValue];
    [_viewTop1 addSubview:labelCURTitle];
    [_viewTop1 addSubview:_labelCURDate];
    [_viewTop1 addSubview:_labelChangeValue];
    [_viewTop1 addSubview:labelChangeTitle];

    //_viewTopHistroy
    _viewHistroy = [[UIView alloc]initWithFrame:CGRectMake(0, 130, self.view.bounds.size.width, 44)];
    _viewHistroy.backgroundColor = [ACFunction colorWithHexString:@"#f6f6f6"];
    //添加手势
    UITapGestureRecognizer *tapgesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ShowHistory)];
    [_viewHistroy addGestureRecognizer:tapgesture];

    [self.view addSubview:_viewHistroy];
    
    UILabel *labelHistory = [[UILabel alloc]initWithFrame:CGRectMake(10, 12, 200, 20)];
    labelHistory.font = [UIFont fontWithName:@"Arial" size:16];
    labelHistory.textAlignment = NSTextAlignmentLeft;
    labelHistory.text = @"查看所有记录";
    [_viewHistroy addSubview:labelHistory];
    
    UILabel *labelHistoryArrow = [[UILabel alloc]initWithFrame:CGRectMake(285, 12, 25, 25)];
    labelHistoryArrow.font = [UIFont fontWithName:@"Arial" size:24];
    labelHistoryArrow.textAlignment = NSTextAlignmentLeft;
    labelHistoryArrow.textColor = [ACFunction colorWithHexString:TEXTCOLOR];
    labelHistoryArrow.text = @">";
    [_viewHistroy addSubview:labelHistoryArrow];
    
    //corePlot
    plotHeight=200;
    if (DEVICE_IS_IPHONE5) {
        plotHeight = 248;
    }
    _viewPlot = [[UIView alloc]initWithFrame:CGRectMake(0, 175, self.view.bounds.size.width, plotHeight)];
    _viewPlot.backgroundColor = [ACFunction colorWithHexString:@"#f6f6f6"];
    [self.view addSubview:_viewPlot];
    
    //adviseView
    [self makeAdvise:CGRectMake(0,175+plotHeight, 320, [UIScreen mainScreen].bounds.size.height - 175 - plotHeight)];
}

-(void)initData{
    //_viewTop1
    if (itemType != 2) {
        arrValues = [[BabyDataDB babyinfoDB] selectBabyPhysiologyList:[[arrayCurrent objectAtIndex:0] intValue]];
    }
    else{
        arrValues = [[BabyDataDB babyinfoDB] selectBabyBMIList];
    }
    
    if ([arrValues count] >= 2) {
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        [myDateFormatter setDateFormat:@"yyyy-MM-dd"];

        //LAST
        NSDictionary *dict2 = [arrValues objectAtIndex:1];
        double v2 = [[dict2 objectForKey:@"value"] doubleValue];
        NSDate *dateB = [ACDate getDateFromTimeStamp:[[dict2 objectForKey:@"measure_time"] longValue]];
        _labelLastValue.text = [NSString stringWithFormat:@"%0.1f",[[dict2 objectForKey:@"value"] doubleValue]];
                _labelLastDate.text = [myDateFormatter stringFromDate:dateB];
        
        //CURRENT
        NSDictionary *dict1 = [arrValues objectAtIndex:0];
        double v1 = [[dict1 objectForKey:@"value"] doubleValue];
        NSDate *date = [ACDate getDateFromTimeStamp:[[dict1 objectForKey:@"measure_time"] longValue]];
        _labelCURValue.text = [NSString stringWithFormat:@"%0.1f",[[dict1 objectForKey:@"value"] doubleValue]];
        _labelCURDate.text = [myDateFormatter stringFromDate:date];
        //CHANGE
        if (v1 >= v2) {
            _labelChangeValue.text= [NSString stringWithFormat:@"↑%0.1f",v1-v2];
        }else{
            _labelChangeValue.text= [NSString stringWithFormat:@"↓%0.1f",v2-v1];
        }
    }
    else if ([arrValues count] == 1){
        //LAST
        _labelLastValue.text = @"-";
        _labelLastDate.text = @"尚无记录";
        //CURRENT
        NSDictionary *dict = [arrValues objectAtIndex:0];
        NSDate *date = [ACDate getDateFromTimeStamp:[[dict objectForKey:@"measure_time"] longValue]]; 
        _labelCURValue.text = [NSString stringWithFormat:@"%0.1f",[[dict objectForKey:@"value"] doubleValue]];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
        _labelCURDate.text = [myDateFormatter stringFromDate:date];
        //CHANGE
        _labelChangeValue.text = @"-";
    }
    else{
        //LAST
        _labelLastValue.text = @"-";
        _labelLastDate.text = @"尚无记录";
        //CURRENT
        _labelCURValue.text = @"-";
        _labelCURDate.text = @"尚无记录";
        //CHANGE
        _labelChangeValue.text = @"-";
    }
    
    //加载CorePlot
    [self drawLine:CGRectMake(0, 0, self.view.bounds.size.width, plotHeight)];
    [_viewPlot addSubview:plot];
    
    
    //图例
    UIImageView *imageViewArea = [[UIImageView alloc]initWithFrame:CGRectMake(200, 5, 20, 20)];
    imageViewArea.backgroundColor = [ACFunction colorWithHexString:@"#f39998"];
//    imageViewArea.image = [UIImage imageNamed:@"plot_area_title@2x.png"];
    [_viewPlot addSubview:imageViewArea];
    
    UILabel *labelArea = [[UILabel alloc]initWithFrame:CGRectMake(195, 25, 30, 18)];
    labelArea.font = [UIFont fontWithName:@"Arial" size:SMALLTEXT];
    labelArea.textColor = [UIColor blackColor];
    labelArea.textAlignment = NSTextAlignmentCenter;
    labelArea.text = @"用户";
    [_viewPlot addSubview:labelArea];
    
    UIImageView *imageViewUser = [[UIImageView alloc]initWithFrame:CGRectMake(232, 5, 20, 20)];
    imageViewUser.backgroundColor = [UIColor colorWithRed:104/255.0 green:191/255.0 blue:204/255.0 alpha:0.3];
    [_viewPlot addSubview:imageViewUser];
    
    UILabel *labelUser = [[UILabel alloc]initWithFrame:CGRectMake(228, 25, 30, 18)];
    labelUser.font = [UIFont fontWithName:@"Arial" size:SMALLTEXT];
    labelUser.textColor = [UIColor blackColor];
    labelUser.textAlignment = NSTextAlignmentCenter;
    labelUser.text = @"标准值";
    [_viewPlot addSubview:labelUser];
}

-(void)makeAdvise:(CGRect)rect
{
    AdviseScrollview *ad;
    
    switch (itemType) {
        case 0:
            ad = [[AdviseScrollview alloc] initWithArray:[GetPhyAdvise getHeight]];
            break;
        case 1:
            ad = [[AdviseScrollview alloc] initWithArray:[GetPhyAdvise getWeight]];
            break;
        case 2:
            ad = [[AdviseScrollview alloc] initWithArray:[GetPhyAdvise getBMI]];
            break;
        case 3:
            ad = [[AdviseScrollview alloc] initWithArray:[GetPhyAdvise getHS]];
            break;
        default:
            break;
    }
    
    adviseImageView = [[UIImageView alloc] init];
    [adviseImageView setFrame:rect];
    [adviseImageView setBackgroundColor:[ACFunction colorWithHexString:@"#f6f6f6"]];
    adviseImageView.userInteractionEnabled = YES;
    [adviseImageView addSubview:ad];
    [self.view addSubview:adviseImageView];
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIImageView *addIamge1;
    UIImageView *addIamge;
    UIImageView *cutline;
    if (DEVICE_IS_IPHONE5){
        addIamge1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, frame.size.height-110+7 - 40  , 130/2.0, 256/2.0)];
        addIamge = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width-100/2.0, frame.size.height-102/2.0 -40 , 171/2.0, 102/2.0)];
        cutline = [[UIImageView alloc]initWithFrame:CGRectMake(0, WINDOWSCREEN-110-40 , 320, 10)];
    }else{
        addIamge = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width-100/2.0, frame.size.height-102/2.0, 171/2.0, 102/2.0)];
        addIamge1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, frame.size.height-110+7, 130/2.0, 256/2.0)];
        cutline = [[UIImageView alloc]initWithFrame:CGRectMake(0, WINDOWSCREEN-110, 320, 10)];
    }
    [cutline setImage:[UIImage imageNamed:@"分界线"]];
    [addIamge1 setImage:[UIImage imageNamed:@"长颈鹿"]];
    [self.view addSubview:addIamge1];
    [addIamge setImage:[UIImage imageNamed:@"大象"]];
    [self.view addSubview:addIamge];
    [self.view addSubview:cutline];
}

-(void)drawLine:(CGRect)rect{
    BabyDataDB *db = [BabyDataDB babyinfoDB];
    
    //获取宝贝信息
    NSDictionary *dict = [db selectBabyInfoByBabyId:BABYID];
    long birthTime = [[dict objectForKey:@"birth"] longValue];
    int sex = [[dict objectForKey:@"sex"] intValue];
    //用户坐标数据
    NSArray *dataUser = [self GetUserAsix:birthTime];
    //获取X轴刻度值
    NSArray *xAxis = [self GetXAsix:dataUser];
    //P25和P75坐标数据
    NSArray *dataP25 = [db getDataArrayByXposition:xAxis Condition:@"P25" Type:itemType Sex:sex];
    NSArray *dataP75 = [db getDataArrayByXposition:xAxis Condition:@"P75" Type:itemType Sex:sex];
    //获取Y轴刻度值
    NSArray *yAxis = [self GetYAsixByUserAxis:dataUser P25Axis:dataP25 P75Axis:dataP75];
    plot = [[PhyCorePlot alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, plotHeight) UserAxis:dataUser HeightAxis:dataP75 LowAxis:dataP25  XAxis:xAxis YAxis:yAxis XTitle:@"日龄" YTitle:itemUnit];
}

-(void)ShowHistory{
    if ([arrValues count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"暂无数据" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    PHYHistoryViewController *pHYHistoryViewController=[[PHYHistoryViewController alloc] init];
    [pHYHistoryViewController setType:[[arrayCurrent objectAtIndex:0]intValue]];
    [self.navigationController pushViewController:pHYHistoryViewController animated:YES];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)AddRecord{
    if (phySaveView==nil) {
        phySaveView = [[PhySaveView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height-64) Type:itemType OpType:@"SAVE" CreateTime:0];
        phySaveView.PhySaveDelegate = self;
    }
    [self.view addSubview:phySaveView];
}

-(void)setVar:(NSArray*) array{
    arrayCurrent = array;
    
    switch ([[array objectAtIndex:0]intValue]) {
        case 0:
            itemName = @"身高";
            itemUnit = @"cm";
            break;
        case 1:
            itemName = @"体重";
            itemUnit = @"kg";
            break;
        case 2:
            itemName = @"BMI";
            itemUnit = @"指数";
            break;
        case 3:
            itemName = @"头围";
            itemUnit = @"cm";
            break;
        case 4:
            itemName = @"体温";
            itemUnit = @"°C";
            break;
        default:
            break;
    }
    itemType = [[array objectAtIndex:0]intValue];
}

#pragma mark - 获取x轴坐标系
-(NSArray*)GetXAsix:(NSArray*)arrUser
{
    /******************************
     *          X轴:控制可显示范围为11个坐标点(包括原点)且不可拉升    实际显示11个坐标点
     *  开始坐标点(原点):   (第一次记录时间 / 10) * 10
     *  结束坐标点:        (最后一次记录时间 / 10 + 1 ) * 10 (增加1格以查看趋势)
     *  间隔:             结束值-开始值 / 10 段
     ******************************/
    NSMutableArray * arrXAsix = [[NSMutableArray alloc]initWithCapacity:11];
    int minDay = [[[arrUser firstObject] objectAtIndex:0] intValue];
    int maxDay = [[[arrUser lastObject] objectAtIndex:0] intValue];
    
    int xBegin = ( minDay / 10) * 10;
    int xEnd = ( maxDay / 10 + 1) * 10;
    int xInterval = ( xEnd - xBegin ) / 10;
    
    for (int i = 0; i <= 10; i++) {
        [arrXAsix addObject:[NSNumber numberWithInt:(xBegin + i * xInterval)]];
    }
    return arrXAsix;
}

#pragma mark - 获取y轴坐标系
-(NSArray*)GetYAsixByUserAxis:(NSArray*)userAxis
                      P25Axis:(NSArray*)p25Axis
                      P75Axis:(NSArray*)p75Axis
{
   /*
    *          Y轴:控制可显示范围7个坐标点(包括原点)且可拉升       实际显示5个坐标点
    *  开始坐标点:      WHO最小值取整
    *  结束坐标点:      WHO与用户最大值取整 + 1
    *  间隔:           (WHO与用户最大值取整 + 1) - WHO最小值取整 / 4
    *
    *          用户数据:数据集@[日龄,数值]
    */
    NSMutableArray *arrUnio = [[NSMutableArray alloc]initWithArray:[p25Axis arrayByAddingObjectsFromArray:p75Axis]];
    for (int i=0; i<[userAxis count]; i++) {
        [arrUnio addObject:[[userAxis objectAtIndex:i] objectAtIndex:1]];
    }
    int yBegin = [[arrUnio valueForKeyPath:@"@min.intValue"] intValue];
    int yEnd = [[arrUnio valueForKeyPath:@"@max.intValue"] intValue] + 1;
    double yInterval = ( yEnd - yBegin ) / 4.0f;
    
    NSMutableArray * arrYAsix = [[NSMutableArray alloc]initWithCapacity:0];
    for (int i = 0; i<5; i++) {
        [arrYAsix addObject:[NSNumber numberWithDouble:(yBegin + yInterval*i)]];
    }
    return arrYAsix;
}

#pragma GetUserData
-(NSArray*)GetUserAsix:(long)birthTime{
    NSArray *arrUserAsix = [[NSArray alloc] init];
    if (itemType != 2) {//身高、体重、头围
        arrUserAsix = [[BabyDataDB babyinfoDB]selectBabyPhysiologyList:itemType BabyBirthTime:birthTime];
    }
    else{//BMI
        NSArray *arrBmi = [[BabyDataDB babyinfoDB]selectBabyBMIList];
        //注:selectBabyBMIList是order by time desc. 所以此处需要倒序遍历
        for (int i=[arrBmi count] -1; i >= 0; i--) {
            NSDictionary *dict = [arrBmi objectAtIndex:i];
            long lMeasureTime = [[dict  objectForKey:@"measure_time"] longValue];
            int iRecordDay = (lMeasureTime - birthTime) / 86400;
            double dValue = [[dict objectForKey:@"value"] doubleValue];
            arrUserAsix = [arrUserAsix arrayByAddingObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:iRecordDay],[NSNumber numberWithDouble:dValue], nil]];
        }
    }
    
    return arrUserAsix;
}

-(void)sendPhyReloadData{
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
