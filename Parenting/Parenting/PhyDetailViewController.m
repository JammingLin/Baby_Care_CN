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

#define YAXISCOUNT 5
#define SIZEINTERVA 10

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

-(void)viewDidDisappear:(BOOL)animated{
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
    
    _buttonBack = [[UIButton alloc] init];
    _buttonBack.frame = CGRectMake(10, 22, 40, 40);
    _buttonBack.titleLabel.font = [UIFont systemFontOfSize:14];
    [_buttonBack setTitle:@"返回" forState:UIControlStateNormal];
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
    
    //corePlot
    _viewPlot = [[UIView alloc]initWithFrame:CGRectMake(0, 175, self.view.bounds.size.width, 65)];
    _viewPlot.backgroundColor = [ACFunction colorWithHexString:@"#f6f6f6"];
    [self.view addSubview:_viewPlot];
    
    //adviseView
    [self makeAdvise:CGRectMake(0, 480-130, 320, 130)];
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
    [self drawLine:CGRectMake(0, 0, self.view.bounds.size.width, 174)];
    [_viewPlot addSubview:plot];
    
    
    //图例
    UIImageView *imageViewArea = [[UIImageView alloc]initWithFrame:CGRectMake(200, 5, 20, 20)];
    imageViewArea.image = [UIImage imageNamed:@"plot_area_title@2x.png"];
    [_viewPlot addSubview:imageViewArea];
    
    UILabel *labelArea = [[UILabel alloc]initWithFrame:CGRectMake(195, 25, 30, 18)];
    labelArea.font = [UIFont fontWithName:@"Arial" size:SMALLTEXT];
    labelArea.textColor = [UIColor blackColor];
    labelArea.textAlignment = NSTextAlignmentCenter;
    labelArea.text = @"正常值";
    [_viewPlot addSubview:labelArea];
    
    UIImageView *imageViewUser = [[UIImageView alloc]initWithFrame:CGRectMake(232, 5, 20, 20)];
    imageViewUser.backgroundColor = [UIColor blueColor];
    [_viewPlot addSubview:imageViewUser];
    
    UILabel *labelUser = [[UILabel alloc]initWithFrame:CGRectMake(228, 25, 30, 18)];
    labelUser.font = [UIFont fontWithName:@"Arial" size:SMALLTEXT];
    labelUser.textColor = [UIColor blackColor];
    labelUser.textAlignment = NSTextAlignmentCenter;
    labelUser.text = @"用户";
    [_viewPlot addSubview:labelUser];
}

-(void)makeAdvise:(CGRect)rect
{
    NSDictionary *dict1=[[NSDictionary alloc]initWithObjectsAndKeys:@"问：一个婴儿低于或仅仅稍高于其年龄体重或身高意味着什么？或者说，世卫组织的生长标准是一个标准适合所有人吗？\n\r答：这并不一定意味着儿童有什么问题；这意味着儿科医生应当注意。世卫组织的研究及其他许多研究都已经证明，对于直到10岁左右的儿童，假如他们获得适当的照料、喂养和免疫，则均有可能生长到平均水平。在生长模式中，没有所谓的“统一尺寸”，然而（从0到100百分值的）数值分布使得基因造成的高和矮的儿童均能够成为一样的健康分布中的一部分。",@"content", nil];
    NSDictionary *dict2=[[NSDictionary alloc]initWithObjectsAndKeys:@"问：世卫组织生长标准是如何制定的？\n\r答：世卫组织的生长标准以（1997-2003）世卫组织多中心生长参照研究为基础，这一研究所运用的一套严谨方法可以作为开展国际研究合作的模型。由于以生长环境不受约束的健康儿童为样本，因而此项研究为标准的制定提供了坚实的基础。另外，为制定标准而选择的这些儿童的母亲均参与了关键的健康促进做法，即母乳喂养和不吸烟。标准的产生则遵照了最高技术水平的统计学方法。",@"content", nil];
    NSDictionary *dict3=[[NSDictionary alloc]initWithObjectsAndKeys:@"问:什么是世卫组织儿童生长标准？\n\r答：这些图表是评估儿童是否按照他们应达到的速度生长和发展的简单工具。它们也可以用来检查降低儿童死亡率和疾病的努力是否有效。新标准首次证明：如果出生在世界不同地区的儿童被赋予最有利的开端，那么他们将有潜力生长和发展到年龄身高和体重的相同范围之内。标准同时还用于发现未达到完全生长能力或平均体重不足或超重的儿童。",@"content", nil];
    
    AdviseScrollview *ad=[[AdviseScrollview alloc]initWithArray:[NSArray arrayWithObjects:dict1,dict2,dict3, nil]];
    
    adviseImageView = [[UIImageView alloc] init];
    [adviseImageView setFrame:rect];
    [adviseImageView setBackgroundColor:[ACFunction colorWithHexString:@"#f6f6f6"]];
    adviseImageView.userInteractionEnabled = YES;
    [adviseImageView addSubview:ad];
    [self.view addSubview:adviseImageView];
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIImageView *addIamge1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, frame.size.height-130+7, 130/2.0, 256/2.0)];
    [addIamge1 setImage:[UIImage imageNamed:@"长颈鹿"]];
    [self.view addSubview:addIamge1];
    
    UIImageView *addIamge = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width-171/2.0, frame.size.height-102/2.0, 171/2.0, 102/2.0)];
    [addIamge setImage:[UIImage imageNamed:@"大象"]];
    [self.view addSubview:addIamge];

    UIImageView *cutline = [[UIImageView alloc]initWithFrame:CGRectMake(0, WINDOWSCREEN-130, 320, 10)];
    [cutline setImage:[UIImage imageNamed:@"分界线"]];
    [self.view addSubview:cutline];
}

-(void)drawLine:(CGRect)rect{
    //********Start********
    //Step-1:                           根据宝宝的出生天数得出X轴范围
    //Argument:postnatalDays            宝宝的出生天数
    //Method:                           xAsix = GetXAsix(postnatalDays)
    NSDictionary *dict = [[BabyDataDB babyinfoDB]selectBabyInfoByBabyId:BABYID];
    int postnatalDays = [self numberOfDaysFromTodayByTime:[[dict objectForKey:@"birth"] intValue]];
    
    NSArray *xAsix = [self GetXAsix:postnatalDays];
    
    BabyDataDB *db = [BabyDataDB babyinfoDB];
    //Step-2:根据X轴值获取WHO对应数值 
    NSArray *dataP25 = [db getDataArrayByXposition:xAsix Condition:@"P25" Type:itemType Sex:[[[db selectBabyInfoByBabyId:BABYID] objectForKey:@"sex"] intValue]];
    
    NSArray *dataP75 = [db getDataArrayByXposition:xAsix Condition:@"P75" Type:itemType Sex:[[[db selectBabyInfoByBabyId:BABYID] objectForKey:@"sex"] intValue]];
    //获取用户数据
    NSArray *dataUser = [self GetUserAsix:xAsix PostnatalDay:postnatalDays];
    //Step-3:根据WHO的对应值得出Y轴范围
    NSArray *yAsix = [self GetYAsixByBiger:dataP75 andSmaller:dataP25];
    
    //录入P25;P75;用户数值
    NSArray *xyPlot = @[dataP25,dataP75,dataUser];
    NSArray *xyTitle = @[@"日龄",itemUnit];
    NSArray *axis = @[xAsix,yAsix];
    
    plot = [[PhyCorePlot alloc]initWithFrame:rect Title:@"" XYPlotRange:xyPlot XYTitle:xyTitle Axis:axis YBaseV:yBaseValue YSizeInterval:ySizeInterval];
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

- (NSInteger)numberOfDaysFromTodayByTime:(int)birth
{
    NSDate *today = [NSDate date];
    NSTimeZone *localTimeZone = [NSTimeZone systemTimeZone];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:localTimeZone];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    double dBirth = (double)birth;
    double dToday = [ACDate getTimeStampFromDate:today];
    NSInteger nSecs = (NSInteger)(dToday - dBirth);
    NSInteger oneDaySecs = 24*3600;
    return nSecs / oneDaySecs;
    
}

#pragma mark - 获取x轴坐标系
-(NSArray*)GetXAsix:(int)PostnatalDays
{
    NSMutableArray * arrXAsix = [[NSMutableArray alloc]initWithCapacity:0];
    if (PostnatalDays <= 30) {
        PostnatalDays = 30;
        sizeInterval = 30 / SIZEINTERVA;
        for (int i = 0; i <= PostnatalDays; i++) {
            if (i % sizeInterval == 0) {
                [arrXAsix addObject:[NSNumber numberWithInt:i]];
            }
        }
        return arrXAsix;
    }
    else if (PostnatalDays > 30 && PostnatalDays <=60){
        PostnatalDays=60;
        sizeInterval = 60 / SIZEINTERVA;
        for (int i = 0; i <= PostnatalDays; i++) {
            if (i % sizeInterval == 0) {
                [arrXAsix addObject:[NSNumber numberWithInt:i]];
            }
        }
        return arrXAsix;
    }
    else if (PostnatalDays> 60 && PostnatalDays <=90){
        PostnatalDays = 90;
        sizeInterval = 90 / SIZEINTERVA;
        for (int i = 0; i <= PostnatalDays; i++) {
            if (i % sizeInterval == 0) {
                [arrXAsix addObject:[NSNumber numberWithInt:i]];
            }
        }
        return arrXAsix;
    }
    else{
        sizeInterval = 90 / SIZEINTERVA;
        while (PostnatalDays % sizeInterval != 0)
        {
            PostnatalDays++;
        }
        
        for (int i = (PostnatalDays - 90); i <= PostnatalDays; i++) {
            if (i % sizeInterval == 0) {
                [arrXAsix addObject:[NSNumber numberWithInt:i]];
            }
        }
        return arrXAsix;
    }
}

#pragma mark - 获取y轴坐标系
-(NSArray*)GetYAsixByBiger:(NSArray*)Barr andSmaller:(NSArray*)Sarr
{
    NSComparator cmptr = ^(id obj1, id obj2){
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSMutableArray * arrYAsix = [[NSMutableArray alloc]initWithCapacity:0];
    NSArray *Bsort = [Barr sortedArrayUsingComparator:cmptr];
    NSArray *Ssort = [Sarr sortedArrayUsingComparator:cmptr];
    float max = [[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%.0f",[[Bsort lastObject]floatValue]] floatValue]] floatValue];
    float min = [[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%.0f",[[Ssort firstObject]floatValue]] floatValue]] floatValue];
    
    yBaseValue = min;
    ySizeInterval = [[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%.1f",(max - min) / (YAXISCOUNT-1)] floatValue]] floatValue];
    
    [arrYAsix addObject:[NSNumber numberWithFloat:0.0f]];
    
    //确保最大值在区间内
    max += ySizeInterval;
    for (float i = min; i < max; i=i+ySizeInterval) {
        [arrYAsix addObject:[NSNumber numberWithFloat:i]];
    }
    return arrYAsix;
}

#pragma GetUserData
-(NSArray*)GetUserAsix:(NSArray*)Barr PostnatalDay:(int)postnatalDays{
    int beginDay = [[Barr objectAtIndex:0] intValue];
    int endDay = [[Barr objectAtIndex:[Barr count]-1] intValue];
    long birthTime =[[[[BabyDataDB babyinfoDB] selectBabyInfoByBabyId:BABYID] objectForKey:@"birth"] longValue];
    NSMutableArray *arrRes = [[NSMutableArray alloc] initWithCapacity:50];
    if (itemType != 2) {
        arrRes = [[NSMutableArray alloc]initWithArray:[[BabyDataDB babyinfoDB] selectBabyPhysiologyList:itemType BeginDay:beginDay EndDay:endDay BabyBirthTime:birthTime]];
    }
    else{
        arrRes = [[NSMutableArray alloc]initWithArray:[[BabyDataDB babyinfoDB] selectBabyBMIList:itemType BeginDay:beginDay EndDay:endDay BabyBirthTime:birthTime]]; 
    }
    NSArray *arrPro = [[NSArray alloc]init];

    /**
     *  a.如果区间内无数据,则根据x轴坐标返回:0 0 0 0 0 0
     *  b.如果只有一个值,则根据x轴返回:0 0 0 值 值 值
     *  c.如果有两个值以上,则根据x轴返回:0 值1 值1和值2根据直线求出的坐标 值2  值3
     *  ---  X轴对应的值等于前后区间/2的时间长度内所有值的平均值  ---
     */
    if ([arrRes count] == 0) {
        for (int i=0; i<[Barr count]; i++) {
            arrPro = [arrPro arrayByAddingObject:[NSNumber numberWithDouble:0.0f]];
        }
    }
    else{
        //归拢到对应坐标轴
        for (int i=0; i<[arrRes count]; i++) {
            NSDictionary *tDict = [arrRes objectAtIndex:i];
            int resDay = [[tDict objectForKey:@"recordDay"]intValue];
            //iDis:第几个间隔 = (当前日数-开始日数 + 间隔单位 / 2) / 间隔单位
            int iDis = (resDay - beginDay + sizeInterval / 2 ) / sizeInterval;
            [tDict setValue:[NSNumber numberWithInt:(beginDay + iDis*sizeInterval)] forKey:@"recordDay"];
        }
        
        //如果有多个数值,求坐标轴对应点上的平均值
        for (int i=0; i<[Barr count]; i++) {
            double dTotal = 0;
            int dCount = 0;
            for(int k=0;k<[arrRes count];k++)
            {
                NSDictionary *tDict = [arrRes objectAtIndex:k];
                if ([[tDict objectForKey:@"recordDay"]intValue] == [[Barr objectAtIndex:i] intValue]) {
                    dTotal = dTotal + [[tDict objectForKey:@"value"] doubleValue];
                    dCount = dCount + 1;
                }
            }
            if (dCount == 0){
                arrPro = [arrPro arrayByAddingObject:[NSNumber numberWithDouble:0.0f]];
            }
            else if (dCount != 0){
                arrPro = [arrPro arrayByAddingObject:[NSNumber  numberWithDouble:(dTotal / dCount)]];
            }
        }
    }
    
    NSMutableArray *arrRet = [arrPro mutableCopy];
    //把空值去掉
    int iRCount = [arrRet count];
    for(int i = iRCount - 1; i >= 0 ; i--){
        if ([[arrRet objectAtIndex:i] doubleValue] == 0) {
            [arrRet removeObjectAtIndex:i];
        }
        else{
            NSArray *arrTemp = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:i],[arrRet objectAtIndex:i], nil];
            [arrRet replaceObjectAtIndex:i withObject:arrTemp];
        }
    }
    return arrRet;
}

-(void)sendPhyReloadData{
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
