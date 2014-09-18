/*
 *  2014/08/25 - 时间轴内容
 *
 *  0:系统消息 
 *
 *  **** 提醒根据时间节点判断进行添删 ****
 *  key:-1代表该提醒事项未完成 1代表该提醒事项已经完成
 *  1:用户自定义提醒
 *  10:疫苗提醒
 *  11:评测提醒
 *  12:日志提醒
 *  20:生理-身高记录提醒
 *  21:生理-体重记录提醒
 *  22:生理-头围记录提醒
 *
 *  **** 贴士推送 ****
 *  key:代表该贴士ID
 *  99:贴士推送-（根据用户及贴士属性推送）
 *
 */

#import "HomeViewController.h"
#import "InitTimeLineData.h"
#import "NetWorkConnect.h"
#import "DataContract.h"
#import "InitBabyInfoViewController.h"

#import "NoteController.h"
#import "VaccineController.h"
#import "TestController.h"
#import "TestReportController.h"
#import "TestModel.h"
#import "PHYDetailViewController.h"
#import "PhysiologyViewController.h"

#import "LoginViewController.h"
#import "LoginMainViewController.h"
#import "UMSocial.h"
#import "MBProgressHUD.h"
#import "MD5.h"
#import "APService.h"
#import "DataContract.h"
#import "NetWorkConnect.h"
#import "UserDataDB.h"
#import "SyncController.h"



#define _SHOW_HEIGHT 185
#define _CELL_NORMAL_BASEHEIGHT 52.0f
#define _CELL_NORMAL_INSHEIGHT  18.0f
#define _CELL_TIPS_BASEHEIGHT 223.0f

#define _CELL_CHANGE_MAXLEN 17
#define _TIPS_ID 99

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //时间轴默认展示10条数据
    _timeLineShowCount = 5;
    
    [self initView];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kBabyNickname"] != nil) {
        _initTimeLineData = [[InitTimeLineData alloc]init];
        _initTimeLineData.targetViewController = self;
        [_initTimeLineData getTimeLineData];
    }
} 

-(void)viewWillAppear:(BOOL)animated    {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] == nil){
        [_photoAreaView removeFromSuperview];
        [_mainScrollView removeFromSuperview];
        _data = nil;
        [self initView];
        [self initData];
        isPushSocialView = NO;
        _loginView.hidden = NO;
    }
    //未初始化宝宝基本信息时跳转
    else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kBabyNickname"] == nil) {
        InitBabyInfoViewController *ctr = [[InitBabyInfoViewController alloc]init];
        ctr.initBabyInfoDelegate = self;
        [self.navigationController pushViewController:ctr animated:NO];
        return;
    }
    else{ 
        [self initData];
    }
    [MobClick beginLogPageView:@"首页"];
}

-(void)viewDidAppear:(BOOL)animated{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"] == nil){
        isPushSocialView = NO;
        _loginView.hidden = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
}

-(void)viewDidDisappear:(BOOL)animated{
    if (isPushSocialView) {
        isPushSocialView = NO;
    }
}

-(void)initHomeData{
    _initTimeLineData = [[InitTimeLineData alloc]init];
    _initTimeLineData.targetViewController = self;
    [_initTimeLineData getTimeLineData];
    [self initData];
}

-(void)initView{
    //LoginView
    _loginView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _loginView.backgroundColor = [UIColor blackColor];
    _loginView.alpha = 0.9;
    
    UIButton *buttonLogin = [[UIButton alloc]initWithFrame:CGRectMake(45, [UIScreen mainScreen].bounds.size.height - 50 -40 -50-50, 230, 38)];
    [buttonLogin setImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
    [buttonLogin addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
    [_loginView addSubview:buttonLogin];
    
    UIButton *buttonTen = [[UIButton alloc]initWithFrame:CGRectMake(45, [UIScreen mainScreen].bounds.size.height - 50 -40 -50, 230, 38)];
    [buttonTen setImage:[UIImage imageNamed:@"btn_tent"] forState:UIControlStateNormal];
    [buttonTen addTarget:self action:@selector(doTenLogin) forControlEvents:UIControlEventTouchUpInside];
    [_loginView addSubview:buttonTen];
    
    UIButton *buttonSina = [[UIButton alloc]initWithFrame:CGRectMake(45, [UIScreen mainScreen].bounds.size.height - 50 - 40, 230, 38)];
    [buttonSina setImage:[UIImage imageNamed:@"btn_sina.png"] forState:UIControlStateNormal];
    [buttonSina addTarget:self action:@selector(doSinaLogin) forControlEvents:UIControlEventTouchUpInside];
    [_loginView addSubview:buttonSina];
    
    UIButton *buttonRegister = [[UIButton alloc]initWithFrame:CGRectMake(200,[UIScreen mainScreen].bounds.size.height - 50, 120, 38)];
    [buttonRegister setTitle:@"注册账号" forState:UIControlStateNormal];
    [buttonRegister.titleLabel setFont:[UIFont systemFontOfSize:MIDTEXT]];
    [buttonRegister setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [buttonRegister addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBarController.view.superview addSubview:_loginView];
    _loginView.hidden = YES;
    //LoginView end

    _photoAreaView = [[PhotoAreaView alloc]initWithFrame:CGRectMake(0, 0, 320, _SHOW_HEIGHT)];
//    _photoAreaView.top = _SHOW_HEIGHT - _photoAreaView.height; 
    [self.view addSubview:_photoAreaView];
    
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _SHOW_HEIGHT, 320, [UIScreen mainScreen].bounds.size.height - _SHOW_HEIGHT - 49)];
    _mainScrollView.scrollEnabled = YES;
    _mainScrollView.delegate = self;
    [self.view addSubview:_mainScrollView];
    
    _timeLineTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320    ,0)];
    _timeLineTableView.dataSource = self;
    _timeLineTableView.delegate = self;
    _timeLineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _timeLineTableView.scrollEnabled= NO;
    [_mainScrollView addSubview:_timeLineTableView];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake(10,_photoAreaView.height - 25, 20.0f, 20.0f);
    [_photoAreaView addSubview:_activityView];
}

-(void)initData{
    [_photoAreaView initData];
    
    //加载时间轴数据源
    [self initTimeLineData];
}

-(void)initTimeLineData{
    [_activityView stopAnimating];
    _mainScrollView.scrollEnabled = YES;
    
    _data = [[NSMutableArray alloc]initWithArray:[[BabyMessageDataDB babyMessageDB]selectByLast:0 Count:_timeLineShowCount]];
    
    //计算表格高度
    double dTableHeight = 0;
    for (int i = 0; i<[_data count];i++ ) {
        if ([[[_data objectAtIndex:i] objectAtIndex:0] intValue] != _TIPS_ID) {
            int tLen = [[[_data objectAtIndex:i] objectAtIndex:1] length];
            if (tLen <= _CELL_CHANGE_MAXLEN) {
                dTableHeight = dTableHeight + _CELL_NORMAL_BASEHEIGHT;
            }
            else {
                dTableHeight = dTableHeight + _CELL_NORMAL_BASEHEIGHT + _CELL_NORMAL_INSHEIGHT;
            }
        }
        else{
            dTableHeight = dTableHeight + _CELL_TIPS_BASEHEIGHT;
        }
    }
    
    _timeLineTableView.height = dTableHeight;
    _mainScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,_timeLineTableView.height);
    [_timeLineTableView reloadData];
}

#pragma tableView datasource Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_data count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //labelTitle 如果大于_CELL_CHANGE_MAXLEN个字需要换行
    if ([[[_data objectAtIndex:indexPath.row] objectAtIndex:0] intValue] != _TIPS_ID) {
        int tLen = [[[_data objectAtIndex:indexPath.row] objectAtIndex:1] length];
        
        if (tLen <= _CELL_CHANGE_MAXLEN) {
            return _CELL_NORMAL_BASEHEIGHT ;
        }
        else {
            return _CELL_NORMAL_BASEHEIGHT + _CELL_NORMAL_INSHEIGHT;
        }
        
    }
    else{
        return _CELL_TIPS_BASEHEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *curData = [_data objectAtIndex:indexPath.row];
    
    if ([[curData objectAtIndex:0]intValue] != _TIPS_ID) {
        
        /** init cell view **/
        UIImageView *imageViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        [cell addSubview:imageViewIcon];
        
        UIImageView *imageViewContentBg = [[UIImageView alloc] init];
        [cell addSubview:imageViewContentBg];
        
        UILabel *labelContent = [[UILabel alloc] init];
        labelContent.font = [UIFont systemFontOfSize:HOME_TIPSTEXT];
        labelContent.textColor = [ACFunction colorWithHexString:TEXTCOLOR];
        [imageViewContentBg addSubview:labelContent];
        
        UILabel *labelTime = [[UILabel alloc] init];
        labelTime.font = [UIFont systemFontOfSize:SMALLTEXT];
        labelTime.textColor = [ACFunction colorWithHexString:TEXTCOLOR];
        labelTime.textAlignment = NSTextAlignmentRight;
        [imageViewContentBg addSubview:labelTime];
        
        /** init cell data **/
        switch ([[curData objectAtIndex:0]intValue]) {
            case 0:
                imageViewIcon.image = [UIImage imageNamed:@"icon_news.png"];
                break;
            case 1:
                imageViewIcon.image = [UIImage imageNamed:@"icon_alarm.png"];
                break;
            case 10:
                imageViewIcon.image = [UIImage imageNamed:@"icon_alerm_vaccine.png"];
                break;
            case 11:
                imageViewIcon.image = [UIImage imageNamed:@"icon_alerm_milstone.png"];
                break;
            case 12:
                imageViewIcon.image = [UIImage imageNamed:@"icon_alerm_dialy.png"];
                break;
            case 20:
                imageViewIcon.image = [UIImage imageNamed:@"icon_height.png"];
                break;
            case 21:
                imageViewIcon.image = [UIImage imageNamed:@"icon_weight.png"];
                break;
            default:
                imageViewIcon.image = [UIImage imageNamed:@"icon_news.png"];
                break;
        }
        
        //根据标题长度判断是否需要拉升
        if ([[curData objectAtIndex:1] length] <= _CELL_CHANGE_MAXLEN) {
            imageViewContentBg.frame = CGRectMake(57, 6, 246, 40);
            imageViewContentBg.image = [UIImage imageNamed:@"input_word.png"];
            labelContent.frame = CGRectMake(10, 5, 230, 16);
            labelTime.frame = CGRectMake(193, 22, 48, 15);
        }
        else {
            imageViewContentBg.frame = CGRectMake(57, 6, 246, 58);
            imageViewContentBg.image = [[UIImage imageNamed:@"input_word.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:30];
            labelContent.frame = CGRectMake(10, 5, 230, 36);
            labelContent.lineBreakMode = NSLineBreakByWordWrapping;
            labelContent.numberOfLines = 0;
            labelTime.frame = CGRectMake(193, 40, 48, 15);
        }
        
        labelContent.text = [curData objectAtIndex:1];
        labelTime.text = [ACDate getMsgTimeSinceDate:[ACDate getDateFromTimeStamp:[[curData objectAtIndex:4]longValue]]];
    }
    else {
        /** init cell view **/
        UIImageView *imageViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        [cell addSubview:imageViewIcon];
        UIImageView *imageViewContentBg = [[UIImageView alloc] init];
        imageViewContentBg.frame = CGRectMake(57, 6, 246, 211);
        imageViewContentBg.image = [[UIImage imageNamed:@"input_word.png"]stretchableImageWithLeftCapWidth:10 topCapHeight:30];
        [cell addSubview:imageViewContentBg];
        
        UILabel *labelContent = [[UILabel alloc] init];
        labelContent.frame = CGRectMake(10, 5, 230, 16);
        labelContent.font = [UIFont systemFontOfSize:HOME_TIPSTEXT];
        labelContent.textColor = [ACFunction colorWithHexString:TEXTCOLOR];
        [imageViewContentBg addSubview:labelContent];
        
        UIImageView *imagePic = [[UIImageView alloc] init];
        imagePic.frame = CGRectMake(10, 26, 230, 161);
        imagePic.image = [UIImage imageNamed:@"tip_demo.jpg"];
//        [imageViewContentBg addSubview:imagePic];
        
        UILabel *labelTime = [[UILabel alloc] init];
        labelTime.frame = CGRectMake(193, 192, 48, 15);
        labelTime.font = [UIFont systemFontOfSize:SMALLTEXT];
        labelTime.textColor = [ACFunction colorWithHexString:TEXTCOLOR];
        labelTime.textAlignment = NSTextAlignmentRight;
        [imageViewContentBg addSubview:labelTime];
        
        /** init cell data **/
        
        /*
        NSString *key = [curData objectAtIndex:5];
        NSArray *keySplit = [key componentsSeparatedByString:@","];
        int category_id = [[keySplit objectAtIndex:0] intValue];
        int tip_id = [[keySplit objectAtIndex:1] intValue];
        
        NSArray* arrCategory = [TipCategoryDB selectCategoryById:category_id];
        NSString *imageUrl = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),[arrCategory objectAtIndex:3]];
        UIImage *imagea = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageUrl]];
        imageViewIcon = [[UIImageView alloc]initWithImage:imagea];
        [imageViewIcon setFrame:CGRectMake(10, 10, 60, 60)];
         */
        
        imageViewIcon.image = [UIImage imageNamed:@"icon_message.png"];
        labelContent.text = [curData objectAtIndex:1];
        labelTime.text = [ACDate getMsgTimeSinceDate:[ACDate getDateFromTimeStamp:[[curData objectAtIndex:4]longValue]]];
//        labelTime.text = @"1天前";
        
        NSString *picUrl = [NSString stringWithFormat:@"%@/%@",WEBPHOTO(@"Tip"),[curData objectAtIndex:2]];
        UIASYImageView *imageView = [[UIASYImageView alloc] initWithFrame:imagePic.frame];
        [imageView showImageWithUrl:picUrl];
        [imageViewContentBg addSubview:imageView];
//        imagePic.image = imageView.image;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma tableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /*  1:用户自定义提醒
    *  10:疫苗提醒
    *  11:评测提醒
    *  12:日志提醒
    *  20:生理-身高记录提醒
    *  21:生理-体重记录提醒
    *  22:生理-头围记录提醒
    */
    
    NSArray *curArr = [_data objectAtIndex:indexPath.row];
    if ([[curArr objectAtIndex:0] intValue] == 10) {
        VaccineController* vaccineVc = [[VaccineController alloc] init];
        [self.navigationController pushViewController:vaccineVc animated:YES];
    }
    else if ([[curArr objectAtIndex:0] intValue] == 11) {
        NSDate* birthDate = [BaseMethod dateFormString:kBirthday];
        NSDate* selectedDate = [BaseMethod beijingDate:[ACDate getDateFromTimeStamp:[[curArr objectAtIndex:4] longValue]]];
        
        int days = [BaseMethod fromStartDate:birthDate withEndDate:selectedDate];
        int month = days/30; // 第几个月
        
        NSArray* tests = [BaseSQL queryData_test];
        
        if (month < [BaseMethod month_test] && month >= 0 &&[BaseMethod month_test]>0) {
            
            TestModel* model = tests[month];
            if ([model.completed boolValue]) {
                TestReportController* reportVc = [[TestReportController alloc] init];
                reportVc.month = month;
                [self.navigationController pushViewController:reportVc animated:YES];
            }else
            {
                TestController* testVc = [[TestController alloc] init];
                testVc.month = month;
                [self.navigationController pushViewController:testVc animated:YES];
            }
            
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"暂无该月份的测评题" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }

    }
    else if ([[curArr objectAtIndex:0] intValue] == 12) {
        NoteController* noteVc = [[NoteController alloc] init];
        [self.navigationController pushViewController:noteVc animated:YES];
    }
    else if ([[curArr objectAtIndex:0] intValue] == 20) {
        NSArray *arrayHeight = @[@0,@"icon_height.png",@"当前身高",[self getValues:0],[self getIncrease:0],@"CM",[self getRecordDate:0],@"#84c082"];
        PHYDetailViewController *pHYDetailViewController = [[PHYDetailViewController alloc] init];
        [pHYDetailViewController setVar:arrayHeight];
        [self.navigationController pushViewController:pHYDetailViewController animated:YES];
    }
    else if ([[curArr objectAtIndex:0] intValue] == 21) {
        NSArray *arrayWeight = @[@1,@"icon_weight.png",@"当前体重",[self getValues:1],[self getIncrease:1],@"KG",[self getRecordDate:1],@"#efc654"];
        PHYDetailViewController *pHYDetailViewController = [[PHYDetailViewController alloc] init];
        [pHYDetailViewController setVar:arrayWeight];
        [self.navigationController pushViewController:pHYDetailViewController animated:YES];
    }
    else if ([[curArr objectAtIndex:0] intValue] == 22) {
        NSArray *arrayCRI = @[@3,@"icon_CIR.png",@"当前头围",[self getValues:3],[self getIncrease:3],@"CM",[self getRecordDate:3],@"#69b3e0"];
        PHYDetailViewController *pHYDetailViewController = [[PHYDetailViewController alloc] init];
        [pHYDetailViewController setVar:arrayCRI];
        [self.navigationController pushViewController:pHYDetailViewController animated:YES];
    }
    else if ([[curArr objectAtIndex:0] intValue] == 99) {
        NSString *str = [curArr objectAtIndex:5];
        NSArray *arrSplit = [str componentsSeparatedByString:@","];
        int tip_id = [[arrSplit lastObject] intValue];
        
        TipsWebViewController *tipsWeb = [[TipsWebViewController alloc]init];
        NSString *Url = [NSString stringWithFormat:@"%@tips/showTip.aspx?id=%d",BASE_URL,tip_id];
        [tipsWeb setTipsUrl:Url];
        [tipsWeb setTipsTitle:[curArr objectAtIndex:1]];
        NSString *picUrl = [NSString stringWithFormat:@"%@/%@",WEBPHOTO(@"Tip"),[curArr objectAtIndex:2]];
        [tipsWeb setShowImage:picUrl];
        [tipsWeb setFlag:1];
        [self.navigationController pushViewController:tipsWeb animated:YES];
    }
}

#pragma scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y + _mainScrollView.height > _timeLineTableView.bounds.size.height + 20 && !_activityView.isAnimating){
        [_activityView startAnimating];
        _mainScrollView.scrollEnabled = NO;
        _timeLineShowCount = _timeLineShowCount + 3;
        //获取当前列表最后一条的createTime
        [_initTimeLineData checkTips:[[[_data lastObject] objectAtIndex:4] longValue]];
    }
}

#pragma PHY methods
-(NSString*)getIncrease:(int)index{
    if (index != 2) {
        NSArray *arrValues = [[BabyDataDB babyinfoDB] selectBabyPhysiologyList:index];
        if ([arrValues count] >= 2) {
            NSDictionary *dict1 = [arrValues objectAtIndex:0];
            NSDictionary *dict2 = [arrValues objectAtIndex:1];
            
            double v1 = [[dict1 objectForKey:@"value"] doubleValue];
            double v2 = [[dict2 objectForKey:@"value"] doubleValue];
            
            if (v1 >= v2) {
                return [NSString stringWithFormat:@"↑%0.1f",v1-v2];
            }else{
                return [NSString stringWithFormat:@"↓%0.1f",v2-v1];
            }
        }
        else{
            return @"";
        }
    }
    else{
        NSArray *arrValues = [[BabyDataDB babyinfoDB] selectBabyBMIList];
        if ([arrValues count] >= 2) {
            NSDictionary *dict1 = [arrValues objectAtIndex:0];
            NSDictionary *dict2 = [arrValues objectAtIndex:1];
            
            double v1 = [[dict1 objectForKey:@"value"] doubleValue];
            double v2 = [[dict2 objectForKey:@"value"] doubleValue];
            
            if (v1 >= v2) {
                return [NSString stringWithFormat:@"↑%0.1f",v1-v2];
            }else{
                return [NSString stringWithFormat:@"↓%0.1f",v2-v1];
            }
        }
        else{
            return @"";
        }
    }
}

-(NSString*)getValues:(int)index{
    //非BMI
    if (index != 2){
        NSArray *arrValues = [[BabyDataDB babyinfoDB] selectBabyPhysiologyList:index];
        if ([arrValues count] == 0) {
            return @"--";
        }
        else{
            NSDictionary *dict = [arrValues objectAtIndex:0];
            return [NSString stringWithFormat:@"%0.1f",[[dict objectForKey:@"value"] doubleValue]];
        }
    }else{
        NSArray *arrValues = [[BabyDataDB babyinfoDB] selectBabyBMIList];
        if ([arrValues count] == 0) {
            return @"--";
        }
        else{
            NSDictionary *dict = [arrValues objectAtIndex:0];
            return [NSString stringWithFormat:@"%0.1f",[[dict objectForKey:@"value"] doubleValue]];
        }
    }
    
}

-(NSString*)getRecordDate:(int)index{
    //非BMI
    if (index != 2){
        NSArray *arrValues = [[BabyDataDB babyinfoDB] selectBabyPhysiologyList:index];
        if ([arrValues count] > 0) {
            NSDictionary *dict = [arrValues objectAtIndex:0];
            NSDate *date = [ACDate getDateFromTimeStamp:[[dict objectForKey:@"measure_time"] longValue]];
            return [ACDate getDaySinceDate:date];
        }
        else{
            return @"尚无记录";
        }
    }
    else{
        NSArray *arrValues = [[BabyDataDB babyinfoDB] selectBabyBMIList];
        if ([arrValues count] > 0) {
            NSDictionary *dict = [arrValues objectAtIndex:0];
            NSDate *date = [ACDate getDateFromTimeStamp:[[dict objectForKey:@"measure_time"] longValue]];
            return [ACDate getDaySinceDate:date];
        }
        else{
            return @"尚无记录";
        }
    }
}

#pragma 登陆相关
-(void)doLogin{
    _loginView.hidden = YES;
    
    LoginMainViewController *loginMainViewController = [[LoginMainViewController alloc]initWithNibName:@"LoginMainViewController" bundle:nil];
    loginMainViewController.mainViewController = self;
    [self.navigationController pushViewController:loginMainViewController animated:NO];
}

-(void)doTenLogin{
    _loginView.hidden = YES;
    
    isPushSocialView = YES;
    
    BOOL isOauth = [UMSocialAccountManager isOauthWithPlatform:UMShareToQQ];
    if (isOauth) {
        //TODO:有登录过，如何处理
        //return;
    }
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response)
                                  {
                                      //加载登录进度条
                                      _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                      _hud.mode = MBProgressHUDModeIndeterminate;
                                      _hud.alpha = 0.5;
                                      _hud.color = [UIColor grayColor];
                                      _hud.labelText = @"登录验证中...";
                                      
                                      if ([[snsPlatform platformName] isEqualToString:UMShareToQQ])
                                      {
                                          [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *accountResponse){
                                              if ([[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToQQ] == NULL) {
                                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                  return;
                                              }
                                              
                                              //封装数据
                                              NSMutableDictionary *dictBody = [[DataContract dataContract]UserCreateDict:RTYPE_TENCENT account:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToQQ] objectForKey:@"username"]  password:@""];
                                              //Http请求
                                              [[NetWorkConnect sharedRequest]
                                               httpRequestWithURL:USER_LOGIN_URL
                                               data:dictBody
                                               mode:@"POST"
                                               HUD:_hud
                                               didFinishBlock:^(NSDictionary *result){
                                                   _hud.labelText = [result objectForKey:@"msg"];
                                                   //处理反馈信息: code=1为成功  code=99为失败
                                                   if ([[result objectForKey:@"code"]intValue] == 1) {
                                                       NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToQQ] objectForKey:@"username"]  forKey:@"ACCOUNT_NAME"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RTYPE_TENCENT] forKey:@"ACCOUNT_TYPE"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"ACCOUNT_UID"];
                                                       [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
                                                       //数据库保存用户信息
                                                       if ([[UserDataDB dataBase] selectUser:[[resultBody objectForKey:@"userId"] intValue]] == nil){
                                                           [[UserDataDB dataBase] createNewUser:[[resultBody objectForKey:@"userId"]intValue] andCategoryIds:@"" andIcon:@"" andUserType:RTYPE_TENCENT andUserAccount:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToQQ] objectForKey:@"username"]   andAppVer:PROVERSION andCreateTime:[[resultBody objectForKey:@"createTime"] longValue] andUpdateTime:[[resultBody objectForKey:@"updateTime"] longValue]];
                                                       } 
                                                       //提示是否同步数据
                                                                                    [_hud hide:YES];
                                                       [self performSelector:@selector(isSyncData) withObject:nil afterDelay:0.8];
                                                   }
                                                   else{
                                                       [_hud hide:YES afterDelay:1.2];
                                                   }
                                               }
                                               didFailBlock:^(NSString *error){
                                                   //请求失败处理
                                                   _hud.labelText = http_error;
                                                   [_hud hide:YES afterDelay:1];
                                               }
                                               isShowProgress:YES
                                               isAsynchronic:YES
                                               netWorkStatus:YES
                                               viewController:self];
                                              
                                          }];
                                      }
                                  });
}

-(void)doSinaLogin{
    _loginView.hidden = YES;
    
    isPushSocialView = YES;
    BOOL isOauth = [UMSocialAccountManager isOauthWithPlatform:UMShareToSina];
    if (isOauth) {
        //TODO:有登录过，如何处理
        //return;
    }
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response)
                                  {
                                      //加载登录进度条
                                      _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                      _hud.mode = MBProgressHUDModeIndeterminate;
                                      _hud.alpha = 0.5;
                                      _hud.color = [UIColor grayColor];
                                      _hud.labelText = @"登录验证中...";
                                      
                                      if ([[snsPlatform platformName] isEqualToString:UMShareToSina])
                                      {
                                          [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *accountResponse){
                                              if ([[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] == NULL) {
                                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                  return;
                                              }
                                              //封装数据
                                              NSMutableDictionary *dictBody = [[DataContract dataContract]UserCreateDict:RTYPE_SINA account:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]  password:@""];
                                              //Http请求
                                              [[NetWorkConnect sharedRequest]
                                               httpRequestWithURL:USER_LOGIN_URL
                                               data:dictBody
                                               mode:@"POST"
                                               HUD:_hud
                                               didFinishBlock:^(NSDictionary *result){
                                                   _hud.labelText = [result objectForKey:@"msg"];
                                                   //处理反馈信息: code=1为成功  code=99为失败
                                                   if ([[result objectForKey:@"code"]intValue] == 1) {
                                                       NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]  forKey:@"ACCOUNT_NAME"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RTYPE_TENCENT] forKey:@"ACCOUNT_TYPE"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:[resultBody objectForKey:@"userId"] forKey:@"ACCOUNT_UID"];
                                                       [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"BABYID"];
                                                       //数据库保存用户信息
                                                       if ([[UserDataDB dataBase] selectUser:[[resultBody objectForKey:@"userId"] intValue]] == nil){
                                                           [[UserDataDB dataBase] createNewUser:[[resultBody objectForKey:@"userId"]intValue] andCategoryIds:@"" andIcon:@"" andUserType:RTYPE_SINA andUserAccount:[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]   andAppVer:PROVERSION andCreateTime:[[resultBody objectForKey:@"createTime"] longValue] andUpdateTime:[[resultBody objectForKey:@"updateTime"] longValue]];
                                                       }
                                                       //提示是否同步数据
                                                       [_hud hide:YES];
                                                       [self performSelector:@selector(isSyncData) withObject:nil afterDelay:0.8];
                                                   }
                                                   else{
                                                       [_hud hide:YES afterDelay:1.2];
                                                   }
                                               }
                                               didFailBlock:^(NSString *error){
                                                   //请求失败处理
                                                   _hud.labelText = http_error;
                                                   [_hud hide:YES afterDelay:1];
                                               }
                                               isShowProgress:YES
                                               isAsynchronic:YES
                                               netWorkStatus:YES
                                               viewController:self];
                                          }];
                                      }
                                  });

}

-(void)doRegister{
    _loginView.hidden = YES;
    
}

-(void)isSyncData{
    [self checkBaby];
    
    /*UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否同步该账户数据" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
     alertView.tag = 10109;
     [alertView show];
     */
}

#pragma 检测or创建宝贝
-(void)checkBaby{
    if (ACCOUNTUID) {
        if (!BABYID) {
            //注册接口
            _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //隐藏键盘
            _hud.mode = MBProgressHUDModeIndeterminate;
            _hud.alpha = 0.5;
            _hud.color = [UIColor grayColor];
            _hud.labelText = http_requesting;
            //封装数据
            NSMutableDictionary *dictBody = [[DataContract dataContract]BabyCreateByUserIdDict:ACCOUNTUID];
            //Http请求
            [[NetWorkConnect sharedRequest]
             httpRequestWithURL:BABY_CREATEBYUSERID_URL
             data:dictBody
             mode:@"POST"
             HUD:_hud
             didFinishBlock:^(NSDictionary *result){
                 _hud.labelText = [result objectForKey:@"msg"];
                 //处理反馈信息: code=1为成功  code=99为失败
                 if ([[result objectForKey:@"code"]intValue] == 1) {
                     NSMutableDictionary *resultBody = [result objectForKey:@"body"];
                     //保存Babyid
                     [[NSUserDefaults standardUserDefaults]setObject:[resultBody objectForKey:@"babyId"] forKey:@"BABYID"];
                     //数据库保存Baby信息
                     [BabyDataDB createNewBabyInfo:ACCOUNTUID BabyId:BABYID Nickname:@"" Birthday:nil Sex:nil HeadPhoto:@"" RelationShip:@"" RelationShipNickName:@"" Permission:nil CreateTime:[resultBody objectForKey:@"create_time"] UpdateTime:nil];
                     [_hud hide:YES afterDelay:0.5];
                     _loginView.hidden = YES;
                     [self viewWillAppear:NO];
                 }
                 else{
                     _hud.labelText = http_error;
                     [_hud hide:YES afterDelay:1];
                 }
             }
             didFailBlock:^(NSString *error){
                 //请求失败处理
                 _hud.labelText = http_error;
                 [_hud hide:YES afterDelay:1];
             }
             isShowProgress:YES
             isAsynchronic:NO
             netWorkStatus:YES
             viewController:self];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
